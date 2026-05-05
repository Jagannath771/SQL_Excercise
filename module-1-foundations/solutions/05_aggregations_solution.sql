-- ============================================================
-- MODULE 1 | Exercise 5 SOLUTIONS: Aggregations
-- ============================================================

-- 5.1  Customers per tier
SELECT tier,
       COUNT(*) AS customer_count
FROM   customers
GROUP BY tier
ORDER BY customer_count DESC;

-- 5.2  Revenue by region with min/max
SELECT o.region,
       COUNT(p.id)              AS payment_count,
       ROUND(SUM(p.amount), 2)  AS total_revenue,
       ROUND(AVG(p.amount), 2)  AS avg_order_value,
       ROUND(MIN(p.amount), 2)  AS min_order_value,
       ROUND(MAX(p.amount), 2)  AS max_order_value
FROM   orders o
INNER JOIN payments p ON p.order_id = o.id
WHERE  p.status = 'completed'
GROUP BY o.region
ORDER BY total_revenue DESC;

-- 5.3  Customers with more than 2 orders
SELECT c.id            AS customer_id,
       c.first_name,
       COUNT(o.id)     AS order_count
FROM   customers c
INNER JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.first_name
HAVING COUNT(o.id) > 2
ORDER BY order_count DESC;

-- 5.4  Top 5 customers by completed spend
SELECT c.first_name,
       c.last_name,
       COUNT(DISTINCT o.id)     AS order_count,
       ROUND(SUM(p.amount), 2)  AS total_spent
FROM   customers c
INNER JOIN orders   o ON o.customer_id = c.id
INNER JOIN payments p ON p.order_id    = o.id
WHERE  p.status = 'completed'
GROUP BY c.id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- 5.5  Category stats
SELECT category,
       COUNT(*)                    AS product_count,
       ROUND(AVG(price), 2)        AS avg_price,
       SUM(stock_quantity)         AS total_stock,
       SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_products
FROM   products
GROUP BY category
ORDER BY avg_price DESC;

-- 5.6  Challenge: monthly order trend
SELECT SUBSTR(o.created_at, 1, 7)         AS year_month,
       COUNT(DISTINCT o.id)               AS order_count,
       ROUND(SUM(COALESCE(p.amount, 0)), 2) AS total_revenue
FROM   orders   o
LEFT JOIN payments p ON p.order_id = o.id AND p.status = 'completed'
GROUP BY SUBSTR(o.created_at, 1, 7)
HAVING COUNT(DISTINCT o.id) >= 3
ORDER BY year_month;
