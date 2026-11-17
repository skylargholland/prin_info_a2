-- error_tests.sql
-- CS336 Project 2, Step 4 video: each statement below is invalid and must be
-- REJECTED by the database. Run it after step3_normalize.sql:   \i error_tests.sql
-- (Every statement runs on its own, so one error does not stop the next test.
--  Nothing is changed: every insert fails.)

\set ON_ERROR_STOP off

\echo '--- Test 1: property_type 4 does not exist (foreign key) ---'
INSERT INTO Loan_Application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
    property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
    location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
    purchaser_type, hoepa_status, lien_status)
VALUES (999999999, 2017, '0000177957', 2, 1,
    4, 1, 1, 250, 3, 1,
    1, 2, 5, 1, 5,
    0, 2, 1);

\echo '--- Test 2: respondent_id is never empty in the data (NOT NULL) ---'
INSERT INTO Loan_Application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
    property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
    location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
    purchaser_type, hoepa_status, lien_status)
VALUES (999999999, 2017, NULL, 2, 1,
    1, 1, 1, 250, 3, 1,
    1, 2, 5, 1, 5,
    0, 2, 1);

\echo '--- Test 3: sequence_number 1 already exists (primary key) ---'
INSERT INTO Loan_Application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
    property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
    location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
    purchaser_type, hoepa_status, lien_status)
VALUES (1, 2017, '0000177957', 2, 1,
    1, 1, 1, 250, 3, 1,
    1, 2, 5, 1, 5,
    0, 2, 1);

\echo '--- Test 4: applicant_race_number must be 1-5 (check constraint) ---'
INSERT INTO Applicant_Race (sequence_number, applicant_race_number, applicant_race) VALUES (1, 6, 5);

\echo '--- Test 5: location_id 99999999 does not exist (foreign key) ---'
UPDATE Loan_Application SET location_id = 99999999 WHERE sequence_number = 1;

\echo '--- Test 6: a race code still used by applications cannot be deleted (foreign key) ---'
DELETE FROM Race WHERE race = 5;

\echo '--- Test 7: county 999 is not a New Jersey county (composite foreign key) ---'
INSERT INTO Location (state_code, county_code, census_tract_number) VALUES (34, 999, '0001.00');

\echo '--- Test 8: edit_status 9 does not exist (foreign key) ---'
UPDATE Loan_Application SET edit_status = 9 WHERE sequence_number = 1;

\echo '--- Test 9: loan_amount_000s must be a number (type check) ---'
UPDATE Loan_Application SET loan_amount_000s = 'abc' WHERE sequence_number = 1;
