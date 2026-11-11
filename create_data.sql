-- create_load.sql
-- Project 1 (CS336): load the HMDA 2017 nationwide CSV into Preliminary.
-- Run inside psql, started from the folder that holds the CSV:
--     \i create_load.sql

SET statement_timeout = 0;

DROP TABLE IF EXISTS Preliminary;

-- Step 1: create the table with every column as TEXT.
-- Loading as TEXT first means the \copy below can never fail on a bad value;
-- we fix the real types afterward in Step 3.
CREATE TABLE Preliminary (
    as_of_year TEXT,
    respondent_id TEXT,
    agency_name TEXT,
    agency_abbr TEXT,
    agency_code TEXT,
    loan_type_name TEXT,
    loan_type TEXT,
    property_type_name TEXT,
    property_type TEXT,
    loan_purpose_name TEXT,
    loan_purpose TEXT,
    owner_occupancy_name TEXT,
    owner_occupancy TEXT,
    loan_amount_000s TEXT,
    preapproval_name TEXT,
    preapproval TEXT,
    action_taken_name TEXT,
    action_taken TEXT,
    msamd_name TEXT,
    msamd TEXT,
    state_name TEXT,
    state_abbr TEXT,
    state_code TEXT,
    county_name TEXT,
    county_code TEXT,
    census_tract_number TEXT,
    applicant_ethnicity_name TEXT,
    applicant_ethnicity TEXT,
    co_applicant_ethnicity_name TEXT,
    co_applicant_ethnicity TEXT,
    applicant_race_name_1 TEXT,
    applicant_race_1 TEXT,
    applicant_race_name_2 TEXT,
    applicant_race_2 TEXT,
    applicant_race_name_3 TEXT,
    applicant_race_3 TEXT,
    applicant_race_name_4 TEXT,
    applicant_race_4 TEXT,
    applicant_race_name_5 TEXT,
    applicant_race_5 TEXT,
    co_applicant_race_name_1 TEXT,
    co_applicant_race_1 TEXT,
    co_applicant_race_name_2 TEXT,
    co_applicant_race_2 TEXT,
    co_applicant_race_name_3 TEXT,
    co_applicant_race_3 TEXT,
    co_applicant_race_name_4 TEXT,
    co_applicant_race_4 TEXT,
    co_applicant_race_name_5 TEXT,
    co_applicant_race_5 TEXT,
    applicant_sex_name TEXT,
    applicant_sex TEXT,
    co_applicant_sex_name TEXT,
    co_applicant_sex TEXT,
    applicant_income_000s TEXT,
    purchaser_type_name TEXT,
    purchaser_type TEXT,
    denial_reason_name_1 TEXT,
    denial_reason_1 TEXT,
    denial_reason_name_2 TEXT,
    denial_reason_2 TEXT,
    denial_reason_name_3 TEXT,
    denial_reason_3 TEXT,
    rate_spread TEXT,
    hoepa_status_name TEXT,
    hoepa_status TEXT,
    lien_status_name TEXT,
    lien_status TEXT,
    edit_status_name TEXT,
    edit_status TEXT,
    sequence_number TEXT,
    population TEXT,
    minority_population TEXT,
    hud_median_family_income TEXT,
    tract_to_msamd_income TEXT,
    number_of_owner_occupied_units TEXT,
    number_of_1_to_4_family_units TEXT,
    application_date_indicator TEXT,
    load_order BIGSERIAL
);

-- Step 2: load the CSV. Adjust the filename below if yours differs.
\copy Preliminary (as_of_year, respondent_id, agency_name, agency_abbr, agency_code, loan_type_name, loan_type, property_type_name, property_type, loan_purpose_name, loan_purpose, owner_occupancy_name, owner_occupancy, loan_amount_000s, preapproval_name, preapproval, action_taken_name, action_taken, msamd_name, msamd, state_name, state_abbr, state_code, county_name, county_code, census_tract_number, applicant_ethnicity_name, applicant_ethnicity, co_applicant_ethnicity_name, co_applicant_ethnicity, applicant_race_name_1, applicant_race_1, applicant_race_name_2, applicant_race_2, applicant_race_name_3, applicant_race_3, applicant_race_name_4, applicant_race_4, applicant_race_name_5, applicant_race_5, co_applicant_race_name_1, co_applicant_race_1, co_applicant_race_name_2, co_applicant_race_2, co_applicant_race_name_3, co_applicant_race_3, co_applicant_race_name_4, co_applicant_race_4, co_applicant_race_name_5, co_applicant_race_5, applicant_sex_name, applicant_sex, co_applicant_sex_name, co_applicant_sex, applicant_income_000s, purchaser_type_name, purchaser_type, denial_reason_name_1, denial_reason_1, denial_reason_name_2, denial_reason_2, denial_reason_name_3, denial_reason_3, rate_spread, hoepa_status_name, hoepa_status, lien_status_name, lien_status, edit_status_name, edit_status, sequence_number, population, minority_population, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units, application_date_indicator) FROM 'hmda_2017_nj_all-records_labels.csv' WITH (FORMAT csv, HEADER true)

-- Step 3: cast columns to their correct types.
--   INT     : codes, counts, years, dollar amounts (in thousands)
--   NUMERIC : decimals (rate_spread, minority_population, tract_to_msamd_income)
--   TEXT    : plain-language "_name" columns, IDs, and abbreviations
-- NULLIF(col, '') turns empty strings into NULL before casting, since many
-- rows leave some fields blank (e.g. rate_spread is only set for high-cost loans).


ALTER TABLE Preliminary
    ALTER COLUMN as_of_year TYPE INT USING NULLIF(as_of_year, '')::INT,
    ALTER COLUMN agency_code TYPE INT USING NULLIF(agency_code, '')::INT,
    ALTER COLUMN loan_type TYPE INT USING NULLIF(loan_type, '')::INT,
    ALTER COLUMN property_type TYPE INT USING NULLIF(property_type, '')::INT,
    ALTER COLUMN loan_purpose TYPE INT USING NULLIF(loan_purpose, '')::INT,
    ALTER COLUMN owner_occupancy TYPE INT USING NULLIF(owner_occupancy, '')::INT,
    ALTER COLUMN loan_amount_000s TYPE INT USING NULLIF(loan_amount_000s, '')::INT,
    ALTER COLUMN preapproval TYPE INT USING NULLIF(preapproval, '')::INT,
    ALTER COLUMN action_taken TYPE INT USING NULLIF(action_taken, '')::INT,
    ALTER COLUMN msamd TYPE INT USING NULLIF(msamd, '')::INT,
    ALTER COLUMN state_code TYPE INT USING NULLIF(state_code, '')::INT,
    ALTER COLUMN county_code TYPE INT USING NULLIF(county_code, '')::INT,
    ALTER COLUMN applicant_ethnicity TYPE INT USING NULLIF(applicant_ethnicity, '')::INT,
    ALTER COLUMN co_applicant_ethnicity TYPE INT USING NULLIF(co_applicant_ethnicity, '')::INT,
    ALTER COLUMN applicant_race_1 TYPE INT USING NULLIF(applicant_race_1, '')::INT,
    ALTER COLUMN applicant_race_2 TYPE INT USING NULLIF(applicant_race_2, '')::INT,
    ALTER COLUMN applicant_race_3 TYPE INT USING NULLIF(applicant_race_3, '')::INT,
    ALTER COLUMN applicant_race_4 TYPE INT USING NULLIF(applicant_race_4, '')::INT,
    ALTER COLUMN applicant_race_5 TYPE INT USING NULLIF(applicant_race_5, '')::INT,
    ALTER COLUMN co_applicant_race_1 TYPE INT USING NULLIF(co_applicant_race_1, '')::INT,
    ALTER COLUMN co_applicant_race_2 TYPE INT USING NULLIF(co_applicant_race_2, '')::INT,
    ALTER COLUMN co_applicant_race_3 TYPE INT USING NULLIF(co_applicant_race_3, '')::INT,
    ALTER COLUMN co_applicant_race_4 TYPE INT USING NULLIF(co_applicant_race_4, '')::INT,
    ALTER COLUMN co_applicant_race_5 TYPE INT USING NULLIF(co_applicant_race_5, '')::INT,
    ALTER COLUMN applicant_sex TYPE INT USING NULLIF(applicant_sex, '')::INT,
    ALTER COLUMN co_applicant_sex TYPE INT USING NULLIF(co_applicant_sex, '')::INT,
    ALTER COLUMN applicant_income_000s TYPE INT USING NULLIF(applicant_income_000s, '')::INT,
    ALTER COLUMN purchaser_type TYPE INT USING NULLIF(purchaser_type, '')::INT,
    ALTER COLUMN denial_reason_1 TYPE INT USING NULLIF(denial_reason_1, '')::INT,
    ALTER COLUMN denial_reason_2 TYPE INT USING NULLIF(denial_reason_2, '')::INT,
    ALTER COLUMN denial_reason_3 TYPE INT USING NULLIF(denial_reason_3, '')::INT,
    ALTER COLUMN hoepa_status TYPE INT USING NULLIF(hoepa_status, '')::INT,
    ALTER COLUMN lien_status TYPE INT USING NULLIF(lien_status, '')::INT,
    ALTER COLUMN edit_status TYPE INT USING NULLIF(edit_status, '')::INT,
    ALTER COLUMN population TYPE INT USING NULLIF(population, '')::INT,
    ALTER COLUMN hud_median_family_income TYPE INT USING NULLIF(hud_median_family_income, '')::INT,
    ALTER COLUMN number_of_owner_occupied_units TYPE INT USING NULLIF(number_of_owner_occupied_units, '')::INT,
    ALTER COLUMN number_of_1_to_4_family_units TYPE INT USING NULLIF(number_of_1_to_4_family_units, '')::INT,
    ALTER COLUMN application_date_indicator TYPE INT USING NULLIF(application_date_indicator, '')::INT,
    ALTER COLUMN minority_population TYPE NUMERIC USING NULLIF(minority_population, '')::NUMERIC,
    ALTER COLUMN rate_spread TYPE NUMERIC USING NULLIF(rate_spread, '')::NUMERIC,
    ALTER COLUMN tract_to_msamd_income TYPE NUMERIC USING NULLIF(tract_to_msamd_income, '')::NUMERIC;

-- Step 4: keep the COPY order as the primary key for an ordered export.
ALTER TABLE Preliminary DROP COLUMN sequence_number;
ALTER TABLE Preliminary RENAME COLUMN load_order TO sequence_number;
ALTER TABLE Preliminary ADD PRIMARY KEY (sequence_number);