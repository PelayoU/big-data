-- =============================================================================
-- Q6 - "Redundancy"
-- Question: performers whose composition includes two contemporary members
--           playing the same instrument (role).
-- Output:   intérprete, instrumento, miembro_1, periodo_1, miembro_2, periodo_2
-- -----------------------------------------------------------------------------
-- Notes:
--   - Self-join on INVOLVEMENT (alias a, b) by band+role.
--   - "Contemporary" means the membership intervals overlap. Two intervals
--     [a.start_d, a.end_d] and [b.start_d, b.end_d] overlap iff
--         a.start_d <= b.end_d  AND  b.start_d <= a.end_d
--     With NULL end_d treated as +infinity:
--         (a.end_d IS NULL OR b.start_d <= a.end_d)
--         AND
--         (b.end_d IS NULL OR a.start_d <= b.end_d)
--   - a.musician < b.musician avoids reporting each pair twice (and rules
--     out matching a row against itself).
-- =============================================================================

SELECT
    a.band     AS interprete,
    a.role     AS instrumento,
    a.musician AS miembro_1,
    a.start_d  AS inicio_1,
    a.end_d    AS fin_1,
    b.musician AS miembro_2,
    b.start_d  AS inicio_2,
    b.end_d    AS fin_2
FROM   FINTECH10.involvement a
JOIN   FINTECH10.involvement b
    ON a.band = b.band
   AND a.role = b.role
   AND a.musician < b.musician
   AND (a.end_d IS NULL OR b.start_d <= a.end_d)
   AND (b.end_d IS NULL OR a.start_d <= b.end_d)
ORDER  BY interprete, instrumento, miembro_1, miembro_2;
