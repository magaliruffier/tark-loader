--Statements to clean LRG
DELETE from exon_release_tag where feature_id in (SELECT exon_id from exon e where e.stable_id like "LRG%");
DELETE from exon_transcript  where exon_id in (SELECT exon_id from exon  e where e.stable_id like "LRG%");
DELETE from exon where stable_id like "LRG%";

DELETE from gene_release_tag where feature_id in(SELECT gene_id from gene g where g.stable_id like "LRG%");
DELETE from transcript_release_tag where feature_id in (SELECT transcript_id from transcript t  where t.stable_id like "LRG%");
DELETE from transcript_gene where transcript_id in(SELECT transcript_id  from transcript t where t.stable_id like "LRG%");

DELETE from translation_release_tag where feature_id in (SELECT translation_id from translation t where t.stable_id like "LRG%");
DELETE from translation_transcript where translation_id in (SELECT translation_id from translation t  where t.stable_id like "LRG%");

truncate gene_names;

DELETE from gene where stable_id like "LRG%";
DELETE from transcript where stable_id like "LRG%";
DELETE from translation where stable_id like "LRG%";

DELETE from release_stats where release_id in (SELECT release_id from release_set where description like "%LRG%");
DELETE from release_set where description like "%LRG%";

