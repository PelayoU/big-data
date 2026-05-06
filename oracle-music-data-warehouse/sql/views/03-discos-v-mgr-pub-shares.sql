-- =============================================================================
-- View 3 - discos_v_mgr_pub_shares
-- =============================================================================
-- Question:
--   For every (manager, publisher) pair, expose:
--     - the number of albums that combination has produced together,
--     - the percentage of the manager's catalogue published by that publisher,
--     - the percentage of the publisher's catalogue managed by that manager.
--
-- Implementation notes:
--   - Three CTEs:
--       base    : (manager, publisher, albums_cnt)
--       tot_mgr : (manager,           total_mgr)
--       tot_pub : (publisher,         total_pub)
--     The two totals are then joined back to base to compute the relative
--     percentages on a per-row basis.
--   - The two percentages are deliberately asymmetric (numerator is always
--     albums_cnt; the denominator changes), so the view exposes both sides
--     of the same relationship in a single row.
-- =============================================================================

CREATE OR REPLACE VIEW discos_v_mgr_pub_shares AS
WITH base AS (
    SELECT
        manager,
        publisher,
        COUNT(*) AS albums_cnt
    FROM   discos_albums_stg
    GROUP  BY manager, publisher
),
tot_mgr AS (
    SELECT
        manager,
        SUM(albums_cnt) AS total_mgr
    FROM   base
    GROUP  BY manager
),
tot_pub AS (
    SELECT
        publisher,
        SUM(albums_cnt) AS total_pub
    FROM   base
    GROUP  BY publisher
)
SELECT
    base.manager,
    base.publisher,
    base.albums_cnt,
    tm.total_mgr,
    tp.total_pub,

    -- % of THIS MANAGER's albums that THIS PUBLISHER produced
    ROUND(100 * base.albums_cnt / NULLIF(tm.total_mgr, 0), 2)
        AS pct_of_manager_published_by_this_publisher,

    -- % of THIS PUBLISHER's albums that THIS MANAGER managed
    ROUND(100 * base.albums_cnt / NULLIF(tp.total_pub, 0), 2)
        AS pct_of_publisher_managed_by_this_manager
FROM base
JOIN tot_mgr tm ON base.manager   = tm.manager
JOIN tot_pub tp ON base.publisher = tp.publisher;

-- -----------------------------------------------------------------------------
-- Worked example (from a real run on the UC3M dataset):
--   manager=555645760, publisher='Hispano Vos'
--     albums_cnt = 12
--     total_mgr  = 152  -> this manager has produced 152 albums in total
--     total_pub  = 827  -> Hispano Vos has published 827 albums in total
--     pct_of_manager_published_by_this_publisher = 7.89%
--     pct_of_publisher_managed_by_this_manager   = 1.45%
--   Reading: Hispano Vos is one of the labels this manager works with,
--   accounting for 7.89% of his/her catalogue, but only 1.45% of
--   Hispano Vos's catalogue is managed by this person.
-- -----------------------------------------------------------------------------
