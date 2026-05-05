-- ============================================================
-- MODULE 1 | Exercise 3 SOLUTIONS: String Functions
-- ============================================================

-- 3.1  All customers with whitespace flag
SELECT id,
       first_name,
       email                          AS raw_email,
       TRIM(email)                    AS clean_email,
       CASE
           WHEN email != TRIM(email)  THEN 'YES'
           ELSE                            'NO'
       END                            AS had_whitespace
FROM   customers
ORDER BY had_whitespace DESC, id;

-- 3.2  Full name + uppercase tier
SELECT first_name || ' ' || last_name  AS full_name,
       UPPER(tier)                      AS tier_display
FROM   customers
ORDER BY full_name;

-- 3.3  Replace NULL updated_at
SELECT id,
       customer_id,
       COALESCE(updated_at, 'Not yet updated') AS updated_at_display
FROM   orders
ORDER BY id;

-- 3.4  Tier level numeric mapping
SELECT id,
       first_name,
       tier,
       CASE tier
           WHEN 'gold'   THEN 3
           WHEN 'silver' THEN 2
           WHEN 'bronze' THEN 1
           ELSE               0
       END AS tier_level
FROM   customers
ORDER BY tier_level DESC, first_name;

-- 3.5  Extract email domain
SELECT first_name,
       email,
       SUBSTR(email, INSTR(email, '@') + 1) AS domain
FROM   customers
WHERE  email IS NOT NULL
ORDER BY domain, first_name;

-- 3.6  Challenge: full cleaning pipeline
SELECT id,
       UPPER(first_name)                                AS first_name,
       last_name,
       TRIM(COALESCE(email, 'unknown@shopmetrics.com')) AS email,
       CASE country
           WHEN 'US'  THEN 'United States'
           WHEN 'USA' THEN 'United States'
           ELSE COALESCE(country, 'Unknown')
       END                                             AS country,
       UPPER(tier)                                     AS tier,
       SUBSTR(signup_date, 1, 4)                       AS signup_year
FROM   customers
ORDER BY signup_year ASC, first_name ASC;
