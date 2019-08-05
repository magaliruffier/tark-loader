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

use warnings;
use strict;

package Bio::EnsEMBL::Tark::LRG;

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

has session => (
  is  => 'rw',
  isa => 'Bio::EnsEMBL::Tark::DB',
);

sub BUILD {
    my ($self) = @_;

    $self->log()->info("Initializing LRG Name loader");

    # Attempt a connection to the database
    my $dbh = $self->session->dbh();

    # Setup the update queries
    my $sth = $dbh->prepare("UPDATE gene SET name_id=? WHERE stable_id=?") ||
	$self->log->logdie("Error UPDATEing gene: " . $DBI::errstr);
    $self->set_query('update_gene' => $sth);

    $sth = $dbh->prepare("SELECT external_id FROM gene_names WHERE source='HGNC' AND name = ? LIMIT 1") ||
	$self->log->logdie("Error selecting gene_names: $DBI::errstr");
    $self->set_query('get_gene_name' => $sth);

}

# Col 1: LRG_ID
# Col 2: HGNC_SYMBOL


sub load_lrg_names {
    my $self = shift;
    my $lrg_file = shift;

    $self->log()->info("Starting LRG Name load");

    my $in_fh;
    if($lrg_file) {
	$self->log()->info("Using LRG Gene file $lrg_file");
	my $file_handle = Bio::EnsEMBL::Tark::FileHandle->new();
	$in_fh = $file_handle->get_file_handle($lrg_file);
    } else {
	$in_fh = *STDIN;
    }

    my $get_gene_name = $self->get_query('get_gene_name');
    my $update_gene = $self->get_query('update_gene');

    while(<$in_fh>) {
    
	chomp;

	my @lrg_line = split '\t';
    next unless($lrg_line[0]=~/^LRG_/);
    
    my $lrg_stable_id = $lrg_line[0];
	my $hgnc_symbol = $lrg_line[1];
	
	# get hgnc id from gene_names using the hgnc_symbl
	# SELECT external_id FROM gene_names WHERE source='HGNC' AND name = ?
	$get_gene_name->execute( $hgnc_symbol );
    my ($external_id) = $get_gene_name->fetchrow_array;
   

    if($external_id) {
      print("Updating for " , "lrg_stable_id ", $lrg_stable_id, " External Id ", $external_id, "  hgnc symbol ", $hgnc_symbol, "\n");
	  # UPDATE gene SET name_id=? WHERE stable_id=?
	  $update_gene->execute($external_id, $lrg_stable_id);
    }
  }    
}

1;
