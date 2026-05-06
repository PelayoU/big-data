-- =============================================================================
-- Hive Q3 - Number of books published by each publisher
-- =============================================================================
-- Output: /query3 (HDFS)
-- =============================================================================

INSERT OVERWRITE DIRECTORY '/query3'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT editorial, COUNT(*)
FROM   epublishing
GROUP  BY editorial;
