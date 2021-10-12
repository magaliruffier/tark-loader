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

package Bio::EnsEMBL::Tark::Schema::Result::Transcript;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::Transcript - loc_str includes sets of exon start-stop locations: 1000,200

=cut

use strict;
use warnings;
use utf8;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<transcript>

=cut

__PACKAGE__->table("transcript");

=head1 ACCESSORS

=head2 transcript_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 stable_id

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 stable_id_version

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 assembly_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 loc_start

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 loc_end

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 loc_strand

  data_type: 'tinyint'
  is_nullable: 1

=head2 loc_region

  data_type: 'varchar'
  is_nullable: 1
  size: 42

=head2 loc_checksum

  data_type: 'binary'
  is_nullable: 1
  size: 20

=head2 exon_set_checksum

  data_type: 'binary'
  is_nullable: 1
  size: 20

=head2 transcript_checksum

  data_type: 'binary'
  is_nullable: 1
  size: 20

=head2 seq_checksum

  data_type: 'binary'
  is_foreign_key: 1
  is_nullable: 1
  size: 20

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

#populate biotype for transcript
=head2 biotype

  data_type: 'varchar'
  is_nullable: 1
  size: 40
  
=cut

__PACKAGE__->add_columns(
  "transcript_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "stable_id",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "stable_id_version",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "assembly_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "loc_start",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "loc_end",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "loc_strand",
  { data_type => "tinyint", is_nullable => 1 },
  "loc_region",
  { data_type => "varchar", is_nullable => 1, size => 42 },
  "loc_checksum",
  { data_type => "binary", is_nullable => 1, size => 20 },
  "exon_set_checksum",
  { data_type => "binary", is_nullable => 1, size => 20 },
  "transcript_checksum",
  { data_type => "binary", is_nullable => 1, size => 20 },
  "seq_checksum",
  { data_type => "binary", is_foreign_key => 1, is_nullable => 1, size => 20 },
  "session_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  # populate biotype for transcript
  "biotype",
  { data_type => "varchar", is_nullable => 1, size => 40 }, 
);

=head1 PRIMARY KEY

=over 4

=item * L</transcript_id>

=back

=cut

__PACKAGE__->set_primary_key("transcript_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<transcript_chk>

=over 4

=item * L</transcript_checksum>

=back

=cut

__PACKAGE__->add_unique_constraint("transcript_chk", ["transcript_checksum"]);

=head1 RELATIONS

=head2 assembly

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Assembly>

=cut

__PACKAGE__->belongs_to(
  "assembly",
  "Bio::EnsEMBL::Tark::Schema::Result::Assembly",
  { assembly_id => "assembly_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 exon_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ExonTranscript>

=cut

__PACKAGE__->has_many(
  "exon_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::ExonTranscript",
  { "foreign.transcript_id" => "self.transcript_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 operon_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::OperonTranscript>

=cut

__PACKAGE__->has_many(
  "operon_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::OperonTranscript",
  { "foreign.transcript_id" => "self.transcript_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 seq_checksum

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Sequence>

=cut

__PACKAGE__->belongs_to(
  "seq_checksum",
  "Bio::EnsEMBL::Tark::Schema::Result::Sequence",
  { seq_checksum => "seq_checksum" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 session

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Session>

=cut

__PACKAGE__->belongs_to(
  "session",
  "Bio::EnsEMBL::Tark::Schema::Result::Session",
  { session_id => "session_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Tag>

=cut

__PACKAGE__->has_many(
  "tags",
  "Bio::EnsEMBL::Tark::Schema::Result::Tag",
  { "foreign.transcript_id" => "self.transcript_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_genes

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranscriptGene>

=cut

__PACKAGE__->has_many(
  "transcript_genes",
  "Bio::EnsEMBL::Tark::Schema::Result::TranscriptGene",
  { "foreign.transcript_id" => "self.transcript_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranscriptReleaseTag>

=cut

__PACKAGE__->has_many(
  "transcript_release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::TranscriptReleaseTag",
  { "foreign.feature_id" => "self.transcript_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 translation_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranslationTranscript>

=cut

__PACKAGE__->has_many(
  "translation_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::TranslationTranscript",
  { "foreign.transcript_id" => "self.transcript_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vO0dvCP70RQc2QULazYglg

=head2 sqlt_deploy_hook
  Arg [1]    : $sqlt_table : Bio::EnsEMBL::Tark::Schema::Result::Session
  Description: Add relevant missing indexes to the table
  Returntype : undef
  Exceptions : none
  Caller     : general

=cut

sub sqlt_deploy_hook {
  my ($self, $sqlt_table) = @_;

  $sqlt_table->add_index(name => 'stable_id', fields => ['stable_id', 'stable_id_version']);

  return;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
