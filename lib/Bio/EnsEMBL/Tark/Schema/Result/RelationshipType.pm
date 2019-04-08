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

package Bio::EnsEMBL::Tark::Schema::Result::RelationshipType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::ReleaseType

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

=head1 TABLE: C<release_set>

=cut

__PACKAGE__->table("relationship_type");

=head1 ACCESSORS

=head2 relationship_type_id

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

=head2 version

  data_type: 'varchar'
  is_nullable: 1
  size: 24

=head2 release_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "relationship_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "shortname",
  { data_type => "varchar", is_nullable => 0, size => 24 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "version",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "release_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</release_id>

=back

=cut

__PACKAGE__->set_primary_key("relationship_type_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<shortname_assembly_source_idx>

=over 4

=item * L</shortname>

=item * L</assembly_id>

=item * L</source_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "shortname_version_idx",
  ["shortname", "version"],
);

=head2 transcript_relationships

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::TranscriptReleaseTagRelationship>

=cut

__PACKAGE__->has_many(
  "transcript_relationships",
  "Bio::EnsEMBL::Tark::Schema::Result::TranscriptReleaseTagRelationship",
  { "foreign.relationship_type_id" => "self.relationship_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CwBWlTZQ/q0xC9tn38EAng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
