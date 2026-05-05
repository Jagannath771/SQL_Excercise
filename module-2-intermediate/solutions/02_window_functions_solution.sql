-- ============================================================
-- MODULE 2 | Exercise 2 SOLUTIONS: Window Functions
-- ============================================================

-- 2.1  Most recent order per customer
WITH numbered_orders AS (
    SELECT customer_id,
           id           AS order_id,
           created_at,
           status,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY created_at DESC
           ) AS rn
    FROM   orders
)
SELECT c.first_name, no.order_id, no.created_at, no.status
FROM   numbered_orders no
INNER JOIN customers c ON c.id = no.customer_id
WHERE  no.rn = 1
ORDER BY c.first_name;

-- 2.2  Customer spend ranking
WITH customer_spend AS (
    SELECT o.customer_id,
           SUM(p.amount) AS total_spent
    FROM   orders o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT RANK() OVER (ORDER BY cs.total_spent DESC)  AS spend_rank,
       c.first_name,
       c.last_name,
       c.tier,
       ROUND(cs.total_spent, 2)                    AS total_spent
FROM   customer_spend cs
INNER JOIN customers c ON c.id = cs.customer_id
ORDER BY spend_rank
LIMIT 10;

-- 2.3  Running total + pct of total
SELECT p.id,
       p.paid_at,
       p.amount,
       ROUND(
           SUM(p.amount) OVER (
               ORDER BY p.paid_at
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ), 2)  AS running_revenue,
       ROUND(
           p.amount * 100.0 / SUM(p.amount) OVER (),
       2)         AS pct_of_total
FROM   payments p
WHERE  p.status = 'completed'
ORDER BY p.paid_at;

-- 2.4  MoM growth with pct_change
WITH monthly_revenue AS (
    SELECT SUBSTR(paid_at, 1, 7) AS month,
           SUM(amount)            AS revenue
    FROM   payments
    WHERE  status = 'completed'
    GROUP BY SUBSTR(paid_at, 1, 7)
)
SELECT month,
       ROUND(revenue, 2)                                  AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2)       AS prev_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS revenue_change,
       CASE
           WHEN LAG(revenue) OVER (ORDER BY month) IS NULL THEN NULL
           ELSE ROUND(
               (revenue - LAG(revenue) OVER (ORDER BY month))
               / LAG(revenue) OVER (ORDER BY month) * 100,
           1)
       END                                                AS pct_change
FROM   monthly_revenue
ORDER BY month;

-- 2.5  Spend rank within tier
WITH customer_spend AS (
    SELECT o.customer_id,
           SUM(p.amount) AS total_spent
    FROM   orders o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT c.first_name,
       c.tier,
       ROUND(cs.total_spent, 2)  AS total_spent,
       RANK() OVER (
           PARTITION BY c.tier
           ORDER BY cs.total_spent DESC
       )                         AS spend_rank_in_tier
FROM   customer_spend cs
INNER JOIN customers c ON c.id = cs.customer_id
ORDER BY c.tier, spend_rank_in_tier;

-- 2.6  Challenge: first/last order gap
SELECT c.first_name,
       c.tier,
       MIN(o.created_at)                                    AS first_order_date,
       MAX(o.created_at)                                    AS last_order_date,
       ROUND(JULIANDAY(MAX(o.created_at))
           - JULIANDAY(MIN(o.created_at)))                  AS days_between,
       COUNT(o.id)                                          AS total_orders
FROM   customers c
INNER JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.first_name, c.tier
HAVING COUNT(o.id) > 1
ORDER BY days_between DESC;
