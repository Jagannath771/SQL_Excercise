-- ============================================================
-- MODULE 1 | Exercise 2 SOLUTIONS: Filtering & Sorting
-- ============================================================

-- 2.1  Silver customers in the United States
SELECT id, first_name, last_name, tier, country
FROM   customers
WHERE  tier    = 'silver'
  AND  country = 'United States';

-- 2.2  Orders not delivered and not cancelled (two approaches)
-- Using NOT IN:
SELECT id, customer_id, status, region
FROM   orders
WHERE  status NOT IN ('delivered', 'cancelled');

-- Using != with AND:
SELECT id, customer_id, status, region
FROM   orders
WHERE  status != 'delivered'
  AND  status != 'cancelled';

-- 2.3  Customers who signed up in 2023
SELECT id, first_name, signup_date
FROM   customers
WHERE  signup_date BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY signup_date;

-- 2.4  Pattern matching
-- Emails ending with @email.com:
SELECT id, first_name, email
FROM   customers
WHERE  email LIKE '%@email.com';

-- First names starting with 'A':
SELECT id, first_name
FROM   customers
WHERE  first_name LIKE 'A%';

-- 2.5  10 most recent orders
SELECT id, customer_id, status, created_at
FROM   orders
ORDER BY created_at DESC
LIMIT  10;

-- 2.6  Orders where updated_at is NULL + count
SELECT id, customer_id, status, created_at
FROM   orders
WHERE  updated_at IS NULL;

SELECT COUNT(*) AS orders_not_yet_updated
FROM   orders
WHERE  updated_at IS NULL;

-- 2.7  Challenge: combined filter
SELECT id, customer_id, status, region, created_at
FROM   orders
WHERE  status IN ('delivered')
  AND  region IN ('South', 'Online')
  AND  created_at >= '2024-01-01'
  AND  created_at <  '2025-01-01'
ORDER BY created_at DESC;
