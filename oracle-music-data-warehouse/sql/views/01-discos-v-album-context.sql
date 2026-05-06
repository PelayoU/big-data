-- =============================================================================
-- View 1 - discos_v_album_context
-- =============================================================================
-- Question:
--   For every album, expose:
--     - months elapsed since the same performer's previous album,
--     - albums published the same year by the same publisher,
--     - albums managed the same year by the same manager.
--
-- Implementation notes:
--   - LAG(rel_date) OVER (PARTITION BY performer ORDER BY rel_date, pair)
--     returns the previous album release date for the same artist; the tie
--     breaker on pair makes the order fully deterministic when two albums
--     share rel_date.
--   - MONTHS_BETWEEN gives the difference in months as a NUMBER, so ROUND
--     trims it to an integer count.
--   - For each "same publisher / same year" count, both the inclusive (this
--     album included) and the exclusive (this album excluded) variants are
--     exposed. The exclusive form is just the inclusive minus 1, which lets
--     consumers pick whichever semantics fits their report.
--   - Same idiom is reused for the manager partition.
-- =============================================================================

CREATE OR REPLACE VIEW discos_v_album_context AS
SELECT
    a.pair,
    a.performer,
    a.title,
    a.rel_date,
    a.release_year,
    a.publisher,
    a.manager,

    LAG(a.rel_date) OVER (
        PARTITION BY a.performer
        ORDER BY a.rel_date, a.pair
    ) AS prev_rel_date,

    ROUND(
        MONTHS_BETWEEN(
            a.rel_date,
            LAG(a.rel_date) OVER (
                PARTITION BY a.performer
                ORDER BY a.rel_date, a.pair
            )
        )
    ) AS months_since_prev_album,

    COUNT(*) OVER (PARTITION BY a.publisher, a.release_year)
        AS albums_same_year_same_publisher_incl,
    COUNT(*) OVER (PARTITION BY a.publisher, a.release_year) - 1
        AS albums_same_year_same_publisher_excl,

    COUNT(*) OVER (PARTITION BY a.manager, a.release_year)
        AS albums_same_year_same_manager_incl,
    COUNT(*) OVER (PARTITION BY a.manager, a.release_year) - 1
        AS albums_same_year_same_manager_excl
FROM discos_albums_stg a;

-- -----------------------------------------------------------------------------
-- Sample probe — first 10 rows for which the artist had a previous album.
-- -----------------------------------------------------------------------------
-- SELECT performer, title, rel_date, prev_rel_date, months_since_prev_album,
--        release_year, publisher, albums_same_year_same_publisher_incl,
--        albums_same_year_same_publisher_excl,
--        manager, albums_same_year_same_manager_incl,
--        albums_same_year_same_manager_excl
-- FROM   discos_v_album_context
-- WHERE  months_since_prev_album IS NOT NULL
-- FETCH  FIRST 10 ROWS ONLY;
