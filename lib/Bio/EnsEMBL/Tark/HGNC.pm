=head1 LICENSE

Copyright 2016 EMBL-European Bioinformatics Institute

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

package Bio::EnsEMBL::Tark::HGNC;

use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::FileHandle;

use Moose;
with 'MooseX::Log::Log4perl';

has 'query' => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
         set_query     => 'set',
         get_query     => 'get',
         delete_query  => 'delete',
         clear_queries => 'clear',
         fetch_keys    => 'keys',
         fetch_values  =>'values',
         query_pairs   => 'kv',
    },
);

has 'session_id' => ( is => 'ro', isa => 'Int' );

sub BUILD {
    my ($self) = @_;

    $self->log()->info("Initializing HGNC loader");

    # Attempt a connection to the database
    my $dbh = Bio::EnsEMBL::Tark::DB->dbh();

    # Setup the insert queries
    my $sth = $dbh->prepare("INSERT INTO gene_names (external_id, name, source, primary_id, session_id) VALUES (?, ?, 'HGNC', ?, ?)") ||
	$self->log->logdie("Error creating gene name insert: " . $DBI::errstr);
    $self->set_query('hgnc' => $sth);

    $sth = $dbh->prepare("SELECT gene_id, assembly_id FROM gene WHERE stable_id = ?") ||
	$self->log->logdie("Error creating gene select: $DBI::errstr");
    $self->set_query('gene' => $sth);

}

sub flush_hgnc {
    my $self = shift;

    $self->log()->info("Truncating gene names table");

    my $dbh = Bio::EnsEMBL::Tark::DB->dbh();

    $dbh->do("TRUNCATE gene_names");
}

# Col 1: hgnc_id
# Col 2: symbol/name
# Col 9: alias_symbols
# Col 20: ensembl_gene_id
# (counting from 1)

sub load_hgnc {
    my $self = shift;
    my $hgnc_file = shift;

    $self->log()->info("Starting HGNC load");

    my $in_fh;
    if($hgnc_file) {
	$self->log()->info("Using HGNC file $hgnc_file");
	$in_fh = Bio::EnsEMBL::Tark::FileHandle->open($hgnc_file);
    } else {
	$in_fh = *STDIN;
    }

    my $get_gene = $self->get_query('gene');
    my $insert_hgnc = $self->get_query('hgnc');

    while(<$in_fh>) {
	chomp;

	my @hgnc_line = split '\t';

	# If there's no ensembl id, skip
#	next unless($hgnc_line[19]);

	my (undef, $hgnc_id) = split ':', $hgnc_line[0];

	# Insert the hgnc symbol
	$insert_hgnc->execute($hgnc_id, $hgnc_line[1], 1, $self->session_id);

	# Add any synomyms
	next unless($hgnc_line[8]);

	$hgnc_line[8] =~ s/^"//;
	$hgnc_line[8] =~ s/"$//;
	my @aliases = split '\|', $hgnc_line[8];
	foreach my $alias (@aliases) {
	    $insert_hgnc->execute($hgnc_id, $alias, 0, $self->session_id);
		
	}
    }

}

1;
