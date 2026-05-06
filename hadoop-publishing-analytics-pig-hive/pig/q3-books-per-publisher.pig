-- =============================================================================
-- Pig Q3 - Number of books published by each publisher
-- =============================================================================
-- Output: /query3 (HDFS)
-- =============================================================================

t3_B = GROUP epub BY editorial;
t3_C = FOREACH t3_B GENERATE group AS editorial, COUNT(epub) AS n_libros;

DUMP t3_C;

STORE t3_C INTO '/query3' USING PigStorage(',');

-- fs -copyToLocal /query3 /home/hadoop/
