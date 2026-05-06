-- =============================================================================
-- Pig Q4 - Books published by Elsevier (joining ebooks with epub)
-- =============================================================================
-- Output: /query4 (HDFS)
--
-- The publisher-side relation `epub` is filtered first, then joined to the
-- catalog-side relation `ebooks` on `isbn`. Pre-filtering keeps the JOIN
-- input small.
-- =============================================================================

t4_B = FILTER epub  BY editorial == 'Elsevier';
t4_C = JOIN   t4_B  BY isbn,  ebooks BY isbn;
t4_D = FOREACH t4_C GENERATE ebooks::title, ebooks::author, ebooks::year;

DUMP t4_D;

STORE t4_D INTO '/query4' USING PigStorage(',');

-- fs -copyToLocal /query4 /home/hadoop/
