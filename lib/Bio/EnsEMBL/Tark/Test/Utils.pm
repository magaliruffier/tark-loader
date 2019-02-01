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

package Bio::EnsEMBL::Tark::Test::Utils;

use strict;
use warnings;
use Moose;


=head2 check_db
  Arg [1]    : $dba : Bio::EnsEMBL::Tark::DB
  Arg [2]    : $table : string
  Arg [3]    : $search_conditions : HashRef
  Arg [4]    : $count : integer [OPTIONAL]
  Description: Run a query for a given table and set of conditions. By default
               this returns the first row only. If the $count value is set to `1`
               this returns a count of the number of matching rows.
  Returntype : HashRef | integer
  Exceptions : none
  Caller     : general

=cut

sub check_db {
  my ( $self, $dba, $table, $search_conditions, $count ) = @_;

  my $result_set = $dba->schema->resultset( $table )->search( $search_conditions );
  if ( defined $count and $count == 1 ) {
    return $result_set->count;
  }
  return $result_set->next;
} ## end sub check_db

1;
