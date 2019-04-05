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

package Bio::EnsEMBL::Tark::Schema::Result::ReleaseStats;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::ReleaseSource

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

=head1 TABLE: C<release_stats>

=cut

__PACKAGE__->table("release_stats");

=head1 ACCESSORSCREATE TABLE release_stats (
  release_stats_id integer unsigned NOT NULL,
  release_id integer unsigned NOT NULL,
  json text NULL,
  INDEX release_stats_idx_release_id (release_id),
  PRIMARY KEY (release_stats_id),
  CONSTRAINT release_stats_fk_release_id FOREIGN KEY (release_id) REFERENCES release_set (release_id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB

=head2 release_stats_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 release_id

  data_type: 'varchar'
  is_nullable: 1
  size: 24

=head2 json

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=cut

__PACKAGE__->add_columns(
  "release_stats_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "release_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "json",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</release_stats_id>

=back

=cut

__PACKAGE__->set_primary_key("release_stats_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<release_idx>

=over 4

=item * L</release_id>

=back

=cut

__PACKAGE__->add_unique_constraint("release_idx", ["release_id"]);

=head1 RELATIONS

=head2 release_set

Type: belongs_to

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet>

=cut

__PACKAGE__->belongs_to(
  "release_set",
  "Bio::EnsEMBL::Tark::Schema::Result::ReleaseSet",
  { release_id => "release_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zxQttTG7klfBXtUwgDIIWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
