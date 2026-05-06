-- =============================================================================
-- Hive Q1 - Titles and authors of every book published in 2000
-- =============================================================================
-- Output: /query1 (HDFS)
-- =============================================================================

INSERT OVERWRITE DIRECTORY '/query1'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT title, author
FROM   ebooks
WHERE  year = 2000;
