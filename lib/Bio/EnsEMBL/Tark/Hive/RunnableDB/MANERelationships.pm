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

  Bio::EnsEMBL::Tark::Hive::Runnable::MANERelationships


=head1 DESCRIPTION

  Runnable for the loading of MANE relationshipd between the Ensembl and RefSeq
  entities within the Tark DB.

=cut


package Bio::EnsEMBL::Tark::Hive::RunnableDB::MANERelationships;

use strict;
use warnings;
use Carp;

use base ('Bio::EnsEMBL::Hive::Process');

use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::MANE;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);


=head2 param_defaults
  Description : Defines the default parameters for the param variables

=cut

sub param_defaults {
  return {
    'tark_host' => 'localhost',
    'tark_port' => '3306',
    'tark_user' => 'travis',
    'tark_pass' => q{},
    'tark_db'   => 'test_tark'
  };
} ## end sub param_defaults



=head2 run
  Description : Implements run() interface method of Bio::EnsEMBL::Hive::Process
                that is used to perform the main bulk of the job (minus input and
                output).
  param
    column_names : Controls the column names that come out of the parser:
=cut

sub run {
  my ( $self ) = @_;

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

  my $core_dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new(
    -host   => $self->param('host'),
    -port   => $self->param('port'),
    -user   => $self->param('user'),
    -pass   => $self->param('pass'),
    -group  => 'core',
    -dbname => $self->param('db'),
  );

  # start_session
  my $session_id_start = $tark_dba->start_session();

  my %object_config = (
    source    => $self->param('object_source'),
    shortname => $self->param('object_shortname'),
  );

  my %subject_config = (
    source    => $self->param('subject_source'),
    shortname => $self->param('subject_shortname'),
  );

  my $mane_loader = Bio::EnsEMBL::Tark::MANE->new(
    session => $tark_dba,
    object_config  => \%object_config,
    subject_config => \%subject_config,
    relationship_config => {
      select => {
        version => 0.5,
        date    => '2019-03-08'
      },
      plus => {
        version => 0.5,
        date    => '2019-03-08'
      }
    }
  );

  $mane_loader->load_mane( $core_dba );

  $tark_dba->end_session();

  return;
}

1;
