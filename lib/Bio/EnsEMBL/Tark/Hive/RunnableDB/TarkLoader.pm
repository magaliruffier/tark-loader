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


=head1 SYNOPSIS

  # Prepare the pipeline
  init_pipeline.pl Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkLoader_conf
    --tark_host 127.0.0.1
    --tark_port 3306
    --tark_user travis
    --tark_pass ''
    --tark_db $TARK_SPP_DB
    --core_host 127.0.0.1
    --core_port 3306
    --core_user travis
    --core_pass ''
    --core_dbname $ENS_SPP_CORE_DB
    --host 127.0.0.1
    --port 3306
    --user travis
    --password ''
    --pipeline_name test_hive_1234
    --species homo_sapiens
    --tag_block release
    --tag_shortname 84
    --tag_description 'Ensembl release 84'
    --tag_feature_type all
    --tag_version 1
    --block_size 10

  runWorker.pl -url $EHIVE_URL


=head1 DESCRIPTION

  A pipeline for loading ensembl genomic features into the Tark DB.

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

    # Examples of the remaining block parameters:
    # block_size => 1000,
    # start_block => 1,
    # max_gene_id => 1000,
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

  if ( $self->param_is_defined( 'gene_id_list' ) ) {
    my @gene_id_list = split /,/, $self->param( 'gene_id_list' ) ;

    $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
      session     =>  $tark_dba,
      tag_config  =>  $tag_config,
      gene_id_list => \@gene_id_list,
    );
  } else {
    $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
      session     =>  $tark_dba,
      tag_config  =>  $tag_config,
    );
  }

  foreach my $block_label (
    qw/ block_size start_block max_gene_id /
  ) {
    if ($self->param_is_defined( $block_label ) ) {
      $loader->{$block_label} = $self->param( $block_label );
    }
  }

  $loader->load_species( $core_dba, 'Ensembl' );

  $tark_dba->end_session();

  return;
}

################################### main functionality starts here ###################

1;