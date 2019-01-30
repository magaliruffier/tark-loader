=head1 LICENSE

See the NOTICE file distributed with this work for additional information
   regarding copyright ownership.
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

=cut

=head1 Bio::EnsEMBL::Tark::Tag

Have removed the initialize() function so that this can be done by the code in a
lazy fashion using Moose for the building.

What was:
  Bio::EnsEMBL::Tark::Tag->initialize(config_file => $config_file);

Should now be:

  my $cfg = Config::Simple->new( filename=>$self->config_file );
  Bio::EnsEMBL::Tark::Tag->new(
    config  => $cfg,
    session => $session
  );

The block creation is then done the first time that the blocks() are required
rather than getting built at the beginning.

=cut


package Bio::EnsEMBL::Tark::Tag;

use warnings;
use strict;
use DBI;
use Config::Simple;

use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::Utils;

use Moose;
with 'MooseX::Log::Log4perl';

use Data::Dumper;

has session => (
  is => 'rw',
  isa => 'Bio::EnsEMBL::Tark::DB',
);

has 'config' => ( is => 'ro', isa => 'Bio::EnsEMBL::Tark::TagConfig' );

has 'assembly_id' => ( is => 'rw', isa => 'Int' );

# removed  'operon' => 5,
has 'feature_type' => (
  traits    => ['Hash'],
  is        => 'ro',
  isa       => 'HashRef[Str]',
  default   => sub { {
    'gene'        => 1,
    'transcript'  => 2,
    'exon'        => 3,
    'translation' => 4
  } },
  handles   => {
    get_type      => 'get',
    get_types     => 'keys',
    feature_pairs => 'kv',
  },
);

has 'inserts' => (
  traits  => ['Hash'],
  is      => 'rw',
  isa     => 'HashRef',
  default => sub { {} },
  handles => {
    set_insert     => 'set',
    get_insert     => 'get',
    delete_insert  => 'delete',
    clear_inserts  => 'clear',
    fetch_keys     => 'keys',
    fetch_values   =>'values',
    insert_pairs   => 'kv',
  },
);


=head2 init_tags
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub init_tags {
  my ($self, $assembly_id) = @_;

  $self->assembly_id($assembly_id);

  foreach my $block (@{$self->config->blocks()}) {
    $self->fetch_tag($block);
  }
} ## end sub init_tags


=head2 tag_feature
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub tag_feature {
  my ($self, $feature_id, $feature_type) = @_;
  foreach my $tag (@{$self->config->blocks()}) {
    if ( $feature_type ne 'transcript' && $tag ne 'release' ) {
      next;
    }

    my $feature_tag = 'transcript_tag';
    if ( $tag eq 'release' ) {
      $feature_tag = $feature_type . '_' . $tag;
    }
    my $sth = $self->get_insert($feature_tag);

    my @vals = ( $feature_id );
    $sth->execute(@vals);
  }

  return;
} ## end sub tag_feature


=head2 checksum_sets
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub checksum_sets {
  my $self = shift;

  $self->log->info('Checksumming tagging sets');

  foreach my $tag (@{$self->config->blocks()}) {
    print "Checksumming tag set $tag\n";
    $self->log("Checksumming tag set $tag");
    my $tagset_id = $self->config->config->{$tag}->{'id'};

    if ( !defined $tagset_id ) {
      $self->log->warn( "No tagset id for $tag" );
      next;
    }

    my $tagset_checksum = $self->checksum_set($tagset_id, $tag);
    $self->log( "Checksum for tag set $tag is " . unpack( "H*", $tagset_checksum) );

    $self->write_checksum($tagset_id, $tagset_checksum, $tag);
  }
} ## end sub checksum_sets


=head2 write_checksum
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub write_checksum {
  my $self = shift;
  my $tagset_id = shift;
  my $checksum = shift;
  my $set_type = ( @_ ? shift : 'tag' );

  # my $dbh = Bio::EnsEMBL::Tark::DB->dbh();
  my $dbh = $self->session->dbh();

  my $table        = 'tagset';
  my $checksum_col = 'tagset_checksum';
  my $key_col      = 'tagset_id';

  if ( $set_type eq 'release' ) {
    $table        = 'release_set';
    $checksum_col = 'release_checksum';
    $key_col      = 'release_id';
  }

  $dbh->do(
    "UPDATE $table SET $checksum_col = ? WHERE $key_col = ?",
    undef, $checksum, $tagset_id
  );

} ## end sub write_checksum


=head2 checksum_set
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub checksum_set {
  my ($self, $tagset_id, $set_type) = @_;
  my @cumulative_checksums;

  # Make the checksums in order found in the enum lookup of feature names
  foreach my $feature_type ( sort { $a->[1] <=> $b->[1] } $self->feature_pairs() ) {

    # We only to transcript for tags sets
    if ( $feature_type->[0] ne 'transcript' && $set_type ne 'release' ) {
      next;
    }

    $self->log->info(
      "Computing checksum for tagset type $set_type, id $tagset_id, feature type ". $feature_type->[0]
    );

    my $feature_checksum = $self->checksum_feature_set(
      $tagset_id, $feature_type->[0], $set_type
    );

    # Skip to the next feature type is no checksum was returned
    if ( !defined $feature_checksum ) {
      next;
    }

    $self->log->info( 'Found checksum of ' . unpack("H*", $feature_checksum) );

    # Now push it on to the features cumulative checksums
    push @cumulative_checksums, $feature_checksum;
  }

  # Find the final cumulative checksum
  my $utils = Bio::EnsEMBL::Tark::Utils->new();
  my $tag_checksum = ($#cumulative_checksums > 1 ? $utils->checksum_array(@cumulative_checksums) : shift @cumulative_checksums);

  return $tag_checksum;
} ## end sub checksum_set


=head2 checksum_feature_set
  Description: Optional $set_type can be 'release' or 'tag' (anything non-'release'
               is considered 'tag')
               $feature_type is the word, 'gene', 'transcript',...
  Returntype : string
  Exceptions : none
  Caller     : general

=cut

sub checksum_feature_set {
  my $self = shift;
  my $tagset_id = shift;
  my $feature_type = shift;
  my $set_type = ( @_ ? shift : 'tag' );

  # my $dbh = Bio::EnsEMBL::Tark::DB->dbh();
  my $dbh = $self->session->dbh();

  my $tagset_table = 'tag';
  my $tagset_col = 'tagset_id';
  my $tagset_join_col = 'transcript_id';

  if($set_type eq 'release') {
    $tagset_table = $feature_type.'_release_tag';
    $tagset_col = 'release_id';
    $tagset_join_col = 'feature_id';
  } else {
    # Don't let users do stupid things
    $feature_type = 'transcript';
  }

  my $key_col = "${feature_type}_id";
  my $checksum_col = "${feature_type}_checksum";

  my $stmt = (<<"SQL");
    SELECT
      $feature_type.$checksum_col
    FROM
      $feature_type, $tagset_table
    WHERE
          $tagset_table.$tagset_join_col = $feature_type.$key_col
      AND $tagset_table.$tagset_col = ?
    ORDER BY
      $feature_type.$key_col
SQL

  my $sth = $dbh->prepare($stmt);
  $sth->execute(
    $tagset_id
  );

  # Don't do a checksum if no rows for that type
  if ( !$sth->rows ) {
    return;
  }

  # Now we loop through and create a checksum of the checksums
  my @feature_checksums;

  while(my ($checksum) = $sth->fetchrow_array) {
    push @feature_checksums, $checksum;
  }

  # Find and send back the checksum of the checksums
  my $utils = Bio::EnsEMBL::Tark::Utils->new();
  return $utils->checksum_array(
    @feature_checksums
  );
} ## end sub checksum_feature_set


=head2 fetch_tag
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub fetch_tag {
  my ($self, $tag) = @_;

  my $shortname = $self->config->config->{ 'release' }->{ 'shortname' };
  my $desc      = $self->config->config->{ 'release' }->{ 'description' };
  my $source_id = 1;
  if ( defined $self->config->config->{ 'release' }->{ 'source' } ) {
    $source_id = $self->config->config->{ 'release' }->{ 'source' };
  }

  print "From fetch_tag shortname $shortname desc $desc source_id $source_id\n";

  my $dbh = $self->session->dbh();
  my $session_id = $self->session->session_id;

  my $insert_tagset_sql = (<<'SQL');
    INSERT INTO tagset (
      shortname, description, session_id
    ) VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE tagset_id=LAST_INSERT_ID(tagset_id)
SQL

  my $insert_release_sql = (<<'SQL');
    INSERT INTO release_set (
      shortname, description, assembly_id, release_date, session_id, source_id
    ) VALUES (?, ?, ?, NOW(), ?, ?)
    ON DUPLICATE KEY UPDATE release_id=LAST_INSERT_ID(release_id)
SQL

  my ( $sth, $tag_id );
  if ( $tag eq 'release' ) {
    $sth = $dbh->prepare( $insert_release_sql );

    # Create or find the release
    $sth->execute($shortname, $desc, $self->assembly_id(), $session_id, $source_id);
    $tag_id = $sth->{mysql_insertid};
  }
  else {
    $sth = $dbh->prepare( $insert_tagset_sql );

    # Create or find the release
    $sth->execute($shortname, $desc, $session_id);
    $tag_id = $sth->{mysql_insertid};
  }
  print "\nRelease id :   $tag_id\n";

  # Save the release_id for later
  $self->config->set_id( $tag, $tag_id );

  # Create the insert statement for later
  # Do it for all feature_type
  if ( $tag eq 'release' ) {
    foreach my $feature_type ( qw / gene transcript translation exon / ) {
      my $feature_tag = $feature_type.'_'.$tag;

      my $insert_table = $feature_type . '_release_tag';
      my $sql = (<<"SQL");
        INSERT IGNORE INTO $insert_table (feature_id, release_id, session_id)
        VALUES (?, $tag_id, $session_id)
SQL

      $sth = $dbh->prepare( $sql );
      print $sth->{Statement};
      print "Setting insert for $feature_tag \n";
      $self->set_insert($feature_tag => $sth);
    }
  } else {
    my $sql = (<<"SQL");
      INSERT IGNORE INTO tag (transcript_id, tagset_id, session_id)
      VALUES (?, $tag_id, $session_id)
SQL

    $sth = $dbh->prepare( $sql );
    print $sth->{Statement};
    print "Setting insert for transcript_tag (tag) \n";
    $self->set_insert( transcript_tag => $sth );
  }
  #exit 0;
} ## end sub fetch_tag

1;
