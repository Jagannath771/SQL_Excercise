-- ============================================================
-- MODULE 3 | Exercise 1 SOLUTIONS: Advanced CTEs
-- ============================================================

-- 1.1  Monthly order counts including zero months
WITH RECURSIVE month_series AS (
    SELECT DATE('2023-01-01') AS month_start
    UNION ALL
    SELECT DATE(month_start, '+1 month')
    FROM   month_series
    WHERE  DATE(month_start, '+1 month') <= DATE('2024-12-01')
),
monthly_orders AS (
    SELECT STRFTIME('%Y-%m', created_at) AS year_month,
           COUNT(*)                       AS order_count
    FROM   orders
    GROUP BY STRFTIME('%Y-%m', created_at)
)
SELECT STRFTIME('%Y-%m', ms.month_start) AS year_month,
       COALESCE(mo.order_count, 0)        AS order_count
FROM   month_series ms
LEFT JOIN monthly_orders mo
       ON mo.year_month = STRFTIME('%Y-%m', ms.month_start)
ORDER BY year_month;

-- 1.2  Price bucket distribution
WITH RECURSIVE buckets AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM buckets WHERE n < 10
),
bucket_assignments AS (
    SELECT p.name,
           p.category,
           p.price,
           b.n AS bucket_num
    FROM   products p
    INNER JOIN buckets b
           ON p.price >= (b.n - 1) * 50
          AND p.price <   b.n      * 50
)
SELECT '$' || ((bucket_num-1)*50) || '-$' || (bucket_num*50) AS price_range,
       COUNT(*)                                               AS product_count,
       ROUND(AVG(price), 2)                                   AS avg_price
FROM   bucket_assignments
GROUP BY bucket_num
ORDER BY bucket_num;

-- 1.3  Customer journey with extra columns
WITH ordered_purchases AS (
    SELECT o.customer_id,
           c.first_name,
           o.id           AS order_id,
           o.created_at,
           o.status,
           p.amount,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id ORDER BY o.created_at
           ) AS order_seq
    FROM   orders      o
    INNER JOIN customers c ON c.id       = o.customer_id
    LEFT  JOIN payments  p ON p.order_id = o.id
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
       SUBSTR(created_at, 1, 10)                              AS order_date,
       ROUND(COALESCE(amount, 0), 2)                          AS payment,
       ROUND(cumulative_spend, 2)                             AS cumulative_spend,
       ROUND(cumulative_spend / order_seq, 2)                 AS spend_velocity,
       CASE
           WHEN prev_order_at IS NULL THEN 0
           WHEN JULIANDAY(created_at) - JULIANDAY(prev_order_at) <= 30 THEN 1
           ELSE 0
       END                                                    AS is_repeat_within_30_days
FROM   with_lag
WHERE  customer_id IN (
    SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*) >= 2
)
ORDER BY customer_id, order_seq;

-- 1.4  Challenge: cohort retention matrix
WITH RECURSIVE month_series AS (
    SELECT DATE('2023-01-01') AS month_start
    UNION ALL
    SELECT DATE(month_start, '+1 month')
    FROM   month_series
    WHERE  DATE(month_start, '+1 month') <= DATE('2024-12-01')
),
customer_first_order AS (
    SELECT customer_id,
           MIN(STRFTIME('%Y-%m', created_at)) AS cohort_month
    FROM   orders
    GROUP BY customer_id
),
customer_activity AS (
    SELECT o.customer_id,
           STRFTIME('%Y-%m', o.created_at) AS activity_month
    FROM   orders o
    WHERE  o.status != 'cancelled'
    GROUP BY o.customer_id, STRFTIME('%Y-%m', o.created_at)
),
cohort_join AS (
    SELECT cfo.cohort_month,
           ca.activity_month,
           COUNT(DISTINCT cfo.customer_id) AS active_customers,
           CAST(
               (JULIANDAY(ca.activity_month || '-01')
                - JULIANDAY(cfo.cohort_month || '-01'))
               / 30.44 AS INTEGER
           ) AS months_since_first
    FROM   customer_first_order cfo
    INNER JOIN customer_activity ca ON ca.customer_id = cfo.customer_id
    GROUP BY cfo.cohort_month, ca.activity_month
)
SELECT cohort_month,
       activity_month,
       months_since_first,
       active_customers
FROM   cohort_join
WHERE  months_since_first BETWEEN 0 AND 3
ORDER BY cohort_month, months_since_first;
