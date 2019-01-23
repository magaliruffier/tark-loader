use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet

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

=head1 TABLE: C<release_set>

=cut

__PACKAGE__->table("release_set");

=head1 ACCESSORS

=head2 release_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 shortname

  data_type: 'varchar'
  is_nullable: 1
  size: 24

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 assembly_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 release_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 release_checksum

  data_type: 'binary'
  is_nullable: 1
  size: 20

=head2 source_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "release_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "shortname",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "assembly_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "release_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "session_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "release_checksum",
  { data_type => "binary", is_nullable => 1, size => 20 },
  "source_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</release_id>

=back

=cut

__PACKAGE__->set_primary_key("release_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<shortname_assembly_source_idx>

=over 4

=item * L</shortname>

=item * L</assembly_id>

=item * L</source_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "shortname_assembly_source_idx",
  ["shortname", "assembly_id", "source_id"],
);

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

=head2 exon_release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ExonReleaseTag>

=cut

__PACKAGE__->has_many(
  "exon_release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::ExonReleaseTag",
  { "foreign.release_id" => "self.release_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::GeneReleaseTag>

=cut

__PACKAGE__->has_many(
  "gene_release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::GeneReleaseTag",
  { "foreign.release_id" => "self.release_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseTag>

=cut

__PACKAGE__->has_many(
  "release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseTag",
  { "foreign.release_id" => "self.release_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 source

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseSource>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseSource",
  { source_id => "source_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 transcript_release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranscriptReleaseTag>

=cut

__PACKAGE__->has_many(
  "transcript_release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::TranscriptReleaseTag",
  { "foreign.release_id" => "self.release_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 translation_release_tags

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranslationReleaseTag>

=cut

__PACKAGE__->has_many(
  "translation_release_tags",
  "Bio::EnsEMBL::Tark::Schema::Result::TranslationReleaseTag",
  { "foreign.release_id" => "self.release_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CwBWlTZQ/q0xC9tn38EAng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
