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

use Cwd;
use Test::More;

use Bio::EnsEMBL::Tark::Test::TestDB;
use Bio::EnsEMBL::Tark::Test::Utils;
use Bio::EnsEMBL::Test::MultiTestDB;

use Bio::EnsEMBL::Hive::Utils::Test qw(standaloneJob get_test_url_or_die make_new_db_from_sqls run_sql_on_db);


# Need EHIVE_ROOT_DIR to be able to point at specific files
$ENV{'EHIVE_ROOT_DIR'} ||= File::Basename::dirname(
  File::Basename::dirname(
    File::Basename::dirname(
      Cwd::realpath( $0 )
    )
  )
);

my $multi_db = Bio::EnsEMBL::Test::MultiTestDB->new;
my $core_dba = $multi_db->get_DBAdaptor('core');

my $tark_dba = Bio::EnsEMBL::Tark::Test::TestDB->new();
$tark_dba->schema();


standaloneJob(
  'Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoader',
  {
    'species'   => 'homo_sapiens',
    'host' => $core_dba->dbc->host,
    'port' => $core_dba->dbc->port,
    'user' => $core_dba->dbc->user,
    'pass' => $core_dba->dbc->pass,
    'db'   => $core_dba->dbc->dbname,

    'tark_host' => $tark_dba->config->{host},
    'tark_port' => $tark_dba->config->{port},
    'tark_user' => $tark_dba->config->{user},
    'tark_pass' => $tark_dba->config->{pass},
    'tark_db'   => $tark_dba->config->{db},

    'tag_block'        => 'release',
    'tag_shortname'    => 84,
    'tag_description'  => 'Ensembl release 84',
    'tag_feature_type' => 'all',

    'block_size'   => 10,
    'gene_id_list' => '18258,18264',

    'source_name'       => 'Ensembl',
    'naming_consortium' => 'HGNC',
  },
);


# start_session
my $session_id_start = $tark_dba->start_session();
ok( $session_id_start, "start_session - $session_id_start");

my $test_utils = Bio::EnsEMBL::Tark::Test::Utils->new();

my $result_transcript_01 = $test_utils->check_db(
  $tark_dba, 'Transcript', { stable_id => 'ENST00000202017' }
);
my $t1_id = $tark_dba->schema->resultset( 'Transcript' )->create( {
  stable_id           => 'NM_030815',
  stable_id_version   => $result_transcript_01->stable_id_version,
  assembly_id         => $result_transcript_01->assembly_id,
  loc_start           => $result_transcript_01->loc_start,
  loc_end             => $result_transcript_01->loc_end,
  loc_strand          => $result_transcript_01->loc_strand,
  loc_region          => $result_transcript_01->loc_region,
  loc_checksum        => undef,
  exon_set_checksum   => undef,
  transcript_checksum => undef,
  seq_checksum        => $result_transcript_01->seq_checksum,
  session_id          => $session_id_start,
} );

my $result_transcript_02 = $test_utils->check_db(
  $tark_dba, 'Transcript', { stable_id => 'ENST00000246229' }
);
my $t2_id = $tark_dba->schema->resultset( 'Transcript' )->create( {
  stable_id           => 'NM_002657',
  stable_id_version   => $result_transcript_02->stable_id_version,
  assembly_id         => $result_transcript_02->assembly_id,
  loc_start           => $result_transcript_02->loc_start,
  loc_end             => $result_transcript_02->loc_end,
  loc_strand          => $result_transcript_02->loc_strand,
  loc_region          => $result_transcript_02->loc_region,
  loc_checksum        => undef,
  exon_set_checksum   => undef,
  transcript_checksum => undef,
  seq_checksum        => $result_transcript_02->seq_checksum,
  session_id          => $session_id_start,
} );

my $rs_id = $tark_dba->schema->resultset( 'ReleaseSet' )->create( {
  shortname   => 92,
  description => 'RefSeq',
  assembly_id => 1,
  source_id   => 2,
  session_id  => $session_id_start,
} );

$tark_dba->schema->resultset( 'TranscriptReleaseTag' )->create( {
  feature_id => $t1_id->transcript_id,
  release_id => $rs_id->release_id,
  session_id => $session_id_start,
} );

$tark_dba->schema->resultset( 'TranscriptReleaseTag' )->create( {
  feature_id => $t2_id->transcript_id,
  release_id => $rs_id->release_id,
  session_id => $session_id_start,
} );

$tark_dba->end_session();


standaloneJob(
  'Bio::EnsEMBL::Tark::Hive::RunnableDB::MANERelationships',
  {
    'species'   => 'homo_sapiens',
    'host' => $core_dba->dbc->host,
    'port' => $core_dba->dbc->port,
    'user' => $core_dba->dbc->user,
    'pass' => $core_dba->dbc->pass,
    'db'   => $core_dba->dbc->dbname,

    'tark_host' => $tark_dba->config->{host},
    'tark_port' => $tark_dba->config->{port},
    'tark_user' => $tark_dba->config->{user},
    'tark_pass' => $tark_dba->config->{pass},
    'tark_db'   => $tark_dba->config->{db},

    'object_shortname'  => 84,
    'object_source'     => 'Ensembl',

    'subject_shortname' => 92,
    'subject_source'    => 'RefSeq',
  },
);

my $result = $test_utils->check_db(
  $tark_dba, 'TranscriptReleaseTagRelationship', {}, 1
);

is( $result, 2, 'Loaded MANE relationships' );

# run_sql_on_db($test_url, 'DROP DATABASE');

done_testing();

1;
