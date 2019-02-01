use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::Tagset;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::Tagset

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

=head1 TABLE: C<tagset>

=cut

__PACKAGE__->table("tagset");

=head1 ACCESSORS

=head2 tagset_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 shortname

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 version

  data_type: 'varchar'
  default_value: 1
  is_nullable: 1
  size: 20

=head2 is_current

  data_type: 'tinyint'
  is_nullable: 1

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 tagset_checksum

  data_type: 'binary'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "tagset_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "shortname",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "version",
  { data_type => "varchar", default_value => 1, is_nullable => 1, size => 20 },
  "is_current",
  { data_type => "tinyint", is_nullable => 1 },
  "session_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "tagset_checksum",
  { data_type => "binary", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tagset_id>

=back

=cut

__PACKAGE__->set_primary_key("tagset_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_version_idx>

=over 4

=item * L</shortname>

=item * L</version>

=back

=cut

__PACKAGE__->add_unique_constraint("name_version_idx", ["shortname", "version"]);

=head1 RELATIONS

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
  { "foreign.tagset_id" => "self.tagset_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7SOaI/1+A7C2EDoolFzxPQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
