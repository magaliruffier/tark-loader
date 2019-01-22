#!/usr/bin/env perl


=head1 LICENSE
Copyright 2016 EMBL-European Bioinformatics Institute
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

$|++;

use warnings;
use strict;

use Log::Log4perl qw(:easy);
use Getopt::Long qw(:config no_ignore_case);

use Bio::EnsEMBL::Tark::Tag;

my ( $dbuser, $dbpass, $dbhost, $database, $config_file );
my $dbport = 3306;

Log::Log4perl->easy_init($DEBUG);

get_options();

Bio::EnsEMBL::Tark::DB->initialize(
  dsn => "DBI:mysql:database=$database;host=$dbhost;port=$dbport",
  dbuser => $dbuser,
  dbpass => $dbpass
);

Bio::EnsEMBL::Tark::DB->start_session();

Bio::EnsEMBL::Tark::Tag->initialize( config_file => $config_file );

Bio::EnsEMBL::Tark::Tag->init_tags( 1 );

Bio::EnsEMBL::Tark::Tag->tag_feature( 1, 'transcript' );
Bio::EnsEMBL::Tark::Tag->tag_feature( 2, 'gene' );


=head2 get_options
  Description:
  Returntype :
  Exceptions : none
  Caller     : general

=cut

sub get_options {
  my $help;

  GetOptions(
    'config=s'   => \$config_file,
    'dbuser=s'   => \$dbuser,
    'dbpass=s'   => \$dbpass,
    'dbhost=s'   => \$dbhost,
    'database=s' => \$database,
    'dbport=s'   => \$dbport,
    'help'       => \$help,
  );

  if ($help) {
    exec 'perldoc', $0;
  }

}
