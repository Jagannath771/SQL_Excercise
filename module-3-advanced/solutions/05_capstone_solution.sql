-- ============================================================
-- MODULE 3 | Exercise 5 SOLUTIONS: Capstone Dashboard
-- NOTE: Multiple valid approaches exist. These are reference answers.
-- ============================================================

-- QUESTION 1 — Revenue Performance
WITH monthly AS (
    SELECT STRFTIME('%Y-%m', paid_at) AS year_month,
           SUM(amount)                AS revenue
    FROM   payments WHERE status = 'completed'
    GROUP BY STRFTIME('%Y-%m', paid_at)
),
with_calcs AS (
    SELECT year_month, revenue,
           LAG(revenue) OVER (ORDER BY year_month)             AS prev_month,
           AVG(revenue) OVER (ORDER BY year_month
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)       AS rolling_3m_avg
    FROM   monthly
)
SELECT year_month,
       ROUND(revenue,2)                                        AS revenue,
       ROUND(prev_month,2)                                     AS prev_month,
       CASE WHEN prev_month IS NULL THEN NULL
            ELSE ROUND((revenue-prev_month)/prev_month*100,1)
       END                                                     AS mom_growth_pct,
       ROUND(rolling_3m_avg,2)                                 AS rolling_3m_avg,
       CASE
           WHEN prev_month IS NULL THEN 'OK'
           WHEN (revenue-prev_month)/prev_month < -0.2 THEN 'Drop >20%'
           ELSE 'OK'
       END                                                     AS flag
FROM   with_calcs ORDER BY year_month;

-- QUESTION 2 — Customer Health Scorecard
WITH last_order AS (
    SELECT customer_id,
           MAX(created_at) AS last_order_at,
           COUNT(id)        AS total_orders
    FROM   orders GROUP BY customer_id
),
spend AS (
    SELECT o.customer_id, SUM(p.amount) AS total_spent
    FROM   orders o INNER JOIN payments p ON p.order_id=o.id AND p.status='completed'
    GROUP BY o.customer_id
)
SELECT c.first_name || ' ' || c.last_name                     AS full_name,
       c.tier,
       CASE
           WHEN lo.customer_id IS NULL                        THEN 'Prospect'
           WHEN lo.total_orders=1                             THEN 'New'
           WHEN lo.total_orders>=3
                AND JULIANDAY('now')-JULIANDAY(lo.last_order_at)<=180 THEN 'Champion'
           WHEN lo.total_orders>=2
                AND JULIANDAY('now')-JULIANDAY(lo.last_order_at)>180  THEN 'At Risk'
           ELSE 'Active'
       END                                                    AS health_label,
       COALESCE(ROUND(sp.total_spent,2), 0.00)                AS total_spent,
       COALESCE(lo.total_orders, 0)                           AS order_count,
       CASE WHEN COALESCE(lo.total_orders,0)>0
            THEN ROUND(COALESCE(sp.total_spent,0)/lo.total_orders,2)
            ELSE 0 END                                        AS avg_order_value,
       CASE WHEN lo.last_order_at IS NOT NULL
            THEN CAST(ROUND(JULIANDAY('now')-JULIANDAY(lo.last_order_at)) AS INTEGER)
            END                                               AS days_since_last_order
FROM   customers c
LEFT JOIN last_order lo ON lo.customer_id = c.id
LEFT JOIN spend      sp ON sp.customer_id = c.id
ORDER BY
    CASE health_label WHEN 'Champion' THEN 1 WHEN 'At Risk' THEN 2
                      WHEN 'Active'   THEN 3 WHEN 'New'     THEN 4
                      ELSE 5 END,
    total_spent DESC;

-- QUESTION 3 — Product Profitability
WITH delivered_items AS (
    SELECT oi.product_id,
           SUM(oi.quantity)                       AS units_sold,
           SUM(oi.quantity * oi.unit_price)        AS gross_revenue,
           SUM(oi.quantity * p_cost.cost)          AS cogs
    FROM   order_items oi
    INNER JOIN orders       o     ON o.id    = oi.order_id  AND o.status='delivered'
    INNER JOIN products     p_cost ON p_cost.id = oi.product_id
    GROUP BY oi.product_id
)
SELECT p.category,
       p.name                                      AS product_name,
       COALESCE(di.units_sold, 0)                  AS units_sold,
       ROUND(COALESCE(di.gross_revenue,0), 2)      AS gross_revenue,
       ROUND(COALESCE(di.cogs,0), 2)               AS cogs,
       ROUND(COALESCE(di.gross_revenue,0)
           - COALESCE(di.cogs,0), 2)               AS gross_profit,
       CASE WHEN COALESCE(di.gross_revenue,0)>0
            THEN ROUND((COALESCE(di.gross_revenue,0)-COALESCE(di.cogs,0))
                       /di.gross_revenue*100,1)
            ELSE 0 END                             AS margin_pct,
       RANK() OVER (PARTITION BY p.category
                    ORDER BY COALESCE(di.gross_revenue,0)
                             - COALESCE(di.cogs,0) DESC) AS category_rank,
       CASE WHEN p.is_active=0 THEN 'DISCONTINUED' ELSE 'Active' END AS status_flag
FROM   products      p
LEFT JOIN delivered_items di ON di.product_id = p.id
ORDER BY p.category, category_rank;

-- QUESTION 4 — Operations Quality
WITH q1 AS (SELECT COUNT(*) AS cnt, 'unique_emails' AS chk
            FROM (SELECT TRIM(LOWER(email)) AS e FROM customers WHERE email IS NOT NULL
                  GROUP BY e HAVING COUNT(*)>1)),
     q2 AS (SELECT COUNT(*) AS cnt, 'invalid_statuses' AS chk
            FROM orders WHERE status NOT IN
            ('pending','processing','shipped','delivered','cancelled','returned')),
     q3 AS (SELECT COUNT(*) AS cnt, 'delivered_no_payment' AS chk
            FROM orders o LEFT JOIN payments p ON p.order_id=o.id
            WHERE o.status='delivered' AND p.order_id IS NULL),
     q4 AS (SELECT COUNT(*) AS cnt, 'zero_payments' AS chk
            FROM payments WHERE amount<=0),
     q5 AS (SELECT COUNT(*) AS cnt, 'orphaned_items' AS chk
            FROM order_items oi LEFT JOIN products p ON p.id=oi.product_id
            WHERE p.id IS NULL),
     q6 AS (SELECT ROUND(SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END)*100.0/COUNT(*),1)
            AS cnt, 'pct_missing_email' AS chk FROM customers)
SELECT chk AS check_name,
       CASE chk WHEN 'pct_missing_email' THEN CAST(cnt AS TEXT)||'%'
                ELSE CAST(cnt AS TEXT) END AS result,
       CASE WHEN chk='pct_missing_email' THEN NULL ELSE cnt END AS count,
       CASE WHEN chk='pct_missing_email' THEN 'INFO'
            WHEN cnt>0 THEN 'FAIL' ELSE 'PASS' END AS detail
FROM (SELECT cnt, chk FROM q1 UNION ALL SELECT cnt,chk FROM q2
      UNION ALL SELECT cnt,chk FROM q3 UNION ALL SELECT cnt,chk FROM q4
      UNION ALL SELECT cnt,chk FROM q5 UNION ALL SELECT cnt,chk FROM q6);

-- QUESTION 5 — Repeat Purchase Rate (the one metric I'd show the board)
-- A high repeat purchase rate means customers trust the product enough
-- to come back. It's a leading indicator of LTV and CAC payback.
-- New customer acquisition is expensive; repeat buyers are profit.
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM   orders
    WHERE  status IN ('delivered','shipped','processing')
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                            AS total_buyers,
    SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END)                  AS repeat_buyers,
    ROUND(SUM(CASE WHEN order_count>=2 THEN 1 ELSE 0 END)*100.0
          / COUNT(*), 1)                                               AS repeat_purchase_rate_pct,
    ROUND(AVG(order_count), 2)                                         AS avg_orders_per_buyer
FROM customer_order_counts;
