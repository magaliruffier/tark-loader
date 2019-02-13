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

package Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL;

use strict;
use warnings;

use Moose;


=head2 gene_grouping
  Description : Query for getting lists of genes split into n batches. Genes are
               Randomly assigned to each group
=cut

sub gene_grouping {
  my ($self) = @_;

  my $sql = (<<'SQL');
    SELECT
      GROUP_CONCAT(gene_grp.gene_id SEPARATOR ',')
    FROM
      (
        SELECT gene_id, CEILING( RAND() * %d ) AS grp FROM gene
      ) gene_grp
    GROUP BY
      gene_grp.grp
SQL

  return $sql;
} ## end sub gene_grouping


=head2 gene_grouping_exclusion
  Description : Query for getting lists of genes split into n batches. Genes are
               Randomly assigned to each group
=cut

sub gene_grouping_exclusion {
  my ($self) = @_;

  my $sql = (<<'SQL');
    SELECT
      GROUP_CONCAT(gene_grp.gene_id SEPARATOR ',')
    FROM
      (
        SELECT gene_id, CEILING( RAND() * %d ) AS grp FROM gene WHERE source NOT IN ( %s )
      ) gene_grp
    GROUP BY
      gene_grp.grp
SQL

  return $sql;
} ## end sub gene_grouping_exclusion


=head2 gene_grouping_inclusion
  Description : Query for getting lists of genes split into n batches. Genes are
               Randomly assigned to each group
=cut

sub gene_grouping_inclusion {
  my ($self) = @_;

  my $sql = (<<'SQL');
    SELECT
      GROUP_CONCAT(gene_grp.gene_id SEPARATOR ',')
    FROM
      (
        SELECT gene_id, CEILING( RAND() * %d ) AS grp FROM gene WHERE source IN ( %s )
      ) gene_grp
    GROUP BY
      gene_grp.grp
SQL

  return $sql;
} ## end sub gene_grouping_inclusion

1;
