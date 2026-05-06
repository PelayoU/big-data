-- =============================================================================
-- Pig load relations
-- =============================================================================
-- Two source CSVs in HDFS root:
--   /ebooks.csv      (isbn, title, author, year)
--   /epublishing.csv (isbn, editorial)
--
-- Both relations are loaded once and reused across q1..q4. Run this script
-- inside `pig -x mapreduce` (or paste line-by-line into the grunt shell).
-- =============================================================================

ebooks = LOAD '/ebooks.csv'
         USING PigStorage(',')
         AS (isbn:chararray, title:chararray, author:chararray, year:int);

epub   = LOAD '/epublishing.csv'
         USING PigStorage(',')
         AS (isbn:chararray, editorial:chararray);
