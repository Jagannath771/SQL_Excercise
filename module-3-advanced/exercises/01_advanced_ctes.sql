-- ============================================================
-- MODULE 3 | Exercise 1: Advanced CTEs & Recursive SQL
-- Difficulty: ⭐⭐⭐ Hard  |  Estimated time: 20 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Write recursive CTEs for sequence generation
-- 2. Use recursive CTEs for hierarchical data traversal
-- 3. Understand base case + recursive step structure
-- 4. Apply recursive CTEs to solve real analytics problems
--
-- RECURSIVE CTE SYNTAX:
--   WITH RECURSIVE cte_name AS (
--       -- Base case (starting rows)
--       SELECT ...
--       UNION ALL
--       -- Recursive step (references cte_name itself)
--       SELECT ... FROM cte_name WHERE <stop condition>
--   )
--   SELECT * FROM cte_name;
--
-- IMPORTANT: SQLite uses WITH RECURSIVE (required keyword).
-- PostgreSQL supports both WITH and WITH RECURSIVE.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1.1  Generating a date series
-- ─────────────────────────────────────────────────────────────
-- Generate every month from 2023-01 to 2024-12.
-- This is the backbone of "fill in missing months" reports.

WITH RECURSIVE month_series AS (
    -- Base case: start at the first month
    SELECT DATE('2023-01-01') AS month_start
    UNION ALL
    -- Recursive step: add one month each iteration
    SELECT DATE(month_start, '+1 month')
    FROM   month_series
    WHERE  DATE(month_start, '+1 month') <= DATE('2024-12-01')
)
SELECT month_start,
       STRFTIME('%Y-%m', month_start) AS year_month
FROM   month_series;

-- ✏️  YOUR TURN:
-- Use this month_series technique to show monthly order counts,
-- including months with ZERO orders (those months won't appear
-- in a plain GROUP BY — the recursive CTE fills the gaps).
-- Columns: year_month, order_count (0 if no orders that month).
-- Hint: LEFT JOIN month_series to orders on STRFTIME matching.



-- ─────────────────────────────────────────────────────────────
-- 1.2  Generating a number sequence
-- ─────────────────────────────────────────────────────────────
-- Generate numbers 1 through 10 (building block for many patterns):
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT n FROM numbers;

-- ✏️  YOUR TURN:
-- Use a number sequence to generate 10 "buckets" for a price
-- distribution of products. Each bucket covers $50 of price range.
-- Show: bucket (e.g. '$0-$50'), product_count, avg_price.
-- Hint: n * 50 defines bucket boundaries. JOIN to products on
-- price BETWEEN (n-1)*50 AND n*50.



-- ─────────────────────────────────────────────────────────────
-- 1.3  Customer order journey
-- ─────────────────────────────────────────────────────────────
-- Find each customer's "journey" — order number, days since previous order,
-- and cumulative spend — using window functions + CTEs.
-- (This simulates what a recursive CTE would do hierarchically.)

WITH ordered_purchases AS (
    SELECT o.customer_id,
           c.first_name,
           o.id           AS order_id,
           o.created_at,
           o.status,
           p.amount,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id
               ORDER BY o.created_at
           ) AS order_seq
    FROM   orders      o
    INNER JOIN customers c ON c.id       = o.customer_id
    LEFT  JOIN payments  p ON p.order_id = o.id
    WHERE  p.status = 'completed' OR p.status IS NULL
),
with_lag AS (
    SELECT *,
           LAG(created_at) OVER (
               PARTITION BY customer_id ORDER BY order_seq
           ) AS prev_order_at,
           SUM(COALESCE(amount, 0)) OVER (
               PARTITION BY customer_id
               ORDER BY order_seq
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS cumulative_spend
    FROM ordered_purchases
)
SELECT first_name,
       order_seq,
       order_id,
       SUBSTR(created_at, 1, 10)  AS order_date,
       ROUND(COALESCE(amount, 0), 2) AS payment,
       ROUND(cumulative_spend, 2) AS cumulative_spend,
       CASE
           WHEN prev_order_at IS NULL THEN 'First order'
           ELSE CAST(ROUND(JULIANDAY(created_at) - JULIANDAY(prev_order_at)) AS INTEGER) || ' days'
       END AS days_since_prev
FROM   with_lag
ORDER BY customer_id, order_seq;

-- ✏️  YOUR TURN:
-- Modify the query above to also calculate:
--   - 'is_repeat_within_30_days': 1 if days since prev order <= 30
--   - 'spend_velocity': cumulative_spend / order_seq (avg spend per order so far)
-- Filter to show only customers who have 2+ orders.



-- ─────────────────────────────────────────────────────────────
-- 1.4  CHALLENGE: Cohort first-order month
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Use WITH RECURSIVE to generate all months from 2023-01 to 2024-12.
-- Then:
--   1. Find each customer's first order month (cohort assignment)
--   2. For each cohort (first order month), show how many customers
--      placed orders in each SUBSEQUENT month (retention)
--   3. Output columns:
--        cohort_month | activity_month | months_since_first | customer_count
-- This is the foundation of cohort retention analysis (covered more
-- in Exercise 3 of this module).
