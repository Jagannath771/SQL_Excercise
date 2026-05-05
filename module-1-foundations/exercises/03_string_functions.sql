-- ============================================================
-- MODULE 1 | Exercise 3: String Functions & Basic Cleaning
-- Difficulty: ⭐ Easy  |  Estimated time: 10 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Clean whitespace with TRIM / LTRIM / RTRIM
-- 2. Standardize case with UPPER / LOWER
-- 3. Replace missing values with COALESCE
-- 4. Transform values with CASE WHEN
-- 5. Extract parts of strings with SUBSTR and LENGTH
--
-- WHY THIS MATTERS:
-- Raw data almost always has formatting issues: extra spaces,
-- mixed case, NULLs, inconsistent values. Cleaning at the
-- SQL layer means every downstream query gets clean data.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 3.1  Trimming whitespace
-- ─────────────────────────────────────────────────────────────
-- Run this to see the dirty emails:
SELECT id, first_name, email,
       LENGTH(email) AS raw_length
FROM   customers
WHERE  id IN (3, 9);

-- Notice the lengths are longer than expected because of spaces.

-- Now clean them with TRIM (removes both leading AND trailing spaces):
SELECT id, first_name,
       email                   AS raw_email,
       TRIM(email)             AS clean_email,
       LENGTH(TRIM(email))     AS clean_length
FROM   customers
WHERE  id IN (3, 9);

-- ✏️  YOUR TURN:
-- Write a query that shows all 25 customers with their
-- emails cleaned (trimmed). Add a column 'had_whitespace'
-- that is 'YES' when email != TRIM(email), else 'NO'.
-- (Hint: use CASE WHEN)



-- ─────────────────────────────────────────────────────────────
-- 3.2  Standardizing case
-- ─────────────────────────────────────────────────────────────
-- Product names in mixed case — uppercase them for display:
SELECT name,
       UPPER(name)  AS name_upper,
       LOWER(name)  AS name_lower
FROM   products
LIMIT 5;

-- ✏️  YOUR TURN:
-- The tier column uses lowercase ('gold', 'silver', 'bronze').
-- Write a query that displays each customer's full name
-- (first + last) and their tier in UPPERCASE.
-- Format: "Alice Johnson" → columns: full_name, tier_display



-- ─────────────────────────────────────────────────────────────
-- 3.3  Handling NULLs with COALESCE
-- ─────────────────────────────────────────────────────────────
-- COALESCE returns the first non-NULL value in its argument list.

-- Replace NULL emails with a placeholder:
SELECT id, first_name,
       COALESCE(email, 'no-email@unknown.com') AS safe_email
FROM   customers;

-- ✏️  YOUR TURN:
-- Write a query that shows each order's id, customer_id, and
-- updated_at. For orders where updated_at is NULL, show the
-- text 'Not yet updated' instead.



-- ─────────────────────────────────────────────────────────────
-- 3.4  Standardizing values with CASE WHEN
-- ─────────────────────────────────────────────────────────────
-- The country column has three variants for the same country.
-- Let's standardize them:

SELECT DISTINCT country FROM customers ORDER BY country;

-- Now write a CASE WHEN to normalize:
SELECT id, first_name, country,
       CASE country
           WHEN 'US'  THEN 'United States'
           WHEN 'USA' THEN 'United States'
           ELSE country
       END AS country_clean
FROM   customers
ORDER BY country;

-- ✏️  YOUR TURN:
-- Write a query that adds a 'tier_level' column:
--   gold   → 3
--   silver → 2
--   bronze → 1
-- Show: id, first_name, tier, tier_level, sorted by tier_level DESC.



-- ─────────────────────────────────────────────────────────────
-- 3.5  String extraction with SUBSTR and LENGTH
-- ─────────────────────────────────────────────────────────────
-- Extract just the year from signup_date (stored as 'YYYY-MM-DD'):
SELECT first_name,
       signup_date,
       SUBSTR(signup_date, 1, 4)  AS signup_year,
       SUBSTR(signup_date, 6, 2)  AS signup_month
FROM   customers
LIMIT 10;

-- ✏️  YOUR TURN:
-- Write a query that extracts the domain from each customer's email.
-- e.g. 'alice.johnson@email.com' → 'email.com'
-- Hint: SUBSTR(email, INSTR(email, '@') + 1)
-- Skip NULL emails using WHERE email IS NOT NULL.



-- ─────────────────────────────────────────────────────────────
-- 3.6  CHALLENGE: Full cleaning pipeline
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a single SELECT that outputs a "clean" version of customers:
--   - id, first_name (UPPER), last_name
--   - email: TRIM'd, NULLs replaced with 'unknown@shopmetrics.com'
--   - country: standardized ('US'/'USA' → 'United States')
--   - tier: UPPER
--   - signup_year: extracted from signup_date
-- Sort by signup_year ASC, then first_name ASC.
