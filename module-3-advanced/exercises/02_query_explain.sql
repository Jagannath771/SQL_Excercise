-- ============================================================
-- MODULE 3 | Exercise 2: EXPLAIN & Query Performance
-- Difficulty: ⭐⭐⭐ Hard  |  Estimated time: 20 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Use EXPLAIN QUERY PLAN to inspect how SQLite runs a query
-- 2. Identify full table scans vs index seeks
-- 3. Create indexes and measure their impact
-- 4. Understand join ordering and its performance implications
-- 5. Write EXPLAIN-informed rewrites to speed up slow queries
--
-- HOW TO USE IN DBEAVER:
-- Method 1: Prefix any query with EXPLAIN QUERY PLAN and run normally.
-- Method 2: Highlight a query → right-click → "Explain Execution Plan"
--           (DBeaver shows a visual tree — very helpful for complex joins)
--
-- WHAT TO LOOK FOR:
-- "SCAN TABLE X"         → full table scan (bad on large tables)
-- "SEARCH TABLE X USING INDEX" → index lookup (good)
-- "USING COVERING INDEX"       → even better (no table read needed)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 2.1  Your first EXPLAIN
-- ─────────────────────────────────────────────────────────────
-- See how SQLite plans a simple filter:
EXPLAIN QUERY PLAN
SELECT * FROM customers WHERE tier = 'gold';

-- You'll see "SCAN TABLE customers" — it reads every row to find gold ones.
-- On a 1M-row table, this would be slow.

-- ✏️  OBSERVE:
-- Run EXPLAIN QUERY PLAN on these queries and note what you see:
EXPLAIN QUERY PLAN SELECT * FROM customers WHERE id = 5;
-- (id is a PRIMARY KEY — should use index)

EXPLAIN QUERY PLAN SELECT * FROM orders WHERE customer_id = 1;
-- (customer_id has no index — full scan)

-- Write your observations:
-- Query 1 (id=5):
-- Query 2 (customer_id=1):



-- ─────────────────────────────────────────────────────────────
-- 2.2  Creating an index and seeing its effect
-- ─────────────────────────────────────────────────────────────
-- BEFORE index: explain the join query
EXPLAIN QUERY PLAN
SELECT o.id, o.status, c.first_name
FROM   orders o
INNER JOIN customers c ON c.id = o.customer_id
WHERE  o.status = 'delivered';

-- Now create an index on orders.status and orders.customer_id:
CREATE INDEX IF NOT EXISTS idx_orders_status      ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id  ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_oi_order_id        ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_oi_product_id      ON order_items(product_id);

-- AFTER index: run the same explain
EXPLAIN QUERY PLAN
SELECT o.id, o.status, c.first_name
FROM   orders o
INNER JOIN customers c ON c.id = o.customer_id
WHERE  o.status = 'delivered';

-- ✏️  YOUR TURN:
-- Run EXPLAIN QUERY PLAN on the 3-table join below BEFORE and AFTER
-- creating the indexes above. What changed?
EXPLAIN QUERY PLAN
SELECT c.first_name, p.amount
FROM   customers c
INNER JOIN orders   o ON o.customer_id = c.id
INNER JOIN payments p ON p.order_id    = o.id
WHERE  p.status = 'completed'
  AND  c.tier   = 'gold';

-- Before indexes observation:
-- After indexes observation:



-- ─────────────────────────────────────────────────────────────
-- 2.3  Slow query vs fast query
-- ─────────────────────────────────────────────────────────────
-- SLOW: correlated subquery (runs once per outer row)
EXPLAIN QUERY PLAN
SELECT id,
       first_name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS order_count
FROM   customers c;

-- FAST: pre-aggregated JOIN (runs aggregation once)
EXPLAIN QUERY PLAN
SELECT c.id,
       c.first_name,
       COALESCE(o.order_count, 0) AS order_count
FROM   customers c
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS order_count
    FROM   orders
    GROUP BY customer_id
) o ON o.customer_id = c.id;

-- ✏️  YOUR TURN:
-- Rewrite this correlated subquery as a pre-aggregated join:
--
--   SELECT id, name, price,
--          (SELECT SUM(quantity) FROM order_items oi
--           WHERE oi.product_id = p.id) AS total_sold
--   FROM products p;
--
-- Then run EXPLAIN QUERY PLAN on both versions. Which reads fewer rows?



-- ─────────────────────────────────────────────────────────────
-- 2.4  Covering index — the fastest possible read
-- ─────────────────────────────────────────────────────────────
-- A covering index stores ALL columns the query needs, so SQLite
-- never touches the actual table row. You'll see "USING COVERING INDEX".

-- Create a composite index that covers a common query:
CREATE INDEX IF NOT EXISTS idx_orders_status_region
    ON orders(status, region);

-- Now check if this query benefits:
EXPLAIN QUERY PLAN
SELECT status, region, COUNT(*) AS cnt
FROM   orders
WHERE  status = 'delivered'
GROUP BY region;

-- ✏️  YOUR TURN:
-- Think of one more query pattern from your earlier exercises.
-- Create an index that would help it, run EXPLAIN QUERY PLAN
-- before and after, and document the improvement.

-- Your query:
-- Index you created:
-- Observation:



-- ─────────────────────────────────────────────────────────────
-- 2.5  CHALLENGE: Optimize the capstone-style query
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- This query calculates customer lifetime value.
-- Run EXPLAIN QUERY PLAN first, then optimize it:
--
--   SELECT c.id, c.first_name, c.tier,
--          SUM(p.amount) AS ltv,
--          COUNT(DISTINCT o.id) AS order_count,
--          MIN(o.created_at)    AS first_order,
--          MAX(o.created_at)    AS last_order
--   FROM customers c
--   LEFT JOIN orders   o ON o.customer_id = c.id
--   LEFT JOIN payments p ON p.order_id = o.id AND p.status='completed'
--   GROUP BY c.id, c.first_name, c.tier
--   ORDER BY ltv DESC;
--
-- Steps:
-- 1. Run EXPLAIN QUERY PLAN and identify any SCANs
-- 2. Add any missing indexes
-- 3. Rewrite to pre-aggregate before joining if needed
-- 4. Run EXPLAIN QUERY PLAN again and compare
