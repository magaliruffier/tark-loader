
select count(*) from exon_release_tag ert inner join exon e on e.exon_id=ert.feature_id  where e.stable_id like "LRG%";
select count(*) from exon_transcript et inner join exon e on et.exon_id=e.exon_id  where e.stable_id like "LRG%";
select count(*) from exon where stable_id like "LRG%";

select count(*) from gene_release_tag grt inner join gene g on g.gene_id=grt.feature_id  where g.stable_id like "LRG%";
select count(*) from gene where stable_id like "LRG%";



select count(*) from transcript_release_tag trt inner join transcript t on t.transcript_id=trt.feature_id  where t.stable_id like "LRG%";
select count(*) from transcript_gene tg inner join transcript t on tg.transcript_id=t.transcript_id  where t.stable_id like "LRG%";
select count(*) from transcript where stable_id like "LRG%";


select count(*) from translation_release_tag trt inner join translation t on t.translation_id=trt.feature_id  where t.stable_id like "LRG%";
select count(*) from translation_transcript tg inner join transcript t on tg.transcript_id=t.transcript_id  where t.stable_id like "LRG%";
select count(*) from translation where stable_id like "LRG%";


select * from release_set where description like "%LRG%";

