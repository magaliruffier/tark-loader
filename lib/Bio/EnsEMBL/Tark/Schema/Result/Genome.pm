use utf8;
package Bio::EnsEMBL::Tark::Schema::Result::Genome;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Bio::EnsEMBL::Tark::Schema::Result::Genome

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

=head1 TABLE: C<genome>

=cut

__PACKAGE__->table("genome");

=head1 ACCESSORS

=head2 genome_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 tax_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 session_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "genome_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "tax_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
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

=item * L</genome_id>

=back

=cut

__PACKAGE__->set_primary_key("genome_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<genome_idx>

=over 4

=item * L</name>

=item * L</tax_id>

=back

=cut

__PACKAGE__->add_unique_constraint("genome_idx", ["name", "tax_id"]);

=head1 RELATIONS

=head2 assemblies

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::Assembly>

=cut

__PACKAGE__->has_many(
  "assemblies",
  "Bio::EnsEMBL::Tark::Schema::Result::Assembly",
  { "foreign.genome_id" => "self.genome_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 assembly_aliases

Type: has_many

Related object: L<Bio::EnsEMBL::Tark::Schema::Result::AssemblyAlias>

=cut

__PACKAGE__->has_many(
  "assembly_aliases",
  "Bio::EnsEMBL::Tark::Schema::Result::AssemblyAlias",
  { "foreign.genome_id" => "self.genome_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2019-01-22 14:34:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7U13wQ/V+hhT6UdVf4XKNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
