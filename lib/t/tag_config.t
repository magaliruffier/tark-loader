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
use Bio::EnsEMBL::Tark::TagConfig;


my $tag = Bio::EnsEMBL::Tark::TagConfig->new();
ok( !defined $tag->load_config_file( 'etc/release84.ini' ), 'load_config_file' );

foreach my $block ( @{ $tag->blocks } ) {
  ok( $block eq 'release' || $block eq 'CARS', "Block: $block" );
}

$tag->set_id( 'release', 2 );
is( $tag->config->{'release'}->{'id'}, 2, 'set_id' );

done_testing();

1;
