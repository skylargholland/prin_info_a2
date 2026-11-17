-- step3_normalize.sql
-- CS336 Project 2, Steps 3 + 4: builds the fully normalized (BCNF) database from
-- Preliminary (built by create_preliminary.sql).
--   * 1st normal form: applicant_race_1..5, co_applicant_race_1..5 and
--     denial_reason_1..3 become rows in join tables (with a race/reason number).
--   * BCNF: every code -> name dependency gets a lookup table; location data gets
--     its own table keyed by a new location_id.
--   * Error checking (Step 4): primary keys, foreign keys, NOT NULL on every column
--     that is never empty in the CSV, and range checks on the race/reason numbers.
-- Run inside psql:   \i step3_normalize.sql

SET statement_timeout = 0;
\set ON_ERROR_STOP on
BEGIN;

DROP TABLE IF EXISTS Loan_Denial, Applicant_Race, Co_Applicant_Race,
    Loan_Application, Location, Edit_Status, MSA,
    Application_Denial_Reason, Application, Null_Columns,
    Agency, Loan_Type, Property_Type, Loan_Purpose, Owner_Occupancy, Preapproval,
    Action_Taken, MSAMD, County, State, Ethnicity, Race, Sex, Purchaser_Type,
    Denial_Reason, HOEPA_Status, Lien_Status CASCADE;

-- =========================================================================
-- 1. Lookup tables (code -> name). Filled from the data so names match exactly.
--    If one code ever appeared with two different names the PRIMARY KEY would
--    reject the insert, so the dependency is checked while loading.
-- =========================================================================
CREATE TABLE Agency (
    agency_code INT  PRIMARY KEY,
    agency_name TEXT NOT NULL,
    agency_abbr TEXT NOT NULL
);
INSERT INTO Agency
SELECT DISTINCT agency_code, agency_name, agency_abbr FROM Preliminary WHERE agency_code IS NOT NULL;

CREATE TABLE Loan_Type (loan_type INT PRIMARY KEY, loan_type_name TEXT NOT NULL);
INSERT INTO Loan_Type SELECT DISTINCT loan_type, loan_type_name FROM Preliminary WHERE loan_type IS NOT NULL;

CREATE TABLE Property_Type (property_type INT PRIMARY KEY, property_type_name TEXT NOT NULL);
INSERT INTO Property_Type SELECT DISTINCT property_type, property_type_name FROM Preliminary WHERE property_type IS NOT NULL;

CREATE TABLE Loan_Purpose (loan_purpose INT PRIMARY KEY, loan_purpose_name TEXT NOT NULL);
INSERT INTO Loan_Purpose SELECT DISTINCT loan_purpose, loan_purpose_name FROM Preliminary WHERE loan_purpose IS NOT NULL;

CREATE TABLE Owner_Occupancy (owner_occupancy INT PRIMARY KEY, owner_occupancy_name TEXT NOT NULL);
INSERT INTO Owner_Occupancy SELECT DISTINCT owner_occupancy, owner_occupancy_name FROM Preliminary WHERE owner_occupancy IS NOT NULL;

CREATE TABLE Preapproval (preapproval INT PRIMARY KEY, preapproval_name TEXT NOT NULL);
INSERT INTO Preapproval SELECT DISTINCT preapproval, preapproval_name FROM Preliminary WHERE preapproval IS NOT NULL;

CREATE TABLE Action_Taken (action_taken INT PRIMARY KEY, action_taken_name TEXT NOT NULL);
INSERT INTO Action_Taken SELECT DISTINCT action_taken, action_taken_name FROM Preliminary WHERE action_taken IS NOT NULL;

CREATE TABLE Purchaser_Type (purchaser_type INT PRIMARY KEY, purchaser_type_name TEXT NOT NULL);
INSERT INTO Purchaser_Type SELECT DISTINCT purchaser_type, purchaser_type_name FROM Preliminary WHERE purchaser_type IS NOT NULL;

CREATE TABLE HOEPA_Status (hoepa_status INT PRIMARY KEY, hoepa_status_name TEXT NOT NULL);
INSERT INTO HOEPA_Status SELECT DISTINCT hoepa_status, hoepa_status_name FROM Preliminary WHERE hoepa_status IS NOT NULL;

CREATE TABLE Lien_Status (lien_status INT PRIMARY KEY, lien_status_name TEXT NOT NULL);
INSERT INTO Lien_Status SELECT DISTINCT lien_status, lien_status_name FROM Preliminary WHERE lien_status IS NOT NULL;

-- applicant and co-applicant share the same code lists, so one table each
CREATE TABLE Ethnicity (ethnicity INT PRIMARY KEY, ethnicity_name TEXT NOT NULL);
INSERT INTO Ethnicity
SELECT applicant_ethnicity, applicant_ethnicity_name FROM Preliminary WHERE applicant_ethnicity IS NOT NULL
UNION
SELECT co_applicant_ethnicity, co_applicant_ethnicity_name FROM Preliminary WHERE co_applicant_ethnicity IS NOT NULL;

CREATE TABLE Sex (sex INT PRIMARY KEY, sex_name TEXT NOT NULL);
INSERT INTO Sex
SELECT applicant_sex, applicant_sex_name FROM Preliminary WHERE applicant_sex IS NOT NULL
UNION
SELECT co_applicant_sex, co_applicant_sex_name FROM Preliminary WHERE co_applicant_sex IS NOT NULL;

CREATE TABLE Race (race INT PRIMARY KEY, race_name TEXT NOT NULL);
INSERT INTO Race
SELECT applicant_race_1, applicant_race_name_1 FROM Preliminary WHERE applicant_race_1 IS NOT NULL
UNION SELECT applicant_race_2, applicant_race_name_2 FROM Preliminary WHERE applicant_race_2 IS NOT NULL
UNION SELECT applicant_race_3, applicant_race_name_3 FROM Preliminary WHERE applicant_race_3 IS NOT NULL
UNION SELECT applicant_race_4, applicant_race_name_4 FROM Preliminary WHERE applicant_race_4 IS NOT NULL
UNION SELECT applicant_race_5, applicant_race_name_5 FROM Preliminary WHERE applicant_race_5 IS NOT NULL
UNION SELECT co_applicant_race_1, co_applicant_race_name_1 FROM Preliminary WHERE co_applicant_race_1 IS NOT NULL
UNION SELECT co_applicant_race_2, co_applicant_race_name_2 FROM Preliminary WHERE co_applicant_race_2 IS NOT NULL
UNION SELECT co_applicant_race_3, co_applicant_race_name_3 FROM Preliminary WHERE co_applicant_race_3 IS NOT NULL
UNION SELECT co_applicant_race_4, co_applicant_race_name_4 FROM Preliminary WHERE co_applicant_race_4 IS NOT NULL
UNION SELECT co_applicant_race_5, co_applicant_race_name_5 FROM Preliminary WHERE co_applicant_race_5 IS NOT NULL;

CREATE TABLE Denial_Reason (denial_reason INT PRIMARY KEY, denial_reason_name TEXT NOT NULL);
INSERT INTO Denial_Reason
SELECT denial_reason_1, denial_reason_name_1 FROM Preliminary WHERE denial_reason_1 IS NOT NULL
UNION SELECT denial_reason_2, denial_reason_name_2 FROM Preliminary WHERE denial_reason_2 IS NOT NULL
UNION SELECT denial_reason_3, denial_reason_name_3 FROM Preliminary WHERE denial_reason_3 IS NOT NULL;

-- msamd_name is empty in the CSV for two codes (35620, 37980), so it may be NULL
CREATE TABLE MSA (msamd INT PRIMARY KEY, msamd_name TEXT);
INSERT INTO MSA SELECT DISTINCT msamd, msamd_name FROM Preliminary WHERE msamd IS NOT NULL;

-- one row (New Jersey) for now; keeps name and abbreviation for future states
CREATE TABLE State (
    state_code INT  PRIMARY KEY,
    state_name TEXT NOT NULL,
    state_abbr TEXT NOT NULL
);
INSERT INTO State SELECT DISTINCT state_code, state_name, state_abbr FROM Preliminary WHERE state_code IS NOT NULL;

-- county codes are only unique inside a state
CREATE TABLE County (
    state_code  INT  NOT NULL REFERENCES State (state_code),
    county_code INT  NOT NULL,
    county_name TEXT NOT NULL,
    PRIMARY KEY (state_code, county_code)
);
INSERT INTO County SELECT DISTINCT state_code, county_code, county_name FROM Preliminary WHERE county_code IS NOT NULL;

-- =========================================================================
-- 2. Edit status: edit_status -> edit_status_name is a code -> name dependency
--    like the others. In this CSV edit_status is empty in every row, so the
--    table has no rows yet, but it is ready for any edit status code.
--    application_date_indicator (also empty in every row) stays in
--    Loan_Application as an INT.
-- =========================================================================
CREATE TABLE Edit_Status (edit_status INT PRIMARY KEY, edit_status_name TEXT NOT NULL);
INSERT INTO Edit_Status SELECT DISTINCT edit_status, edit_status_name FROM Preliminary WHERE edit_status IS NOT NULL;

-- =========================================================================
-- 3. Location. The 10 location columns together identify a location; each
--    distinct combination gets one integer location_id.
--    DENSE_RANK numbers the distinct combinations; rows whose 10 values are
--    all equal (NULL counted as equal to NULL) get the same number.
-- =========================================================================
CREATE TABLE Location (
    location_id                    SERIAL  PRIMARY KEY,
    state_code                     INT     NOT NULL REFERENCES State (state_code),
    county_code                    INT,
    msamd                          INT     REFERENCES MSA (msamd),
    census_tract_number            TEXT,
    population                     INT,
    minority_population            NUMERIC,
    hud_median_family_income       INT,
    tract_to_msamd_income          NUMERIC,
    number_of_owner_occupied_units INT,
    number_of_1_to_4_family_units  INT,
    FOREIGN KEY (state_code, county_code) REFERENCES County (state_code, county_code)
);
-- the 10 columns form a candidate key (COALESCE so that NULLs count as equal)
CREATE UNIQUE INDEX location_columns_unique ON Location (
    state_code, COALESCE(county_code, -1), COALESCE(msamd, -1), COALESCE(census_tract_number, ''),
    COALESCE(population, -1), COALESCE(minority_population, -1), COALESCE(hud_median_family_income, -1),
    COALESCE(tract_to_msamd_income, -1), COALESCE(number_of_owner_occupied_units, -1),
    COALESCE(number_of_1_to_4_family_units, -1));

CREATE TEMP TABLE App_Location ON COMMIT DROP AS
SELECT sequence_number,
       DENSE_RANK() OVER (ORDER BY state_code, county_code, msamd, census_tract_number, population,
                                   minority_population, hud_median_family_income, tract_to_msamd_income,
                                   number_of_owner_occupied_units, number_of_1_to_4_family_units)::INT AS location_id,
       state_code, county_code, msamd, census_tract_number, population, minority_population,
       hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units,
       number_of_1_to_4_family_units
FROM Preliminary;

INSERT INTO Location
SELECT DISTINCT location_id, state_code, county_code, msamd, census_tract_number, population,
       minority_population, hud_median_family_income, tract_to_msamd_income,
       number_of_owner_occupied_units, number_of_1_to_4_family_units
FROM App_Location;

-- new locations added later continue after the highest id
SELECT setval(pg_get_serial_sequence('location', 'location_id'), (SELECT MAX(location_id) FROM Location));

-- =========================================================================
-- 4. Main table: one row per application, numeric columns only
--    (respondent_id is the one TEXT column; it is an ID like "62-1532940").
-- =========================================================================
CREATE TABLE Loan_Application (
    sequence_number         BIGINT  PRIMARY KEY,
    as_of_year             INT     NOT NULL,
    respondent_id          TEXT    NOT NULL,
    agency_code            INT     NOT NULL REFERENCES Agency (agency_code),
    loan_type              INT     NOT NULL REFERENCES Loan_Type (loan_type),
    property_type          INT     NOT NULL REFERENCES Property_Type (property_type),
    loan_purpose           INT     NOT NULL REFERENCES Loan_Purpose (loan_purpose),
    owner_occupancy        INT     NOT NULL REFERENCES Owner_Occupancy (owner_occupancy),
    loan_amount_000s       INT,
    preapproval            INT     NOT NULL REFERENCES Preapproval (preapproval),
    action_taken           INT     NOT NULL REFERENCES Action_Taken (action_taken),
    location_id            INT     NOT NULL REFERENCES Location (location_id),
    applicant_ethnicity    INT     NOT NULL REFERENCES Ethnicity (ethnicity),
    co_applicant_ethnicity INT     NOT NULL REFERENCES Ethnicity (ethnicity),
    applicant_sex          INT     NOT NULL REFERENCES Sex (sex),
    co_applicant_sex       INT     NOT NULL REFERENCES Sex (sex),
    applicant_income_000s  INT,
    purchaser_type         INT     NOT NULL REFERENCES Purchaser_Type (purchaser_type),
    rate_spread            NUMERIC,
    hoepa_status           INT     NOT NULL REFERENCES HOEPA_Status (hoepa_status),
    lien_status            INT     NOT NULL REFERENCES Lien_Status (lien_status),
    edit_status            INT              REFERENCES Edit_Status (edit_status),
    application_date_indicator INT
);

INSERT INTO Loan_Application
SELECT p.sequence_number, p.as_of_year, p.respondent_id, p.agency_code, p.loan_type, p.property_type,
       p.loan_purpose, p.owner_occupancy, p.loan_amount_000s, p.preapproval, p.action_taken,
       l.location_id, p.applicant_ethnicity, p.co_applicant_ethnicity, p.applicant_sex, p.co_applicant_sex,
       p.applicant_income_000s, p.purchaser_type, p.rate_spread, p.hoepa_status, p.lien_status,
       p.edit_status, p.application_date_indicator
FROM Preliminary p
JOIN App_Location l ON l.sequence_number = p.sequence_number;

-- =========================================================================
-- 5. 1st normal form join tables: one row per non-empty race / denial reason.
--    The _number column records which original column (1-5 / 1-3) the value
--    came from, so the CSV can be rebuilt exactly.
-- =========================================================================
CREATE TABLE Applicant_Race (
    sequence_number       BIGINT NOT NULL REFERENCES Loan_Application (sequence_number),
    applicant_race_number INT    NOT NULL CHECK (applicant_race_number BETWEEN 1 AND 5),
    applicant_race        INT    NOT NULL REFERENCES Race (race),
    PRIMARY KEY (sequence_number, applicant_race_number)
);
INSERT INTO Applicant_Race
SELECT sequence_number, n, race FROM (
    SELECT sequence_number, 1 AS n, applicant_race_1 AS race FROM Preliminary
    UNION ALL SELECT sequence_number, 2, applicant_race_2 FROM Preliminary
    UNION ALL SELECT sequence_number, 3, applicant_race_3 FROM Preliminary
    UNION ALL SELECT sequence_number, 4, applicant_race_4 FROM Preliminary
    UNION ALL SELECT sequence_number, 5, applicant_race_5 FROM Preliminary
) r WHERE race IS NOT NULL;

CREATE TABLE Co_Applicant_Race (
    sequence_number          BIGINT NOT NULL REFERENCES Loan_Application (sequence_number),
    co_applicant_race_number INT    NOT NULL CHECK (co_applicant_race_number BETWEEN 1 AND 5),
    co_applicant_race        INT    NOT NULL REFERENCES Race (race),
    PRIMARY KEY (sequence_number, co_applicant_race_number)
);
INSERT INTO Co_Applicant_Race
SELECT sequence_number, n, race FROM (
    SELECT sequence_number, 1 AS n, co_applicant_race_1 AS race FROM Preliminary
    UNION ALL SELECT sequence_number, 2, co_applicant_race_2 FROM Preliminary
    UNION ALL SELECT sequence_number, 3, co_applicant_race_3 FROM Preliminary
    UNION ALL SELECT sequence_number, 4, co_applicant_race_4 FROM Preliminary
    UNION ALL SELECT sequence_number, 5, co_applicant_race_5 FROM Preliminary
) r WHERE race IS NOT NULL;

CREATE TABLE Loan_Denial (
    sequence_number      BIGINT NOT NULL REFERENCES Loan_Application (sequence_number),
    denial_reason_number INT    NOT NULL CHECK (denial_reason_number BETWEEN 1 AND 3),
    denial_reason        INT    NOT NULL REFERENCES Denial_Reason (denial_reason),
    PRIMARY KEY (sequence_number, denial_reason_number)
);
INSERT INTO Loan_Denial
SELECT sequence_number, n, denial_reason FROM (
    SELECT sequence_number, 1 AS n, denial_reason_1 AS denial_reason FROM Preliminary
    UNION ALL SELECT sequence_number, 2, denial_reason_2 FROM Preliminary
    UNION ALL SELECT sequence_number, 3, denial_reason_3 FROM Preliminary
) d WHERE denial_reason IS NOT NULL;

COMMIT;
\set ON_ERROR_STOP off

-- quick summary
SELECT 'Loan_Application' AS table_name, COUNT(*) AS row_count FROM Loan_Application
UNION ALL SELECT 'Location', COUNT(*) FROM Location
UNION ALL SELECT 'Applicant_Race', COUNT(*) FROM Applicant_Race
UNION ALL SELECT 'Co_Applicant_Race', COUNT(*) FROM Co_Applicant_Race
UNION ALL SELECT 'Loan_Denial', COUNT(*) FROM Loan_Denial;
