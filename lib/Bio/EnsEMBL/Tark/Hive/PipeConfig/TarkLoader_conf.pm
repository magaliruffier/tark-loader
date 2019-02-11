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

package Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkLoader_conf;

use strict;
use warnings;

# All Hive databases configuration files should inherit from HiveGeneric, directly
# or indirectly
use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');

# Allow this particular config to use conditional dataflow and INPUT_PLUS
use Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf;

use Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL;

use Bio::EnsEMBL::DBSQL::DBAdaptor;



=head2 default_options
    Description : Implements default_options() interface method of Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf that is used to initialize default options.
                  In addition to the standard things it defines four options:
                    o('concurrent_jobs')   defines how many tables can be worked on in parallel
=cut

sub default_options {
    my ($self) = @_;

    return {
        %{$self->SUPER::default_options(@_)},

        'core_db'  => {
          -host   => $self->o( 'core_host' ),
          -port   => $self->o( 'core_port' ),
          -user   => $self->o( 'core_user' ),
          -pass   => $self->o( 'core_pass' ),
          -dbname => $self->o( 'core_dbname' ),
          -driver => 'mysql',
        },
    };
}

=head2 pipeline_analyses
  Description : Implements pipeline_analyses() interface method of
                Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf that defines the
                structure of the pipeline: analyses, jobs, rules, etc.
                Here it defines three analyses:
                  * 'chunk_sequences' which uses the FastaFactory runnable to split
                     sequences in an input file into smaller chunks
                  * 'count_atgc' which takes a chunk produced by chunk_sequences,
                    and tallies the number of occurrences of each base in the
                    sequence(s) in the file
                  * 'calc_overall_percentage' which takes the base count subtotals
                    from all count_atgc jobs and calculates the overall %GC in the
                    sequence(s) in the original input file. The
                    'calc_overall_percentage' job is blocked by a semaphore until
                    all count_atgc jobs have completed.
=cut

sub pipeline_analyses {
  my ($self) = @_;

  my $sql_handle = Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL->new();

  my $sql = sprintf $sql_handle->gene_grouping(), $self->o('block_size');

  return [
    {
      -logic_name => 'generate_sql_params',
      -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
      -parameters => {
        'db_conn'      => $self->dbconn_2_url( 'core_db' ),
        'column_names' => [ 'gene_id_list' ],
        'inputquery'   => $sql,
        },
      -input_ids => [
        {
          'target_db'  => $self->dbconn_2_url( 'core_db' ),
        }
      ],
      -flow_into  => { 2 => { 'load_tark' => INPUT_PLUS() } },
    },

    {
      -logic_name => 'load_tark',
      -module     => 'Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoader',
      -parameters => {

        # Worker block size params
        tag_block        => $self->o( 'tag_block' ),
        tag_shortname    => $self->o( 'tag_shortname' ),
        tag_description  => $self->o( 'tag_description' ),
        tag_feature_type => $self->o( 'tag_feature_type' ),
        tag_version      => $self->o( 'tag_version' ),

        # Species name
        species     => $self->o( 'species' ),

        # Core db params
        host => $self->o( 'core_host' ),
        port => $self->o( 'core_port' ),
        user => $self->o( 'core_user' ),
        pass => $self->o( 'core_pass' ),
        db   => $self->o( 'core_dbname' ),

        # Tark db params
        tark_host => $self->o( 'tark_host' ),
        tark_port => $self->o( 'tark_port' ),
        tark_user => $self->o( 'tark_user' ),
        tark_pass => $self->o( 'tark_pass' ),
        tark_db   => $self->o( 'tark_db' ),

      },
    },

    # {
    #   -logic_name => 'load_hgnc',
    #   -module     => 'Bio::EnsEMBL::Tark::HiveRunnableDB::HGNCLoader',
    #   -flow_into => {
    #     1 => [
    #       '?table_name=final_result' #Flows output into the DB table 'final_result'
    #     ]
    #   },
    # },
  ];
}

1;