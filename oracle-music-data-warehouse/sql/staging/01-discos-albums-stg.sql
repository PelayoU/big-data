-- =============================================================================
-- Staging table for the "discos" warehouse
-- =============================================================================
-- Purpose:
--   Make a clean, query-isolated copy of FINTECH10.ALBUMS to operate against
--   without touching the upstream production table. The staging row mirrors
--   the source columns, plus a *virtual* RELEASE_YEAR generated on read from
--   REL_DATE — this avoids storing the year and prevents drift between the
--   real release date and the year used by the analytical views.
--
-- Why a virtual column:
--   Every analytical view in this project partitions / groups by year. Having
--   it as a virtual column means:
--     - It is always consistent with REL_DATE (cannot be set independently).
--     - It is not duplicated on disk.
--     - It can be indexed if a future view ever needs to filter by year.
-- =============================================================================

CREATE TABLE discos_albums_stg (
    pair         CHAR(15)     NOT NULL,
    performer    VARCHAR2(50) NOT NULL,
    format       CHAR(1)      NOT NULL,
    title        VARCHAR2(50) NOT NULL,
    rel_date     DATE         NOT NULL,
    publisher    VARCHAR2(25) NOT NULL,
    manager      NUMBER(9)    NOT NULL,
    release_year NUMBER GENERATED ALWAYS AS (EXTRACT(YEAR FROM rel_date)) VIRTUAL,
    CONSTRAINT pk_discos_albums_stg PRIMARY KEY (pair)
);

-- Bulk-load every row from the upstream production table. The virtual column
-- is intentionally omitted from the column list — Oracle computes it on read.
INSERT INTO discos_albums_stg (
    pair, performer, format, title, rel_date, publisher, manager
)
SELECT
    pair, performer, format, title, rel_date, publisher, manager
FROM   FINTECH10.ALBUMS;

COMMIT;

-- Sanity check (expected: 21,561 rows on the canonical UC3M dataset).
-- SELECT COUNT(*) FROM discos_albums_stg;
