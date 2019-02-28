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

my $test_utils = Bio::EnsEMBL::Tark::Test::Utils->new();

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
  },
);


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
    'gene_id_list' => '18271,18256,18262',

    'naming_consortium' => 'HGNC',
  },
);

my $result = $test_utils->check_db(
  $tark_dba, 'Gene', { stable_id => 'ENSG00000149600' }, 1
);
is( $result, 2, 'Loaded genes with HGNC names' );

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
    'gene_id_list' => '18271,18256,18262',

    'naming_consortium'     => 'HGNC',
    'add_consortium_prefix' => 1,
  },
);

$result = $test_utils->check_db(
  $tark_dba, 'Gene', { stable_id => 'ENSG00000149600' }, 1
);
is( $result, 3, 'Loaded genes with HGNC names' );

$result = $test_utils->check_db(
  $tark_dba, 'Gene', { hgnc_id => { -like => 'HGNC:HGNC:%' } }, 1
);
is( $result, 3, 'Loaded genes with HGNC names' );

# run_sql_on_db($test_url, 'DROP DATABASE');

done_testing();

1;
