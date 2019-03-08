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
use Bio::EnsEMBL::Tark::Test::Utils;
use Bio::EnsEMBL::Tark::MANE;
use Bio::EnsEMBL::Tark::SpeciesLoader;
use Bio::EnsEMBL::Tark::TagConfig;
use Bio::EnsEMBL::Tark::Utils;

use Bio::EnsEMBL::Test::MultiTestDB;

# Check that the modules loaded correctly
use_ok 'Bio::EnsEMBL::Tark::DB';

my $multi_db = Bio::EnsEMBL::Test::MultiTestDB->new;
my $dba = $multi_db->get_DBAdaptor('core');

my $db = Bio::EnsEMBL::Tark::Test::TestDB->new();

my $test_utils = Bio::EnsEMBL::Tark::Test::Utils->new();

ok($db, 'TestDB ready to go');

use_ok 'Bio::EnsEMBL::Tark::SpeciesLoader';


# start_session
my $session_id_start = $db->start_session();
ok( $session_id_start, "start_session - $session_id_start");

my $tag_config = Bio::EnsEMBL::Tark::TagConfig->new();
ok( !defined $tag_config->load_config_file( 'etc/release84.ini' ), 'load_config_file' );

my $loader = Bio::EnsEMBL::Tark::SpeciesLoader->new(
  session    => $db,
  tag_config => $tag_config
);

ok( !defined $loader->load_species( $dba, 'Ensembl' ), 'load_species' );
my $result_count_00 = $test_utils->check_db(
  $db, 'Gene', {}, 1
);
is( $result_count_00, 21, 'load_species' );

my $result_transcript_01 = $test_utils->check_db(
  $db, 'Transcript', { stable_id => 'ENST00000202017' }
);
my $t1_id = $db->schema->resultset( 'Transcript' )->create( {
  stable_id           => 'NM_030815',
  stable_id_version   => $result_transcript_01->stable_id_version,
  assembly_id         => $result_transcript_01->assembly_id,
  loc_start           => $result_transcript_01->loc_start,
  loc_end             => $result_transcript_01->loc_end,
  loc_strand          => $result_transcript_01->loc_strand,
  loc_region          => $result_transcript_01->loc_region,
  loc_checksum        => undef,
  exon_set_checksum   => undef,
  transcript_checksum => undef,
  seq_checksum        => $result_transcript_01->seq_checksum,
  session_id          => 9000000,
} );

my $result_transcript_02 = $test_utils->check_db(
  $db, 'Transcript', { stable_id => 'ENST00000246229' }
);
my $t2_id = $db->schema->resultset( 'Transcript' )->create( {
  stable_id           => 'NM_002657',
  stable_id_version   => $result_transcript_02->stable_id_version,
  assembly_id         => $result_transcript_02->assembly_id,
  loc_start           => $result_transcript_02->loc_start,
  loc_end             => $result_transcript_02->loc_end,
  loc_strand          => $result_transcript_02->loc_strand,
  loc_region          => $result_transcript_02->loc_region,
  loc_checksum        => undef,
  exon_set_checksum   => undef,
  transcript_checksum => undef,
  seq_checksum        => $result_transcript_02->seq_checksum,
  session_id          => 9000000,
} );

my $rs_id = $db->schema->resultset( 'ReleaseSet' )->create( {
  shortname   => 92,
  description => 'RefSeq',
  assembly_id => 1,
  source_id   => 2,
  session_id  => 9000000,
} );

$db->schema->resultset( 'TranscriptReleaseTag' )->create( {
  feature_id => $t1_id->transcript_id,
  release_id => $rs_id->release_id,
  session_id => 9000000,
} );

$db->schema->resultset( 'TranscriptReleaseTag' )->create( {
  feature_id => $t2_id->transcript_id,
  release_id => $rs_id->release_id,
  session_id => 9000000,
} );


# start_session
$session_id_start = $db->start_session();
ok( $session_id_start, "start_session - $session_id_start");

my %object_config = %{ $tag_config->config->{'release'} };
$object_config{'source'} = 'Ensembl';
my %subject_config = %{ $tag_config->config->{'refseq'} };
$subject_config{'source'} = 'RefSeq';


my $mane_loader = Bio::EnsEMBL::Tark::MANE->new(
  session => $db,
  object_config  => \%object_config,
  subject_config => \%subject_config,
  relationship_config => {
    select => {
      version => 0.5,
      date    => '2019-03-08'
    },
    plus => {
      version => 0.5,
      date    => '2019-03-08'
    }
  }
);

$mane_loader->load_mane( $dba );

done_testing();

1;
