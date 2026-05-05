-- ============================================================
-- MODULE 2 | Exercise 4 SOLUTIONS: Data Transformation Pipeline
-- ============================================================

-- 4.1  Product margin analysis
SELECT name,
       CAST(price AS REAL)                               AS price,
       ROUND((price - cost) / price * 100, 1)            AS margin_pct,
       CASE
           WHEN (price - cost) / price * 100 > 40 THEN 'High'
           WHEN (price - cost) / price * 100 > 20 THEN 'Medium'
           ELSE                                         'Low'
       END                                              AS margin_tier
FROM   products
WHERE  price > 0
ORDER BY margin_pct DESC;

-- 4.2  stg_orders CTE
WITH stg_orders AS (
    SELECT id,
           customer_id,
           status,
           created_at,
           COALESCE(updated_at, 'pending')               AS updated_at,
           region,
           COALESCE(discount_pct, 0)                     AS discount_pct,
           SUBSTR(created_at, 1, 10)                     AS order_date,
           CASE
               WHEN status IN ('delivered','cancelled','returned') THEN 1
               ELSE 0
           END                                           AS is_terminal
    FROM   orders
)
SELECT * FROM stg_orders LIMIT 20;

-- 4.3  enriched_customers + spend
WITH stg_customers AS (
    SELECT id,
           TRIM(first_name)  AS first_name,
           TRIM(COALESCE(last_name, '')) AS last_name,
           CASE country
               WHEN 'US'  THEN 'United States'
               WHEN 'USA' THEN 'United States'
               ELSE COALESCE(country, 'Unknown')
           END AS country,
           tier, age
    FROM customers
),
order_stats AS (
    SELECT customer_id,
           COUNT(*)                                          AS total_orders,
           SUM(CASE WHEN status='delivered' THEN 1 ELSE 0 END) AS delivered_orders,
           MIN(created_at) AS first_order_at,
           MAX(created_at) AS last_order_at
    FROM orders
    GROUP BY customer_id
),
enriched_customers AS (
    SELECT sc.*,
           COALESCE(os.total_orders,    0)  AS total_orders,
           COALESCE(os.delivered_orders,0)  AS delivered_orders,
           os.first_order_at,
           os.last_order_at,
           CASE
               WHEN os.total_orders IS NULL THEN 'no_orders'
               WHEN os.total_orders  >= 3   THEN 'loyal'
               WHEN os.delivered_orders > 0 THEN 'active'
               ELSE 'inactive'
           END AS customer_segment
    FROM stg_customers sc
    LEFT JOIN order_stats os ON os.customer_id = sc.id
),
with_spend AS (
    SELECT ec.*,
           COALESCE(ps.total_spent, 0.00) AS total_spent,
           CASE
               WHEN ec.total_orders > 0
               THEN ROUND(COALESCE(ps.total_spent, 0) / ec.total_orders, 2)
               ELSE 0.00
           END AS avg_order_value
    FROM enriched_customers ec
    LEFT JOIN (
        SELECT o.customer_id, SUM(p.amount) AS total_spent
        FROM orders o
        INNER JOIN payments p ON p.order_id = o.id
        WHERE p.status = 'completed'
        GROUP BY o.customer_id
    ) ps ON ps.customer_id = ec.id
)
SELECT * FROM with_spend ORDER BY total_spent DESC;

-- 4.4  Challenge: mart_orders
WITH stg_orders AS (
    SELECT id, customer_id,
           SUBSTR(created_at, 1, 10)       AS order_date,
           status, region,
           COALESCE(discount_pct, 0)       AS discount_pct,
           created_at, updated_at
    FROM   orders
),
order_items_summary AS (
    SELECT order_id,
           COUNT(*)                         AS item_count,
           SUM(quantity * unit_price)       AS gross_value
    FROM   order_items
    GROUP BY order_id
),
order_payments AS (
    SELECT order_id,
           COALESCE(amount, 0)              AS payment_amount,
           COALESCE(status, 'no_payment')   AS payment_status
    FROM   payments
)
SELECT so.id                                               AS order_id,
       so.order_date,
       so.status,
       so.region,
       c.first_name || ' ' || c.last_name                 AS customer_name,
       c.tier,
       c.country,
       COALESCE(op.payment_amount, 0)                     AS payment_amount,
       COALESCE(op.payment_status, 'no_payment')          AS payment_status,
       COALESCE(ois.item_count,    0)                     AS item_count,
       ROUND(COALESCE(ois.gross_value, 0), 2)             AS gross_value,
       ROUND(COALESCE(ois.gross_value, 0)
             * (1 - so.discount_pct / 100.0), 2)          AS net_value,
       CASE
           WHEN so.updated_at IS NOT NULL
           THEN ROUND(JULIANDAY(so.updated_at)
                    - JULIANDAY(so.created_at), 1)
       END                                                AS days_to_ship
FROM   stg_orders            so
INNER JOIN customers          c   ON c.id        = so.customer_id
LEFT  JOIN order_items_summary ois ON ois.order_id = so.id
LEFT  JOIN order_payments      op  ON op.order_id  = so.id
ORDER BY so.order_date DESC;
