-- =============================================================================
-- Pig Q1 - Titles and authors of every book published in 2000
-- =============================================================================
-- Output: /query1 (HDFS)
-- =============================================================================

B = FILTER ebooks BY year == 2000;
C = FOREACH B GENERATE title, author;

DUMP C;

STORE C INTO '/query1' USING PigStorage(',');

-- Pull the result back to the local filesystem:
-- fs -copyToLocal /query1 /home/hadoop/
