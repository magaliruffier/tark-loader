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

# use Bio::EnsEMBL::Test::MultiTestDB;

# Check that the modules loaded correctly
use_ok 'Bio::EnsEMBL::Tark::DB';

# my $multi_db = Bio::EnsEMBL::Test::MultiTestDB->new;
# my $dba = $multi_db->get_DBAdaptor('core');

my $db = Bio::EnsEMBL::Tark::Test::TestDB->new();

ok($db, 'TestDB ready to go');

use_ok 'Bio::EnsEMBL::Tark::SpeciesLoader';

done_testing();

1;
