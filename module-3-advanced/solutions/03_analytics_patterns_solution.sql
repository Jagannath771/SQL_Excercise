-- ============================================================
-- MODULE 3 | Exercise 3 SOLUTIONS: Analytics Patterns
-- ============================================================

-- 3.1  Cohort retention with months_since
WITH customer_cohorts AS (
    SELECT id,
           STRFTIME('%Y-%m', signup_date) AS cohort_month
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
cohort_with_months AS (
    SELECT cc.cohort_month,
           ca.activity_month,
           CAST(
               (JULIANDAY(ca.activity_month || '-01')
                - JULIANDAY(cc.cohort_month || '-01'))
               / 30.44 AS INTEGER
           ) AS months_since_cohort,
           COUNT(DISTINCT cc.id) AS active_customers
    FROM   customer_cohorts cc
    LEFT JOIN customer_activity ca ON ca.customer_id = cc.id
    GROUP BY cc.cohort_month, ca.activity_month
)
SELECT cohort_month,
       activity_month,
       months_since_cohort,
       active_customers
FROM   cohort_with_months
WHERE  months_since_cohort BETWEEN 0 AND 3
  AND  activity_month IS NOT NULL
ORDER BY cohort_month, months_since_cohort;

-- 3.2  Conversion funnel with repeat buyer + pct_of_prev
WITH all_customers       AS (SELECT COUNT(DISTINCT id) AS n FROM customers),
     with_orders         AS (SELECT COUNT(DISTINCT customer_id) AS n FROM orders),
     with_delivered      AS (SELECT COUNT(DISTINCT customer_id) AS n FROM orders WHERE status='delivered'),
     with_completed      AS (
         SELECT COUNT(DISTINCT o.customer_id) AS n
         FROM orders o INNER JOIN payments p ON p.order_id=o.id WHERE p.status='completed'
     ),
     repeat_buyers       AS (
         SELECT COUNT(DISTINCT o.customer_id) AS n
         FROM orders o
         INNER JOIN payments p ON p.order_id=o.id AND p.status='completed'
         WHERE o.status='delivered'
         GROUP BY o.customer_id HAVING COUNT(DISTINCT o.id)>=2
     ),
     repeat_count        AS (SELECT COUNT(*) AS n FROM repeat_buyers)
SELECT 'Signed up'       AS stage, (SELECT n FROM all_customers)  AS customers,
    100.0                AS pct_of_top, NULL AS pct_of_prev
UNION ALL
SELECT 'Placed order',   (SELECT n FROM with_orders),
    ROUND((SELECT n FROM with_orders)*100.0/(SELECT n FROM all_customers),1),
    ROUND((SELECT n FROM with_orders)*100.0/(SELECT n FROM all_customers),1)
UNION ALL
SELECT 'Had delivery',   (SELECT n FROM with_delivered),
    ROUND((SELECT n FROM with_delivered)*100.0/(SELECT n FROM all_customers),1),
    ROUND((SELECT n FROM with_delivered)*100.0/(SELECT n FROM with_orders),1)
UNION ALL
SELECT 'Paid (completed)',(SELECT n FROM with_completed),
    ROUND((SELECT n FROM with_completed)*100.0/(SELECT n FROM all_customers),1),
    ROUND((SELECT n FROM with_completed)*100.0/(SELECT n FROM with_delivered),1)
UNION ALL
SELECT 'Repeat buyer',   (SELECT n FROM repeat_count),
    ROUND((SELECT n FROM repeat_count)*100.0/(SELECT n FROM all_customers),1),
    ROUND((SELECT n FROM repeat_count)*100.0/(SELECT n FROM with_completed),1);

-- 3.3  MoM growth with 3-month rolling average
WITH monthly AS (
    SELECT STRFTIME('%Y-%m', paid_at) AS month,
           SUM(amount)                AS revenue
    FROM   payments WHERE status='completed'
    GROUP BY STRFTIME('%Y-%m', paid_at)
),
with_growth AS (
    SELECT month, revenue,
           LAG(revenue)  OVER (ORDER BY month)  AS prev_revenue,
           AVG(revenue)  OVER (ORDER BY month
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3m
    FROM   monthly
)
SELECT month,
       ROUND(revenue,2)      AS revenue,
       ROUND(prev_revenue,2) AS prev_month,
       CASE WHEN prev_revenue IS NULL THEN NULL
            ELSE ROUND((revenue-prev_revenue)/prev_revenue*100,1)
       END                   AS mom_pct,
       ROUND(rolling_3m,2)   AS rolling_3m_avg
FROM   with_growth ORDER BY month;

-- 3.4  Customer revenue quartiles
WITH customer_spend AS (
    SELECT o.customer_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           SUM(p.amount) AS total_spent
    FROM orders o
    INNER JOIN customers c ON c.id=o.customer_id
    INNER JOIN payments p ON p.order_id=o.id AND p.status='completed'
    GROUP BY o.customer_id, c.first_name, c.last_name
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY total_spent) AS rn,
           COUNT(*) OVER ()                          AS total_count
    FROM customer_spend
)
SELECT customer_name,
       ROUND(total_spent,2) AS total_spent,
       CASE
           WHEN rn <= total_count * 0.25 THEN 'Q1 - Bottom 25%'
           WHEN rn <= total_count * 0.50 THEN 'Q2 - 25-50%'
           WHEN rn <= total_count * 0.75 THEN 'Q3 - 50-75%'
           ELSE                               'Q4 - Top 25%'
       END AS revenue_quartile
FROM ranked ORDER BY total_spent DESC;
