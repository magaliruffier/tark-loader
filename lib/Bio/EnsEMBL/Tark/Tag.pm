=head1 LICENSE

Copyright 2015 EMBL-European Bioinformatics Institute

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

use warnings;
use strict;
use DBI;
use Config::Simple;

package Bio::EnsEMBL::Tark::Tag;

use Bio::EnsEMBL::Tark::DB;

use MooseX::Singleton;
with 'MooseX::Log::Log4perl';

use Data::Dumper;

my $singleton;

has 'config_file' => ( is => 'ro', isa => 'Str' );

has 'config' => ( is => 'ro', isa => 'Ref', writer => '_config' );

has 'blocks' => ( is => 'ro', isa => 'ArrayRef[Str]', writer => '_blocks', 
                  default => sub { [] }, traits => ['Array'] );

has 'assembly_id' => ( is => 'rw', isa => 'Int' );

has 'feature_type' => (
    traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[Str]',
    default   => sub { { 'gene' => 1, 
                         'transcript' => 2,
                         'exon' => 3,
                         'translation' => 4,
                         'operon' => 5,
                     } },
    handles   => {
        get_type       => 'get',
        get_types      => 'keys'
    },
);

has 'inserts' => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
         set_insert     => 'set',
         get_insert     => 'get',
         delete_insert  => 'delete',
         clear_inserts  => 'clear',
         fetch_keys     => 'keys',
         fetch_values   =>'values',
         insert_pairs   => 'kv',
    },
);

sub initialize {
    my ($self, @args) = @_;

    # Pass the arguments to the super class to set the ro object
    $self->SUPER::initialize(@args);

    print $self->config_file();
    print "\n";

    my $cfg = new Config::Simple(filename=>$self->config_file);

    $self->_config($cfg);

    my %blocks;
    foreach my $block_var ($self->config()->param()) {
	my ($block, $var) = split '\.', $block_var;
	$blocks{$block} = 1;
    }

    my @blocks = keys %blocks;
    $self->_blocks( \@blocks );

    print "Blocks: " . join( ',', $self->config()->param()) . "\n";
    print "Blocks: " . join( ',', @{$self->blocks()} ) . "\n";

}

sub init_tags {
    my ($self, $assembly_id) = @_;

    $self->assembly_id($assembly_id);

    foreach my $block (@{$self->blocks()}) {
	$self->fetch_tag($block);
    }
}

sub tag_feature {
    my ($self, $feature_id, $feature_type) = @_;

    foreach my $tag (@{$self->blocks()}) {
	my $sth = $self->get_insert($tag);

	next if($feature_type ne 'transcript' && $tag ne 'release');

	my @vals = ( $feature_id );
	push(@vals, $self->get_type($feature_type)) if($tag eq 'release');
	$sth->execute(@vals);
    }
}

sub fetch_tag {
    my ($self, $tag) = @_;

    my $shortname = $self->config()->param("$tag.shortname");
    my $desc = $self->config()->param("$tag.description");

    my $assembly_field = ''; my $assembly_val = ''; my $table = 'tagset'; my $keycol = 'tagset';
    my $tag_table = ''; my $feature_col = 'transcript_id'; my $feature_val = '';
    if($tag eq 'release') {
	$assembly_field = 'assembly_id, release_date,';
	$assembly_val = $self->assembly_id() . ', NOW(),';
	$table = 'release_set';
	$keycol = 'release';
	$tag_table = 'release_';
	$feature_col = 'feature_id, feature_type';
	$feature_val = '?,';
    }

    my $dbh = Bio::EnsEMBL::Tark::DB->dbh();
    my $session_id = Bio::EnsEMBL::Tark::DB->session_id();

    my $sth = $dbh->prepare("INSERT INTO $table (shortname, description, $assembly_field session_id) VALUES (?, ?, $assembly_val $session_id) ON DUPLICATE KEY UPDATE ${keycol}_id=LAST_INSERT_ID(${keycol}_id)");

    # Create or find the release
    $sth->execute($shortname, $desc);
    my $tag_id = $sth->{mysql_insertid};

    # Save the release_id for later
    $self->config()->param("$tag.id", $tag_id);

    # Create the insert statement for later
    $sth = $dbh->prepare("INSERT INTO " . $tag_table . "tag ($feature_col, ${keycol}_id, session_id) VALUES (?, $feature_val $tag_id, $session_id)");
    $self->set_insert($tag => $sth);

}

1;
