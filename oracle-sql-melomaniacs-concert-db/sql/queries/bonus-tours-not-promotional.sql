-- =============================================================================
-- Bonus track - Tours that are NOT album-promotional
-- Question: list the tours whose name does NOT contain the title of an album
--           by the same performer (some tours promote an album by embedding
--           its title in the tour name; we want the rest).
-- Output:   nombre intérprete, nombre gira
-- -----------------------------------------------------------------------------
-- Notes:
--   - The match is done with UPPER('%' || a.title || '%') so the LIKE check is
--     case-insensitive. The album title can sit anywhere in the tour name.
--   - NOT EXISTS keeps a tour iff the performer has no album whose title is
--     contained in the tour name.
-- =============================================================================

SELECT
    t.performer AS interprete,
    t.name      AS nombre_gira
FROM   FINTECH10.tours t
WHERE  NOT EXISTS (
    SELECT 1
    FROM   FINTECH10.albums a
    WHERE  a.performer = t.performer
      AND  UPPER(t.name) LIKE '%' || UPPER(a.title) || '%'
)
ORDER  BY interprete, nombre_gira;
