-- =============================================================================
-- Q10 - "Top-5 ChartMaster"
-- Question: top 5 musicians by number of distinct songs of theirs (as writer
--           or co-writer) that have been played in concerts.
-- Output:   id músico, número de temas
-- -----------------------------------------------------------------------------
-- Notes:
--   - First CTE 'temas_propios' lists each musician's authored songs, by
--     joining MUSICIANS to SONGS on writer OR cowriter (a song has one writer
--     and at most one cowriter).
--   - Second CTE 'temas_interpretados' filters to songs that match a row in
--     PERFORMANCES on (songtitle, songwriter). DISTINCT is needed because a
--     song can be performed many times across concerts.
--   - FETCH FIRST 5 ROWS WITH TIES is the Oracle-12c clean way to break the
--     "top-5 plus ties" rule — if several musicians tie on the 5th value,
--     every tied row is returned.
-- =============================================================================

WITH temas_propios AS (
    SELECT
        m.passport AS id_musico,
        s.title,
        s.writer
    FROM   FINTECH10.musicians m
    JOIN   FINTECH10.songs     s
        ON m.passport = s.writer
        OR m.passport = s.cowriter
),
temas_interpretados AS (
    SELECT DISTINCT
        tp.id_musico,
        tp.title,
        tp.writer
    FROM   temas_propios tp
    JOIN   FINTECH10.performances p
        ON p.songtitle  = tp.title
       AND p.songwriter = tp.writer
)
SELECT
    id_musico,
    COUNT(*) AS num_temas
FROM   temas_interpretados
GROUP  BY id_musico
ORDER  BY num_temas DESC, id_musico
FETCH  FIRST 5 ROWS WITH TIES;
