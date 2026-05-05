-- ============================================================
-- MODULE 2 | Exercise 5: Data Quality Framework
-- Difficulty: ⭐⭐ Medium  |  Estimated time: 15 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Write NULL checks, uniqueness checks, and range validations
-- 2. Detect referential integrity violations
-- 3. Build a self-contained "quality report" query
-- 4. Understand why data quality checks belong in SQL (not just Python)
--
-- WHY THIS MATTERS:
-- Bad data costs more than the tests that catch it.
-- A data quality check is just a SQL query that returns rows
-- when something is wrong. Zero rows = test passed.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 5.1  NULL checks
-- ─────────────────────────────────────────────────────────────
-- Count NULLs across key columns in the customers table:
SELECT
    COUNT(*)                                     AS total_rows,
    SUM(CASE WHEN id         IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS null_first_name,
    SUM(CASE WHEN email      IS NULL THEN 1 ELSE 0 END) AS null_email,
    SUM(CASE WHEN country    IS NULL THEN 1 ELSE 0 END) AS null_country,
    SUM(CASE WHEN tier       IS NULL THEN 1 ELSE 0 END) AS null_tier
FROM customers;

-- ✏️  YOUR TURN:
-- Write the same NULL check query for the ORDERS table.
-- Check: id, customer_id, status, created_at, region.
-- Which column has the most NULLs? Is that expected? Why?

-- Your observations:



-- ─────────────────────────────────────────────────────────────
-- 5.2  Uniqueness check
-- ─────────────────────────────────────────────────────────────
-- Every customer id should be unique. Find any duplicates:
SELECT id, COUNT(*) AS occurrences
FROM   customers
GROUP BY id
HAVING COUNT(*) > 1;
-- Zero rows = no duplicates. Good!

-- ✏️  YOUR TURN:
-- Check uniqueness of order_id in the payments table.
-- (There is a UNIQUE constraint, but verify it via SQL.)
-- Also check if any (order_id, product_id) combination appears
-- more than once in order_items (that would be suspicious).



-- ─────────────────────────────────────────────────────────────
-- 5.3  Accepted values check
-- ─────────────────────────────────────────────────────────────
-- Status should only be one of the known values:
SELECT status, COUNT(*) AS count
FROM   orders
GROUP BY status
ORDER BY count DESC;

-- ✏️  YOUR TURN:
-- Write a query that finds any orders with an INVALID status.
-- Valid statuses: 'pending','processing','shipped','delivered',
--                'cancelled','returned'
-- Expected result: zero rows. If any rows return, that's a bug!



-- ─────────────────────────────────────────────────────────────
-- 5.4  Range / business rule checks
-- ─────────────────────────────────────────────────────────────
-- Prices and quantities should be positive. Payments should be > 0.

-- Find any suspicious product prices:
SELECT id, name, price, cost
FROM   products
WHERE  price <= 0
   OR  cost  <= 0
   OR  price < cost;   -- selling below cost is suspicious!

-- ✏️  YOUR TURN:
-- Write range checks for the payments table:
--   1. Find any payments where amount <= 0
--   2. Find any payments where paid_at is before 2020-01-01
--      (clearly bad data — the company didn't exist yet)
--   3. Find any order_items where quantity <= 0 or unit_price <= 0



-- ─────────────────────────────────────────────────────────────
-- 5.5  Referential integrity check
-- ─────────────────────────────────────────────────────────────
-- Find orders where the customer_id doesn't exist in customers:
SELECT o.id AS order_id, o.customer_id
FROM   orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE  c.id IS NULL;

-- ✏️  YOUR TURN:
-- Write referential integrity checks for:
--   1. order_items.order_id → orders.id
--   2. order_items.product_id → products.id
--   3. payments.order_id → orders.id
-- Which checks pass? Which (if any) fail?



-- ─────────────────────────────────────────────────────────────
-- 5.6  The missing payment problem
-- ─────────────────────────────────────────────────────────────
-- Find delivered orders that have no payment record at all:
SELECT o.id       AS order_id,
       o.status,
       o.created_at,
       c.first_name,
       c.last_name
FROM   orders    o
INNER JOIN customers c ON c.id = o.customer_id
LEFT  JOIN payments  p ON p.order_id = o.id
WHERE  o.status = 'delivered'
  AND  p.order_id IS NULL;

-- ✏️  YOUR TURN:
-- Extend this to find ALL orders (any status) with no payment.
-- Also add the column: days_since_order (using JULIANDAY).
-- Are any of these recent orders that just haven't been paid yet?



-- ─────────────────────────────────────────────────────────────
-- 5.7  CHALLENGE: Master quality report
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Build a single "data quality dashboard" query using UNION ALL
-- that returns one row per check result:
--
--   check_name          | table_name  | failed_rows | status
--   null_emails         | customers   | 2           | FAIL
--   null_customer_ids   | orders      | 0           | PASS
--   invalid_statuses    | orders      | 0           | PASS
--   negative_prices     | products    | 0           | PASS
--   missing_payments    | orders      | 5           | FAIL
--
-- Tip: each CTE or subquery counts failures. Use CASE WHEN count > 0
-- THEN 'FAIL' ELSE 'PASS' END for the status column.
