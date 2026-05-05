-- ============================================================
-- MODULE 2 | Exercise 1 SOLUTIONS: CTE Patterns
-- ============================================================

-- 1.1  Rewrite nested query as CTE
WITH active_premium_products AS (
    SELECT *
    FROM   products
    WHERE  is_active = 1
      AND  price > 50
)
SELECT category, COUNT(*) AS product_count
FROM   active_premium_products
GROUP BY category;

-- 1.2  3-step CTE chain: product sales
WITH active_products AS (
    SELECT id, name, category
    FROM   products
    WHERE  is_active = 1
),
product_sales AS (
    SELECT product_id,
           SUM(quantity) AS total_units_sold
    FROM   order_items
    GROUP BY product_id
),
final AS (
    SELECT ap.name,
           ap.category,
           COALESCE(ps.total_units_sold, 0) AS total_units_sold
    FROM   active_products ap
    LEFT JOIN product_sales ps ON ps.product_id = ap.id
)
SELECT * FROM final
ORDER BY total_units_sold DESC;

-- 1.3  Top countries filter
WITH clean_customers AS (
    SELECT id,
           TRIM(COALESCE(email, 'unknown@shopmetrics.com')) AS email,
           CASE country
               WHEN 'US'  THEN 'United States'
               WHEN 'USA' THEN 'United States'
               ELSE COALESCE(country, 'Unknown')
           END AS country_std,
           tier
    FROM   customers
),
tier_summary AS (
    SELECT country_std,
           tier,
           COUNT(*) AS customer_count
    FROM   clean_customers
    GROUP BY country_std, tier
),
top_countries AS (
    SELECT country_std
    FROM   tier_summary
    GROUP BY country_std
    HAVING SUM(customer_count) >= 3
)
SELECT ts.*
FROM   tier_summary ts
INNER JOIN top_countries tc ON tc.country_std = ts.country_std
ORDER BY ts.country_std, ts.tier;

-- 1.4  Challenge: full customer report
WITH clean_customers AS (
    SELECT id,
           first_name,
           last_name,
           TRIM(COALESCE(email, 'unknown@shopmetrics.com')) AS email,
           CASE country
               WHEN 'US'  THEN 'United States'
               WHEN 'USA' THEN 'United States'
               ELSE COALESCE(country, 'Unknown')
           END AS country_std,
           tier
    FROM customers
),
order_stats AS (
    SELECT customer_id,
           COUNT(*)                                          AS total_orders,
           SUM(CASE WHEN status='delivered' THEN 1 ELSE 0 END) AS delivered_orders
    FROM   orders
    GROUP BY customer_id
),
payment_stats AS (
    SELECT o.customer_id,
           SUM(p.amount) AS total_spent
    FROM   orders o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT cc.id,
       cc.first_name,
       cc.last_name,
       cc.email,
       cc.country_std,
       cc.tier,
       COALESCE(os.total_orders,     0)    AS total_orders,
       COALESCE(os.delivered_orders, 0)    AS delivered_orders,
       COALESCE(ps.total_spent,      0.00) AS total_spent
FROM   clean_customers  cc
LEFT JOIN order_stats   os ON os.customer_id = cc.id
LEFT JOIN payment_stats ps ON ps.customer_id = cc.id
ORDER BY total_spent DESC;
