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

use Bio::EnsEMBL::Tark::HGNC;
use Bio::EnsEMBL::Tark::DB;

my $dbuser; my $dbpass; my $dbhost; my $database; my $dbport = 3306;
my $hgnc_file;

Log::Log4perl->easy_init($DEBUG);

get_options();

Bio::EnsEMBL::Tark::DB->initialize( dsn => "DBI:mysql:database=$database;host=$dbhost;port=$dbport",
				    dbuser => $dbuser,
				    dbpass => $dbpass );

my $session_id = Bio::EnsEMBL::Tark::DB->start_session("HGNC loader");

my $loader = Bio::EnsEMBL::Tark::HGNC->new(session_id => $session_id);

#eval {
    $loader->load_hgnc($hgnc_file);
#};
#if($@) {
#    $loader->abort_session($session_id);
#    die "Error loading species: $@";
#}

Bio::EnsEMBL::Tark::DB->end_session($session_id);

sub get_options {
    my $help;

    GetOptions(
#	"config=s"               => \$config_file,
	"dbuser=s"               => \$dbuser,
	"dbpass=s"               => \$dbpass,
	"dbhost=s"               => \$dbhost,
	"database=s"             => \$database,
	"dbport=s"               => \$dbport,
	"hgnc=s"                 => \$hgnc_file,
        "help"                   => \$help,
        );
    
    if ($help) {
        exec('perldoc', $0);
    }

}
