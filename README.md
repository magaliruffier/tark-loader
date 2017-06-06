# tark-loader
# tark-loader

## Loading an Ensembl release

To load an Ensembl species instance in to TArK, you first need a configuration file defining the release attributes and and tags the release should receive as a whole. For example, to load Human e84 instance and tag all records as 'CARS' a configuration file such as this would be used:

```
[release]
shortname=84
description=Ensembl release 84
feature_type=all

[CARS]
shortname=CARS
description=CARS clinical set
version=1
```

You would then issue the command to load the instance with:

```
perl bin/load_species.pl -c etc/release84.ini --dbuser=<TARK_DBUSER> --dbhost=<TARK_DBHOST> --dbpass=<TARK_DBPASS> --dbport=<TARK_DBPORT> --database=<TARK_DBNAME> \
--species=homo_sapiens --release 84 --enshost=<ENSEMBL_DBHOST> --ensport=<ENSEMBL_DBPORT>
```

## Checksums

Checksums are concat of elements separated by ':' and run through SHA1

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

## Todo

* Create a script to tag a list of given stable ids with a specific tag name
* Create a script to load a non-Ensembl geneset
