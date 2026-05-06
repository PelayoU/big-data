-- =============================================================================
-- Q3 - "Estudios aislados"
-- Question: studios located on an island, identified by the address containing
--           the substring 'isla' (Spanish) or 'island' (English).
-- Output:   nombre de estudio
-- -----------------------------------------------------------------------------
-- Notes:
--   - UPPER() is applied to the address so the LIKE match is case-insensitive.
--   - Both keywords are checked in the same WHERE for compactness.
-- =============================================================================

SELECT name
FROM   FINTECH10.STUDIOS
WHERE  UPPER(address) LIKE '%ISLA%'
   OR  UPPER(address) LIKE '%ISLAND%'
ORDER  BY name;

-- Verification: the matching studios should sit on real island names.
-- SELECT address FROM FINTECH10.STUDIOS
-- WHERE UPPER(address) LIKE '%ISLA%' OR UPPER(address) LIKE '%ISLAND%'
-- ORDER BY name;
