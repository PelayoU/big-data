-- =============================================================================
-- Q9 - "Loyalty-card"
-- Question: client(s) who have attended the most concerts AND whose attendance
--           is restricted to a single performer (always the same one). If
--           several clients tie on attendance count, all of them are listed.
-- Output:   email, intérprete
-- -----------------------------------------------------------------------------
-- Notes:
--   - The CTE 'leales' aggregates per client and applies HAVING
--     COUNT(DISTINCT a.performer) = 1, which is the loyalty filter:
--     attended only one distinct performer, ever.
--   - MIN(a.performer) returns that single performer name (any aggregate of
--     a constant column works; MIN is a common idiom).
--   - The outer query keeps only clients whose total_conciertos equals the
--     maximum across the CTE — that's the "most concerts" tie-breaker.
-- =============================================================================

WITH leales AS (
    SELECT
        a.client,
        COUNT(*)         AS total_conciertos,
        MIN(a.performer) AS interprete_unico
    FROM   FINTECH10.attendances a
    GROUP  BY a.client
    HAVING COUNT(DISTINCT a.performer) = 1
)
SELECT
    client            AS email,
    interprete_unico  AS interprete
FROM   leales
WHERE  total_conciertos = (SELECT MAX(total_conciertos) FROM leales)
ORDER  BY email;

-- -----------------------------------------------------------------------------
-- Validation: distribution of distinct performers per client. Run-time check
-- to confirm the HAVING filter selects the right shape of clients.
-- -----------------------------------------------------------------------------
-- SELECT a.client, COUNT(DISTINCT a.performer) AS n_interpretes
-- FROM   FINTECH10.attendances a
-- GROUP  BY a.client
-- ORDER  BY n_interpretes DESC, a.client;
