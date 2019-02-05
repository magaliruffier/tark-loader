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

package Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoader;

use strict;
use warnings;
use Carp;

use base ('Bio::EnsEMBL::Hive::Process');

use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::TagConfig;
use Bio::EnsEMBL::Tark::Utils;


sub param_defaults {
  return {
    'host' => 'localhost',
    'port' => '3306',
    'user' => 'travis',
    'pass' => q{},
  };
}



=head2 run
  Description : Implements run() interface method of Bio::EnsEMBL::Hive::Process
                that is used to perform the main bulk of the job (minus input and
                output).
  param
    column_names : Controls the column names that come out of the parser:
=cut

sub run {
  my $self = shift @_;

  my $species  = $self->param('species');
  my $core_dba = Bio::EnsEMBL::Registry->get_DBAdaptor( $species, 'core' );
  my $tark_dba = Bio::EnsEMBL::Tark::DB->new(
    config => {
      driver => 'mysql',
      host   => $self->param('tark_host'),
      port   => $self->param('tark_port'),
      user   => $self->param('tark_user'),
      pass   => $self->param('tark_pass'),
      db     => $self->param('tark_db'),
    }
  );

  # start_session
  my $session_id_start = $tark_dba->start_session();

  my %tag_config_hash;
  $tag_config_hash[ 'tag_block' ] = $self->param_required( 'tag_block' );

  foreach my $tag_label (
    qw/ tag_shortname tag_description tag_feature_type tag_version /
  ) {
    if ( $self->param_defined( $tag_label ) ) {
      $tag_config_hash[ $tag_label ] = $self->param( $tag_label );
    }
  }

  my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new(
    config => \%tag_config_hash
  );

  my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
    session    => $tark_dba,
    tag_config => $tag_config
  );

  $loader->load_species( $core_dba, 'Ensembl' );

  $tark_dba->end_session();
}

################################### main functionality starts here ###################


1;