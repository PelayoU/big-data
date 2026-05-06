-- =============================================================================
-- Q2 - "Concert-site"
-- Question: municipalities that have hosted more than 20 concerts during the
--           decade 2010-01-01 .. 2019-12-31.
-- Output:   nombre municipalidad
-- -----------------------------------------------------------------------------
-- Notes:
--   - "WHEN" is a reserved word in SQL, so the column has to be quoted to
--     reach the date attribute of CONCERTS.
--   - The decade is expressed as a half-open range [2010-01-01, 2020-01-01)
--     to avoid the trailing-day boundary issue with DATE comparisons.
--   - municipality IS NOT NULL filters out ungeolocated concerts so the
--     aggregate doesn't pile them under a single NULL bucket.
-- =============================================================================

SELECT municipality
FROM   FINTECH10.CONCERTS
WHERE  "WHEN" >= DATE '2010-01-01'
  AND  "WHEN" <  DATE '2020-01-01'
  AND  municipality IS NOT NULL
GROUP  BY municipality
HAVING COUNT(*) > 20
ORDER  BY municipality;
