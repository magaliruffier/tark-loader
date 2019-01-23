use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::Session

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<session>

=cut

__PACKAGE__->table("session");

=head1 ACCESSORS

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 client_id

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 start_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=cut

__PACKAGE__->add_columns(
  "session_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "client_id",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "start_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</session_id>

=back

=cut

__PACKAGE__->set_primary_key("session_id");

=head1 RELATIONS

=head2 assemblies

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Assembly>

=cut

__PACKAGE__->has_many(
  "assemblies",
  "Bio::EnsEMBL::Tark::Schema::Result::Assembly",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 assembly_aliases

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::AssemblyAlias>

=cut

__PACKAGE__->has_many(
  "assembly_aliases",
  "Bio::EnsEMBL::Tark::Schema::Result::AssemblyAlias",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 exon_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ExonTranscript>

=cut

__PACKAGE__->has_many(
  "exon_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::ExonTranscript",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 exons

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Exon>

=cut

__PACKAGE__->has_many(
  "exons",
  "Bio::EnsEMBL::Tark::Schema::Result::Exon",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_names

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::GeneName>

=cut

__PACKAGE__->has_many(
  "gene_names",
  "Bio::EnsEMBL::Tark::Schema::Result::GeneName",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genes

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Gene>

=cut

__PACKAGE__->has_many(
  "genes",
  "Bio::EnsEMBL::Tark::Schema::Result::Gene",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genomes

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Genome>

=cut

__PACKAGE__->has_many(
  "genomes",
  "Bio::EnsEMBL::Tark::Schema::Result::Genome",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 operon_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::OperonTranscript>

=cut

__PACKAGE__->has_many(
  "operon_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::OperonTranscript",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 operons

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Operon>

=cut

__PACKAGE__->has_many(
  "operons",
  "Bio::EnsEMBL::Tark::Schema::Result::Operon",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 release_sets

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet>

=cut

__PACKAGE__->has_many(
  "release_sets",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseTag>

=cut

__PACKAGE__->has_many(
  "release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseTag",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sequences

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Sequence>

=cut

__PACKAGE__->has_many(
  "sequences",
  "Bio::EnsEMBL::Tark::Schema::Result::Sequence",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Tag>

=cut

__PACKAGE__->has_many(
  "tags",
  "Bio::EnsEMBL::Tark::Schema::Result::Tag",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tagsets

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Tagset>

=cut

__PACKAGE__->has_many(
  "tagsets",
  "Bio::EnsEMBL::Tark::Schema::Result::Tagset",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_genes

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranscriptGene>

=cut

__PACKAGE__->has_many(
  "transcript_genes",
  "Bio::EnsEMBL::Tark::Schema::Result::TranscriptGene",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::Transcript",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 translation_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranslationTranscript>

=cut

__PACKAGE__->has_many(
  "translation_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::TranslationTranscript",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 translations

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Translation>

=cut

__PACKAGE__->has_many(
  "translations",
  "Bio::EnsEMBL::Tark::Schema::Result::Translation",
  { "foreign.session_id" => "self.session_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MD+5oRlBUTFrYNFZeRYiYQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
