-- CS336 Project 2, Step 3: build the normalized schema directly from Preliminary.
-- Run inside psql after create_data.sql: \i step3_normalize.sql

SET statement_timeout = 0;
\set ON_ERROR_STOP on
BEGIN;

DROP TABLE IF EXISTS
    ApplicationDenialReason,
    CoApplicantRace,
    ApplicantRace,
    Application,
    Race,
    DenialReasonType,
    Location,
    State,
    County,
    MSAMD,
    Agency,
    LoanType,
    PropertyType,
    LoanPurpose,
    OwnerOccupancy,
    Preapproval,
    ActionTaken,
    ApplicantEthnicity,
    CoApplicantEthnicity,
    ApplicantSex,
    CoApplicantSex,
    PurchaserType,
    HOEPAStatus,
    LienStatus,
    Questionnaire
CASCADE;

CREATE TABLE Agency (
    agency_code INT PRIMARY KEY,
    agency_name TEXT,
    agency_abbr TEXT
);
INSERT INTO Agency
SELECT DISTINCT agency_code, agency_name, agency_abbr
FROM Preliminary
WHERE agency_code IS NOT NULL;

CREATE TABLE LoanType (
    loan_type INT PRIMARY KEY,
    loan_type_name TEXT
);
INSERT INTO LoanType
SELECT DISTINCT loan_type, loan_type_name
FROM Preliminary
WHERE loan_type IS NOT NULL;

CREATE TABLE PropertyType (
    property_type INT PRIMARY KEY,
    property_type_name TEXT
);
INSERT INTO PropertyType
SELECT DISTINCT property_type, property_type_name
FROM Preliminary
WHERE property_type IS NOT NULL;

CREATE TABLE LoanPurpose (
    loan_purpose INT PRIMARY KEY,
    loan_purpose_name TEXT
);
INSERT INTO LoanPurpose
SELECT DISTINCT loan_purpose, loan_purpose_name
FROM Preliminary
WHERE loan_purpose IS NOT NULL;

CREATE TABLE OwnerOccupancy (
    owner_occupancy INT PRIMARY KEY,
    owner_occupancy_name TEXT
);
INSERT INTO OwnerOccupancy
SELECT DISTINCT owner_occupancy, owner_occupancy_name
FROM Preliminary
WHERE owner_occupancy IS NOT NULL;

CREATE TABLE Preapproval (
    preapproval INT PRIMARY KEY,
    preapproval_name TEXT
);
INSERT INTO Preapproval
SELECT DISTINCT preapproval, preapproval_name
FROM Preliminary
WHERE preapproval IS NOT NULL;

CREATE TABLE ActionTaken (
    action_taken INT PRIMARY KEY,
    action_taken_name TEXT
);
INSERT INTO ActionTaken
SELECT DISTINCT action_taken, action_taken_name
FROM Preliminary
WHERE action_taken IS NOT NULL;

CREATE TABLE ApplicantEthnicity (
    applicant_ethnicity INT PRIMARY KEY,
    applicant_ethnicity_name TEXT
);
INSERT INTO ApplicantEthnicity
SELECT DISTINCT applicant_ethnicity, applicant_ethnicity_name
FROM Preliminary
WHERE applicant_ethnicity IS NOT NULL;

CREATE TABLE CoApplicantEthnicity (
    co_applicant_ethnicity INT PRIMARY KEY,
    co_applicant_ethnicity_name TEXT
);
INSERT INTO CoApplicantEthnicity
SELECT DISTINCT co_applicant_ethnicity, co_applicant_ethnicity_name
FROM Preliminary
WHERE co_applicant_ethnicity IS NOT NULL;

CREATE TABLE ApplicantSex (
    applicant_sex INT PRIMARY KEY,
    applicant_sex_name TEXT
);
INSERT INTO ApplicantSex
SELECT DISTINCT applicant_sex, applicant_sex_name
FROM Preliminary
WHERE applicant_sex IS NOT NULL;

CREATE TABLE CoApplicantSex (
    co_applicant_sex INT PRIMARY KEY,
    co_applicant_sex_name TEXT
);
INSERT INTO CoApplicantSex
SELECT DISTINCT co_applicant_sex, co_applicant_sex_name
FROM Preliminary
WHERE co_applicant_sex IS NOT NULL;

CREATE TABLE PurchaserType (
    purchaser_type INT PRIMARY KEY,
    purchaser_type_name TEXT
);
INSERT INTO PurchaserType
SELECT DISTINCT purchaser_type, purchaser_type_name
FROM Preliminary
WHERE purchaser_type IS NOT NULL;

CREATE TABLE HOEPAStatus (
    hoepa_status INT PRIMARY KEY,
    hoepa_status_name TEXT
);
INSERT INTO HOEPAStatus
SELECT DISTINCT hoepa_status, hoepa_status_name
FROM Preliminary
WHERE hoepa_status IS NOT NULL;

CREATE TABLE LienStatus (
    lien_status INT PRIMARY KEY,
    lien_status_name TEXT
);
INSERT INTO LienStatus
SELECT DISTINCT lien_status, lien_status_name
FROM Preliminary
WHERE lien_status IS NOT NULL;

CREATE TABLE State (
    state_code INT PRIMARY KEY,
    state_name TEXT,
    state_abbr TEXT
);
INSERT INTO State
SELECT DISTINCT state_code, state_name, state_abbr
FROM Preliminary
WHERE state_code IS NOT NULL;

CREATE TABLE County (
    state_code INT NOT NULL REFERENCES State (state_code),
    county_code INT NOT NULL,
    county_name TEXT,
    PRIMARY KEY (state_code, county_code)
);
INSERT INTO County
SELECT DISTINCT state_code, county_code, county_name
FROM Preliminary
WHERE state_code IS NOT NULL
  AND county_code IS NOT NULL;

CREATE TABLE MSAMD (
    msamd INT PRIMARY KEY,
    msamd_name TEXT
);
INSERT INTO MSAMD
SELECT DISTINCT msamd, msamd_name
FROM Preliminary
WHERE msamd IS NOT NULL;

CREATE TABLE Location (
    location_id INT PRIMARY KEY,
    state_code INT NOT NULL REFERENCES State (state_code),
    county_code INT,
    msamd INT REFERENCES MSAMD (msamd),
    census_tract_number TEXT,
    population INT,
    minority_population NUMERIC,
    hud_median_family_income INT,
    tract_to_msamd_income NUMERIC,
    number_of_owner_occupied_units INT,
    number_of_1_to_4_family_units INT,
    FOREIGN KEY (state_code, county_code)
        REFERENCES County (state_code, county_code)
);

INSERT INTO Location (
    location_id,
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
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY state_code, county_code, msamd, census_tract_number,
                 population, minority_population, hud_median_family_income,
                 tract_to_msamd_income, number_of_owner_occupied_units,
                 number_of_1_to_4_family_units
    )::INT,
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
) AS distinct_locations;

CREATE TABLE Race (
    race_code INT PRIMARY KEY,
    race_name TEXT
);
INSERT INTO Race (race_code, race_name)
SELECT DISTINCT race_code, race_name
FROM (
    SELECT applicant_race_1 AS race_code, applicant_race_name_1 AS race_name FROM Preliminary
    UNION ALL
    SELECT applicant_race_2, applicant_race_name_2 FROM Preliminary
    UNION ALL
    SELECT applicant_race_3, applicant_race_name_3 FROM Preliminary
    UNION ALL
    SELECT applicant_race_4, applicant_race_name_4 FROM Preliminary
    UNION ALL
    SELECT applicant_race_5, applicant_race_name_5 FROM Preliminary
    UNION ALL
    SELECT co_applicant_race_1, co_applicant_race_name_1 FROM Preliminary
    UNION ALL
    SELECT co_applicant_race_2, co_applicant_race_name_2 FROM Preliminary
    UNION ALL
    SELECT co_applicant_race_3, co_applicant_race_name_3 FROM Preliminary
    UNION ALL
    SELECT co_applicant_race_4, co_applicant_race_name_4 FROM Preliminary
    UNION ALL
    SELECT co_applicant_race_5, co_applicant_race_name_5 FROM Preliminary
) AS all_races
WHERE race_code IS NOT NULL;

CREATE TABLE DenialReasonType (
    denial_reason_code INT PRIMARY KEY,
    denial_reason_name TEXT
);
INSERT INTO DenialReasonType (denial_reason_code, denial_reason_name)
SELECT DISTINCT denial_reason_code, denial_reason_name
FROM (
    SELECT denial_reason_1 AS denial_reason_code, denial_reason_name_1 AS denial_reason_name FROM Preliminary
    UNION ALL
    SELECT denial_reason_2, denial_reason_name_2 FROM Preliminary
    UNION ALL
    SELECT denial_reason_3, denial_reason_name_3 FROM Preliminary
) AS all_denial_reasons
WHERE denial_reason_code IS NOT NULL;

CREATE TABLE Questionnaire (
    edit_status INT,
    edit_status_name TEXT,
    application_date_indicator INT
);
COMMENT ON TABLE Questionnaire IS
    'REVIEW: These fields appear constant throughout the dataset. Questionnaire table retained solely to preserve original CSV contents and allow lossless reconstruction.';
INSERT INTO Questionnaire
SELECT DISTINCT edit_status, edit_status_name, application_date_indicator
FROM Preliminary;

CREATE TABLE Application (
    sequence_number BIGINT PRIMARY KEY,
    as_of_year INT,
    respondent_id TEXT,
    agency_code INT REFERENCES Agency (agency_code),
    loan_type INT REFERENCES LoanType (loan_type),
    property_type INT REFERENCES PropertyType (property_type),
    loan_purpose INT REFERENCES LoanPurpose (loan_purpose),
    owner_occupancy INT REFERENCES OwnerOccupancy (owner_occupancy),
    loan_amount_000s INT,
    preapproval INT REFERENCES Preapproval (preapproval),
    action_taken INT REFERENCES ActionTaken (action_taken),
    location_id INT REFERENCES Location (location_id),
    applicant_ethnicity INT REFERENCES ApplicantEthnicity (applicant_ethnicity),
    co_applicant_ethnicity INT REFERENCES CoApplicantEthnicity (co_applicant_ethnicity),
    applicant_sex INT REFERENCES ApplicantSex (applicant_sex),
    co_applicant_sex INT REFERENCES CoApplicantSex (co_applicant_sex),
    applicant_income_000s INT,
    purchaser_type INT REFERENCES PurchaserType (purchaser_type),
    rate_spread NUMERIC,
    hoepa_status INT REFERENCES HOEPAStatus (hoepa_status),
    lien_status INT REFERENCES LienStatus (lien_status)
);

INSERT INTO Application (
    sequence_number,
    as_of_year,
    respondent_id,
    agency_code,
    loan_type,
    property_type,
    loan_purpose,
    owner_occupancy,
    loan_amount_000s,
    preapproval,
    action_taken,
    location_id,
    applicant_ethnicity,
    co_applicant_ethnicity,
    applicant_sex,
    co_applicant_sex,
    applicant_income_000s,
    purchaser_type,
    rate_spread,
    hoepa_status,
    lien_status
)
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
    p.applicant_sex,
    p.co_applicant_sex,
    p.applicant_income_000s,
    p.purchaser_type,
    p.rate_spread,
    p.hoepa_status,
    p.lien_status
FROM Preliminary AS p
JOIN Location AS l
  ON p.state_code IS NOT DISTINCT FROM l.state_code
 AND p.county_code IS NOT DISTINCT FROM l.county_code
 AND p.msamd IS NOT DISTINCT FROM l.msamd
 AND p.census_tract_number IS NOT DISTINCT FROM l.census_tract_number
 AND p.population IS NOT DISTINCT FROM l.population
 AND p.minority_population IS NOT DISTINCT FROM l.minority_population
 AND p.hud_median_family_income IS NOT DISTINCT FROM l.hud_median_family_income
 AND p.tract_to_msamd_income IS NOT DISTINCT FROM l.tract_to_msamd_income
 AND p.number_of_owner_occupied_units IS NOT DISTINCT FROM l.number_of_owner_occupied_units
 AND p.number_of_1_to_4_family_units IS NOT DISTINCT FROM l.number_of_1_to_4_family_units;

CREATE TABLE ApplicantRace (
    sequence_number BIGINT REFERENCES Application (sequence_number),
    race_number INT CHECK (race_number BETWEEN 1 AND 5),
    race_code INT REFERENCES Race (race_code),
    PRIMARY KEY (sequence_number, race_number)
);
INSERT INTO ApplicantRace (sequence_number, race_number, race_code)
SELECT sequence_number, race_number, race_code
FROM (
    SELECT sequence_number, 1 AS race_number, applicant_race_1 AS race_code FROM Preliminary
    UNION ALL
    SELECT sequence_number, 2, applicant_race_2 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 3, applicant_race_3 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 4, applicant_race_4 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 5, applicant_race_5 FROM Preliminary
) AS applicant_races
WHERE race_code IS NOT NULL;

CREATE TABLE CoApplicantRace (
    sequence_number BIGINT REFERENCES Application (sequence_number),
    race_number INT CHECK (race_number BETWEEN 1 AND 5),
    race_code INT REFERENCES Race (race_code),
    PRIMARY KEY (sequence_number, race_number)
);
INSERT INTO CoApplicantRace (sequence_number, race_number, race_code)
SELECT sequence_number, race_number, race_code
FROM (
    SELECT sequence_number, 1 AS race_number, co_applicant_race_1 AS race_code FROM Preliminary
    UNION ALL
    SELECT sequence_number, 2, co_applicant_race_2 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 3, co_applicant_race_3 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 4, co_applicant_race_4 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 5, co_applicant_race_5 FROM Preliminary
) AS co_applicant_races
WHERE race_code IS NOT NULL;

CREATE TABLE ApplicationDenialReason (
    sequence_number BIGINT REFERENCES Application (sequence_number),
    denial_reason_number INT CHECK (denial_reason_number BETWEEN 1 AND 3),
    denial_reason_code INT REFERENCES DenialReasonType (denial_reason_code),
    PRIMARY KEY (sequence_number, denial_reason_number)
);
INSERT INTO ApplicationDenialReason (
    sequence_number,
    denial_reason_number,
    denial_reason_code
)
SELECT sequence_number, denial_reason_number, denial_reason_code
FROM (
    SELECT sequence_number, 1 AS denial_reason_number, denial_reason_1 AS denial_reason_code FROM Preliminary
    UNION ALL
    SELECT sequence_number, 2, denial_reason_2 FROM Preliminary
    UNION ALL
    SELECT sequence_number, 3, denial_reason_3 FROM Preliminary
) AS application_denial_reasons
WHERE denial_reason_code IS NOT NULL;

COMMIT;

-- Row-count and duplicate-key validation.
SELECT 'Preliminary' AS table_name, COUNT(*) AS row_count FROM Preliminary
UNION ALL
SELECT 'Application', COUNT(*) FROM Application;

SELECT 'ApplicantRace' AS table_name, COUNT(*) AS row_count FROM ApplicantRace
UNION ALL
SELECT 'CoApplicantRace', COUNT(*) FROM CoApplicantRace
UNION ALL
SELECT 'ApplicationDenialReason', COUNT(*) FROM ApplicationDenialReason
UNION ALL
SELECT 'Location', COUNT(*) FROM Location
UNION ALL
SELECT 'Questionnaire', COUNT(*) FROM Questionnaire;

SELECT table_name, key_value, copies
FROM (
    SELECT 'Agency' AS table_name, agency_code::TEXT AS key_value, COUNT(*) AS copies FROM Agency GROUP BY agency_code
    UNION ALL
    SELECT 'LoanType', loan_type::TEXT, COUNT(*) FROM LoanType GROUP BY loan_type
    UNION ALL
    SELECT 'PropertyType', property_type::TEXT, COUNT(*) FROM PropertyType GROUP BY property_type
    UNION ALL
    SELECT 'LoanPurpose', loan_purpose::TEXT, COUNT(*) FROM LoanPurpose GROUP BY loan_purpose
    UNION ALL
    SELECT 'OwnerOccupancy', owner_occupancy::TEXT, COUNT(*) FROM OwnerOccupancy GROUP BY owner_occupancy
    UNION ALL
    SELECT 'Preapproval', preapproval::TEXT, COUNT(*) FROM Preapproval GROUP BY preapproval
    UNION ALL
    SELECT 'ActionTaken', action_taken::TEXT, COUNT(*) FROM ActionTaken GROUP BY action_taken
    UNION ALL
    SELECT 'ApplicantEthnicity', applicant_ethnicity::TEXT, COUNT(*) FROM ApplicantEthnicity GROUP BY applicant_ethnicity
    UNION ALL
    SELECT 'CoApplicantEthnicity', co_applicant_ethnicity::TEXT, COUNT(*) FROM CoApplicantEthnicity GROUP BY co_applicant_ethnicity
    UNION ALL
    SELECT 'ApplicantSex', applicant_sex::TEXT, COUNT(*) FROM ApplicantSex GROUP BY applicant_sex
    UNION ALL
    SELECT 'CoApplicantSex', co_applicant_sex::TEXT, COUNT(*) FROM CoApplicantSex GROUP BY co_applicant_sex
    UNION ALL
    SELECT 'PurchaserType', purchaser_type::TEXT, COUNT(*) FROM PurchaserType GROUP BY purchaser_type
    UNION ALL
    SELECT 'HOEPAStatus', hoepa_status::TEXT, COUNT(*) FROM HOEPAStatus GROUP BY hoepa_status
    UNION ALL
    SELECT 'LienStatus', lien_status::TEXT, COUNT(*) FROM LienStatus GROUP BY lien_status
    UNION ALL
    SELECT 'Race', race_code::TEXT, COUNT(*) FROM Race GROUP BY race_code
    UNION ALL
    SELECT 'DenialReasonType', denial_reason_code::TEXT, COUNT(*) FROM DenialReasonType GROUP BY denial_reason_code
    UNION ALL
    SELECT 'State', state_code::TEXT, COUNT(*) FROM State GROUP BY state_code
    UNION ALL
    SELECT 'County', state_code::TEXT || ':' || county_code::TEXT, COUNT(*) FROM County GROUP BY state_code, county_code
    UNION ALL
    SELECT 'MSAMD', msamd::TEXT, COUNT(*) FROM MSAMD GROUP BY msamd
) AS duplicate_keys
WHERE copies > 1;
