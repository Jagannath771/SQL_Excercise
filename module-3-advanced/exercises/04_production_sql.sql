-- ============================================================
-- MODULE 3 | Exercise 4: Production SQL Patterns
-- Difficulty: ⭐⭐⭐ Hard  |  Estimated time: 20 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Write self-documenting SQL with meaningful CTE names
-- 2. Make every nullable column safe with COALESCE
-- 3. Add assertion CTEs that fail loudly on bad data
-- 4. Structure SQL for maximum reviewability (vertical alignment,
--    consistent spacing, top-to-bottom readability)
-- 5. Write SQL that your future self (at 2am debugging) will thank you for
--
-- THE PHILOSOPHY (from the talk):
-- "Readable code = Maintainable code"
-- "Every query should earn its place in production"
-- "Write SQL that is clean, tested, and trusted"
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 4.1  Before & after: readable SQL
-- ─────────────────────────────────────────────────────────────
-- BEFORE: works, but painful to review/debug
SELECT c.id,c.first_name||' '||c.last_name as name,sum(p.amount) as rev,count(distinct o.id) as orders
FROM customers c join orders o on c.id=o.customer_id join payments p on p.order_id=o.id
where p.status='completed' and c.tier in('gold','silver') group by c.id,c.first_name,c.last_name
order by rev desc;

-- AFTER: same logic, production-ready
WITH paying_customers AS (
    SELECT c.id,
           c.first_name || ' ' || c.last_name AS full_name,
           c.tier
    FROM   customers c
    WHERE  c.tier IN ('gold', 'silver')
),
completed_payments AS (
    SELECT o.customer_id,
           COUNT(DISTINCT o.id) AS order_count,
           SUM(p.amount)        AS total_revenue
    FROM   orders   o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT pc.full_name,
       pc.tier,
       COALESCE(cp.order_count,   0)    AS order_count,
       COALESCE(cp.total_revenue, 0.00) AS total_revenue
FROM   paying_customers  pc
LEFT JOIN completed_payments cp ON cp.customer_id = pc.id
ORDER BY total_revenue DESC;

-- ✏️  YOUR TURN:
-- Take this ugly query and rewrite it in production style:
--
--  SELECT p.name,sum(oi.quantity*oi.unit_price) as rev,count(oi.id) as line_items
--  FROM products p JOIN order_items oi ON p.id=oi.product_id
--  JOIN orders o ON o.id=oi.order_id WHERE o.status!='cancelled'
--  GROUP BY p.name ORDER BY rev desc LIMIT 5;
--
-- Requirements: at least 2 CTEs, aligned keywords, meaningful names.



-- ─────────────────────────────────────────────────────────────
-- 4.2  Defensive COALESCE — never trust nullable columns
-- ─────────────────────────────────────────────────────────────
-- Without defensive COALESCE, a single NULL can silently zero out a SUM.
-- Demonstrate: add a NULL to a SUM.
SELECT SUM(amount) AS wrong_way  -- NULL + anything = NULL in some databases
FROM (
    SELECT 100.0 AS amount
    UNION ALL SELECT NULL
    UNION ALL SELECT 200.0
);

-- The safe way: COALESCE before aggregation
SELECT SUM(COALESCE(amount, 0)) AS safe_way
FROM (
    SELECT 100.0 AS amount
    UNION ALL SELECT NULL
    UNION ALL SELECT 200.0
);

-- ✏️  YOUR TURN:
-- Write a customer revenue query where EVERY numeric column is
-- wrapped in COALESCE before use in arithmetic. Include:
--   - total_revenue: sum of payments (0 if no payments)
--   - avg_discount:  avg discount_pct (0 if no discounts)
--   - delivery_rate: delivered_orders / total_orders (0 if no orders)
-- All three should return 0 for customers with no orders/payments.



-- ─────────────────────────────────────────────────────────────
-- 4.3  Assertion CTEs — fail loud, fail early
-- ─────────────────────────────────────────────────────────────
-- An assertion CTE runs a quality check inline with your query.
-- If it returns rows, the data has a problem you should know about.
-- Zero rows = assertion passed.

WITH assert_no_negative_payments AS (
    SELECT id, amount
    FROM   payments
    WHERE  amount <= 0
),
assert_all_orders_have_customers AS (
    SELECT o.id
    FROM   orders    o
    LEFT JOIN customers c ON c.id = o.customer_id
    WHERE  c.id IS NULL
)
-- You'd typically put these in a separate "quality" run.
-- For this exercise, just show the results:
SELECT 'negative_payments'      AS check_name,
       COUNT(*)                 AS failures
FROM   assert_no_negative_payments
UNION ALL
SELECT 'orphaned_orders', COUNT(*)
FROM   assert_all_orders_have_customers;

-- ✏️  YOUR TURN:
-- Add three more assertions to the block above:
--   1. assert_valid_tier: customers with tier NOT IN ('bronze','silver','gold')
--   2. assert_positive_quantity: order_items where quantity <= 0
--   3. assert_logical_dates: orders where updated_at < created_at



-- ─────────────────────────────────────────────────────────────
-- 4.4  Idempotent INSERT pattern
-- ─────────────────────────────────────────────────────────────
-- A production pipeline should be safe to re-run. INSERT OR REPLACE
-- (or INSERT OR IGNORE) prevents duplicate key errors.

-- Create a summary table (run once):
DROP TABLE IF EXISTS customer_summary;
CREATE TABLE customer_summary (
    customer_id    INTEGER PRIMARY KEY,
    full_name      TEXT,
    tier           TEXT,
    total_orders   INTEGER,
    total_spent    REAL,
    last_updated   TEXT
);

-- Populate it idempotently (safe to run again):
INSERT OR REPLACE INTO customer_summary
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS cnt
    FROM   orders
    GROUP BY customer_id
),
payment_totals AS (
    SELECT o.customer_id, SUM(p.amount) AS total
    FROM   orders o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT c.id,
       c.first_name || ' ' || COALESCE(c.last_name, '') AS full_name,
       c.tier,
       COALESCE(oc.cnt,   0)     AS total_orders,
       COALESCE(pt.total, 0.00)  AS total_spent,
       DATETIME('now')           AS last_updated
FROM   customers c
LEFT JOIN order_counts  oc ON oc.customer_id = c.id
LEFT JOIN payment_totals pt ON pt.customer_id = c.id;

SELECT * FROM customer_summary ORDER BY total_spent DESC;

-- ✏️  YOUR TURN:
-- Run the INSERT OR REPLACE block a second time. What happens?
-- Now simulate an update: manually change one customer's tier
-- in the customers table, re-run the insert, and verify the
-- summary table reflects the change.



-- ─────────────────────────────────────────────────────────────
-- 4.5  CHALLENGE: Production-grade revenue report
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a production-quality regional revenue report that:
--   1. Has a leading comment block explaining what it does
--   2. Uses at least 4 named CTEs (each doing ONE job)
--   3. Uses COALESCE on every nullable aggregation
--   4. Includes an assertion CTE that validates input data
--   5. Produces: region, year_month, order_count,
--      gross_revenue (from order_items), net_revenue (after discount),
--      payment_collected (from payments), payment_gap (gross - collected)
--   6. Filters to 'delivered' orders only
--   7. Sorts by year_month DESC, region ASC
