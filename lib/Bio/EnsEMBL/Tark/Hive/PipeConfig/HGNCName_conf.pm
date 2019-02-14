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

=head1 DESCRIPTION

  A pipeline for the loading of the HGNC gene names into a Tark DB.

=head1 SYNOPSIS

  # Prepare the pipeline
  init_pipeline.pl Bio::EnsEMBL::Tark::Hive::PipeConfig::HGNCName_conf
    --tark_host $TARK_HOST
    --tark_port $TARK_PORT
    --tark_user $TARK_USER
    --tark_pass $TARK_PASS
    --tark_db $TARK_SPP_DB
    --host $HIVE_HOST
    --port $HIVE_PORT
    --user $HIVE_USER
    --password $HIVE_PASS
    --pipeline_name test_hive_1234
    --hgnc_file $HGNC_NAME_FILE

=cut

package Bio::EnsEMBL::Tark::Hive::PipeConfig::HGNCName_conf;

use strict;
use warnings;

# All Hive databases configuration files should inherit from HiveGeneric, directly
# or indirectly
use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');

# Allow this particular config to use conditional dataflow and INPUT_PLUS
use Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf;


=head2 default_options
    Description : Implements default_options() interface method of Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf that is used to initialize default options.
                  In addition to the standard things it defines four options:
                    o('concurrent_jobs')   defines how many tables can be worked on in parallel
=cut

sub default_options {
    my ($self) = @_;

    return {
        %{$self->SUPER::default_options(@_)},
    };
} ## end sub default_options


=head2 pipeline_analyses
  Description : Implements pipeline_analyses() interface method of
                Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf that defines the
                structure of the pipeline: analyses, jobs, rules, etc.
                Here it defines a single analysis:
                  * 'HGNCName' which takes the HGNC names file and loads it into
                    a defined Tark DB.

=cut

sub pipeline_analyses {
  my ($self) = @_;

  return [
    {
      -logic_name => 'load_hgnc',
      -module     => 'Bio::EnsEMBL::Tark::Hive::RunnableDB::HGNCNames',
      -parameters => {

        # Tark db params
        tark_host => $self->o( 'tark_host' ),
        tark_port => $self->o( 'tark_port' ),
        tark_user => $self->o( 'tark_user' ),
        tark_pass => $self->o( 'tark_pass' ),
        tark_db   => $self->o( 'tark_db' ),

        hgnc_file => $self->o( 'hgnc_file' ),
      },
      -input_ids => [ {} ],
    },
  ];
} ## end sub pipeline_analyses

1;
