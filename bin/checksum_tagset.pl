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
use Bio::EnsEMBL::Tark::Tag;
use Bio::EnsEMBL::Tark::TagConfig

my ( $dbuser, $dbpass, $dbhost, $database, $config_file, $tagset_id );
my $dbport = 3306;
my $set_type = 'tag';

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

my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new();
$tag_config->load_config_file( $config_file );

my $tag = Bio::EnsEMBL::Tark::Tag->new(
  config  => $tag_config,
  session => $db
);

my $checksum = $tag->checksum_set($tagset_id, $set_type);

print "\nFound checksum: " .  unpack("H*", $checksum) . "\n";

$tag->write_checksum($tagset_id, $checksum, $set_type);

sub get_options {
  my $help;

  GetOptions(
    'tagset=s'   => \$tagset_id,
    'set_type=s' => \$set_type,
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
