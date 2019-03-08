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

package Bio::EnsEMBL::Tark::MANE;

use Moose;
with 'MooseX::Log::Log4perl';

use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::FileHandle;

use Try::Tiny;
use Data::Dumper;

has 'query' => (
  traits  => ['Hash'],
  is      => 'rw',
  isa     => 'HashRef',
  default => sub { {} },
  handles => {
    set_query     => 'set',
    get_query     => 'get',
    delete_query  => 'delete',
    clear_queries => 'clear',
    fetch_keys    => 'keys',
    fetch_values  =>'values',
    query_pairs   => 'kv',
  },
);

has session => (
  is  => 'rw',
  isa => 'Bio::EnsEMBL::Tark::DB',
);

has object_config => (
  is  => 'ro',
  isa => 'HashRef',
);

has subject_config => (
  is  => 'ro',
  isa => 'HashRef',
);

has relationship_config => (
  is  => 'ro',
  isa => 'HashRef',
);


=head2 BUILD
  Description: Initialise the creation of the object
  Returntype : undef
  Exceptions : none
  Caller     : general

=cut

sub BUILD {
  my ($self) = @_;

  $self->log()->info('Initializing MANE loader');

  # Attempt a connection to the database
  my $dbh = $self->session->dbh();

  # Setup the insert queries
  my $insert_relationship_type_select_sql = (<<'SQL');
    INSERT INTO relationship_type (shortname, description, version, release_date)
    VALUES ('MANE SELECT', 'Matched Annotation by NCBI and EMBL-EBI (MANE)', ?, ?)
SQL

  my $sth = $dbh->prepare( $insert_relationship_type_select_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('insert_relationship_type_select' => $sth);


  my $insert_relationship_type_plus_sql = (<<'SQL');
    INSERT INTO relationship_type (shortname, description, version, release_date)
    VALUES ('MANE PLUS', 'Matched Annotation by NCBI and EMBL-EBI (MANE)', ?, ?)
SQL

  $sth = $dbh->prepare( $insert_relationship_type_plus_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('insert_relationship_type_plus' => $sth);


  my $insert_transcript_relationship_sql = (<<'SQL');
    INSERT INTO transcript_release_tag_relationship (
      transcript_release_object_id, transcript_release_subject_id, relationship_type_id)
    VALUES (?, ?, ?)
SQL

  $sth = $dbh->prepare( $insert_transcript_relationship_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('insert_transcript_relationship_sql' => $sth);


  my $select_transcript_release_tag_id_sql = (<<'SQL');
    SELECT
      transcript_release_tag.transcript_release_id
    FROM
      transcript
      JOIN transcript_release_tag ON transcript.transcript_id=transcript_release_tag.feature_id
      JOIN release_set ON transcript_release_tag.release_id=release_set.release_id
      JOIN release_source ON release_set.source_id=release_source.source_id
    WHERE
      transcript.stable_id=? AND
      release_set.shortname=? AND
      release_source.shortname=?
SQL

  $sth = $dbh->prepare( $select_transcript_release_tag_id_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('select_transcript_release_tag_id_sql' => $sth);

  return;
} ## end sub BUILD


=head2 load_man
  Description: Extract MANE mappings from teh ensembl core
  Returntype : undef
  Exceptions : none
  Caller     : general
  Notes      : Col 1: hgnc_id
               Col 2: symbol/name
               Col 9: alias_symbols
               Col 20: ensembl_gene_id
              (counting from 1)

=cut

sub load_mane {
  my ( $self, $dba ) = @_;

  $self->log()->info('Starting MANE load');

  my %mane_config = %{ $self->relationship_config };
  my $insert_mane_select = $self->get_query('insert_relationship_type_select');
  my $insert_mane_plus = $self->get_query('insert_relationship_type_plus');

  my $mane_select_id = $insert_mane_select->execute(
    $mane_config{'select'}{'version'}, $mane_config{'select'}{'release_date'}
  );
  my $mane_plus_id = $insert_mane_plus->execute(
    $mane_config{'plus'}{'version'}, $mane_config{'plus'}{'release_date'}
  );

  # Fetch a gene iterator and cycle through loading the genes
  my $iter = $self->genes_to_metadata_iterator( $dba );

  while ( my $gene = $iter->next() ) {
    $self->log->debug( 'Loading gene ' . $gene->{stable_id} );
    $self->_load_relationship(
      $gene,
      {
        mane_select_id => $mane_select_id,
        mane_plus_id   => $mane_plus_id
      }
    );
  }

  return;
} ## end sub load_mane


sub _load_relationship{
  my ( $self, $gene, $relationship_types ) = @_;

  my $insert_mane = $self->get_query('insert_transcript_relationship_sql');
  my $get_transcript_object_id = $self->get_query('select_transcript_release_tag_id_sql');
  my $get_transcript_subject_id = $self->get_query('select_transcript_release_tag_id_sql');
  my %object_config  = %{ $self->object_config };
  my %subject_config = %{ $self->subject_config };

  for my $transcript ( @{ $gene->get_all_Transcripts() } ) {
    $self->log->debug( 'Loading transcript ' . $transcript->{stable_id} );

    # Iterate through the transcript_attribs
    # my @mane_select = @{ $transcript->get_all_Attributes( 'MANE_Select' ) };
    # print Dumper $transcript->get_all_Attributes();
    my @mane_transcripts = @{ $transcript->get_all_Attributes( 'MANE_Select' ) };
    if ( @mane_transcripts ) {
      $get_transcript_object_id->execute(
        $transcript->{stable_id},
        $object_config{shortname},
        $object_config{source}
      );
      my @transcript_object_id = @{ $get_transcript_object_id->fetchrow_arrayref };

      for my $mane ( @mane_transcripts ) {
        $get_transcript_subject_id->execute(
          $mane->{value},
          $subject_config{shortname},
          $subject_config{source}
        );
        my @transcript_subject_id = @{ $get_transcript_subject_id->fetchrow_arrayref };

        if ( $mane->{code} eq 'MANE_Select' ) {
          $insert_mane->execute(
            $transcript_object_id[0],
            $transcript_subject_id[0],
            $relationship_types->{mane_select_id}
          );
        } elsif ( $mane->{code} eq 'MANE_Plus' ) {
          $insert_mane->execute(
            $transcript_object_id[0],
            $transcript_subject_id[0],
            $relationship_types->{mane_plus_id}
          );
        }
      }
    }
  }
}


=head2 genes_to_metadata_iterator
  Description: This is the place where you should try to get the gene iterator properly
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub genes_to_metadata_iterator {
  my ( $self, $dba, $gene_ids ) = @_;
  my $ga = $dba->get_GeneAdaptor();

  if ( !defined $gene_ids ) {
    $gene_ids = $ga->_list_dbIDs('gene');
  }

  my $len          = scalar @{ $gene_ids };
  my $current_gene = 0;
  my $genes_i      = Bio::EnsEMBL::Utils::Iterator->new(
    sub {
      if ( $current_gene >= $len ) {
        return;
      }
      else {
        my $gene = $ga->fetch_by_dbID( $gene_ids->[ $current_gene++ ] );
        return $gene;
      }
    }
  );
  return $genes_i;
} ## end sub genes_to_metadata_iterator

1;
