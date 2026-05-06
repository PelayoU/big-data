-- =============================================================================
-- View 4 - discos_v_album_tracks_info
-- =============================================================================
-- Question:
--   For every album, expose:
--     - the album title and release date,
--     - the number of tracks the album contains,
--     - the cumulative number of recordings the album's performer had made
--       up to (and including) the album's release date.
--
-- Implementation notes:
--   - tracks_by_album CTE pre-aggregates the tracks count per album. Joining
--     this back with LEFT JOIN means an album with zero tracks resolves to
--     NULL on the count, which NVL(.., 0) folds to a clean 0.
--   - performer_recordings_upto_album_date is a *correlated subquery*:
--     for every row of the outer staging it counts every track the same
--     performer ever recorded whose rec_date <= the current album's rel_date.
--     The join goes through discos_albums_stg ax to recover the performer
--     of each track via its album (TRACKS itself does not store performer).
-- =============================================================================

CREATE OR REPLACE VIEW discos_v_album_tracks_info AS
WITH tracks_by_album AS (
    SELECT
        t.pair,
        COUNT(*) AS tracks_in_album
    FROM   FINTECH10.tracks t
    GROUP  BY t.pair
)
SELECT
    a.pair,
    a.title,
    a.rel_date,
    NVL(tba.tracks_in_album, 0) AS tracks_in_album,

    -- Cumulative recordings of this performer up to (and including) the
    -- album's release date.
    (
        SELECT COUNT(*)
        FROM   FINTECH10.tracks t
        JOIN   discos_albums_stg ax ON ax.pair = t.pair
        WHERE  ax.performer = a.performer
          AND  t.rec_date  <= a.rel_date
    ) AS performer_recordings_upto_album_date
FROM   discos_albums_stg a
LEFT JOIN tracks_by_album tba ON tba.pair = a.pair;

-- -----------------------------------------------------------------------------
-- Sample probe.
-- -----------------------------------------------------------------------------
-- SELECT pair, title, rel_date, tracks_in_album, performer_recordings_upto_album_date
-- FROM   discos_v_album_tracks_info
-- FETCH  FIRST 10 ROWS ONLY;
