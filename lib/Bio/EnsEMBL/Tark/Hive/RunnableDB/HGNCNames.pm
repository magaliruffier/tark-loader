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

  Bio::EnsEMBL::Tark::Hive::PipeConfig::HGNCNames


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


package Bio::EnsEMBL::Tark::Hive::RunnableDB::HGNCNames;

use strict;
use warnings;
use Carp;

use base ('Bio::EnsEMBL::Hive::Process');

use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::HGNC;

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

  # start_session
  my $session_id_start = $tark_dba->start_session();

  my $hgnc_loader = Bio::EnsEMBL::Tark::HGNC->new(
    session => $tark_dba
  );

  # Flush the gene_names table and the hgnc_id column in the gene table
  $hgnc_loader->flush_hgnc();

  $hgnc_loader->load_hgnc( $self->param_required( 'hgnc_file' ) );

  $tark_dba->end_session();

  return;
}

1;
