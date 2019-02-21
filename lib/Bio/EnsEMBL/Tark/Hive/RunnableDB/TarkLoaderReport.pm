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

  Bio::EnsEMBL::Tark::Hive::Runnable::TarkLoaderReport


=head1 DESCRIPTION

  Runnable for the comparison of the Tark db and Core db features.


=head2 DESCRIPTION

  A pipeline for comparing counts between what was loaded into Tark and what is
  in the core db

=cut


package Bio::EnsEMBL::Tark::Hive::RunnableDB::TarkLoaderReport;

use strict;
use warnings;
use Carp;

use JSON;

use base ('Bio::EnsEMBL::Hive::Process');

use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL;
use Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkSQL;
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

  my $core_dbh = $core_dba->dbc();
  my $tark_dbh = $tark_dba->dbh();

  my $core_sql_handle = Bio::EnsEMBL::Tark::Hive::PipeConfig::SQL->new();
  my $tark_sql_handle = Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkSQL->new();

  my $core_sql = q{};
  my $tark_sql = q{};
  my $tark_release_sql = q{};
  my $tark_compare_sql = q{};

  my %output;

  foreach my $table (qw/ gene exon transcript translation /) {
    if ( $self->param_is_defined('exclude_source') and $self->param('exclude_source') ) {
      my @source_list = split /,/, $self->param('exclude_source');
      $core_sql = sprintf $core_sql_handle->feature_count_exclusion(
        $table,
        scalar @source_list
      ), @source_list;
    }
    elsif ( $self->param_is_defined('include_source') and $self->param('include_source') ) {
      my @source_list = split /,/, $self->param('include_source');
      $core_sql = sprintf $core_sql_handle->feature_count_inclusion(
        $table,
        scalar @source_list
      ), @source_list;
    }
    else {
      $core_sql = $core_sql_handle->feature_count( $table );
    }

    $tark_sql = $tark_sql_handle->feature_count( $table );
    $tark_release_sql = $tark_sql_handle->feature_release_count( $table );

    my $sth = $core_dbh->prepare( $core_sql );
    $sth->execute();
    my @core_count_row = $sth->fetchrow_array();

    $sth = $tark_dbh->prepare( $tark_sql );
    $sth->execute();
    my @tark_count_row = $sth->fetchrow_array();

    $sth = $tark_dbh->prepare( $tark_release_sql );
    $sth->execute( $self->param( 'tag_shortname' ) );
    my @tark_release_count_row = $sth->fetchrow_array();

    $output{ $table } = {
      core         => $core_count_row[0],
      tark_total   => $tark_count_row[0],
      tark_release => $tark_release_count_row[1],
    };

    if ( $self->param_is_defined( 'tag_previous_shortname' ) ) {
      $tark_compare_sql = $tark_sql_handle->feature_release_count( $table, 'removed' );
      $sth = $tark_dbh->prepare( $tark_compare_sql );
      $sth->execute(
        $self->param( 'tag_previous_shortname' ),
        $self->param( 'tag_shortname' )
      );
      my @tark_compare_removed = $sth->fetchrow_array();
      $output{ $table }{ 'removed' } = $tark_compare_removed[0];

      $tark_compare_sql = $tark_sql_handle->feature_release_count( $table, 'gained' );
      $sth = $tark_dbh->prepare( $tark_compare_sql );
      $sth->execute(
        $self->param( 'tag_previous_shortname' ),
        $self->param( 'tag_shortname' )
      );
      my @tark_compare_gained = $sth->fetchrow_array();
      $output{ $table }{ 'gained' } = $tark_compare_gained[0];
    }
  }

  open my $fh, '>', $self->param('report') or confess 'Can\'t open report file';

  print $fh encode_json \%output;

  close $fh or confess 'Can\'t close report file';

  return;
}

1;
