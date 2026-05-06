-- =============================================================================
-- Exercise 1 - Relational design + DDL for a floristry catalogue
-- =============================================================================
-- Domain:
--   - RAMOS    (bouquets) identified by 'referencia', priced, available in a
--              date range, composed of one or more flowers.
--   - FLORES   (flowers) identified by their common name; carry scientific
--              name, unit cost, season, and an optional substitute flower.
--   - RACIMOS  (composition) — many-to-many between RAMOS and FLORES, with the
--              number of units of each flower in each bouquet (>= 1).
--
-- Semantic decisions enforced by the schema:
--   - A flower can be substituted by exactly one other flower (or none).
--   - Substitute flowers can be deleted (the FK is SET NULL on the dependants).
--   - A flower belonging to a bouquet's composition cannot be deleted directly:
--     the FK from RACIMOS to FLORES has no cascading rule, so the row in
--     RACIMOS would have to be removed first.
--   - When a bouquet (RAMOS) is removed, its composition rows in RACIMOS are
--     deleted automatically (ON DELETE CASCADE).
--   - Season is stored as a single character ('P', 'V', 'O', 'I') for
--     storage efficiency, validated via CHECK constraint.
-- =============================================================================

CREATE TABLE FLORES (
    nombre_flor       VARCHAR2(20) NOT NULL,
    nombre_cientifico VARCHAR2(30) NOT NULL,
    coste_unitario    NUMBER(4,2)  NOT NULL,
    temporada         CHAR(1)      NOT NULL,
    flor_sustituta    VARCHAR2(20),

    CONSTRAINT pk_flores              PRIMARY KEY (nombre_flor),
    CONSTRAINT ck_flores_temporada    CHECK (temporada IN ('P','V','O','I')),
    CONSTRAINT ck_flores_coste_pos    CHECK (coste_unitario >= 0),
    CONSTRAINT ck_flores_no_auto_sust CHECK (flor_sustituta IS NULL
                                             OR flor_sustituta <> nombre_flor),
    CONSTRAINT fk_flores_sustituta    FOREIGN KEY (flor_sustituta)
        REFERENCES FLORES(nombre_flor)
        ON DELETE SET NULL
);

CREATE TABLE RAMOS (
    referencia        CHAR(12)     NOT NULL,
    nombre_ramo       VARCHAR2(40) NOT NULL,
    disponible_desde  DATE         NOT NULL,
    disponible_hasta  DATE         NOT NULL,
    precio            NUMBER(5,2)  NOT NULL,

    CONSTRAINT pk_ramos          PRIMARY KEY (referencia),
    CONSTRAINT uq_ramos_nombre   UNIQUE (nombre_ramo),
    CONSTRAINT ck_ramos_precio_pos CHECK (precio >= 0),
    CONSTRAINT ck_ramos_fechas   CHECK (
        disponible_desde < disponible_hasta
        AND EXTRACT(YEAR FROM disponible_desde) = EXTRACT(YEAR FROM disponible_hasta)
    )
);

CREATE TABLE RACIMOS (
    ramo     CHAR(12)     NOT NULL,
    flor     VARCHAR2(20) NOT NULL,
    unidades NUMBER(6,3)  NOT NULL,

    CONSTRAINT pk_racimos      PRIMARY KEY (ramo, flor),
    CONSTRAINT fk_racimos_ramo FOREIGN KEY (ramo)
        REFERENCES RAMOS(referencia)
        ON DELETE CASCADE,
    CONSTRAINT fk_racimos_flor FOREIGN KEY (flor)
        REFERENCES FLORES(nombre_flor),
    CONSTRAINT ck_comp_unidades CHECK (unidades >= 1)
);

-- -----------------------------------------------------------------------------
-- Excluded semantics (would require a separate validation procedure / trigger):
--   - The constraint that a bouquet's price must be greater than the sum of
--     unit costs * units across its composition cannot be expressed in pure
--     DDL because it spans three tables. It would need a trigger or a
--     validation query.
-- -----------------------------------------------------------------------------
