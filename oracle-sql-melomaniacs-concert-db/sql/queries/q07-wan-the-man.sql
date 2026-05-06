-- =============================================================================
-- Q7 - "Wan the Man"
-- Question: managers who only produce albums — never tours, never concerts.
-- Output:   nombre completo, num_interpretes, num_albums, num_giras, num_conciertos
-- -----------------------------------------------------------------------------
-- Notes:
--   - The qualifier is double NOT EXISTS: the manager must have ALBUMS but
--     NEITHER TOURS NOR CONCERTS associated.
--   - The MANAGERS schema in Melomaniacs uses the manager's mobile phone as
--     the join key against ALBUMS.manager / TOURS.manager / CONCERTS.manager.
--   - num_giras and num_conciertos are 0 by definition (otherwise the row
--     wouldn't have qualified). Hardcoding the zeros keeps the projection
--     consistent with the requested output schema.
--   - num_interpretes = distinct performers behind the manager's albums.
--   - num_albums      = distinct album ids.
-- =============================================================================

SELECT
    m.name || ' ' || m.f_name || ' ' || m.surname  AS nombre_completo,
    COUNT(DISTINCT a.performer)                    AS num_interpretes,
    COUNT(DISTINCT a.pair)                         AS num_albums,
    0                                              AS num_giras,
    0                                              AS num_conciertos
FROM   FINTECH10.managers m
JOIN   FINTECH10.albums a ON a.manager = m.mobile
WHERE  NOT EXISTS (
    SELECT 1 FROM FINTECH10.tours    t WHERE t.manager = m.mobile
)
AND    NOT EXISTS (
    SELECT 1 FROM FINTECH10.concerts c WHERE c.manager = m.mobile
)
GROUP  BY m.name, m.f_name, m.surname
ORDER  BY nombre_completo;
