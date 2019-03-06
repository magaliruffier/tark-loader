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

  Bio::EnsEMBL::Tark::Hive::Runnable::TarkLoader


=head1 DESCRIPTION

  Runnable for the loading of the Tark db from a Core db.


=head2 DESCRIPTION

  A pipeline for loading ensembl genomic features into the Tark DB. Requires
  connection parameters for the Tark and Core dbs, as well was matching tags to
  describe the entries.

  This process can be run over a whole core db or by passing a list of gene_ids
  in a comma separated string, thus allowing multiple instances to handle the
  loading of the Tark db.

=cut


package Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoader;

use strict;
use warnings;
use Carp;

use base ('Bio::EnsEMBL::Hive::Process');

use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::TagConfig;
use Bio::EnsEMBL::Tark::Utils;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);


=head2 param_defaults
  Description : Defines the default parameters for the param variables

=cut

sub param_defaults {
  return {
    'host' => 'localhost',
    'port' => '3306',
    'user' => 'travis',
    'pass' => q{},
    'db'   => 'species_core_test',

    'tark_host' => 'localhost',
    'tark_port' => '3306',
    'tark_user' => 'travis',
    'tark_pass' => q{},
    'tark_db'   => 'test_tark',

    # Examples of the remaining tag parameters:
    # 'tag_block'        => 'Ensembl',
    # 'tag_shortname'    => 84,
    # 'tag_description'  => 'Ensembl release 84',
    # 'tag_feature_type' => 'all',
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

  my $species  = $self->param('species');
  # my $core_dba = Bio::EnsEMBL::Registry->get_DBAdaptor( $species, 'core' );

  my $core_dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new(
    -host   => $self->param('host'),
    -port   => $self->param('port'),
    -user   => $self->param('user'),
    -pass   => $self->param('pass'),
    -group  => 'core',
    -dbname => $self->param('db'),
  );

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
  my $tag_block = $self->param_required( 'tag_block' );
  $tag_config_hash{ $tag_block } = {};

  foreach my $tag_label (
    qw/ shortname description feature_type version /
  ) {
    if ( $self->param_is_defined( 'tag_' . $tag_label ) ) {
      $tag_config_hash{ $tag_block }{ $tag_label } = $self->param( 'tag_' . $tag_label );
    }
  }

  my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new(
    config => \%tag_config_hash
  );

  my $loader;

  my $naming_consortium = q{};
  if ( $self->param_is_defined( 'naming_consortium' ) ) {
    $naming_consortium = $self->param( 'naming_consortium' );
  }

  my $add_consortium_prefix = 0;
  if ( $self->param_is_defined( 'add_consortium_prefix' ) ) {
    $add_consortium_prefix = $self->param( 'add_consortium_prefix' );
  }

  if ( $self->param_is_defined( 'gene_id_list' ) ) {
    my @gene_id_list = split /,/, $self->param( 'gene_id_list' ) ;

    $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
      session      =>  $tark_dba,
      tag_config   =>  $tag_config,
      gene_id_list => \@gene_id_list,
      naming_consortium => $naming_consortium,
      add_name_prefix   => $add_consortium_prefix,
    );
  } else {
    $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
      session     =>  $tark_dba,
      tag_config  =>  $tag_config,
      naming_consortium => $naming_consortium,
      add_name_prefix   => $add_consortium_prefix,
    );
  }



  $loader->load_species( $core_dba, 'Ensembl' );

  $tark_dba->end_session();

  return;
}

1;
