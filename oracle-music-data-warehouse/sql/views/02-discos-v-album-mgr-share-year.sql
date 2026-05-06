-- =============================================================================
-- View 2 - discos_v_album_mgr_share_year
-- =============================================================================
-- Question:
--   For every album, what percentage of albums published in that same year
--   were managed by the same manager?
--
-- Implementation notes:
--   - PARTITION BY release_year                    -> albums released that year
--   - PARTITION BY manager, release_year           -> albums by that manager
--                                                     in that year
--   - The percentage is the second divided by the first, * 100, rounded.
--   - NULLIF(denominator, 0) is defensive: it shouldn't ever fire because
--     every album has a release_year, but it guards the view from a divide-
--     by-zero if the staging table is ever empty.
-- =============================================================================

CREATE OR REPLACE VIEW discos_v_album_mgr_share_year AS
SELECT
    a.pair,
    a.title,
    a.rel_date,
    a.release_year,
    a.manager,

    -- Total albums published in that year, across all managers
    COUNT(*) OVER (PARTITION BY a.release_year) AS total_albums_year,

    -- Albums managed by this manager, in that same year
    COUNT(*) OVER (PARTITION BY a.manager, a.release_year)
        AS manager_albums_that_year,

    -- Manager's share of that year, in percent (rounded to 2 decimals)
    ROUND(
        100 * (COUNT(*) OVER (PARTITION BY a.manager, a.release_year))
            / NULLIF(COUNT(*) OVER (PARTITION BY a.release_year), 0)
    , 2) AS pct_year_albums_by_this_manager
FROM discos_albums_stg a;

-- -----------------------------------------------------------------------------
-- Sample probe.
-- -----------------------------------------------------------------------------
-- SELECT pair, title, release_year, manager, total_albums_year,
--        manager_albums_that_year, pct_year_albums_by_this_manager
-- FROM   discos_v_album_mgr_share_year
-- FETCH  FIRST 10 ROWS ONLY;
