use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::ReleaseSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::ReleaseSource

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

=head1 TABLE: C<release_source>

=cut

__PACKAGE__->table("release_source");

=head1 ACCESSORSCREATE TABLE gene_release_tag (
  feature_id integer unsigned NOT NULL,
  release_id integer unsigned NOT NULL,
  session_id integer unsigned NULL,
  INDEX gene_release_tag_idx_feature_id (feature_id),
  INDEX gene_release_tag_idx_release_id (release_id),
  PRIMARY KEY (feature_id, release_id),
  CONSTRAINT gene_release_tag_fk_feature_id FOREIGN KEY (feature_id) REFERENCES gene (gene_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT gene_release_tag_fk_release_id FOREIGN KEY (release_id) REFERENCES release_set (release_id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB

=head2 source_id

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

=cut

__PACKAGE__->add_columns(
  "source_id",
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
);

=head1 PRIMARY KEY

=over 4

=item * L</source_id>

=back

=cut

__PACKAGE__->set_primary_key("source_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<shortname_idx>

=over 4

=item * L</shortname>

=back

=cut

__PACKAGE__->add_unique_constraint("shortname_idx", ["shortname"]);

=head1 RELATIONS

=head2 release_sets

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet>

=cut

__PACKAGE__->has_many(
  "release_sets",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet",
  { "foreign.source_id" => "self.source_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zxQttTG7klfBXtUwgDIIWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
