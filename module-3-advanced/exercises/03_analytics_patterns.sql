-- ============================================================
-- MODULE 3 | Exercise 3: Analytics Patterns
-- Difficulty: ⭐⭐⭐ Hard  |  Estimated time: 25 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Build a cohort retention matrix
-- 2. Write a conversion funnel analysis
-- 3. Compute running totals and period-over-period growth
-- 4. Calculate percentiles and distributions
-- 5. Combine all patterns into an executive summary
--
-- WHY THESE PATTERNS MATTER:
-- Cohort analysis, funnels, and period-over-period growth are
-- the three most requested analytics reports in any business.
-- Once you can write these in SQL, you can answer almost any
-- business question from raw data.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 3.1  Cohort analysis — customer retention by signup month
-- ─────────────────────────────────────────────────────────────
-- Assign each customer to a cohort (their signup month).
-- Then for each cohort, count how many customers placed an order
-- in each subsequent month.

WITH customer_cohorts AS (
    SELECT id,
           first_name,
           STRFTIME('%Y-%m', signup_date)  AS cohort_month
    FROM   customers
    WHERE  signup_date IS NOT NULL
),
customer_activity AS (
    SELECT o.customer_id,
           STRFTIME('%Y-%m', o.created_at) AS activity_month
    FROM   orders o
    WHERE  o.status != 'cancelled'
    GROUP BY o.customer_id, STRFTIME('%Y-%m', o.created_at)
),
cohort_activity AS (
    SELECT cc.cohort_month,
           ca.activity_month,
           COUNT(DISTINCT cc.id) AS active_customers
    FROM   customer_cohorts cc
    LEFT JOIN customer_activity ca ON ca.customer_id = cc.id
    GROUP BY cc.cohort_month, ca.activity_month
)
SELECT cohort_month,
       activity_month,
       active_customers
FROM   cohort_activity
WHERE  activity_month IS NOT NULL
ORDER BY cohort_month, activity_month;

-- ✏️  YOUR TURN:
-- Extend the above to add a column 'months_since_cohort':
-- the number of months between cohort_month and activity_month.
-- In SQLite: CAST((JULIANDAY(activity_month||'-01') -
--                  JULIANDAY(cohort_month||'-01')) / 30.44 AS INTEGER)
-- Then filter to show only months_since_cohort IN (0, 1, 2, 3).
-- This is your retention matrix.



-- ─────────────────────────────────────────────────────────────
-- 3.2  Conversion funnel
-- ─────────────────────────────────────────────────────────────
-- The ShopMetrics funnel: Customer signs up → places order →
--                         order delivered → payment completed
-- At each step, count how many customers made it through.

WITH all_customers AS (
    SELECT COUNT(DISTINCT id) AS total FROM customers
),
customers_with_orders AS (
    SELECT COUNT(DISTINCT customer_id) AS ordered
    FROM   orders
),
customers_delivered AS (
    SELECT COUNT(DISTINCT customer_id) AS delivered
    FROM   orders
    WHERE  status = 'delivered'
),
customers_paid AS (
    SELECT COUNT(DISTINCT o.customer_id) AS paid
    FROM   orders   o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
)
SELECT
    'Signed up'          AS stage, total      AS customers,
    100.0                AS pct_of_top
FROM all_customers
UNION ALL
SELECT 'Placed order',  ordered,
    ROUND(ordered   * 100.0 / (SELECT total    FROM all_customers),    1)
FROM customers_with_orders
UNION ALL
SELECT 'Had delivery',  delivered,
    ROUND(delivered * 100.0 / (SELECT total    FROM all_customers),    1)
FROM customers_delivered
UNION ALL
SELECT 'Paid (completed)', paid,
    ROUND(paid      * 100.0 / (SELECT total    FROM all_customers),    1)
FROM customers_paid;

-- ✏️  YOUR TURN:
-- Add a 5th funnel stage: 'Repeat buyer' — customers who have
-- 2+ delivered orders with completed payments.
-- Also add a column 'pct_of_prev_stage' (conversion from prior step).



-- ─────────────────────────────────────────────────────────────
-- 3.3  Period-over-period growth (MoM)
-- ─────────────────────────────────────────────────────────────
WITH monthly AS (
    SELECT STRFTIME('%Y-%m', paid_at) AS month,
           COUNT(*)                   AS orders,
           SUM(amount)                AS revenue
    FROM   payments
    WHERE  status = 'completed'
    GROUP BY STRFTIME('%Y-%m', paid_at)
),
with_growth AS (
    SELECT month,
           orders,
           revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
           LAG(orders)  OVER (ORDER BY month) AS prev_orders
    FROM   monthly
)
SELECT month,
       orders,
       ROUND(revenue, 2)           AS revenue,
       ROUND(prev_revenue, 2)      AS prev_month_revenue,
       CASE
           WHEN prev_revenue IS NULL THEN NULL
           ELSE ROUND((revenue - prev_revenue) / prev_revenue * 100, 1)
       END                         AS revenue_growth_pct,
       SUM(revenue) OVER (ORDER BY month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       )                           AS cumulative_revenue
FROM   with_growth
ORDER BY month;

-- ✏️  YOUR TURN:
-- Calculate the 3-month rolling average revenue
-- (average of current month + previous 2 months).
-- Hint: use AVG(revenue) OVER (ORDER BY month
--            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)



-- ─────────────────────────────────────────────────────────────
-- 3.4  Revenue distribution — percentiles and buckets
-- ─────────────────────────────────────────────────────────────
-- SQLite doesn't have PERCENTILE_CONT, but you can approximate
-- percentiles using window functions + row numbering.

WITH ranked_payments AS (
    SELECT amount,
           ROW_NUMBER() OVER (ORDER BY amount)       AS rn,
           COUNT(*)     OVER ()                      AS total
    FROM   payments
    WHERE  status = 'completed'
)
SELECT
    MIN(amount)                                      AS min_order_value,
    MAX(amount)                                      AS max_order_value,
    ROUND(AVG(amount), 2)                            AS avg_order_value,
    MAX(CASE WHEN rn <= total * 0.25 THEN amount END) AS p25,
    MAX(CASE WHEN rn <= total * 0.50 THEN amount END) AS p50_median,
    MAX(CASE WHEN rn <= total * 0.75 THEN amount END) AS p75,
    MAX(CASE WHEN rn <= total * 0.90 THEN amount END) AS p90
FROM   ranked_payments;

-- ✏️  YOUR TURN:
-- Segment customers into revenue quartiles:
--   Q1: bottom 25% spenders
--   Q2: 25-50%
--   Q3: 50-75%
--   Q4: top 25% (your most valuable customers)
-- Show customer_name, total_spent, and their quartile label.
-- Hint: use NTILE(4) OVER (ORDER BY total_spent) if available,
-- or use the ranked row approach above.



-- ─────────────────────────────────────────────────────────────
-- 3.5  CHALLENGE: Executive summary dashboard
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a single "executive summary" query using UNION ALL that
-- outputs a key_metric / value / context table:
--
--   metric                    | value  | context
--   ─────────────────────────────────────────────
--   Total Customers           | 25     | all time
--   Customers with Orders     | 20     | all time
--   Total Orders              | 50     | all time
--   Delivered Orders          | 25     | all time
--   Cancelled Orders          | 5      | all time
--   Completed Revenue         | 21382  | USD, all time
--   Avg Order Value           | 475    | completed payments
--   Top Region by Revenue     | Online | by sum of payments
--   Best Selling Category     | Books  | by units sold
--   Orders Missing Payment    | 5      | data quality flag
--
-- Use CTEs for each metric and UNION ALL to combine into one table.
