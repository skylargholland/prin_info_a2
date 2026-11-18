-- export.sql  --  CS336 Project 2, Step 4
-- Rebuilds the original HMDA CSV using ONLY the normalized tables built by
-- step3.sql. The Preliminary table is not used anywhere in this script.
--
-- Run inside psql, from the folder you want the file written to:
--     \i export.sql
-- Output: export.csv (identical to hmda_2017_nj_all-records_labels.csv)

\set ON_ERROR_STOP on
SET statement_timeout = 0;

-- Put the 1NF race / denial rows back into numbered columns (1..5, 1..3).
CREATE TEMP VIEW Applicant_Race_Wide AS
SELECT sequence_number,
       MAX(applicant_race) FILTER (WHERE applicant_race_number = 1) AS race_1,
       MAX(applicant_race) FILTER (WHERE applicant_race_number = 2) AS race_2,
       MAX(applicant_race) FILTER (WHERE applicant_race_number = 3) AS race_3,
       MAX(applicant_race) FILTER (WHERE applicant_race_number = 4) AS race_4,
       MAX(applicant_race) FILTER (WHERE applicant_race_number = 5) AS race_5
FROM Applicant_Race
GROUP BY sequence_number;

CREATE TEMP VIEW Co_Applicant_Race_Wide AS
SELECT sequence_number,
       MAX(co_applicant_race) FILTER (WHERE co_applicant_race_number = 1) AS race_1,
       MAX(co_applicant_race) FILTER (WHERE co_applicant_race_number = 2) AS race_2,
       MAX(co_applicant_race) FILTER (WHERE co_applicant_race_number = 3) AS race_3,
       MAX(co_applicant_race) FILTER (WHERE co_applicant_race_number = 4) AS race_4,
       MAX(co_applicant_race) FILTER (WHERE co_applicant_race_number = 5) AS race_5
FROM Co_Applicant_Race
GROUP BY sequence_number;

CREATE TEMP VIEW Loan_Denial_Wide AS
SELECT sequence_number,
       MAX(denial_reason) FILTER (WHERE denial_reason_number = 1) AS reason_1,
       MAX(denial_reason) FILTER (WHERE denial_reason_number = 2) AS reason_2,
       MAX(denial_reason) FILTER (WHERE denial_reason_number = 3) AS reason_3
FROM Loan_Denial
GROUP BY sequence_number;

-- The full report, column for column in the original CSV order.
-- Empty values become '' so FORCE_QUOTE writes them as "" like the original.
-- (The CSV's own sequence_number column is blank in every row; our
-- sequence_number is the generated key, used only to keep the original row order.)
CREATE TEMP VIEW CSV_Report AS
SELECT
    la.sequence_number                                   AS sort_key,
    COALESCE(la.as_of_year::text, '')                    AS as_of_year,
    COALESCE(la.respondent_id, '')                       AS respondent_id,
    COALESCE(ag.agency_name, '')                         AS agency_name,
    COALESCE(ag.agency_abbr, '')                         AS agency_abbr,
    COALESCE(la.agency_code::text, '')                   AS agency_code,
    COALESCE(lt.loan_type_name, '')                      AS loan_type_name,
    COALESCE(la.loan_type::text, '')                     AS loan_type,
    COALESCE(pt.property_type_name, '')                  AS property_type_name,
    COALESCE(la.property_type::text, '')                 AS property_type,
    COALESCE(lp.loan_purpose_name, '')                   AS loan_purpose_name,
    COALESCE(la.loan_purpose::text, '')                  AS loan_purpose,
    COALESCE(oo.owner_occupancy_name, '')                AS owner_occupancy_name,
    COALESCE(la.owner_occupancy::text, '')               AS owner_occupancy,
    COALESCE(la.loan_amount_000s::text, '')              AS loan_amount_000s,
    COALESCE(pa.preapproval_name, '')                    AS preapproval_name,
    COALESCE(la.preapproval::text, '')                   AS preapproval,
    COALESCE(at.action_taken_name, '')                   AS action_taken_name,
    COALESCE(la.action_taken::text, '')                  AS action_taken,
    COALESCE(m.msamd_name, '')                           AS msamd_name,
    COALESCE(l.msamd::text, '')                          AS msamd,
    COALESCE(st.state_name, '')                          AS state_name,
    COALESCE(st.state_abbr, '')                          AS state_abbr,
    COALESCE(l.state_code::text, '')                     AS state_code,
    COALESCE(co.county_name, '')                         AS county_name,
    COALESCE(l.county_code::text, '')                    AS county_code,
    COALESCE(l.census_tract_number, '')                  AS census_tract_number,
    COALESCE(ae.ethnicity_name, '')                      AS applicant_ethnicity_name,
    COALESCE(la.applicant_ethnicity::text, '')           AS applicant_ethnicity,
    COALESCE(ce.ethnicity_name, '')                      AS co_applicant_ethnicity_name,
    COALESCE(la.co_applicant_ethnicity::text, '')        AS co_applicant_ethnicity,
    COALESCE(ar1.race_name, '')                          AS applicant_race_name_1,
    COALESCE(ar.race_1::text, '')                        AS applicant_race_1,
    COALESCE(ar2.race_name, '')                          AS applicant_race_name_2,
    COALESCE(ar.race_2::text, '')                        AS applicant_race_2,
    COALESCE(ar3.race_name, '')                          AS applicant_race_name_3,
    COALESCE(ar.race_3::text, '')                        AS applicant_race_3,
    COALESCE(ar4.race_name, '')                          AS applicant_race_name_4,
    COALESCE(ar.race_4::text, '')                        AS applicant_race_4,
    COALESCE(ar5.race_name, '')                          AS applicant_race_name_5,
    COALESCE(ar.race_5::text, '')                        AS applicant_race_5,
    COALESCE(cr1.race_name, '')                          AS co_applicant_race_name_1,
    COALESCE(cr.race_1::text, '')                        AS co_applicant_race_1,
    COALESCE(cr2.race_name, '')                          AS co_applicant_race_name_2,
    COALESCE(cr.race_2::text, '')                        AS co_applicant_race_2,
    COALESCE(cr3.race_name, '')                          AS co_applicant_race_name_3,
    COALESCE(cr.race_3::text, '')                        AS co_applicant_race_3,
    COALESCE(cr4.race_name, '')                          AS co_applicant_race_name_4,
    COALESCE(cr.race_4::text, '')                        AS co_applicant_race_4,
    COALESCE(cr5.race_name, '')                          AS co_applicant_race_name_5,
    COALESCE(cr.race_5::text, '')                        AS co_applicant_race_5,
    COALESCE(asx.sex_name, '')                           AS applicant_sex_name,
    COALESCE(la.applicant_sex::text, '')                 AS applicant_sex,
    COALESCE(csx.sex_name, '')                           AS co_applicant_sex_name,
    COALESCE(la.co_applicant_sex::text, '')              AS co_applicant_sex,
    COALESCE(la.applicant_income_000s::text, '')         AS applicant_income_000s,
    COALESCE(pu.purchaser_type_name, '')                 AS purchaser_type_name,
    COALESCE(la.purchaser_type::text, '')                AS purchaser_type,
    COALESCE(dr1.denial_reason_name, '')                 AS denial_reason_name_1,
    COALESCE(dn.reason_1::text, '')                      AS denial_reason_1,
    COALESCE(dr2.denial_reason_name, '')                 AS denial_reason_name_2,
    COALESCE(dn.reason_2::text, '')                      AS denial_reason_2,
    COALESCE(dr3.denial_reason_name, '')                 AS denial_reason_name_3,
    COALESCE(dn.reason_3::text, '')                      AS denial_reason_3,
    COALESCE(to_char(la.rate_spread, 'FM00.00'), '')     AS rate_spread,
    COALESCE(ho.hoepa_status_name, '')                   AS hoepa_status_name,
    COALESCE(la.hoepa_status::text, '')                  AS hoepa_status,
    COALESCE(li.lien_status_name, '')                    AS lien_status_name,
    COALESCE(la.lien_status::text, '')                   AS lien_status,
    COALESCE(nc.edit_status_name, '')                    AS edit_status_name,
    COALESCE(nc.edit_status::text, '')                   AS edit_status,
    ''                                                   AS sequence_number,  -- blank in every row of the original CSV
    COALESCE(l.population::text, '')                     AS population,
    COALESCE(l.minority_population::text, '')            AS minority_population,
    COALESCE(l.hud_median_family_income::text, '')       AS hud_median_family_income,
    COALESCE(l.tract_to_msamd_income::text, '')          AS tract_to_msamd_income,
    COALESCE(l.number_of_owner_occupied_units::text, '') AS number_of_owner_occupied_units,
    COALESCE(l.number_of_1_to_4_family_units::text, '')  AS number_of_1_to_4_family_units,
    COALESCE(nc.application_date_indicator::text, '')    AS application_date_indicator
FROM Loan_Application la
JOIN      Agency          ag  ON ag.agency_code      = la.agency_code
JOIN      Loan_Type       lt  ON lt.loan_type        = la.loan_type
JOIN      Property_Type   pt  ON pt.property_type    = la.property_type
JOIN      Loan_Purpose    lp  ON lp.loan_purpose     = la.loan_purpose
JOIN      Owner_Occupancy oo  ON oo.owner_occupancy  = la.owner_occupancy
JOIN      Preapproval     pa  ON pa.preapproval      = la.preapproval
JOIN      Action_Taken    at  ON at.action_taken     = la.action_taken
JOIN      Purchaser_Type  pu  ON pu.purchaser_type   = la.purchaser_type
JOIN      HOEPA_Status    ho  ON ho.hoepa_status     = la.hoepa_status
JOIN      Lien_Status     li  ON li.lien_status      = la.lien_status
CROSS JOIN Null_Columns   nc  -- its one row of NULLs goes on every application
JOIN      Ethnicity       ae  ON ae.ethnicity        = la.applicant_ethnicity
JOIN      Ethnicity       ce  ON ce.ethnicity        = la.co_applicant_ethnicity
JOIN      Sex             asx ON asx.sex             = la.applicant_sex
JOIN      Sex             csx ON csx.sex             = la.co_applicant_sex
JOIN      Location        l   ON l.location_id        = la.location_id
JOIN      State           st  ON st.state_code       = l.state_code
LEFT JOIN County          co  ON co.state_code       = l.state_code
                             AND co.county_code      = l.county_code
LEFT JOIN MSA             m   ON m.msamd             = l.msamd
LEFT JOIN Applicant_Race_Wide    ar ON ar.sequence_number = la.sequence_number
LEFT JOIN Co_Applicant_Race_Wide cr ON cr.sequence_number = la.sequence_number
LEFT JOIN Loan_Denial_Wide       dn ON dn.sequence_number = la.sequence_number
LEFT JOIN Race ar1 ON ar1.race = ar.race_1
LEFT JOIN Race ar2 ON ar2.race = ar.race_2
LEFT JOIN Race ar3 ON ar3.race = ar.race_3
LEFT JOIN Race ar4 ON ar4.race = ar.race_4
LEFT JOIN Race ar5 ON ar5.race = ar.race_5
LEFT JOIN Race cr1 ON cr1.race = cr.race_1
LEFT JOIN Race cr2 ON cr2.race = cr.race_2
LEFT JOIN Race cr3 ON cr3.race = cr.race_3
LEFT JOIN Race cr4 ON cr4.race = cr.race_4
LEFT JOIN Race cr5 ON cr5.race = cr.race_5
LEFT JOIN Denial_Reason dr1 ON dr1.denial_reason = dn.reason_1
LEFT JOIN Denial_Reason dr2 ON dr2.denial_reason = dn.reason_2
LEFT JOIN Denial_Reason dr3 ON dr3.denial_reason = dn.reason_3;

-- \copy must stay on one line. Every column except the sort key, in CSV order.
\copy (SELECT as_of_year, respondent_id, agency_name, agency_abbr, agency_code, loan_type_name, loan_type, property_type_name, property_type, loan_purpose_name, loan_purpose, owner_occupancy_name, owner_occupancy, loan_amount_000s, preapproval_name, preapproval, action_taken_name, action_taken, msamd_name, msamd, state_name, state_abbr, state_code, county_name, county_code, census_tract_number, applicant_ethnicity_name, applicant_ethnicity, co_applicant_ethnicity_name, co_applicant_ethnicity, applicant_race_name_1, applicant_race_1, applicant_race_name_2, applicant_race_2, applicant_race_name_3, applicant_race_3, applicant_race_name_4, applicant_race_4, applicant_race_name_5, applicant_race_5, co_applicant_race_name_1, co_applicant_race_1, co_applicant_race_name_2, co_applicant_race_2, co_applicant_race_name_3, co_applicant_race_3, co_applicant_race_name_4, co_applicant_race_4, co_applicant_race_name_5, co_applicant_race_5, applicant_sex_name, applicant_sex, co_applicant_sex_name, co_applicant_sex, applicant_income_000s, purchaser_type_name, purchaser_type, denial_reason_name_1, denial_reason_1, denial_reason_name_2, denial_reason_2, denial_reason_name_3, denial_reason_3, rate_spread, hoepa_status_name, hoepa_status, lien_status_name, lien_status, edit_status_name, edit_status, sequence_number, population, minority_population, hud_median_family_income, tract_to_msamd_income, number_of_owner_occupied_units, number_of_1_to_4_family_units, application_date_indicator FROM CSV_Report ORDER BY sort_key) TO 'export.csv' WITH (FORMAT csv, HEADER true, FORCE_QUOTE *)
