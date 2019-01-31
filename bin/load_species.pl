#!/usr/bin/env perl


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

$|++;

use warnings;
use strict;

use Log::Log4perl qw(:easy);
use Getopt::Long qw(:config no_ignore_case);

use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::Tag;
use Bio::EnsEMBL::Registry;

my ($dbuser, $dbpass, $dbhost, $database, $species, $release, $config_file);
my $dbport = 3306;
my $source_name = 'Ensembl';
my $ensdbhost = 'mysql-ensembl-mirror.ebi.ac.uk';
my $ensdbport = 4240;

Log::Log4perl->easy_init($DEBUG);

get_options();

my $db = Bio::EnsEMBL::Tark::DB->new(
  config => {
    driver => 'mysql',
    host   => $dbhost,
    port   => $dbport,
    user   => $dbuser,
    pass   => $dbpass,
    db     => $database,
  }
);

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new();

# Connect to the Ensembl Registry to access the databases
Bio::EnsEMBL::Registry->load_registry_from_db(
  -host => $ensdbhost,
  -port => $ensdbport,
  -user => 'anonymous',
  -db_version => $release
);


my $dba = Bio::EnsEMBL::Registry->get_DBAdaptor( $species, 'core' );

my $session_id = $db->start_session('Test client');

my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new();
$tag_config->load_config_file( $config_file );

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
  session    => $db,
  tag_config => $tag_config
);
$loader->load_species( $dba, $source_name );

Bio::EnsEMBL::Tark::DB->end_session($session_id);


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
    'species=s'  => \$species,
    'release=s'  => \$release,
    'enshost=s'  => \$ensdbhost,
    'ensport=s'  => \$ensdbport,
    'source=s'   => \$source_name,
    'help'       => \$help,
  );

  if ($help) {
    exec 'perldoc', $0;
  }
} ## end sub get_options
