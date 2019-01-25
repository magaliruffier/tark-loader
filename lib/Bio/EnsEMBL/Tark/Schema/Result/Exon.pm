use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::Exon;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::Exon

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

=head1 TABLE: C<exon>

=cut

__PACKAGE__->table("exon");

=head1 ACCESSORS

=head2 exon_id

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

=head2 exon_checksum

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

=cut

__PACKAGE__->add_columns(
  "exon_id",
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
  "exon_checksum",
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
);

=head1 PRIMARY KEY

=over 4

=item * L</exon_id>

=back

=cut

__PACKAGE__->set_primary_key("exon_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<exon_chk>

=over 4

=item * L</exon_checksum>

=back

=cut

__PACKAGE__->add_unique_constraint("exon_chk", ["exon_checksum"]);

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
  { "foreign.feature_id" => "self.exon_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 exon_transcripts

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ExonTranscript>

=cut

__PACKAGE__->has_many(
  "exon_transcripts",
  "Bio::EnsEMBL::Tark::Schema::Result::ExonTranscript",
  { "foreign.exon_id" => "self.exon_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Xh/wHDELIQYdxoJH9mkyng

sub sqlt_deploy_hook {
  my ($self, $sqlt_table) = @_;

  $sqlt_table->add_index(name => 'stable_id', fields => ['stable_id', 'stable_id_version']);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
