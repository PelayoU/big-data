-- =============================================================================
-- Hive Q2 - Count books published in 1980
-- =============================================================================
-- Output: /query2 (HDFS)
-- Real-data answer on this dataset: 42 books — same as the Pig version.
-- =============================================================================

INSERT OVERWRITE DIRECTORY '/query2'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT COUNT(*)
FROM   ebooks
WHERE  year = 1980;
