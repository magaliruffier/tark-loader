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

use strict;
use warnings;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;

use Test::More;
use Test::Exception;
use Test::Warnings;
use Bio::EnsEMBL::Tark::Test::TestDB;
use Bio::EnsEMBL::Tark::Tag;
use Bio::EnsEMBL::Tark::TagConfig;

# Check that the modules loaded correctly
use_ok 'Bio::EnsEMBL::Tark::DB';

my $db = Bio::EnsEMBL::Tark::Test::TestDB->new();

# start_session
my $session_id_start = $db->start_session();
ok( $session_id_start, "start_session - $session_id_start");

# INSERT genome
my $genome_sql = (<<'SQL');
  INSERT INTO genome (name, tax_id, session_id)
  VALUES (?, ?, ?)
  ON DUPLICATE KEY UPDATE genome_id=LAST_INSERT_ID(genome_id)
SQL

my $sth = $db->dbh->prepare( $genome_sql );
$sth->execute( 'Homo sapiens', 9606, $db->session_id );
my $genome_id = $sth->{ mysql_insertid };

# INSERT assembly
my $assembly_sql = (<<'SQL');
  INSERT INTO assembly (genome_id, assembly_name, session_id)
  VALUES (?, ?, ?)
  ON DUPLICATE KEY UPDATE assembly_id=LAST_INSERT_ID(assembly_id)
SQL

$sth = $db->dbh->prepare( $assembly_sql );
$sth->execute( $genome_id, 'hg38', $db->session_id );
my $assembly_id = $sth->{ mysql_insertid };

# INSERT assembly_alias
my $assembly_alias_sql = (<<'SQL');
  INSERT INTO assembly_alias (genome_id, assembly_id, alias, session_id)
  VALUES (?, ?, ?, ?)
  ON DUPLICATE KEY UPDATE assembly_id=LAST_INSERT_ID(assembly_id)
SQL

$sth = $db->dbh->prepare( $assembly_alias_sql );
$sth->execute( $genome_id, $assembly_id, 'GCA_000000000', $db->session_id );



my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new();
ok( !defined $tag_config->load_config_file( 'etc/release84.ini' ), 'load_config_file' );

my $tag = Bio::EnsEMBL::Tark::Tag->new(
  config  => $tag_config,
  session => $db
);
$tag->init_tags( 1 );

# ok( $utils->checksum_array( 'acgt' ) eq Digest::SHA1::sha1( 'acgt' ), 'checksum_array');
done_testing();

1;
