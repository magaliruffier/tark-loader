# tark-loader
# tark-loader

## Checksums

Checksums are concat of elements separated by ':' abd run through SHA1

### Gene

loc_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand

gene_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand
- stable_id
- stable_id_version

### Transcript

loc_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand

exon_set_checksum
- @exon_checksum

transcript_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand
- stable_id
- stable_id_version
- exon_set_checksum
- seq_checksum

### Exon

loc_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand

exon_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand
- stable_id
- stable_id_version
- seq_checksum

### Translation

loc_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand

translation_checksum
- assembly_id
- seq_region_name
- seq_region_start
- seq_region_end
- seq_region_strand
- stable_id
- stable_id_version
- seq_checksum
