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

use Bio::EnsEMBL::Tark::LRG;
use Bio::EnsEMBL::Tark::DB;

my $dbuser; my $dbpass; my $dbhost; my $database; my $dbport = 3306;
my $lrg_file; my $flush_names;

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

my $session_id = $db->start_session( 'LRG Name loader' );

my $loader = Bio::EnsEMBL::Tark::LRG->new(
  session => $db
);


# downloaded from ftp://ftp.ebi.ac.uk/pub/databases/lrgex/list_LRGs_GRCh38.txt
$loader->load_lrg_names($lrg_file);

$db->end_session( $session_id );

sub get_options {
    my $help;

    GetOptions(
	"dbuser=s"               => \$dbuser,
	"dbpass=s"               => \$dbpass,
	"dbhost=s"               => \$dbhost,
	"database=s"             => \$database,
	"dbport=s"               => \$dbport,
	"lrg=s"                 => \$lrg_file,
	"flush"                  => \$flush_names,
    "help"                   => \$help,
        );
    
    if ($help) {
        exec('perldoc', $0);
    }

}
