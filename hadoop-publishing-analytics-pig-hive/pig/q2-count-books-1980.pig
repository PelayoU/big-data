-- =============================================================================
-- Pig Q2 - Count books published in 1980
-- =============================================================================
-- Output: /query2 (HDFS)
-- Real-data answer on this dataset: 42 books.
-- =============================================================================

t2_B = FILTER ebooks BY year == 1980;
t2_C = GROUP t2_B ALL;
t2_C = FOREACH t2_C GENERATE COUNT(t2_B);

DUMP t2_C;

STORE t2_C INTO '/query2' USING PigStorage(',');

-- fs -copyToLocal /query2 /home/hadoop/
