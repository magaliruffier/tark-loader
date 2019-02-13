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


=head NAME

  Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkLoader_conf


=head1 DESCRIPTION

  Runnable for the loading of the Tark db from a Core db.


=head1 DESCRIPTION

  A pipeline for loading ensembl genomic features into the Tark DB. Requires
  connection parameters for the Tark and Core dbs, as well was matching tags to
  describe the entries.

  This process can be run over a whole core db or by passing a list of gene_ids
  in a comma separated string, thus allowing multiple instances to handle the
  loading of the Tark db.

=cut


package Bio::EnsEMBL::Tark::Hive::RunnableDB::GeneSetSQL;

use strict;
use warnings;
use Carp;

use base ('Bio::EnsEMBL::Hive::Process');

use Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL;
use Bio::EnsEMBL::Tark::Utils;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);


=head2 run
  Description : Implements run() interface method of Bio::EnsEMBL::Hive::Process
                that is used to perform the main bulk of the job (minus input and
                output).
  param
    column_names : Controls the column names that come out of the parser:
=cut

sub run {
  my ( $self ) = @_;

  my $sql_handle = Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL->new();

  my $sql = q{};

  if ( defined $self->param_is_defined('exclude_source') ) {
    my @source_list = split /,/, $self->param('exclude_source');
    $sql = sprintf $sql_handle->gene_grouping_exclusion(),
      $self->param('block_size'), scalar @source_list;
  }
  elsif ( defined $self->param_is_defined('include_source') ) {
    my @source_list = split /,/, $self->param('include_source');
    $sql = sprintf $sql_handle->gene_grouping_inclusion(),
      $self->param('block_size'), scalar @source_list;
  }
  else {
    $sql = sprintf $sql_handle->gene_grouping(), $self->o('block_size');
  }

  $self->param('sql', $sql);

  return;
}


=head2 write_output
  Description : Implements write_output() interface method of
                Bio::EnsEMBL::Hive::Process to write the SQL out to the param
                for the next job.
=cut

sub write_output {  # but this time we have something to store
  my $self = shift @_;

  $self->dataflow_output_id(
    {
      'sql' => $self->param('sql'),
    }, 2
  );
}

1;
