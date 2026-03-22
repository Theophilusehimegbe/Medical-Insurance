-- ============================================================
-- PROJECT   : Medical Insurance Data - Exploratory Data Analysis
-- AUTHOR    : Theophilus Ehimegbe
-- TOOL      : MySQL Workbench
-- DATASET   : medical_insurance (1,338 records, 7 fields)
-- PURPOSE   : Uncover cost drivers across demographics, smoking
--             status, BMI, family size, and region to support
--             risk-based pricing and wellness strategy decisions.
-- ============================================================


-- ============================================================
-- SECTION 0: DATA STAGING AND DEDUPLICATION
-- Goal: Preserve the raw dataset and remove duplicate records
--       before any analysis begins.
-- ============================================================

-- Confirm raw data loaded correctly before touching anything
SELECT * FROM medical.medical_insurance;


-- Create an identical staging table structure from the source.
-- All analysis will run on this copy, not the original table.
CREATE TABLE insurance_staging
LIKE medical_insurance;

INSERT INTO insurance_staging
SELECT * FROM medical_insurance;

-- Verify the full row count transferred cleanly (expect 1,338)
SELECT * FROM insurance_staging;


-- ---------------------------------------------------------------
-- DUPLICATE DETECTION
-- ROW_NUMBER() partitioned across all 7 columns will assign
-- row_num = 1 to the first occurrence of each unique record.
-- Any row_num > 1 is a duplicate and must be removed.
-- ---------------------------------------------------------------

-- Preview the row numbers before isolating duplicates
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY age, sex, bmi, children, smoker, region, charges
    ) AS row_num
FROM insurance_staging;


-- Use a CTE to surface only the duplicate rows for inspection
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY age, sex, bmi, children, smoker, region, charges
        ) AS row_num
    FROM insurance_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- MySQL does not support DELETE directly from a CTE.
-- Solution: Create a second staging table that physically stores
-- the row_num column, enabling direct WHERE-clause deletion.
CREATE TABLE insurance_staging1 (
    age       INT          DEFAULT NULL,
    sex       TEXT,
    bmi       DOUBLE       DEFAULT NULL,
    children  INT          DEFAULT NULL,
    smoker    TEXT,
    region    TEXT,
    charges   DOUBLE       DEFAULT NULL,
    row_num   INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Populate insurance_staging1 with row numbers assigned
INSERT INTO insurance_staging1
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY age, sex, bmi, children, smoker, region, charges
    ) AS row_num
FROM insurance_staging;


-- Confirm which records are flagged as duplicates
SELECT *
FROM insurance_staging1
WHERE row_num > 1;


-- Remove all duplicate records (keep only the first occurrence)
DELETE FROM insurance_staging1
WHERE row_num > 1;


-- ============================================================
-- SECTION 1: DEMOGRAPHICS AND DISTRIBUTION
-- Goal: Establish a baseline profile of the policyholder pool.
--       These figures anchor every comparison that follows.
-- ============================================================

-- Q1. What is the average age of policyholders?
--     Knowing the median age helps segment risk expectations.
SELECT ROUND(AVG(age), 1) AS avg_age
FROM insurance_staging1;


-- Q2. How is the dataset split between male and female policyholders?
--     A near-even split prevents gender from skewing other averages.
SELECT sex, COUNT(*) AS policyholder_count
FROM insurance_staging1
GROUP BY sex;


-- Q3. How many policyholders are registered in each region?
--     Regional volume differences affect how averages are interpreted.
SELECT region, COUNT(*) AS policyholder_count
FROM insurance_staging1
GROUP BY region
ORDER BY policyholder_count DESC;


-- Q4. What is the average BMI for each gender?
--     Both groups averaging ~30.6 places them in the Obese I range,
--     which is a meaningful baseline for later cost comparisons.
SELECT sex, ROUND(AVG(bmi), 2) AS avg_bmi
FROM insurance_staging1
GROUP BY sex;


-- Q5a. How many policyholders have at least one dependent child?
SELECT COUNT(*) AS policyholders_with_children
FROM insurance_staging1
WHERE children > 0;

-- Q5b. What is the most common number of children among policyholders?
--      Helps identify which family size is most represented.
SELECT children, COUNT(*) AS frequency
FROM insurance_staging1
GROUP BY children
ORDER BY frequency DESC
LIMIT 1;


-- ============================================================
-- SECTION 2: CHARGES AND COST ANALYSIS
-- Goal: Map the financial distribution of claims and identify
--       which factors push costs above the average.
-- ============================================================

-- Q6. What is the overall average, minimum, and maximum medical charge?
--     This establishes the cost range all subsequent figures sit within.
SELECT
    ROUND(AVG(charges), 1) AS avg_charge,
    ROUND(MIN(charges), 1) AS min_charge,
    ROUND(MAX(charges), 1) AS max_charge
FROM insurance_staging1;


-- Q7. How do average charges compare between smokers and non-smokers?
--     Smoking is expected to be the single largest cost differentiator.
SELECT
    smoker,
    ROUND(AVG(charges), 1)  AS avg_charge,
    COUNT(*)                 AS policyholder_count
FROM insurance_staging1
GROUP BY smoker;


-- Q8. What is the average charge broken down by region?
--     Regional variation can signal provider pricing differences
--     or higher concentration of high-risk policyholders.
SELECT region, ROUND(AVG(charges), 1) AS avg_charge
FROM insurance_staging1
GROUP BY region
ORDER BY avg_charge DESC;


-- Q9. Which single region carries the highest average medical cost?
SELECT region, ROUND(AVG(charges), 1) AS avg_charge
FROM insurance_staging1
GROUP BY region
ORDER BY avg_charge DESC
LIMIT 1;


-- Q10. How do average charges shift across age groups?
--      Charges are expected to escalate with age as chronic conditions
--      become more prevalent. This confirms or challenges that assumption.
SELECT
    CASE
        WHEN age BETWEEN 18 AND 19 THEN '18-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    ROUND(AVG(charges), 1) AS avg_charge,
    COUNT(*)               AS policyholder_count
FROM insurance_staging1
GROUP BY age_group
ORDER BY age_group ASC;


-- ============================================================
-- SECTION 3: BMI AND HEALTH INDICATORS
-- Goal: Assess how body weight classification influences costs
--       and whether it compounds the impact of smoking.
-- ============================================================

-- Q11. Does smoking correlate with higher average BMI?
--      If BMI is nearly identical, smoking alone (not weight) explains
--      the charge gap -- a critical distinction for pricing models.
SELECT
    smoker,
    ROUND(AVG(bmi), 2) AS avg_bmi,
    COUNT(*)            AS policyholder_count
FROM insurance_staging1
GROUP BY smoker;


-- Q12. How do average charges differ across BMI classification bands?
--      Uses the standard WHO BMI scale to group policyholders.
--      Reveals which obesity tier drives the steepest cost escalation.
SELECT
    CASE
        WHEN bmi < 18.5            THEN 'Underweight'
        WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal Weight'
        WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
        WHEN bmi BETWEEN 30.0 AND 34.9 THEN 'Obese I'
        WHEN bmi BETWEEN 35.0 AND 39.9 THEN 'Obese II'
        ELSE                            'Obese III'
    END AS bmi_category,
    COUNT(*)                AS policyholder_count,
    ROUND(AVG(charges), 1)  AS avg_charge
FROM insurance_staging1
GROUP BY bmi_category
ORDER BY avg_charge DESC;


-- Q13. How many policyholders have a BMI above 30 (clinically obese)?
--      This figure quantifies the scale of the high-BMI risk pool.
SELECT COUNT(*) AS policyholders_bmi_over_30
FROM insurance_staging1
WHERE bmi > 30;


-- Q14. What is the average charge for BMI > 30 versus BMI <= 30?
--      The dollar gap here quantifies the actuarial cost of obesity.
SELECT
    CASE
        WHEN bmi > 30 THEN 'BMI Above 30'
        ELSE               'BMI 30 or Below'
    END AS bmi_group,
    COUNT(*)               AS policyholder_count,
    ROUND(AVG(charges), 2) AS avg_charge
FROM insurance_staging1
GROUP BY bmi_group;


-- ============================================================
-- SECTION 4: FAMILY AND DEPENDENTS
-- Goal: Understand whether having children influences the
--       volume or cost of medical claims.
-- ============================================================

-- Q15. What is the average charge for policyholders with children?
--      Isolates the cost profile of family-plan holders specifically.
SELECT
    COUNT(*)               AS policyholders_with_children,
    ROUND(AVG(charges), 1) AS avg_charge
FROM insurance_staging1
WHERE children > 0;


-- Q16. Does total claim cost increase with more children?
--      SUM captures the aggregate burden per family-size tier,
--      which matters more for reserve planning than per-person averages.
SELECT
    children,
    COUNT(*)               AS policyholder_count,
    ROUND(SUM(charges), 1) AS total_charges,
    ROUND(AVG(charges), 1) AS avg_charge
FROM insurance_staging1
GROUP BY children
ORDER BY children ASC;


-- Q17. Do smokers tend to have more children covered on the plan?
--      Identifies whether smoking households place a larger dependent
--      burden on the insurer's family plan structure.
SELECT
    smoker,
    COUNT(children) AS total_children_covered
FROM insurance_staging1
GROUP BY smoker
ORDER BY total_children_covered DESC;


-- ============================================================
-- SECTION 5: COMBINED MULTI-VARIABLE ANALYSIS
-- Goal: Layer variables together to find the highest-cost
--       segments, which are the clearest targets for
--       differentiated pricing and intervention programs.
-- ============================================================

-- Q18. What is the average charge by smoker status AND region?
--      Pinpoints which region-smoker combinations generate peak costs.
SELECT
    smoker,
    region,
    ROUND(AVG(charges), 1) AS avg_charge,
    COUNT(*)               AS policyholder_count
FROM insurance_staging1
GROUP BY smoker, region
ORDER BY smoker, avg_charge DESC;


-- Q19. What is the average charge by sex AND smoking status?
--      Identifies whether gender compounds the smoking cost premium.
SELECT
    sex,
    smoker,
    ROUND(AVG(charges), 1) AS avg_charge,
    COUNT(*)               AS policyholder_count
FROM insurance_staging1
GROUP BY sex, smoker
ORDER BY avg_charge DESC;


-- Q20. What is the highest single charge recorded for a non-smoker?
--      Even without smoking, some policyholders generate extreme claims.
--      This upper bound is important for outlier and fraud screening.
SELECT
    smoker,
    ROUND(MAX(charges), 2) AS highest_charge
FROM insurance_staging1
WHERE smoker = 'no';


-- ============================================================
-- SECTION 6: CLEANUP
-- Goal: Remove the helper column that was added only to
--       support duplicate detection. Returns the staging table
--       to its original 7-column structure.
-- ============================================================

ALTER TABLE insurance_staging1
DROP COLUMN row_num;

-- Final check: confirm the table is clean and analysis-ready
SELECT * FROM insurance_staging1 LIMIT 10;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================
