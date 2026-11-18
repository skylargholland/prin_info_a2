-- step2.sql
-- CS336 Project 2 Step 2
-- Assumes create_data.sql has already been run and Preliminary exists.

SET statement_timeout = 0;

--------------------------------------------------
-- Drop tables if they already exist
--------------------------------------------------

DROP TABLE IF EXISTS Loan_Application CASCADE;
DROP TABLE IF EXISTS Null_Columns CASCADE;
DROP TABLE IF EXISTS Location CASCADE;
DROP TABLE IF EXISTS County CASCADE;
DROP TABLE IF EXISTS State CASCADE;
DROP TABLE IF EXISTS MSAMD CASCADE;

DROP TABLE IF EXISTS Agency CASCADE;
DROP TABLE IF EXISTS Loan_Type CASCADE;
DROP TABLE IF EXISTS Property_Type CASCADE;
DROP TABLE IF EXISTS Loan_Purpose CASCADE;
DROP TABLE IF EXISTS Owner_Occupancy CASCADE;
DROP TABLE IF EXISTS Preapproval CASCADE;
DROP TABLE IF EXISTS Action_Taken CASCADE;
DROP TABLE IF EXISTS ApplicantEthnicity CASCADE;
DROP TABLE IF EXISTS CoApplicantEthnicity CASCADE;
DROP TABLE IF EXISTS ApplicantSex CASCADE;
DROP TABLE IF EXISTS CoApplicantSex CASCADE;
DROP TABLE IF EXISTS Purchaser_Type CASCADE;
DROP TABLE IF EXISTS HOEPA_Status CASCADE;
DROP TABLE IF EXISTS Lien_Status CASCADE;

--------------------------------------------------
-- Lookup Tables
--------------------------------------------------

CREATE TABLE Agency AS
SELECT DISTINCT
    agency_code,
    agency_name,
    agency_abbr
FROM Preliminary;

ALTER TABLE Agency
ADD PRIMARY KEY (agency_code);

--------------------------------------------------

CREATE TABLE Loan_Type AS
SELECT DISTINCT
    loan_type,
    loan_type_name
FROM Preliminary;

ALTER TABLE Loan_Type
ADD PRIMARY KEY (loan_type);

--------------------------------------------------

CREATE TABLE Property_Type AS
SELECT DISTINCT
    property_type,
    property_type_name
FROM Preliminary;

ALTER TABLE Property_Type
ADD PRIMARY KEY (property_type);

--------------------------------------------------

CREATE TABLE Loan_Purpose AS
SELECT DISTINCT
    loan_purpose,
    loan_purpose_name
FROM Preliminary;

ALTER TABLE Loan_Purpose
ADD PRIMARY KEY (loan_purpose);

--------------------------------------------------

CREATE TABLE Owner_Occupancy AS
SELECT DISTINCT
    owner_occupancy,
    owner_occupancy_name
FROM Preliminary;

ALTER TABLE Owner_Occupancy
ADD PRIMARY KEY (owner_occupancy);

--------------------------------------------------

CREATE TABLE Preapproval AS
SELECT DISTINCT
    preapproval,
    preapproval_name
FROM Preliminary;

ALTER TABLE Preapproval
ADD PRIMARY KEY (preapproval);

--------------------------------------------------

CREATE TABLE Action_Taken AS
SELECT DISTINCT
    action_taken,
    action_taken_name
FROM Preliminary;

ALTER TABLE Action_Taken
ADD PRIMARY KEY (action_taken);

--------------------------------------------------

CREATE TABLE ApplicantEthnicity AS
SELECT DISTINCT
    applicant_ethnicity,
    applicant_ethnicity_name
FROM Preliminary;

ALTER TABLE ApplicantEthnicity
ADD PRIMARY KEY (applicant_ethnicity);

--------------------------------------------------

CREATE TABLE CoApplicantEthnicity AS
SELECT DISTINCT
    co_applicant_ethnicity,
    co_applicant_ethnicity_name
FROM Preliminary;

ALTER TABLE CoApplicantEthnicity
ADD PRIMARY KEY (co_applicant_ethnicity);

--------------------------------------------------

CREATE TABLE ApplicantSex AS
SELECT DISTINCT
    applicant_sex,
    applicant_sex_name
FROM Preliminary;

ALTER TABLE ApplicantSex
ADD PRIMARY KEY (applicant_sex);

--------------------------------------------------

CREATE TABLE CoApplicantSex AS
SELECT DISTINCT
    co_applicant_sex,
    co_applicant_sex_name
FROM Preliminary;

ALTER TABLE CoApplicantSex
ADD PRIMARY KEY (co_applicant_sex);

--------------------------------------------------

CREATE TABLE Purchaser_Type AS
SELECT DISTINCT
    purchaser_type,
    purchaser_type_name
FROM Preliminary;

ALTER TABLE PurchaserType
ADD PRIMARY KEY (purchaser_type);

--------------------------------------------------

CREATE TABLE HOEPA_Status AS
SELECT DISTINCT
    hoepa_status,
    hoepa_status_name
FROM Preliminary;

ALTER TABLE HOEPA_Status
ADD PRIMARY KEY (hoepa_status);

--------------------------------------------------

CREATE TABLE Lien_Status AS
SELECT DISTINCT
    lien_status,
    lien_status_name
FROM Preliminary;

ALTER TABLE Lien_Status
ADD PRIMARY KEY (lien_status);

--------------------------------------------------
-- State Table
--------------------------------------------------

CREATE TABLE State AS
SELECT DISTINCT
    state_code,
    state_name,
    state_abbr
FROM Preliminary;

ALTER TABLE State
ADD PRIMARY KEY (state_code);

--------------------------------------------------
-- County Table
--------------------------------------------------

CREATE TABLE County AS
SELECT DISTINCT
    state_code,
    county_code,
    county_name
FROM Preliminary
WHERE county_code IS NOT NULL;

ALTER TABLE County
ADD PRIMARY KEY (state_code, county_code);

--------------------------------------------------
-- MSAMD Table
--------------------------------------------------

CREATE TABLE MSAMD AS
SELECT DISTINCT
    msamd,
    msamd_name
FROM Preliminary
WHERE msamd IS NOT NULL;

ALTER TABLE MSAMD
ADD PRIMARY KEY (msamd);

--------------------------------------------------
-- Location Table
--------------------------------------------------

CREATE TABLE Location AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            state_code,
            county_code,
            msamd,
            census_tract_number
    ) AS location_id,

    state_code,
    county_code,
    msamd,
    census_tract_number,
    population,
    minority_population,
    hud_median_family_income,
    tract_to_msamd_income,
    number_of_owner_occupied_units,
    number_of_1_to_4_family_units

FROM (
    SELECT DISTINCT
        state_code,
        county_code,
        msamd,
        census_tract_number,
        population,
        minority_population,
        hud_median_family_income,
        tract_to_msamd_income,
        number_of_owner_occupied_units,
        number_of_1_to_4_family_units
    FROM Preliminary
) loc;

ALTER TABLE Location
ADD PRIMARY KEY (location_id);

--------------------------------------------------
-- Blank Columns Table
--------------------------------------------------

CREATE TABLE Null_Columns AS
SELECT DISTINCT
    edit_status,
    edit_status_name,
    application_date_indicator
FROM Preliminary;

--------------------------------------------------
-- Main Loan_Application Table
--------------------------------------------------

CREATE TABLE Loan_Application AS
SELECT
    p.sequence_number,
    p.as_of_year,
    p.respondent_id,

    p.agency_code,
    p.loan_type,
    p.property_type,
    p.loan_purpose,
    p.owner_occupancy,

    p.loan_amount_000s,

    p.preapproval,
    p.action_taken,

    l.location_id,

    p.applicant_ethnicity,
    p.co_applicant_ethnicity,

    p.applicant_race_1,
    p.applicant_race_2,
    p.applicant_race_3,
    p.applicant_race_4,
    p.applicant_race_5,

    p.co_applicant_race_1,
    p.co_applicant_race_2,
    p.co_applicant_race_3,
    p.co_applicant_race_4,
    p.co_applicant_race_5,

    p.applicant_sex,
    p.co_applicant_sex,

    p.applicant_income_000s,

    p.purchaser_type,

    p.denial_reason_1,
    p.denial_reason_2,
    p.denial_reason_3,

    p.rate_spread,

    p.hoepa_status,
    p.lien_status

FROM Preliminary p
JOIN Location l
ON p.state_code = l.state_code
AND (
    (p.county_code = l.county_code)
    OR
    (p.county_code IS NULL AND l.county_code IS NULL)
)
AND (
    (p.msamd = l.msamd)
    OR
    (p.msamd IS NULL AND l.msamd IS NULL)
)
AND (
    (p.census_tract_number = l.census_tract_number)
    OR
    (p.census_tract_number IS NULL AND l.census_tract_number IS NULL)
)
AND (
    (p.population = l.population)
    OR
    (p.population IS NULL AND l.population IS NULL)
)
AND (
    (p.minority_population = l.minority_population)
    OR
    (p.minority_population IS NULL AND l.minority_population IS NULL)
)
AND (
    (p.hud_median_family_income = l.hud_median_family_income)
    OR
    (p.hud_median_family_income IS NULL AND l.hud_median_family_income IS NULL)
)
AND (
    (p.tract_to_msamd_income = l.tract_to_msamd_income)
    OR
    (p.tract_to_msamd_income IS NULL AND l.tract_to_msamd_income IS NULL)
)
AND (
    (p.number_of_owner_occupied_units = l.number_of_owner_occupied_units)
    OR
    (p.number_of_owner_occupied_units IS NULL
     AND l.number_of_owner_occupied_units IS NULL)
)
AND (
    (p.number_of_1_to_4_family_units = l.number_of_1_to_4_family_units)
    OR
    (p.number_of_1_to_4_family_units IS NULL
     AND l.number_of_1_to_4_family_units IS NULL)
);

ALTER TABLE Loan_Application
ADD PRIMARY KEY (sequence_number);

--------------------------------------------------
-- Foreign Keys
--------------------------------------------------

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_location
FOREIGN KEY (location_id)
REFERENCES Location(location_id);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_agency
FOREIGN KEY (agency_code)
REFERENCES Agency(agency_code);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_loan_type
FOREIGN KEY (loan_type)
REFERENCES Loan_Type(loan_type);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_property_type
FOREIGN KEY (property_type)
REFERENCES Property_Type(property_type);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_loan_purpose
FOREIGN KEY (loan_purpose)
REFERENCES Loan_Purpose(loan_purpose);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_owner_occupancy
FOREIGN KEY (owner_occupancy)
REFERENCES Owner_Occupancy(owner_occupancy);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_preapproval
FOREIGN KEY (preapproval)
REFERENCES Preapproval(preapproval);

ALTER TABLE Loan_Application
ADD CONSTRAINT fk_application_action_taken
FOREIGN KEY (action_taken)
REFERENCES Action_Taken(action_taken);