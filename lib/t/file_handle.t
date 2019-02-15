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

use Bio::EnsEMBL::Tark::FileHandle;

use_ok 'Bio::EnsEMBL::Tark::FileHandle';


my $file_handle = Bio::EnsEMBL::Tark::FileHandle->new();
my $in_fh = $file_handle->get_file_handle( 'lib/t/hgnc.txt' );

my $first_line = <$in_fh>;
my @hgnc_line = split '\t', $first_line;

is( $hgnc_line[0], 'hgnc_id', 'file_handle' );

done_testing();

1;
