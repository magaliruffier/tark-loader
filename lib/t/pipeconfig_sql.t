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

use Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL;

use_ok('Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL');

my $sql_handle = Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL->new();
my $sql = $sql_handle->gene_grouping_template_SQL();
ok( $sql =~ m/#WHERE#/, 'gene_grouping_template_SQL' );

$sql = $sql_handle->gene_grouping();
ok( $sql !~ m/#WHERE#/, 'gene_grouping' );

$sql = $sql_handle->gene_grouping_exclusion( 2 );
ok( $sql !~ m/#WHERE#/, 'gene_grouping_exclusion' );

$sql = $sql_handle->gene_grouping_inclusion( 2 );
ok( $sql !~ m/#WHERE#/, 'gene_grouping_inclusion' );

done_testing();

1;
