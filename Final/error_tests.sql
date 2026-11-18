-- error_tests.sql -- CS336 Project 2, Step 4
-- Each test tries a change that must be rejected (or, in Test 12, accepted) and
-- prints PASS or FAIL. Nothing is changed: every statement fails or is rolled back.
-- Run inside psql after step3.sql:   \i error_tests.sql

\set ON_ERROR_STOP off
\pset pager off

-- ---------------------------------------------------------------------------
-- Part A: single rule tests (each statement breaks exactly ONE rule)
-- ---------------------------------------------------------------------------

\echo '--- Test 1: property_type 4 does not exist (foreign key) ---'
DO $$ BEGIN
  INSERT INTO Loan_Application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
      property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
      location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
      purchaser_type, hoepa_status, lien_status)
  VALUES (999999999, 2017, '0000177957', 2, 1, 4, 1, 1, 250, 3, 1, 1, 2, 5, 1, 5, 0, 2, 1);
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 2: respondent_id is never empty in the CSV (NOT NULL) ---'
DO $$ BEGIN
  INSERT INTO Loan_Application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
      property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
      location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
      purchaser_type, hoepa_status, lien_status)
  VALUES (999999999, 2017, NULL, 2, 1, 1, 1, 1, 250, 3, 1, 1, 2, 5, 1, 5, 0, 2, 1);
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN not_null_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 3: sequence_number 1 already exists (primary key) ---'
DO $$ BEGIN
  INSERT INTO Loan_Application (sequence_number, as_of_year, respondent_id, agency_code, loan_type,
      property_type, loan_purpose, owner_occupancy, loan_amount_000s, preapproval, action_taken,
      location_id, applicant_ethnicity, co_applicant_ethnicity, applicant_sex, co_applicant_sex,
      purchaser_type, hoepa_status, lien_status)
  VALUES (1, 2017, '0000177957', 2, 1, 1, 1, 1, 250, 3, 1, 1, 2, 5, 1, 5, 0, 2, 1);
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN unique_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 4: applicant_race_number must be 1-5 (check constraint) ---'
DO $$ BEGIN
  INSERT INTO Applicant_Race (sequence_number, applicant_race_number, applicant_race) VALUES (1, 6, 5);
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN check_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 5: location_id 99999999 does not exist (foreign key) ---'
DO $$ BEGIN
  UPDATE Loan_Application SET location_id = 99999999 WHERE sequence_number = 1;
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 6: a race code still used by applications cannot be deleted (foreign key) ---'
DO $$ BEGIN
  DELETE FROM Race WHERE race = 5;
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 7: county 999 is not a New Jersey county (composite foreign key) ---'
DO $$ BEGIN
  INSERT INTO Location (location_id, state_code, county_code, census_tract_number)
  VALUES (999999, 34, 999, '0001.00');
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 8: Null_Columns can only hold NULLs (check constraint) ---'
DO $$ BEGIN
  UPDATE Null_Columns SET edit_status = 9;
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN check_violation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

\echo '--- Test 9: loan_amount_000s must be a number (type check) ---'
DO $$ BEGIN
  UPDATE Loan_Application SET loan_amount_000s = 'abc' WHERE sequence_number = 1;
  RAISE NOTICE 'FAIL: statement was accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN invalid_text_representation THEN RAISE NOTICE 'PASS: rejected -> %', SQLERRM;
  WHEN SQLSTATE 'XX999' THEN NULL;
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: rejected for the wrong reason -> %', SQLERRM;
END $$;

-- ---------------------------------------------------------------------------
-- Part B: every code column must reject a code that is not in its lookup table
-- (foreign key). The bad values below do not occur in the CSV.
-- ---------------------------------------------------------------------------

\echo '--- Test 10: invalid codes in every lookup column (foreign keys) ---'
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM (VALUES
      ('agency_code', 4), ('loan_type', 9), ('property_type', 4), ('loan_purpose', 9),
      ('owner_occupancy', 9), ('preapproval', 9), ('action_taken', 9),
      ('applicant_ethnicity', 9), ('co_applicant_ethnicity', 9),
      ('applicant_sex', 9), ('co_applicant_sex', 9),
      ('purchaser_type', 99), ('hoepa_status', 9), ('lien_status', 9)
    ) AS v(col, bad) LOOP
    BEGIN
      EXECUTE format('UPDATE Loan_Application SET %I = %s WHERE sequence_number = 1', r.col, r.bad);
      RAISE NOTICE 'FAIL: % = % was accepted', r.col, r.bad;
      RAISE EXCEPTION USING ERRCODE = 'XX999';
    EXCEPTION
      WHEN foreign_key_violation THEN RAISE NOTICE 'PASS: % = % rejected', r.col, r.bad;
      WHEN SQLSTATE 'XX999' THEN NULL;
      WHEN OTHERS THEN RAISE NOTICE 'FAIL: % = % rejected for the wrong reason -> %', r.col, r.bad, SQLERRM;
    END;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- Part C: columns that are never empty in the CSV must be NOT NULL.
-- ---------------------------------------------------------------------------

\echo '--- Test 11: NULL in columns that are never null in the data (NOT NULL) ---'
DO $$
DECLARE c text;
BEGIN
  FOREACH c IN ARRAY ARRAY['as_of_year','respondent_id','agency_code','loan_type','property_type',
      'loan_purpose','owner_occupancy','preapproval','action_taken','applicant_ethnicity',
      'co_applicant_ethnicity','applicant_sex','co_applicant_sex','purchaser_type',
      'hoepa_status','lien_status'] LOOP
    BEGIN
      EXECUTE format('UPDATE Loan_Application SET %I = NULL WHERE sequence_number = 1', c);
      RAISE NOTICE 'FAIL: NULL in % was accepted', c;
      RAISE EXCEPTION USING ERRCODE = 'XX999';
    EXCEPTION
      WHEN not_null_violation THEN RAISE NOTICE 'PASS: NULL in % rejected', c;
      WHEN SQLSTATE 'XX999' THEN NULL;
      WHEN OTHERS THEN RAISE NOTICE 'FAIL: NULL in % rejected for the wrong reason -> %', c, SQLERRM;
    END;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- Part D: the opposite check. Columns that ARE empty in the real data must accept
-- NULL, otherwise the original rows could not have been loaded.
-- ---------------------------------------------------------------------------

\echo '--- Test 12: loan_amount_000s is empty in 154 CSV rows, so NULL must be ACCEPTED ---'
DO $$ BEGIN
  UPDATE Loan_Application SET loan_amount_000s = NULL WHERE sequence_number = 1;
  RAISE NOTICE 'PASS: NULL accepted'; RAISE EXCEPTION USING ERRCODE = 'XX999';
EXCEPTION
  WHEN SQLSTATE 'XX999' THEN NULL;   -- change rolled back
  WHEN OTHERS THEN RAISE NOTICE 'FAIL: NULL wrongly rejected -> %', SQLERRM;
END $$;
