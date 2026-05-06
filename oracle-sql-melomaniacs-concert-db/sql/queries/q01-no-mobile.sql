-- =============================================================================
-- Q1 - "No mobile"
-- Question: emails of clients whose mobile phone is unknown.
-- Output:   e_mail
-- -----------------------------------------------------------------------------
-- Notes:
--   - The CLIENTS table marks the mobile column as NULLable in the schema
--     (mobile*). Missing values are NULL, not empty strings, so IS NULL is the
--     correct predicate. Equality with the empty string would not work in
--     Oracle either way, since '' is treated as NULL.
-- =============================================================================

SELECT e_mail
FROM   FINTECH10.CLIENTS
WHERE  PHONE IS NULL;

-- Sanity check: count the matching rows.
-- SELECT COUNT(*) FROM FINTECH10.CLIENTS WHERE PHONE IS NULL;
