-- =============================================================================
-- Q4 - "Tato's band"
-- Question: performer (band) names where no member is currently active —
--           i.e. there has been at least one historical involvement, but no
--           involvement is open as of today.
-- Output:   nombre intérprete
-- -----------------------------------------------------------------------------
-- Notes:
--   - "Active today" means: start_d <= SYSDATE AND (end_d IS NULL OR end_d > SYSDATE).
--   - A band qualifies only if it has had at least one INVOLVEMENT row ever
--     (the EXISTS clause), so soloists with no INVOLVEMENT entries are not
--     listed as "empty bands".
--   - end_d IS NULL is the open-ended interval; we treat that as still active.
-- =============================================================================

SELECT p.name AS interprete
FROM   FINTECH10.performers p
WHERE  EXISTS (
    SELECT 1
    FROM   FINTECH10.involvement
    WHERE  involvement.band = p.name
)
AND    NOT EXISTS (
    SELECT 1
    FROM   FINTECH10.involvement i
    WHERE  i.band = p.name
      AND  i.start_d <= SYSDATE
      AND  (i.end_d IS NULL OR i.end_d > SYSDATE)
)
ORDER  BY interprete;
