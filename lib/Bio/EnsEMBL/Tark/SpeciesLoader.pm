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
package Bio::EnsEMBL::Tark::SpeciesLoader;

use Bio::EnsEMBL::Tark::DB;
use Bio::EnsEMBL::Tark::Tag;

use Moose;
with 'MooseX::Log::Log4perl';

has 'dsn' => ( is => 'ro', isa => 'Str' );

has 'dbuser' => ( is => 'ro', isa => 'Str' );

has 'dbpass' => ( is => 'ro', isa => 'Str' );

has 'query' => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
         set_query     => 'set',
         get_insert     => 'get',
         delete_query  => 'delete',
         clear_queries => 'clear',
         fetch_keys    => 'keys',
         fetch_values  =>'values',
         query_pairs   => 'kv',
    },
);

sub BUILD {
    my ($self) = @_;

    $self->log()->info("Initializing species loader");

    # Attempt a connection to the database
    my $dbh = Bio::EnsEMBL::Tark::DB->dbh();

    # Setup the insert queries
    my $sth = $dbh->prepare("INSERT INTO genome (name, tax_id, session_id) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE genome_id=LAST_INSERT_ID(genome_id)") or
	$self->log->logdie("Error creating genome insert: $DBI::errstr");
    $self->set_query('genome' => $sth);

    $sth = $dbh->prepare("INSERT INTO assembly (genome_id, assembly_name, session_id) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE assembly_id=LAST_INSERT_ID(assembly_id)");
    $self->set_query('assembly' => $sth);

    $sth = $dbh->prepare("INSERT INTO assembly_alias (genome_id, assembly_id, alias, session_id) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE assembly_id=LAST_INSERT_ID(assembly_id)");
    $self->set_query('assembly_alias' => $sth);

    $sth = $dbh->prepare("INSERT INTO gene (stable_id, stable_id_version, assembly_id, loc_region, loc_start, loc_end, loc_strand, loc_checksum, hgnc_id, gene_checksum, session_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE gene_id=LAST_INSERT_ID(gene_id)");
    $self->set_query('gene' => $sth);

    $sth = $dbh->prepare("INSERT INTO transcript_gene (gene_id, transcript_id, session_id) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE transcript_gene_id=LAST_INSERT_ID(transcript_gene_id)");
    $self->set_query('transcript_gene' => $sth);

    $sth = $dbh->prepare("INSERT INTO transcript (stable_id, stable_id_version, assembly_id, loc_region, loc_start, loc_end, loc_strand, loc_checksum, transcript_checksum, exon_set_checksum, seq_checksum, gene_id, session_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE transcript_id=LAST_INSERT_ID(transcript_id)");
    $self->set_query('transcript' => $sth);

    $sth = $dbh->prepare("INSERT INTO exon_transcript (transcript_id, exon_id, exon_order, session_id) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE exon_transcript_id=LAST_INSERT_ID(exon_transcript_id)");
    $self->set_query('exon_transcript' => $sth);

    $sth = $dbh->prepare("INSERT INTO exon (stable_id, stable_id_version, assembly_id, loc_region, loc_start, loc_end, loc_strand, loc_checksum, exon_checksum, seq_checksum, session_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE exon_id=LAST_INSERT_ID(exon_id)");
    $self->set_query('exon' => $sth);

    $sth = $dbh->prepare("INSERT INTO translation (stable_id, stable_id_version, assembly_id, loc_region, loc_start, loc_end, loc_strand, loc_checksum, translation_checksum, seq_checksum, transcript_id, session_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE translation_id=LAST_INSERT_ID(translation_id)");
    $self->set_query('translation' => $sth);

    $sth = $dbh->prepare("INSERT IGNORE INTO sequence (seq_checksum, sequence, session_id) VALUES (?, ?, ?)");
    $self->set_query('sequence' => $sth);

    return;
}

sub load_species {
    my $self = shift;
    my $dba = shift;

    my $session_id = Bio::EnsEMBL::Tark::DB->session_id;

    $self->log->info("Starting loading process");

    my $mc = $dba->get_MetaContainer();
    my $species = $mc->get_production_name();
    $self->log->info("Storing genome for $species");

    my $sth = $self->get_insert('genome');
    $sth->execute($species, $mc->get_taxonomy_id() + 0, $session_id) or
	$self->log->logdie("Error inserting genome: $DBI::errstr");
    my $genome_id = $sth->{mysql_insertid};
    $sth = $self->get_insert('assembly');
    my $assembly_accession = $mc->single_value_by_key('assembly.accession');
    my $assembly_name = $mc->single_value_by_key('assembly.default');
#    my ($accession, $acc_ver) = split '\.', $assembly_accession;
#    $acc_ver ||= 1;
    $self->log->info("Inserting assembly $assembly_name");
    $sth->execute($genome_id, $assembly_name, $session_id) or
	$self->log->logdie("Error inserting assembly: $DBI::errstr");
    my $assembly_id = $sth->{mysql_insertid};
    $self->log->info("Using assembly_id $assembly_id");

    $sth = $self->get_insert('assembly_alias');
    $sth->execute($genome_id, $assembly_id, $assembly_accession, $session_id) or
	$self->log->logdie("Error inserting assembly_alias: $DBI::errstr");


    # Initialize the tags we'll be using
    Bio::EnsEMBL::Tark::Tag->init_tags($assembly_id);

    my $session_pkg = { session_id => $session_id,
			genome_id => $genome_id,
			assembly_id => $assembly_id
    };

    # Fetch a gene iterator and cycle through loading the genes
    my $iter = $self->genes_to_metadata_iterator($dba);
    while ( my $gene = $iter->next() ) {
	$self->log->debug( "Loading gene " . $gene->{stable_id} );
	$self->_load_gene($gene, $session_pkg);
    }
    $self->log->info( "Completed dumping genes for " . $species );

    $self->log->info( "Tagging sets for " . $species );
    Bio::EnsEMBL::Tark::Tag->checksum_sets();

    $self->log->info( "Completed tagging sets for " . $species );

}

sub _load_gene {
    my ( $self, $gene, $session_pkg ) = @_;

    my @loc_pieces = ( $session_pkg->{assembly_id}, $gene->seq_region_name(),
		       $gene->seq_region_start(), $gene->seq_region_end(), $gene->seq_region_strand() );
    my $loc_checksum = Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces );
    my $hgnc_id = $self->_fetch_hgnc_id($gene);
    my $gene_checksum = Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces,
								$gene->stable_id(), $gene->version() );

    my $sth = $self->get_insert('gene');
    $sth->execute( $gene->stable_id(), $gene->version(), @loc_pieces, $loc_checksum, ($hgnc_id ? $hgnc_id : undef), $gene_checksum, $session_pkg->{session_id} ) or
	$self->log->logdie("Error inserting gene: $DBI::errstr");
    my $gene_id = $sth->{mysql_insertid};

    # Apply tags to feature we've just inserted
    Bio::EnsEMBL::Tark::Tag->tag_feature($gene_id, 'gene');

    my $exons = {};
    $session_pkg->{gene_id} = $gene_id;
    for my $transcript ( @{ $gene->get_all_Transcripts() } ) {

	my @exon_checksums; my @exon_ids;
	for my $exon (@{ $transcript->get_all_Exons() }) {
	    my ($exon_id, $exon_checksum) = $self->_load_exon( $exon, $session_pkg );
	    push @exon_checksums, $exon_checksum;
	    push @exon_ids, $exon_id;
	}

	if( @exon_checksums ) {
	    $session_pkg->{exon_set_checksum} =  Bio::EnsEMBL::Tark::DB->checksum_array( @exon_checksums );
	}

	my $transcript_id = $self->_load_transcript( $transcript, $session_pkg );

	my $exon_order = 1;
	for my $exon_id (@exon_ids) {
	    $sth = $self->get_insert('exon_transcript');
	    $sth->execute($transcript_id, $exon_id, $exon_order, $session_pkg->{session_id}) or
		$self->log->logdie("Error inserting exon_transcript: $DBI::errstr");
	    $exon_order++;
	}

	$session_pkg->{transcript_id} = $transcript_id;
	$session_pkg->{transcript} = $transcript;

	my $translation = $transcript->translation();
	if ( defined $translation ) {
	    $self->_load_translation( $translation, $session_pkg );
	}

	delete $session_pkg->{transcript_id};
	delete $session_pkg->{transcript};

    }

}

sub _load_transcript {
    my ($self, $transcript, $session_pkg) = @_;

    # Insert the sequence and get back the checksum
    my $seq_obj = $transcript->seq();
    my $seq_checksum;
    if($seq_obj) {
	$seq_checksum = $self->_insert_sequence($seq_obj->seq(), $session_pkg->{session_id});
    }

    my @loc_pieces = ( $session_pkg->{assembly_id}, $transcript->seq_region_name(),
		       $transcript->seq_region_start(), $transcript->seq_region_end(), 
		       $transcript->seq_region_strand() );
    my $loc_checksum =  Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces );
    my $transcript_checksum =  Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces, $transcript->stable_id(), $transcript->version(),
						     ($session_pkg->{exon_set_checksum} ? $session_pkg->{exon_set_checksum} : undef),
						     $seq_checksum );

    my $sth = $self->get_insert('transcript');
    $sth->execute( $transcript->stable_id(), $transcript->version(), @loc_pieces, $loc_checksum, $transcript_checksum, 
		   ($session_pkg->{exon_set_checksum} ? $session_pkg->{exon_set_checksum} : undef), 
		   $seq_checksum, $session_pkg->{session_id} ) or
		       $self->log->logdie("Error inserting transcript: $DBI::errstr");
    my $transcript_id = $sth->{mysql_insertid};

    $sth = $self->get_insert('transcript_gene');
    $sth->execute( $session_pkg->{gene_id}, $transcript_id, $session_pkg->{session_id} ) or
	$self->log->logdie("Error inserting transcript_gene: $DBI::errstr");

    # Apply tags to feature we've just inserted
    Bio::EnsEMBL::Tark::Tag->tag_feature($transcript_id, 'transcript');

    return $transcript_id;
}

sub _load_exon {
    my ($self, $exon, $session_pkg) = @_;

    # Insert the sequence and get back the checksum
    my $seq_obj = $exon->seq();
    my $seq_checksum;
    if($seq_obj) {
	$seq_checksum = $self->_insert_sequence($seq_obj->seq(), $session_pkg->{session_id});
    }

    my @loc_pieces = ( $session_pkg->{assembly_id},$exon->seq_region_name(),
		       $exon->seq_region_start(), $exon->seq_region_end(), 
		       $exon->seq_region_strand() );
    my $loc_checksum =  Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces );
    my $exon_checksum =  Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces, $exon->stable_id(), $exon->version(), $seq_checksum );

    my $sth = $self->get_insert('exon');
    $sth->execute( @loc_pieces, $loc_checksum, $exon_checksum, $seq_checksum, $session_pkg->{session_id} ) or
	$self->log->logdie("Error inserting exon: $DBI::errstr");
    my $exon_id = $sth->{mysql_insertid};

    # Apply tags to feature we've just inserted
    Bio::EnsEMBL::Tark::Tag->tag_feature($exon_id, 'exon');

    return ($exon_id, $exon_checksum);
}

sub _load_translation {
    my ($self, $translation, $session_pkg) = @_;

    # Insert the sequence and get back the checksum
    my $seq_checksum = $self->_insert_sequence($translation->seq(), $session_pkg->{session_id});

    my @loc_pieces = ( $session_pkg->{assembly_id},$session_pkg->{transcript}->seq_region_name(),
		       $translation->genomic_start(), $translation->genomic_end(),
		       $session_pkg->{transcript}->seq_region_strand() );

    my $loc_checksum =  Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces );
    my $translation_checksum =  Bio::EnsEMBL::Tark::DB->checksum_array( @loc_pieces, $translation->stable_id(), $translation->version(), $seq_checksum );

    my $sth = $self->get_insert('translation');
    $sth->execute( @loc_pieces, $loc_checksum, $translation_checksum, $seq_checksum, $session_pkg->{transcript_id}, $session_pkg->{session_id} ) or
	$self->log->logdie("Error inserting translation: $DBI::errstr");
    my $translation_id = $sth->{mysql_insertid};

    # Apply tags to feature we've just inserted
    Bio::EnsEMBL::Tark::Tag->tag_feature($translation_id, 'translation');
    
}

sub _insert_sequence {
    my ( $self, $sequence, $session_id ) = @_;

    my $sha1 =  Bio::EnsEMBL::Tark::DB->checksum_array($sequence);

    my $sth = $self->get_insert('sequence');
    $sth->execute($sha1, $sequence, $session_id) or
	$self->log->logdie("Error inserting sequence: $DBI::errstr");

    return $sha1;
    
}

sub _fetch_hgnc_id {
    my ( $self, $gene ) = @_;

    foreach my $oxref (@{ $gene->get_all_object_xrefs() }) {
	next unless($oxref->dbname eq 'HGNC');
	my (undef, $hgnc_id) = split ':', $oxref->primary_id;
	return $hgnc_id;
    }
}

sub genes_to_metadata_iterator {
	my ( $self, $dba ) = @_;
	my $ga           = $dba->get_GeneAdaptor();
	my $gene_ids     = $ga->_list_dbIDs('gene');
	my $len          = scalar(@$gene_ids);
	my $current_gene = 0;
	my $genes_i      = Bio::EnsEMBL::Utils::Iterator->new(
		sub {
			if ( $current_gene >= $len ) {
				return undef;
			}
			else {
				my $gene = $ga->fetch_by_dbID( $gene_ids->[ $current_gene++ ] );
				return $gene;
			}
		}
	);
	return $genes_i;
}

1;
