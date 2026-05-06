-- =============================================================================
-- Q5 - "Ese estudio no es manco"
-- Question: how many vinyl albums have at least one track recorded at
--           "Cervantes Recordings"?  ('vinilo' is format = 'V'.)
-- Output:   número de álbumes
-- -----------------------------------------------------------------------------
-- Notes:
--   - COUNT(DISTINCT a.pair) collapses the join multiplicity: if an album has
--     several tracks recorded at Cervantes, we still count the album once.
--   - UPPER() on both columns guards against mixed-case data.
-- =============================================================================

SELECT COUNT(DISTINCT a.pair) AS num_albums
FROM   FINTECH10.albums a
JOIN   FINTECH10.tracks t ON t.pair = a.pair
WHERE  UPPER(a.format) = 'V'
  AND  UPPER(t.studio) = 'CERVANTES RECORDINGS';
