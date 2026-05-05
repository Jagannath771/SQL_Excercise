-- ============================================================
-- MODULE 2 | Exercise 2: Window Functions
-- Difficulty: ⭐⭐ Medium  |  Estimated time: 15 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Understand the difference between GROUP BY and window functions
-- 2. Use ROW_NUMBER() and RANK() to rank rows
-- 3. Use SUM OVER / COUNT OVER for running totals and percentages
-- 4. Use LAG() and LEAD() for period-over-period comparisons
-- 5. Combine PARTITION BY with ORDER BY inside a window
--
-- KEY CONCEPT:
-- Window functions compute values ACROSS rows related to the
-- current row, WITHOUT collapsing the result into fewer rows.
--
-- SYNTAX:
--   function_name() OVER (
--       PARTITION BY column   -- reset for each group
--       ORDER BY column       -- row ordering within the window
--       ROWS/RANGE ...        -- optional: frame definition
--   )
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 2.1  ROW_NUMBER — assign a rank per customer
-- ─────────────────────────────────────────────────────────────
-- Number each customer's orders from earliest to latest:
SELECT c.first_name,
       o.id          AS order_id,
       o.created_at,
       o.status,
       ROW_NUMBER() OVER (
           PARTITION BY o.customer_id
           ORDER BY o.created_at
       ) AS order_number
FROM   orders o
INNER JOIN customers c ON c.id = o.customer_id
ORDER BY c.first_name, order_number;

-- ✏️  YOUR TURN:
-- Use ROW_NUMBER() to find each customer's MOST RECENT order.
-- Hint: number rows newest-first (ORDER BY created_at DESC),
-- then filter WHERE order_number = 1.
-- Wrap in a CTE for clarity.



-- ─────────────────────────────────────────────────────────────
-- 2.2  RANK vs DENSE_RANK
-- ─────────────────────────────────────────────────────────────
-- Rank products by price. Notice how ties are handled differently.
SELECT name,
       category,
       price,
       RANK()       OVER (ORDER BY price DESC) AS price_rank,
       DENSE_RANK() OVER (ORDER BY price DESC) AS price_dense_rank
FROM   products
WHERE  is_active = 1
ORDER BY price DESC;

-- ✏️  YOUR TURN:
-- Rank customers by total completed spend (use a CTE for the spend),
-- then assign a RANK. Show top 10.
-- Columns: rank, first_name, last_name, tier, total_spent.



-- ─────────────────────────────────────────────────────────────
-- 2.3  Running total with SUM OVER
-- ─────────────────────────────────────────────────────────────
-- Show a running total of completed revenue ordered by payment date:
SELECT p.id,
       p.paid_at,
       p.amount,
       SUM(p.amount) OVER (
           ORDER BY p.paid_at
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_revenue
FROM   payments p
WHERE  p.status = 'completed'
ORDER BY p.paid_at;

-- ✏️  YOUR TURN:
-- Add a column 'pct_of_total' that shows what percentage of the
-- TOTAL completed revenue each payment represents.
-- Hint: SUM(amount) OVER () (no ORDER BY, no PARTITION) gives the
-- grand total in every row. Divide amount by that to get percentage.



-- ─────────────────────────────────────────────────────────────
-- 2.4  LAG — previous row value (period-over-period)
-- ─────────────────────────────────────────────────────────────
-- Calculate monthly revenue and compare to the previous month:
WITH monthly_revenue AS (
    SELECT SUBSTR(paid_at, 1, 7) AS month,
           SUM(amount)            AS revenue
    FROM   payments
    WHERE  status = 'completed'
    GROUP BY SUBSTR(paid_at, 1, 7)
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month)           AS prev_month_revenue,
       revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change
FROM   monthly_revenue
ORDER BY month;

-- ✏️  YOUR TURN:
-- Extend the query above to add a column 'pct_change' that shows
-- the percentage change from the previous month.
-- Formula: (revenue - prev_month) / prev_month * 100
-- Handle the first month (where prev_month is NULL) gracefully.



-- ─────────────────────────────────────────────────────────────
-- 2.5  PARTITION BY — window per group
-- ─────────────────────────────────────────────────────────────
-- For each order, show what % of the customer's total spend it represents:
SELECT c.first_name,
       o.id           AS order_id,
       p.amount,
       SUM(p.amount) OVER (PARTITION BY o.customer_id) AS customer_total,
       ROUND(
           p.amount * 100.0 /
           SUM(p.amount) OVER (PARTITION BY o.customer_id),
       2) AS pct_of_customer_total
FROM   orders o
INNER JOIN customers c  ON c.id = o.customer_id
INNER JOIN payments  p  ON p.order_id = o.id
WHERE  p.status = 'completed'
ORDER BY c.first_name, p.amount DESC;

-- ✏️  YOUR TURN:
-- Add a column 'spend_rank_in_tier' that ranks each customer
-- within their tier by total completed spend.
-- Use RANK() OVER (PARTITION BY tier ORDER BY total_spent DESC).
-- You'll need a CTE to compute total_spent first.



-- ─────────────────────────────────────────────────────────────
-- 2.6  CHALLENGE: First and last order per customer
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- For each customer, show:
--   - first_name, tier
--   - first_order_date (MIN created_at)
--   - last_order_date (MAX created_at)
--   - days_between_first_and_last
--     (use JULIANDAY(last) - JULIANDAY(first) in SQLite)
--   - total_orders
-- Only show customers who have more than 1 order.
-- Sort by days_between DESC.
