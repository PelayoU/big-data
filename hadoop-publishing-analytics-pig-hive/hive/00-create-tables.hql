-- =============================================================================
-- Hive table definitions
-- =============================================================================
-- The same two CSVs that Pig loaded by relation are loaded here as managed
-- Hive tables. Once defined, queries on them go through MapReduce / Tez
-- transparently.
-- =============================================================================

CREATE TABLE IF NOT EXISTS ebooks (
    isbn   STRING,
    title  STRING,
    author STRING,
    year   INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS epublishing (
    isbn      STRING,
    editorial STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Load the same CSVs into the Hive tables. The OVERWRITE form makes the load
-- idempotent on re-run.
LOAD DATA INPATH '/ebooks.csv'      OVERWRITE INTO TABLE ebooks;
LOAD DATA INPATH '/epublishing.csv' OVERWRITE INTO TABLE epublishing;
