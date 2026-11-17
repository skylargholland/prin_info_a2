-- step2_name_tables.sql
-- CS336 Project 2, Step 2: remove every functional dependency whose right-hand
-- side is a "_name" column. Each code -> name pair moves to its own lookup table,
-- and the main table keeps only the codes (no TEXT column except respondent_id
-- and census_tract_number, which is a location value, not a name).
-- Reads from Preliminary (built by create_preliminary.sql). Run with:  \i step2_name_tables.sql

SET statement_timeout = 0;
BEGIN;

-- start clean (also removes the Step 3 tables if they exist)
DROP TABLE IF EXISTS Loan_Denial, Applicant_Race, Co_Applicant_Race,
    Loan_Application, Location, Edit_Status, MSA,
    Application_Denial_Reason, Application, Null_Columns,
    Agency, Loan_Type, Property_Type, Loan_Purpose, Owner_Occupancy, Preapproval,
    Action_Taken, MSAMD, County, State, Ethnicity, Race, Sex, Purchaser_Type,
    Denial_Reason, HOEPA_Status, Lien_Status CASCADE;

-- ---------------------------------------------------------------------------
-- Lookup tables: code -> name (filled from the data so every name is exact)
-- ---------------------------------------------------------------------------
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

-- msamd_name is empty in the CSV for two codes (35620, 37980), so it may be NULL
CREATE TABLE MSA (msamd INT PRIMARY KEY, msamd_name TEXT);
INSERT INTO MSA SELECT DISTINCT msamd, msamd_name FROM Preliminary WHERE msamd IS NOT NULL;

-- only New Jersey for now, but built so more states can be added later
CREATE TABLE State (
    state_code INT  PRIMARY KEY,
    state_name TEXT NOT NULL,
    state_abbr TEXT NOT NULL
);
INSERT INTO State SELECT DISTINCT state_code, state_name, state_abbr FROM Preliminary WHERE state_code IS NOT NULL;

-- a county code is only unique inside its state
CREATE TABLE County (
    state_code  INT  NOT NULL REFERENCES State (state_code),
    county_code INT  NOT NULL,
    county_name TEXT NOT NULL,
    PRIMARY KEY (state_code, county_code)
);
INSERT INTO County SELECT DISTINCT state_code, county_code, county_name FROM Preliminary WHERE county_code IS NOT NULL;

-- applicant and co-applicant use the same code lists, so they share one table each
CREATE TABLE Ethnicity (ethnicity INT PRIMARY KEY, ethnicity_name TEXT NOT NULL);
INSERT INTO Ethnicity
SELECT applicant_ethnicity, applicant_ethnicity_name FROM Preliminary WHERE applicant_ethnicity IS NOT NULL
UNION
SELECT co_applicant_ethnicity, co_applicant_ethnicity_name FROM Preliminary WHERE co_applicant_ethnicity IS NOT NULL;

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

CREATE TABLE Sex (sex INT PRIMARY KEY, sex_name TEXT NOT NULL);
INSERT INTO Sex
SELECT applicant_sex, applicant_sex_name FROM Preliminary WHERE applicant_sex IS NOT NULL
UNION
SELECT co_applicant_sex, co_applicant_sex_name FROM Preliminary WHERE co_applicant_sex IS NOT NULL;

CREATE TABLE Purchaser_Type (purchaser_type INT PRIMARY KEY, purchaser_type_name TEXT NOT NULL);
INSERT INTO Purchaser_Type SELECT DISTINCT purchaser_type, purchaser_type_name FROM Preliminary WHERE purchaser_type IS NOT NULL;

-- denial_reason_1, _2 and _3 use the same code list
CREATE TABLE Denial_Reason (denial_reason INT PRIMARY KEY, denial_reason_name TEXT NOT NULL);
INSERT INTO Denial_Reason
SELECT denial_reason_1, denial_reason_name_1 FROM Preliminary WHERE denial_reason_1 IS NOT NULL
UNION SELECT denial_reason_2, denial_reason_name_2 FROM Preliminary WHERE denial_reason_2 IS NOT NULL
UNION SELECT denial_reason_3, denial_reason_name_3 FROM Preliminary WHERE denial_reason_3 IS NOT NULL;

CREATE TABLE HOEPA_Status (hoepa_status INT PRIMARY KEY, hoepa_status_name TEXT NOT NULL);
INSERT INTO HOEPA_Status SELECT DISTINCT hoepa_status, hoepa_status_name FROM Preliminary WHERE hoepa_status IS NOT NULL;

CREATE TABLE Lien_Status (lien_status INT PRIMARY KEY, lien_status_name TEXT NOT NULL);
INSERT INTO Lien_Status SELECT DISTINCT lien_status, lien_status_name FROM Preliminary WHERE lien_status IS NOT NULL;

-- edit_status -> edit_status_name (empty in every row of this CSV, so no rows yet)
CREATE TABLE Edit_Status (edit_status INT PRIMARY KEY, edit_status_name TEXT NOT NULL);
INSERT INTO Edit_Status SELECT DISTINCT edit_status, edit_status_name FROM Preliminary WHERE edit_status IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Main table: codes only. Every *_name column is gone.
-- ---------------------------------------------------------------------------
CREATE TABLE Loan_Application (
    sequence_number                 BIGINT  PRIMARY KEY,
    as_of_year                     INT     NOT NULL,
    respondent_id                  TEXT    NOT NULL,
    agency_code                    INT     NOT NULL REFERENCES Agency (agency_code),
    loan_type                      INT     NOT NULL REFERENCES Loan_Type (loan_type),
    property_type                  INT     NOT NULL REFERENCES Property_Type (property_type),
    loan_purpose                   INT     NOT NULL REFERENCES Loan_Purpose (loan_purpose),
    owner_occupancy                INT     NOT NULL REFERENCES Owner_Occupancy (owner_occupancy),
    loan_amount_000s               INT,
    preapproval                    INT     NOT NULL REFERENCES Preapproval (preapproval),
    action_taken                   INT     NOT NULL REFERENCES Action_Taken (action_taken),
    msamd                          INT              REFERENCES MSA (msamd),
    state_code                     INT     NOT NULL REFERENCES State (state_code),
    county_code                    INT,
    census_tract_number            TEXT,
    applicant_ethnicity            INT     NOT NULL REFERENCES Ethnicity (ethnicity),
    co_applicant_ethnicity         INT     NOT NULL REFERENCES Ethnicity (ethnicity),
    applicant_race_1               INT     NOT NULL REFERENCES Race (race),
    applicant_race_2               INT              REFERENCES Race (race),
    applicant_race_3               INT              REFERENCES Race (race),
    applicant_race_4               INT              REFERENCES Race (race),
    applicant_race_5               INT              REFERENCES Race (race),
    co_applicant_race_1            INT     NOT NULL REFERENCES Race (race),
    co_applicant_race_2            INT              REFERENCES Race (race),
    co_applicant_race_3            INT              REFERENCES Race (race),
    co_applicant_race_4            INT              REFERENCES Race (race),
    co_applicant_race_5            INT              REFERENCES Race (race),
    applicant_sex                  INT     NOT NULL REFERENCES Sex (sex),
    co_applicant_sex               INT     NOT NULL REFERENCES Sex (sex),
    applicant_income_000s          INT,
    purchaser_type                 INT     NOT NULL REFERENCES Purchaser_Type (purchaser_type),
    denial_reason_1                INT              REFERENCES Denial_Reason (denial_reason),
    denial_reason_2                INT              REFERENCES Denial_Reason (denial_reason),
    denial_reason_3                INT              REFERENCES Denial_Reason (denial_reason),
    rate_spread                    NUMERIC,
    hoepa_status                   INT     NOT NULL REFERENCES HOEPA_Status (hoepa_status),
    lien_status                    INT     NOT NULL REFERENCES Lien_Status (lien_status),
    population                     INT,
    minority_population            NUMERIC,
    hud_median_family_income       INT,
    tract_to_msamd_income          NUMERIC,
    number_of_owner_occupied_units INT,
    number_of_1_to_4_family_units  INT,
    edit_status                    INT              REFERENCES Edit_Status (edit_status),
    application_date_indicator     INT,
    FOREIGN KEY (state_code, county_code) REFERENCES County (state_code, county_code)
);

INSERT INTO Loan_Application
SELECT sequence_number, as_of_year, respondent_id, agency_code, loan_type, property_type,
       loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
       msamd, state_code, county_code, census_tract_number,
       applicant_ethnicity, co_applicant_ethnicity,
       applicant_race_1, applicant_race_2, applicant_race_3, applicant_race_4, applicant_race_5,
       co_applicant_race_1, co_applicant_race_2, co_applicant_race_3, co_applicant_race_4, co_applicant_race_5,
       applicant_sex, co_applicant_sex, applicant_income_000s, purchaser_type,
       denial_reason_1, denial_reason_2, denial_reason_3, rate_spread, hoepa_status, lien_status,
       population, minority_population, hud_median_family_income, tract_to_msamd_income,
       number_of_owner_occupied_units, number_of_1_to_4_family_units,
       edit_status, application_date_indicator
FROM Preliminary;

COMMIT;
