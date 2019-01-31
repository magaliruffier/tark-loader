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

package Bio::EnsEMBL::Tark::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::Tag

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

=head1 TABLE: C<tag>

=cut

__PACKAGE__->table("tag");

=head1 ACCESSORS

=head2 transcript_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tagset_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "transcript_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tagset_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
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

=item * L</transcript_id>

=item * L</tagset_id>

=back

=cut

__PACKAGE__->set_primary_key("transcript_id", "tagset_id");

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

=head2 tagset

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Tagset>

=cut

__PACKAGE__->belongs_to(
  "tagset",
  "Bio::EnsEMBL::Tark::Schema::Result::Tagset",
  { tagset_id => "tagset_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 transcript

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Transcript>

=cut

__PACKAGE__->belongs_to(
  "transcript",
  "Bio::EnsEMBL::Tark::Schema::Result::Transcript",
  { transcript_id => "transcript_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qLLfTVrZmGLtL6QmCZY6KA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
