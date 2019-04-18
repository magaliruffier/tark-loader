-- MySQL dump 10.13  Distrib 5.7.25, for Linux (x86_64)
--
-- Host: localhost    Database: mcdowall_tark_test_9242
-- ------------------------------------------------------
-- Server version	5.7.25-0ubuntu0.16.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `assembly`
--

DROP TABLE IF EXISTS `assembly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assembly` (
  `assembly_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `genome_id` int(10) unsigned DEFAULT NULL,
  `assembly_name` varchar(128) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`assembly_id`),
  UNIQUE KEY `assembly_idx` (`assembly_name`),
  KEY `assembly_idx_genome_id` (`genome_id`),
  KEY `assembly_idx_session_id` (`session_id`),
  KEY `fk_assembly_1_idx` (`genome_id`),
  KEY `fk_assembly_2_idx` (`session_id`),
  CONSTRAINT `assembly_fk_genome_id` FOREIGN KEY (`genome_id`) REFERENCES `genome` (`genome_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `assembly_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assembly_alias`
--

DROP TABLE IF EXISTS `assembly_alias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assembly_alias` (
  `assembly_alias_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `alias` varchar(64) DEFAULT NULL,
  `genome_id` int(10) unsigned DEFAULT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`assembly_alias_id`),
  UNIQUE KEY `alias_idx` (`alias`),
  KEY `assembly_alias_idx_assembly_id` (`assembly_id`),
  KEY `assembly_alias_idx_genome_id` (`genome_id`),
  KEY `assembly_alias_idx_session_id` (`session_id`),
  CONSTRAINT `assembly_alias_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `assembly_alias_fk_genome_id` FOREIGN KEY (`genome_id`) REFERENCES `genome` (`genome_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `assembly_alias_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exon`
--

DROP TABLE IF EXISTS `exon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exon` (
  `exon_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) NOT NULL,
  `stable_id_version` tinyint(3) unsigned NOT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `loc_start` int(10) unsigned DEFAULT NULL,
  `loc_end` int(10) unsigned DEFAULT NULL,
  `loc_strand` tinyint(4) DEFAULT NULL,
  `loc_region` varchar(42) DEFAULT NULL,
  `loc_checksum` binary(20) DEFAULT NULL,
  `exon_checksum` binary(20) DEFAULT NULL,
  `seq_checksum` binary(20) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`exon_id`),
  UNIQUE KEY `exon_chk` (`exon_checksum`),
  KEY `exon_idx_assembly_id` (`assembly_id`),
  KEY `exon_idx_seq_checksum` (`seq_checksum`),
  KEY `exon_idx_session_id` (`session_id`),
  KEY `stable_id` (`stable_id`,`stable_id_version`),
  CONSTRAINT `exon_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `exon_fk_seq_checksum` FOREIGN KEY (`seq_checksum`) REFERENCES `sequence` (`seq_checksum`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `exon_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exon_release_tag`
--

DROP TABLE IF EXISTS `exon_release_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exon_release_tag` (
  `feature_id` int(10) unsigned NOT NULL,
  `release_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`feature_id`,`release_id`),
  KEY `exon_release_tag_idx_feature_id` (`feature_id`),
  KEY `exon_release_tag_idx_release_id` (`release_id`),
  CONSTRAINT `exon_release_tag_fk_feature_id` FOREIGN KEY (`feature_id`) REFERENCES `exon` (`exon_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `exon_release_tag_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release_set` (`release_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exon_transcript`
--

DROP TABLE IF EXISTS `exon_transcript`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exon_transcript` (
  `exon_transcript_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `transcript_id` int(10) unsigned DEFAULT NULL,
  `exon_id` int(10) unsigned DEFAULT NULL,
  `exon_order` smallint(5) unsigned DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`exon_transcript_id`),
  UNIQUE KEY `transcript_exon_idx` (`transcript_id`,`exon_id`),
  KEY `exon_transcript_idx_exon_id` (`exon_id`),
  KEY `exon_transcript_idx_session_id` (`session_id`),
  KEY `exon_transcript_idx_transcript_id` (`transcript_id`),
  CONSTRAINT `exon_transcript_fk_exon_id` FOREIGN KEY (`exon_id`) REFERENCES `exon` (`exon_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `exon_transcript_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `exon_transcript_fk_transcript_id` FOREIGN KEY (`transcript_id`) REFERENCES `transcript` (`transcript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene`
--

DROP TABLE IF EXISTS `gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene` (
  `gene_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) NOT NULL,
  `stable_id_version` tinyint(3) unsigned NOT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `loc_start` int(10) unsigned DEFAULT NULL,
  `loc_end` int(10) unsigned DEFAULT NULL,
  `loc_strand` tinyint(4) DEFAULT NULL,
  `loc_region` varchar(42) DEFAULT NULL,
  `loc_checksum` binary(20) DEFAULT NULL,
  `name_id` varchar(32) DEFAULT NULL,
  `gene_checksum` binary(20) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`gene_id`),
  UNIQUE KEY `gene_checksum_idx` (`gene_checksum`),
  KEY `gene_idx_assembly_id` (`assembly_id`),
  KEY `gene_idx_session_id` (`session_id`),
  KEY `name_id` (`name_id`),
  KEY `stable_id` (`stable_id`,`stable_id_version`),
  CONSTRAINT `gene_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `gene_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene_names`
--

DROP TABLE IF EXISTS `gene_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_names` (
  `gene_names_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(32) DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `source` varchar(32) DEFAULT NULL,
  `primary_id` tinyint(4) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`gene_names_id`),
  KEY `gene_names_idx_external_id` (`external_id`),
  KEY `gene_names_idx_session_id` (`session_id`),
  KEY `name_idx` (`name`),
  KEY `external_id_idx` (`external_id`),
  KEY `source_idx` (`source`),
  CONSTRAINT `gene_names_fk_external_id` FOREIGN KEY (`external_id`) REFERENCES `gene` (`name_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `gene_names_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gene_release_tag`
--

DROP TABLE IF EXISTS `gene_release_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene_release_tag` (
  `feature_id` int(10) unsigned NOT NULL,
  `release_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`feature_id`,`release_id`),
  KEY `gene_release_tag_idx_feature_id` (`feature_id`),
  KEY `gene_release_tag_idx_release_id` (`release_id`),
  CONSTRAINT `gene_release_tag_fk_feature_id` FOREIGN KEY (`feature_id`) REFERENCES `gene` (`gene_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `gene_release_tag_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release_set` (`release_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `genome`
--

DROP TABLE IF EXISTS `genome`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `genome` (
  `genome_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `tax_id` int(10) unsigned DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`genome_id`),
  UNIQUE KEY `genome_idx` (`name`,`tax_id`),
  KEY `genome_idx_session_id` (`session_id`),
  KEY `fk_genome_1_idx` (`session_id`),
  CONSTRAINT `genome_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `operon`
--

DROP TABLE IF EXISTS `operon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operon` (
  `operon_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) DEFAULT NULL,
  `stable_id_version` tinyint(3) unsigned DEFAULT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `loc_start` int(10) unsigned DEFAULT NULL,
  `loc_end` int(10) unsigned DEFAULT NULL,
  `loc_strand` tinyint(4) DEFAULT NULL,
  `loc_region` varchar(42) DEFAULT NULL,
  `operon_checksum` binary(20) DEFAULT NULL,
  `seq_checksum` binary(20) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`operon_id`),
  KEY `operon_idx_assembly_id` (`assembly_id`),
  KEY `operon_idx_seq_checksum` (`seq_checksum`),
  KEY `operon_idx_session_id` (`session_id`),
  KEY `stable_id` (`stable_id`,`stable_id_version`),
  CONSTRAINT `operon_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `operon_fk_seq_checksum` FOREIGN KEY (`seq_checksum`) REFERENCES `sequence` (`seq_checksum`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `operon_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `operon_transcript`
--

DROP TABLE IF EXISTS `operon_transcript`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operon_transcript` (
  `operon_transcript_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) DEFAULT NULL,
  `stable_id_version` int(10) unsigned DEFAULT NULL,
  `operon_id` int(10) unsigned DEFAULT NULL,
  `transcript_id` int(10) unsigned DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`operon_transcript_id`),
  UNIQUE KEY `operon_transcript_idx` (`operon_id`,`transcript_id`),
  KEY `operon_transcript_idx_operon_id` (`operon_id`),
  KEY `operon_transcript_idx_session_id` (`session_id`),
  KEY `operon_transcript_idx_transcript_id` (`transcript_id`),
  KEY `stable_id` (`stable_id`,`stable_id_version`),
  CONSTRAINT `operon_transcript_fk_operon_id` FOREIGN KEY (`operon_id`) REFERENCES `operon` (`operon_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `operon_transcript_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `operon_transcript_fk_transcript_id` FOREIGN KEY (`transcript_id`) REFERENCES `transcript` (`transcript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_set`
--

DROP TABLE IF EXISTS `release_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `release_set` (
  `release_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortname` varchar(24) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `release_date` date DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  `release_checksum` binary(20) DEFAULT NULL,
  `source_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`release_id`),
  UNIQUE KEY `shortname_assembly_source_idx` (`shortname`,`assembly_id`,`source_id`),
  KEY `release_set_idx_assembly_id` (`assembly_id`),
  KEY `release_set_idx_session_id` (`session_id`),
  KEY `release_set_idx_source_id` (`source_id`),
  CONSTRAINT `release_set_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `release_set_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `release_set_fk_source_id` FOREIGN KEY (`source_id`) REFERENCES `release_source` (`source_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_source`
--

DROP TABLE IF EXISTS `release_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `release_source` (
  `source_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortname` varchar(24) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`source_id`),
  UNIQUE KEY `shortname_idx` (`shortname`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

INSERT INTO release_source(`shortname`, `description`) VALUES ('Ensembl', 'Ensembl data imports from Human Core DBs');
INSERT INTO release_source(`shortname`, `description`) VALUES ('RefSeq', 'RefSeq data imports from Human otherfeatures DBs');
INSERT INTO release_source(`shortname`, `description`) VALUES ('LRG', 'Locus Reference Genomic records');


--
-- Table structure for table `release_stats`
--

DROP TABLE IF EXISTS `release_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `release_stats` (
  `release_stats_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `release_id` int(10) unsigned DEFAULT NULL,
  `json` longtext,
  PRIMARY KEY (`release_stats_id`),
  UNIQUE KEY `release_idx` (`release_id`),
  KEY `release_stats_idx_release_id` (`release_id`),
  CONSTRAINT `release_stats_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release_set` (`release_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_tag`
--

DROP TABLE IF EXISTS `release_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `release_tag` (
  `feature_id` int(10) unsigned NOT NULL,
  `feature_type` tinyint(3) unsigned NOT NULL,
  `release_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`feature_id`,`feature_type`,`release_id`),
  KEY `release_tag_idx_release_id` (`release_id`),
  KEY `release_tag_idx_session_id` (`session_id`),
  CONSTRAINT `release_tag_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release_set` (`release_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `release_tag_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sequence`
--

DROP TABLE IF EXISTS `sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sequence` (
  `seq_checksum` binary(20) NOT NULL,
  `sequence` longtext,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`seq_checksum`),
  KEY `sequence_idx_session_id` (`session_id`),
  CONSTRAINT `sequence_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `session_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `client_id` varchar(128) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `transcript_id` int(10) unsigned NOT NULL,
  `tagset_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`transcript_id`,`tagset_id`),
  KEY `tag_idx_session_id` (`session_id`),
  KEY `tag_idx_tagset_id` (`tagset_id`),
  KEY `tag_idx_transcript_id` (`transcript_id`),
  CONSTRAINT `tag_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `tag_fk_tagset_id` FOREIGN KEY (`tagset_id`) REFERENCES `tagset` (`tagset_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `tag_fk_transcript_id` FOREIGN KEY (`transcript_id`) REFERENCES `transcript` (`transcript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tagset`
--

DROP TABLE IF EXISTS `tagset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tagset` (
  `tagset_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortname` varchar(45) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `version` varchar(20) DEFAULT '1',
  `is_current` tinyint(4) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  `tagset_checksum` binary(20) DEFAULT NULL,
  PRIMARY KEY (`tagset_id`),
  UNIQUE KEY `name_version_idx` (`shortname`,`version`),
  KEY `tagset_idx_session_id` (`session_id`),
  CONSTRAINT `tagset_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcript`
--

DROP TABLE IF EXISTS `transcript`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcript` (
  `transcript_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) NOT NULL,
  `stable_id_version` tinyint(3) unsigned NOT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `loc_start` int(10) unsigned DEFAULT NULL,
  `loc_end` int(10) unsigned DEFAULT NULL,
  `loc_strand` tinyint(4) DEFAULT NULL,
  `loc_region` varchar(42) DEFAULT NULL,
  `loc_checksum` binary(20) DEFAULT NULL,
  `exon_set_checksum` binary(20) DEFAULT NULL,
  `transcript_checksum` binary(20) DEFAULT NULL,
  `seq_checksum` binary(20) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`transcript_id`),
  UNIQUE KEY `transcript_chk` (`transcript_checksum`),
  KEY `transcript_idx_assembly_id` (`assembly_id`),
  KEY `transcript_idx_seq_checksum` (`seq_checksum`),
  KEY `transcript_idx_session_id` (`session_id`),
  KEY `stable_id` (`stable_id`,`stable_id_version`),
  CONSTRAINT `transcript_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `transcript_fk_seq_checksum` FOREIGN KEY (`seq_checksum`) REFERENCES `sequence` (`seq_checksum`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `transcript_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcript_gene`
--

DROP TABLE IF EXISTS `transcript_gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcript_gene` (
  `gene_transcript_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gene_id` int(10) unsigned DEFAULT NULL,
  `transcript_id` int(10) unsigned DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`gene_transcript_id`),
  UNIQUE KEY `transcript_gene_idx` (`gene_id`,`transcript_id`),
  KEY `transcript_gene_idx_gene_id` (`gene_id`),
  KEY `transcript_gene_idx_session_id` (`session_id`),
  KEY `transcript_gene_idx_transcript_id` (`transcript_id`),
  CONSTRAINT `transcript_gene_fk_gene_id` FOREIGN KEY (`gene_id`) REFERENCES `gene` (`gene_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `transcript_gene_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `transcript_gene_fk_transcript_id` FOREIGN KEY (`transcript_id`) REFERENCES `transcript` (`transcript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transcript_release_tag`
--

DROP TABLE IF EXISTS `transcript_release_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transcript_release_tag` (
  `feature_id` int(10) unsigned NOT NULL,
  `release_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`feature_id`,`release_id`),
  KEY `transcript_release_tag_idx_feature_id` (`feature_id`),
  KEY `transcript_release_tag_idx_release_id` (`release_id`),
  CONSTRAINT `transcript_release_tag_fk_feature_id` FOREIGN KEY (`feature_id`) REFERENCES `transcript` (`transcript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `transcript_release_tag_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release_set` (`release_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `translation`
--

DROP TABLE IF EXISTS `translation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translation` (
  `translation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stable_id` varchar(64) NOT NULL,
  `stable_id_version` tinyint(3) unsigned NOT NULL,
  `assembly_id` int(10) unsigned DEFAULT NULL,
  `loc_start` int(10) unsigned DEFAULT NULL,
  `loc_end` int(10) unsigned DEFAULT NULL,
  `loc_strand` tinyint(4) DEFAULT NULL,
  `loc_region` varchar(42) DEFAULT NULL,
  `loc_checksum` binary(20) DEFAULT NULL,
  `translation_checksum` binary(20) DEFAULT NULL,
  `seq_checksum` binary(20) DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`translation_id`),
  UNIQUE KEY `translation_chk` (`translation_checksum`),
  KEY `translation_idx_assembly_id` (`assembly_id`),
  KEY `translation_idx_seq_checksum` (`seq_checksum`),
  KEY `translation_idx_session_id` (`session_id`),
  KEY `stable_id` (`stable_id`,`stable_id_version`),
  CONSTRAINT `translation_fk_assembly_id` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `translation_fk_seq_checksum` FOREIGN KEY (`seq_checksum`) REFERENCES `sequence` (`seq_checksum`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `translation_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `translation_release_tag`
--

DROP TABLE IF EXISTS `translation_release_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translation_release_tag` (
  `feature_id` int(10) unsigned NOT NULL,
  `release_id` int(10) unsigned NOT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`feature_id`,`release_id`),
  KEY `translation_release_tag_idx_feature_id` (`feature_id`),
  KEY `translation_release_tag_idx_release_id` (`release_id`),
  CONSTRAINT `translation_release_tag_fk_feature_id` FOREIGN KEY (`feature_id`) REFERENCES `translation` (`translation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `translation_release_tag_fk_release_id` FOREIGN KEY (`release_id`) REFERENCES `release_set` (`release_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `translation_transcript`
--

DROP TABLE IF EXISTS `translation_transcript`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `translation_transcript` (
  `transcript_translation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `transcript_id` int(10) unsigned DEFAULT NULL,
  `translation_id` int(10) unsigned DEFAULT NULL,
  `session_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`transcript_translation_id`),
  UNIQUE KEY `transcript_translation_idx` (`transcript_id`,`translation_id`),
  KEY `translation_transcript_idx_session_id` (`session_id`),
  KEY `translation_transcript_idx_transcript_id` (`transcript_id`),
  KEY `translation_transcript_idx_translation_id` (`translation_id`),
  CONSTRAINT `translation_transcript_fk_session_id` FOREIGN KEY (`session_id`) REFERENCES `session` (`session_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `translation_transcript_fk_transcript_id` FOREIGN KEY (`transcript_id`) REFERENCES `transcript` (`transcript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `translation_transcript_fk_translation_id` FOREIGN KEY (`translation_id`) REFERENCES `translation` (`translation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-04-08  8:28:46
