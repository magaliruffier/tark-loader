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
  return [
    # {
    #   -logic_name => 'get_databases',
    #   -module     => 'Bio::EnsEMBL::Hive::RunnableDB::JobFactory',
    #   -parameters => {
    #     'inputquery'   => q{SHOW DATABASES LIKE "}.$self->o('only_databases').q{"},
    #     'column_names' => [ 'dbname' ],
    #   },
    #   -input_ids => [
    #     { 'db_conn' => $self->o('source_server1') },
    #     { 'db_conn' => $self->o('source_server2') },
    #   ],
    #   -flow_into => {
    #     2 => { 'run_sql' => { 'db_conn' => '#db_conn##dbname#' },
    #     }
    #   },
    # },

    {
      -logic_name => 'load_tark',
      -module     => 'Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoader',
      -parameters => {
        tark_host => '#tark_host#',
        tark_port => '#tark_port#',
        tark_user => '#tark_user#',
        tark_pass => '#tark_pass#',
        tark_db => '#tark_db#',
      }
      -analysis_capacity  =>  4,  # use per-analysis limiter
      # -flow_into => {
      #   1 => [
      #     '?accu_name=at_count&accu_address=[]',
      #     '?accu_name=gc_count&accu_address=[]'
      #   ]
      # },
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