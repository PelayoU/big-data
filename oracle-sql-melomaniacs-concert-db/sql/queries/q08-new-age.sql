-- =============================================================================
-- Q8 - "New-Age"
-- Question: performers whose mean age (over members active at the time of
--           each concert) is younger than the mean age of the audience that
--           attended their concerts.
-- Output:   nombre intérprete, nacionalidad, edad media grupo, edad media público
-- -----------------------------------------------------------------------------
-- Notes:
--   - edad_media_grupo:    for each performer, average over their concerts of
--                          (concert_date - musician_birthdate) / 365.2422.
--                          Only members whose involvement spans the concert
--                          date are considered: i.start_d <= concert_when AND
--                          (i.end_d IS NULL OR i.end_d > concert_when).
--   - edad_media_publico:  for each performer, average over their concerts'
--                          attendees of (attendance_when - client_birthdate) /
--                          365.2422.
--   - Final SELECT keeps performers whose edad_media_grupo is *less* than
--     edad_media_publico.
--   - 365.2422 is the tropical-year length; using 365.25 or 365 gives nearly
--     identical results at this precision.
-- =============================================================================

WITH edad_media_grupo AS (
    SELECT
        c.performer,
        AVG((c."WHEN" - m.birthdate) / 365.2422) AS edad_media_grupo
    FROM   FINTECH10.concerts   c
    JOIN   FINTECH10.involvement i
        ON i.band = c.performer
       AND i.start_d <= c."WHEN"
       AND (i.end_d IS NULL OR i.end_d > c."WHEN")
    JOIN   FINTECH10.musicians m
        ON m.passport = i.musician
    GROUP  BY c.performer
),
edad_media_publico AS (
    SELECT
        a.performer,
        AVG((a."WHEN" - cl.birthdate) / 365.2422) AS edad_media_publico
    FROM   FINTECH10.attendances a
    JOIN   FINTECH10.clients     cl
        ON cl.e_mail = a.client
    GROUP  BY a.performer
)
SELECT
    p.name        AS interprete,
    p.nationality,
    g.edad_media_grupo,
    u.edad_media_publico
FROM   edad_media_grupo  g
JOIN   edad_media_publico u ON u.performer = g.performer
JOIN   FINTECH10.performers p ON p.name    = g.performer
WHERE  g.edad_media_grupo < u.edad_media_publico
ORDER  BY interprete;
