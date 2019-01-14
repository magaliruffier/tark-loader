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

use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::Tag;
use Bio::EnsEMBL::Registry;

my $dbuser; my $dbpass; my $dbhost; my $database; my $dbport = 3306; my $source_name = "Ensembl";
my $species;
my $ensdbhost = 'mysql-ensembl-mirror.ebi.ac.uk';
my $ensdbport = 4240;
my $release;
my $config_file;

Log::Log4perl->easy_init($DEBUG);

get_options();

Bio::EnsEMBL::Tark::DB->initialize( dsn => "DBI:mysql:database=$database;host=$dbhost;port=$dbport",
				    dbuser => $dbuser,
				    dbpass => $dbpass );

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new();

# Connect to the Ensembl Registry to access the databases
Bio::EnsEMBL::Registry->load_registry_from_db(
    -host => $ensdbhost,
    -port => $ensdbport,
    -user => 'anonymous',
    -db_version => $release
    );


my $dba = Bio::EnsEMBL::Registry->get_DBAdaptor( $species, "core" );

my $session_id = Bio::EnsEMBL::Tark::DB->start_session("Test client");

Bio::EnsEMBL::Tark::Tag->initialize( config_file => $config_file );



#eval {
    $loader->load_species($dba, $source_name);
#};
#if($@) {
#    $loader->abort_session($session_id);
#    die "Error loading species: $@";
#}

Bio::EnsEMBL::Tark::DB->end_session($session_id);


sub get_options {
    my $help;

    GetOptions(
	"config=s"               => \$config_file,
	"dbuser=s"               => \$dbuser,
	"dbpass=s"               => \$dbpass,
	"dbhost=s"               => \$dbhost,
	"database=s"             => \$database,
	"dbport=s"               => \$dbport,
        "species=s"              => \$species,
	"release=s"              => \$release,
	"enshost=s"              => \$ensdbhost,
	"ensport=s"              => \$ensdbport,
	"source=s"              => \$source_name,
        "help"                   => \$help,
        );
    
    if ($help) {
        exec('perldoc', $0);
    }

}
