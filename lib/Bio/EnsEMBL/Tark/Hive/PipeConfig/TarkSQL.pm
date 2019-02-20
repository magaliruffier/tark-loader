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

package Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkSQL;

use Moose;


=head1 _gene_grouping_template_SQL
  Description: Default SQL for the gene grouping queries. This is an internal
               function and should only be accessed through the gene_grouping,
               gene_grouping_exclusion and gene_grouping_inclusion that will
               handle the substitution of the WHERE clauses.
=cut

sub _feature_template_SQL {
  my ($self) = @_;

  my $sql = (<<'SQL');
    SELECT
      COUNT(*)
    FROM
      #FEATURE#
SQL

  return $sql;
} ## end sub _gene_grouping_template_SQL


=head2 gene_grouping
  Description: Query for getting lists of all genes split into n batches. Genes
               are randomly assigned to each group.
=cut

sub feature_count {
  my ( $self, $feature ) = @_;

  my $sql = $self->_feature_template_SQL();

  $sql =~ s/#FEATURE#/$feature/g;

  return $sql;
} ## end sub feature_count


=head1 _gene_grouping_template_SQL
  Description: Default SQL for the gene grouping queries. This is an internal
               function and should only be accessed through the gene_grouping,
               gene_grouping_exclusion and gene_grouping_inclusion that will
               handle the substitution of the WHERE clauses.
=cut

sub _feature_release_template_SQL {
  my ($self) = @_;

  my $sql = (<<'SQL');
    SELECT
      #FEATURE#_release_tag.release_id,
      COUNT(*)
    FROM
      #FEATURE#_release_tag
      JOIN release_set ON #FEATURE#_release_tag.release_id=release_set.release_id
    WHERE
      release_set.shortname = ?
    GROUP BY
      #FEATURE#_release_tag.release_id
SQL

  return $sql;
} ## end sub _gene_grouping_template_SQL


=head2 gene_grouping
  Description: Query for getting lists of all genes split into n batches. Genes
               are randomly assigned to each group.
=cut

sub feature_release_count {
  my ( $self, $feature ) = @_;

  my $sql = $self->_feature_release_template_SQL();

  $sql =~ s/#FEATURE#/$feature/g;

  return $sql;
} ## end sub feature_count

1;
