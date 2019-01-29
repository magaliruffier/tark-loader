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
use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::TagConfig;
use Bio::EnsEMBL::Tark::Utils;

use Bio::EnsEMBL::Test::MultiTestDB;

# Check that the modules loaded correctly
use_ok 'Bio::EnsEMBL::Tark::DB';

my $multi_db = Bio::EnsEMBL::Test::MultiTestDB->new;
my $dba = $multi_db->get_DBAdaptor('core');

my $db = Bio::EnsEMBL::Tark::Test::TestDB->new();

ok($db, 'TestDB ready to go');

use_ok 'Bio::EnsEMBL::Tark::SpeciesLoader';

# start_session
my $session_id_start = $db->start_session();
ok( $session_id_start, "start_session - $session_id_start");

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
  session => $db
);

my $utils = Bio::EnsEMBL::Tark::Utils->new();

my $tag = Bio::EnsEMBL::Tark::TagConfig->new();
ok( !defined $tag->load_config_file( 'etc/release84.ini' ), 'load_config_file' );

my $loaded_checksum = $loader->_insert_sequence( 'acgt', $db->session_id );
my $result =  _check_db(
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
my $result_count_00 =  _check_db(
  $db, 'Gene', {}, 1
);
is( $result_count_00, 21, 'load_species' );

ok( !defined $loader->load_species( $dba, 'Ensembl' ), 'load_species' );
my $result_count_01 =  _check_db(
  $db, 'Gene', {}, 1
);
is( $result_count_01, $result_count_00, 'load_species - Check for duplicates' );

done_testing();

sub _check_db {
  my ( $check_db_dba, $table, $search_conditions, $count ) = @_;

  my $result_set = $check_db_dba->schema->resultset( $table )->search( $search_conditions );
  if ( defined $count and $count == 1 ) {
    return $result_set->count;
  }
  return $result_set->next;
}

1;
