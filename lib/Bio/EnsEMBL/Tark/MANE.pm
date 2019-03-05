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
    VALUES ('MANE select', 'Matched Annotation by NCBI and EMBL-EBI (MANE)', ?, ?)
SQL

  my $sth = $dbh->prepare( $insert_relationship_type_select_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('insert_relationship_type_select' => $sth);


  my $insert_relationship_type_plus_sql = (<<'SQL');
    INSERT INTO relationship_type (shortname, description, version, release_date)
    VALUES ('MANE plus', 'Matched Annotation by NCBI and EMBL-EBI (MANE)', ?, ?)
SQL

  $sth = $dbh->prepare( $insert_relationship_type_plus_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('insert_relationship_type_plus' => $sth);


  my $insert_transcript_relationship_sql = (<<'SQL');
    INSERT INTO transcript_release_tag_relationship (
      transcript_release_object_id, transcript_release_subject_id, relationship_type_id)
    VALUES ('', '', ?, ?)
SQL

  $sth = $dbh->prepare( $insert_transcript_relationship_sql ) or
    $self->log->logdie("Error creating relationship_type insert: " . $DBI::errstr);
  $self->set_query('insert_transcript_relationship_sql' => $sth);


  my $select_transcript_release_tag_id_sql = (<<'SQL');
    SELECT
      transcript_release_tag.transcript_release_tag_id
    FROM
      transcript
      JOIN transcript_release_tag ON transcript.transcript_id=transcript_release_tag.feature_id
      JOIN release_set ON transcript_release_tag.release_id=release_set.release_id
      JOIN release_source ON release_set.source_id=release_source.source_id
    WHERE
      transcript.stable_id=? AND
      release_set.shortname=? AND
      release_source=?
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

  my $get_transcript_release_id = $self->get_query('select_transcript_release_tag_id_sql');
  my $insert_mane = $self->get_query('insert_transcript_relationship_sql');

  # Fetch a gene iterator and cycle through loading the genes
  my $iter = $self->genes_to_metadata_iterator( $dba );

  while ( my $gene = $iter->next() ) {
    $self->log->debug( 'Loading gene ' . $gene->{stable_id} );
    $self->_load_relationship( $gene );
  }

  return;
} ## end sub load_mane


sub _load_relationship{
  my ( $self, $gene, $session_pkg ) = @_;

  for my $transcript ( @{ $gene->get_all_Transcripts() } ) {
    $self->log->debug( 'Loading transcript ' . $transcript->{stable_id} );
    # Iterate through the transcript_attribs
    # my @mane_select = @{ $transcript->get_all_Attributes( 'MANE_Select' ) };
    # print Dumper $transcript->get_all_Attributes();
    for my $mane ( @{ $transcript->get_all_Attributes( 'MANE_Select' ) } ) {
      print Dumper $mane;
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
