use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::GeneReleaseTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::GeneReleaseTag

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

=head1 TABLE: C<gene_release_tag>

=cut

__PACKAGE__->table("gene_release_tag");

=head1 ACCESSORS

=head2 feature_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 release_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "feature_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "release_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "session_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</feature_id>

=item * L</release_id>

=back

=cut

__PACKAGE__->set_primary_key("feature_id", "release_id");

=head1 RELATIONS

=head2 feature

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Gene>

=cut

__PACKAGE__->belongs_to(
  "feature",
  "Bio::EnsEMBL::Tark::Schema::Result::Gene",
  { gene_id => "feature_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 release

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet>

=cut

__PACKAGE__->belongs_to(
  "release",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet",
  { release_id => "release_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JW1LOIkex8++rBHtjURncg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
