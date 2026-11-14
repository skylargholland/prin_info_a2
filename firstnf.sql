-- firstnf.sql
-- Converts Preliminary into First Normal Form (1NF)

DROP TABLE IF EXISTS DenialReason;
DROP TABLE IF EXISTS CoApplicantRace;
DROP TABLE IF EXISTS ApplicantRace;
DROP TABLE IF EXISTS Loan1NF;

----------------------------------------------------
-- Create Location lookup table
----------------------------------------------------

CREATE TABLE Location AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY state_code, county_code, census_tract_number
    ) AS location_id,
    state_code,
    county_code,
    census_tract_number
FROM (
    SELECT DISTINCT
        state_code,
        county_code,
        census_tract_number
    FROM Preliminary
) loc;

ALTER TABLE Location
ADD PRIMARY KEY (location_id);

----------------------------------------------------
-- Main Loan Table
----------------------------------------------------

CREATE TABLE Loan1NF AS
SELECT
    sequence_number,

    L.location_id,
    
    as_of_year,
    respondent_id,
    agency_name,
    agency_abbr,
    agency_code,

    loan_type_name,
    loan_type,

    property_type_name,
    property_type,

    loan_purpose_name,
    loan_purpose,

    owner_occupancy_name,
    owner_occupancy,

    loan_amount_000s,

    preapproval_name,
    preapproval,

    action_taken_name,
    action_taken,

    msamd_name,
    msamd,

    state_name,
    state_abbr,
    state_code,

    county_name,
    county_code,

    census_tract_number,

    applicant_ethnicity_name,
    applicant_ethnicity,

    co_applicant_ethnicity_name,
    co_applicant_ethnicity,

    applicant_sex_name,
    applicant_sex,

    co_applicant_sex_name,
    co_applicant_sex,

    applicant_income_000s,

    purchaser_type_name,
    purchaser_type,

    rate_spread,

    hoepa_status_name,
    hoepa_status,

    lien_status_name,
    lien_status,

    edit_status_name,
    edit_status,

    population,
    minority_population,
    hud_median_family_income,
    tract_to_msamd_income,

    number_of_owner_occupied_units,
    number_of_1_to_4_family_units,

    application_date_indicator

FROM Preliminary P
JOIN Location L
ON P.state_code = L.state_code
AND P.county_code = L.county_code
AND P.census_tract_number = L.census_tract_number;

ALTER TABLE Loan1NF
ADD PRIMARY KEY (sequence_number);

----------------------------------------------------
-- Applicant Race Table
----------------------------------------------------

CREATE TABLE ApplicantRace (
    sequence_number BIGINT,
    race_name TEXT,
    race_code INT
);

INSERT INTO ApplicantRace
SELECT sequence_number, applicant_race_name_1, applicant_race_1
FROM Preliminary
WHERE applicant_race_name_1 IS NOT NULL

UNION ALL

SELECT sequence_number, applicant_race_name_2, applicant_race_2
FROM Preliminary
WHERE applicant_race_name_2 IS NOT NULL

UNION ALL

SELECT sequence_number, applicant_race_name_3, applicant_race_3
FROM Preliminary
WHERE applicant_race_name_3 IS NOT NULL

UNION ALL

SELECT sequence_number, applicant_race_name_4, applicant_race_4
FROM Preliminary
WHERE applicant_race_name_4 IS NOT NULL

UNION ALL

SELECT sequence_number, applicant_race_name_5, applicant_race_5
FROM Preliminary
WHERE applicant_race_name_5 IS NOT NULL;

ALTER TABLE ApplicantRace
ADD FOREIGN KEY (sequence_number)
REFERENCES Loan1NF(sequence_number);

----------------------------------------------------
-- Co-Applicant Race Table
----------------------------------------------------

CREATE TABLE CoApplicantRace (
    sequence_number BIGINT,
    race_name TEXT,
    race_code INT
);

INSERT INTO CoApplicantRace
SELECT sequence_number, co_applicant_race_name_1, co_applicant_race_1
FROM Preliminary
WHERE co_applicant_race_name_1 IS NOT NULL

UNION ALL

SELECT sequence_number, co_applicant_race_name_2, co_applicant_race_2
FROM Preliminary
WHERE co_applicant_race_name_2 IS NOT NULL

UNION ALL

SELECT sequence_number, co_applicant_race_name_3, co_applicant_race_3
FROM Preliminary
WHERE co_applicant_race_name_3 IS NOT NULL

UNION ALL

SELECT sequence_number, co_applicant_race_name_4, co_applicant_race_4
FROM Preliminary
WHERE co_applicant_race_name_4 IS NOT NULL

UNION ALL

SELECT sequence_number, co_applicant_race_name_5, co_applicant_race_5
FROM Preliminary
WHERE co_applicant_race_name_5 IS NOT NULL;

ALTER TABLE CoApplicantRace
ADD FOREIGN KEY (sequence_number)
REFERENCES Loan1NF(sequence_number);

----------------------------------------------------
-- Denial Reasons Table
----------------------------------------------------

CREATE TABLE DenialReason (
    sequence_number BIGINT,
    denial_reason_name TEXT,
    denial_reason_code INT
);

INSERT INTO DenialReason
SELECT sequence_number, denial_reason_name_1, denial_reason_1
FROM Preliminary
WHERE denial_reason_name_1 IS NOT NULL

UNION ALL

SELECT sequence_number, denial_reason_name_2, denial_reason_2
FROM Preliminary
WHERE denial_reason_name_2 IS NOT NULL

UNION ALL

SELECT sequence_number, denial_reason_name_3, denial_reason_3
FROM Preliminary
WHERE denial_reason_name_3 IS NOT NULL;

ALTER TABLE DenialReason
ADD FOREIGN KEY (sequence_number)
REFERENCES Loan1NF(sequence_number);