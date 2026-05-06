-- =============================================================================
-- Hive Q4 - Books published by Elsevier
-- =============================================================================
-- Output: /query4 (HDFS)
-- =============================================================================

INSERT OVERWRITE DIRECTORY '/query4'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT e.title, e.author, e.year
FROM   ebooks e
JOIN   epublishing p ON (e.isbn = p.isbn)
WHERE  p.editorial = 'Elsevier';
