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

use Data::Dumper;

use Test::More;
use Test::Exception;
use Test::Warnings;
use Bio::EnsEMBL::Tark::Test::TestDB;
use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::TagConfig;
use Bio::EnsEMBL::Tark::Test::Utils;
use Bio::EnsEMBL::Tark::HGNC;

use Bio::EnsEMBL::Test::MultiTestDB;

use_ok 'Bio::EnsEMBL::Tark::HGNC';

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

my $db = Bio::EnsEMBL::Tark::Test::TestDB->new();

# start_session
my $session_id_start = $db->start_session( 'HGNC loader' );
ok( $session_id_start, "start_session - $session_id_start");


my $multi_db = Bio::EnsEMBL::Test::MultiTestDB->new;
my $dba = $multi_db->get_DBAdaptor('core');

my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new();
ok( !defined $tag_config->load_config_file( 'etc/release84.ini' ), 'load_config_file' );

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
  session    => $db,
  tag_config => $tag_config
);

my $test_utils = Bio::EnsEMBL::Tark::Test::Utils->new();

ok( !defined $loader->load_species( $dba, 'Ensembl' ), 'load_species' );
my $result_count_00 = $test_utils->check_db(
  $db, 'Gene', {}, 1
);
is( $result_count_00, 21, 'load_species' );

my $hgnc_loader = Bio::EnsEMBL::Tark::HGNC->new(
  session => $db
);


ok( !defined $hgnc_loader->flush_hgnc(), 'flush_hgnc' );

$hgnc_loader->load_hgnc( 'lib/t/hgnc.txt' );

done_testing();

1;
