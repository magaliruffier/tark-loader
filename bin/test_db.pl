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

use Bio::EnsEMBL::Tark::DB;

my ($dbuser, $dbpass, $dbhost, $database);
my $dbport = 3306;

Log::Log4perl->easy_init($DEBUG);

get_options();

print "Passing:\nDBI:mysql:database=$database;host=$dbhost;port=$dbport\n$dbuser\n$dbpass\n";

Bio::EnsEMBL::Tark::DB->initialize(
  dsn => "DBI:mysql:database=$database;host=$dbhost;port=$dbport",
  dbuser => $dbuser,
  dbpass => $dbpass
);

my $dbh = Bio::EnsEMBL::Tark::DB->dbh();

my $session_id = Bio::EnsEMBL::Tark::DB->start_session( 'My processor' );

Bio::EnsEMBL::Tark::DB->abort_session();

sub get_options {
  my $help;

  GetOptions(
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
