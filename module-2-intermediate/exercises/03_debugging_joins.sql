-- ============================================================
-- MODULE 2 | Exercise 3: Debugging Joins
-- Difficulty: ⭐⭐ Medium  |  Estimated time: 15 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Understand what a "fanout" is and why it silently corrupts data
-- 2. Detect fanout risk BEFORE writing a join
-- 3. Fix a fanout by aggregating before joining
-- 4. Verify join correctness with count checks
-- 5. Use LEFT JOIN + IS NULL to find orphaned records
--
-- WHAT IS A FANOUT?
-- When you join Table A to Table B and B has multiple rows per
-- join key, each A row is duplicated for every matching B row.
-- Your SUM() or COUNT() then returns inflated (wrong) results
-- and no error is thrown. This is one of the most common bugs
-- in production data pipelines.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 3.1  Demonstrating a fanout
-- ─────────────────────────────────────────────────────────────
-- First, check: does one order always have exactly one order_item?
SELECT order_id, COUNT(*) AS item_count
FROM   order_items
GROUP BY order_id
ORDER BY item_count DESC
LIMIT 10;

-- You'll see some orders have 2 or 3 items. That's the fanout risk.

-- Now try to calculate revenue by joining payments → orders → order_items:
-- ⚠️  THIS QUERY IS WRONG — spot the bug:
SELECT o.region,
       SUM(p.amount) AS total_revenue    -- BUG: amount is inflated
FROM   orders      o
INNER JOIN payments    p  ON p.order_id   = o.id
INNER JOIN order_items oi ON oi.order_id  = o.id  -- causes fanout!
WHERE  p.status = 'completed'
GROUP BY o.region;

-- ✏️  OBSERVE:
-- Run the broken query above, then run this correct version:
SELECT o.region,
       SUM(p.amount) AS total_revenue
FROM   orders   o
INNER JOIN payments p ON p.order_id = o.id
WHERE  p.status = 'completed'
GROUP BY o.region;
-- Are the numbers the same? Which is correct? Why?

-- Your explanation:



-- ─────────────────────────────────────────────────────────────
-- 3.2  The fix: aggregate BEFORE joining
-- ─────────────────────────────────────────────────────────────
-- When you need data from order_items AND payments in the same query,
-- aggregate order_items first into one row per order_id, THEN join.

WITH order_totals AS (
    -- Collapse order_items to ONE row per order first
    SELECT order_id,
           COUNT(*)                     AS line_item_count,
           SUM(quantity * unit_price)   AS item_subtotal
    FROM   order_items
    GROUP BY order_id
),
order_payments AS (
    SELECT order_id, amount, status
    FROM   payments
)
SELECT o.region,
       o.status                      AS order_status,
       ot.line_item_count,
       ot.item_subtotal,
       op.amount                     AS payment_amount,
       op.status                     AS payment_status
FROM   orders         o
INNER JOIN order_totals   ot ON ot.order_id = o.id
LEFT  JOIN order_payments op ON op.order_id = o.id
ORDER BY o.id;

-- ✏️  YOUR TURN:
-- Using the pattern above, calculate total revenue per PRODUCT CATEGORY.
-- The tricky part: you need order_items (for category via products)
-- AND payments (for revenue). Aggregate order_items first!
-- Steps:
--   CTE 1: item_revenue  → SUM(qty * unit_price) per order_id, product_id
--   CTE 2: join to products for category
--   CTE 3: join to payments for actual payment amount
--   Final: GROUP BY category, SUM payment amounts



-- ─────────────────────────────────────────────────────────────
-- 3.3  Pre-join cardinality check
-- ─────────────────────────────────────────────────────────────
-- RULE: before any join, count the distinct keys on BOTH sides.
-- If the right side has duplicates per key, you'll get a fanout.

-- Check cardinality before joining orders → order_items:
SELECT 'orders'      AS table_name, COUNT(DISTINCT id)       AS distinct_keys FROM orders
UNION ALL
SELECT 'order_items' AS table_name, COUNT(DISTINCT order_id) AS distinct_keys FROM order_items;
-- Result: orders has more distinct ids than order_items has distinct order_ids
-- because some orders have multiple items — join will fan out.

-- ✏️  YOUR TURN:
-- Check cardinality for payments (order_id) vs orders (id).
-- Is payments safe to join to orders without fanout?
-- (Payments has UNIQUE constraint on order_id — verify this!)



-- ─────────────────────────────────────────────────────────────
-- 3.4  Finding orphaned records
-- ─────────────────────────────────────────────────────────────
-- Orphaned records are rows in a child table that reference a
-- non-existent parent. This shouldn't happen with foreign keys,
-- but in real warehouses it often does (FK constraints are often
-- disabled for performance).

-- Find order_items that reference a non-existent order:
SELECT oi.id, oi.order_id, oi.product_id
FROM   order_items oi
LEFT JOIN orders o ON o.id = oi.order_id
WHERE  o.id IS NULL;

-- ✏️  YOUR TURN:
-- Check for order_items that reference a non-existent product.
-- Also check for orders that reference a non-existent customer.
-- Are there any? Document what you find.

-- Findings:



-- ─────────────────────────────────────────────────────────────
-- 3.5  CHALLENGE: Safe revenue by customer report
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a fanout-safe query showing for each customer:
--   - first_name, last_name, tier
--   - total_orders (count of orders, any status)
--   - delivered_orders (count where status = 'delivered')
--   - total_items_purchased (sum of quantity from order_items,
--     only for delivered orders)
--   - total_spent (sum of completed payment amounts)
-- Use CTEs to aggregate BEFORE joining.
-- Include ALL customers (even those with no orders) — use LEFT JOINs.
