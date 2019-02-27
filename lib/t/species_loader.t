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

use strict;
use warnings;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;

use Test::More;
use Test::Exception;
use Test::Warnings;
use Bio::EnsEMBL::Tark::Test::TestDB;
use Bio::EnsEMBL::Tark::Test::Utils;
use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::TagConfig;
use Bio::EnsEMBL::Tark::Utils;

use Bio::EnsEMBL::Test::MultiTestDB;

# Check that the modules loaded correctly
use_ok 'Bio::EnsEMBL::Tark::DB';

my $multi_db = Bio::EnsEMBL::Test::MultiTestDB->new;
my $dba = $multi_db->get_DBAdaptor('core');

my $db = Bio::EnsEMBL::Tark::Test::TestDB->new();

my $test_utils = Bio::EnsEMBL::Tark::Test::Utils->new();

ok($db, 'TestDB ready to go');

use_ok 'Bio::EnsEMBL::Tark::SpeciesLoader';

# start_session
my $session_id_start = $db->start_session();
ok( $session_id_start, "start_session - $session_id_start");

my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new();
ok( !defined $tag_config->load_config_file( 'etc/release84.ini' ), 'load_config_file' );

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
  session    => $db,
  tag_config => $tag_config
);

my $utils = Bio::EnsEMBL::Tark::Utils->new();

my $iter = $loader->genes_to_metadata_iterator( $dba, 'Ensembl' );
my $gene = $iter->next();
my $gene_test_id = $gene->{stable_id};
ok( defined $gene->{stable_id}, "genes_to_metadata_iterator: ${gene_test_id}");

$iter = $loader->genes_to_metadata_iterator( $dba, 'Ensembl', [ 18260..18264 ] );
my $iter_counter = 0;
while ( my $gene_iter = $iter->next() ) {
  ok(
    defined $gene_iter->{stable_id},
    'genes_to_metadata_iterator - ARRAY: ' . $gene_iter->{stable_id}
  );
  $iter_counter++;
}
is( $iter_counter, 5, "genes_to_metadata_iterator - Count ARRAY: $iter_counter");

my $loaded_checksum = $loader->_insert_sequence( 'acgt', $db->session_id );
my $result = $test_utils->check_db(
  $db, 'Sequence', { session_id => $db->session_id }
);

# There is no getter for the row in DBIx
# is(
#    $result->sequence, 'acgt',
#   '_insert_sequence'
# );
is(
  $result->seq_checksum, $utils->checksum_array( 'acgt' ),
  '_insert_sequence'
);
is(
  $result->session_id, $db->session_id,
  '_insert_sequence'
);

ok( !defined $loader->load_species( $dba, 'Ensembl' ), 'load_species' );
my $result_count_00 = $test_utils->check_db(
  $db, 'Gene', {}, 1
);
is( $result_count_00, 21, 'load_species' );

ok( !defined $loader->load_species( $dba, 'Ensembl' ), 'load_species' );
my $result_count_01 = $test_utils->check_db(
  $db, 'Gene', {}, 1
);
is( $result_count_01, $result_count_00, 'load_species - Check for duplicates' );

my $ga       = $dba->get_GeneAdaptor();
my $gene_ids = $ga->_list_dbIDs('gene');

$gene = $ga->fetch_by_dbID( $gene_ids->[ 0 ] );

$result = $test_utils->check_db(
  $db, 'Assembly', {}
);

# Initialize the tags we'll be using
  my $tag = Bio::EnsEMBL::Tark::Tag->new(
    config  => $tag_config,
    session => $db
  );
  $tag->init_tags( $result->assembly_id );

my $session_pkg = {
  session_id  => $db->session_id,
  genome_id   => $result->genome_id,
  assembly_id => $result->assembly_id
};

ok(
  !defined $loader->_load_gene($gene, $session_pkg, 'Ensembl', $tag),
  '_load_gene'
);

my @transcripts = @{ $gene->get_all_Transcripts() };

my @exon_checksums;
my @exon_ids;
for my $exon (@{ $transcripts[0]->get_all_Exons() }) {
  my ($exon_id, $exon_checksum) = $loader->_load_exon( $exon, $session_pkg, $tag );

  push @exon_checksums, $exon_checksum;
  push @exon_ids, $exon_id;

  ok( defined $exon_id, "_load_exon: $exon_id");
}

$session_pkg->{exon_set_checksum} =  $utils->checksum_array( @exon_checksums );
ok( defined $session_pkg->{exon_set_checksum}, "checksum_array" );

my $transcript_id = $loader->_load_transcript( $transcripts[0], $session_pkg, $tag );

ok( defined $transcript_id, "_load_transcript: $transcript_id");

$session_pkg->{transcript_id} = $transcript_id;
$session_pkg->{transcript} = $transcripts[0];

ok(
  !defined $loader->_load_translation( $transcripts[0]->translation(), $session_pkg, $tag ),
  '_load_translation'
);


$loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
  session    => $db,
  tag_config => $tag_config,
  naming_consortium => 'HGNC'
);
ok( !defined $loader->load_species( $dba, 'Ensembl' ), 'load_species' );
my $result_count_02 = $test_utils->check_db(
  $db, 'Gene', {}, 1
);
is(
  $result_count_02,
  $result_count_00 + 12,
  'load_species - Loading WITH naming consortium values (HGNC)'
);


done_testing();

1;
