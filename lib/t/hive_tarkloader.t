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

use Cwd;
use Test::More;

use Data::Dumper;

use Bio::EnsEMBL::Tark::Test::TestDB;

use Bio::EnsEMBL::Hive::DBSQL::DBConnection;
use Bio::EnsEMBL::Hive::Utils::Test qw(standaloneJob get_test_url_or_die make_new_db_from_sqls run_sql_on_db);

# plan tests => 9;

# Need EHIVE_ROOT_DIR to be able to point at specific files
$ENV{'EHIVE_ROOT_DIR'} ||= File::Basename::dirname(
  File::Basename::dirname(
    File::Basename::dirname(
      Cwd::realpath( $0 )
    )
  )
);
my $input_job_factory = File::Basename::dirname( Cwd::realpath($0) ) . '/input_job_factory.sql';

standaloneJob(
  'Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoader',
  {
    'tark_host' => '',
    'tark_host' => '',
    'tark_host' => '',
    'tark_host' => '',
    'tark_db'   => '',
  },
  [
    [
      'DATAFLOW',
      [
        {
          _range_start => 10,
          _range_end   => 14,
          _range_count => 4,
          _range_list  => [10,11,12,14],
          _start_foo   => 10,
          _end_foo     => 14,
        },
        {
          _range_start => 15,
          _range_end   => 18,
          _range_count => 4,
          _range_list  => [15,16,17,18],
          _start_foo   => 15,
          _end_foo     => 18,
        },
        {
          _range_start => 19,
          _range_end   => 23,
          _range_count => 4,
          _range_list  => [19,21,22,23],
          _start_foo   => 19,
          _end_foo     => 23,
        },
        {
          _range_start => 24,
          _range_end   => 27,
          _range_count => 4,
          _range_list  => [24,25,26,27],
          _start_foo   => 24,
          _end_foo     => 27,
        },
        {
          _range_start => 28,
          _range_end   => 29,
          _range_count => 2,
          _range_list  => [28,29],
          _start_foo   => 28,
          _end_foo     => 29,
        },
      ],
      2
    ]
  ]
);


run_sql_on_db($test_url, 'DROP DATABASE');

done_testing();

chdir $original;
