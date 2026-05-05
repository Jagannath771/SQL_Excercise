-- ============================================================
-- MODULE 2 | Exercise 5 SOLUTIONS: Data Quality Framework
-- ============================================================

-- 5.1  NULL check on orders
SELECT
    COUNT(*)                                                   AS total_rows,
    SUM(CASE WHEN id          IS NULL THEN 1 ELSE 0 END)      AS null_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)      AS null_customer_id,
    SUM(CASE WHEN status      IS NULL THEN 1 ELSE 0 END)      AS null_status,
    SUM(CASE WHEN created_at  IS NULL THEN 1 ELSE 0 END)      AS null_created_at,
    SUM(CASE WHEN region      IS NULL THEN 1 ELSE 0 END)      AS null_region,
    SUM(CASE WHEN updated_at  IS NULL THEN 1 ELSE 0 END)      AS null_updated_at
FROM orders;
-- updated_at will have the most NULLs — expected, for in-progress orders.

-- 5.2  Uniqueness checks
SELECT order_id, COUNT(*) AS cnt
FROM   payments
GROUP BY order_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows (UNIQUE constraint)

SELECT order_id, product_id, COUNT(*) AS cnt
FROM   order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- 5.3  Invalid order statuses
SELECT id, status
FROM   orders
WHERE  status NOT IN ('pending','processing','shipped',
                      'delivered','cancelled','returned');
-- Expected: 0 rows

-- 5.4  Range checks
-- Negative payments:
SELECT id, amount FROM payments WHERE amount <= 0;

-- Payments before 2020:
SELECT id, paid_at FROM payments WHERE paid_at < '2020-01-01';

-- Bad order_items:
SELECT id, quantity, unit_price
FROM   order_items
WHERE  quantity <= 0 OR unit_price <= 0;

-- 5.5  Referential integrity
-- order_items → orders:
SELECT oi.id FROM order_items oi LEFT JOIN orders o ON o.id=oi.order_id WHERE o.id IS NULL;
-- order_items → products:
SELECT oi.id FROM order_items oi LEFT JOIN products p ON p.id=oi.product_id WHERE p.id IS NULL;
-- payments → orders:
SELECT p.id FROM payments p LEFT JOIN orders o ON o.id=p.order_id WHERE o.id IS NULL;
-- All expected: 0 rows

-- 5.6  All orders with no payment + days since
SELECT o.id       AS order_id,
       o.status,
       c.first_name,
       o.created_at,
       ROUND(JULIANDAY('now') - JULIANDAY(o.created_at)) AS days_since_order
FROM   orders    o
INNER JOIN customers c ON c.id = o.customer_id
LEFT  JOIN payments  p ON p.order_id = o.id
WHERE  p.order_id IS NULL
ORDER BY days_since_order;

-- 5.7  Challenge: master quality report
WITH null_emails AS (
    SELECT COUNT(*) AS cnt FROM customers WHERE email IS NULL
),
null_customer_ids AS (
    SELECT COUNT(*) AS cnt FROM orders WHERE customer_id IS NULL
),
invalid_statuses AS (
    SELECT COUNT(*) AS cnt FROM orders
    WHERE status NOT IN ('pending','processing','shipped','delivered','cancelled','returned')
),
negative_prices AS (
    SELECT COUNT(*) AS cnt FROM products WHERE price <= 0 OR cost <= 0
),
missing_payments AS (
    SELECT COUNT(*) AS cnt
    FROM orders o LEFT JOIN payments p ON p.order_id=o.id
    WHERE p.order_id IS NULL
)
SELECT 'null_emails'       AS check_name, 'customers' AS table_name,
       cnt AS failed_rows,
       CASE WHEN cnt > 0 THEN 'FAIL' ELSE 'PASS' END AS status
FROM null_emails
UNION ALL
SELECT 'null_customer_ids', 'orders', cnt,
       CASE WHEN cnt > 0 THEN 'FAIL' ELSE 'PASS' END
FROM null_customer_ids
UNION ALL
SELECT 'invalid_statuses', 'orders', cnt,
       CASE WHEN cnt > 0 THEN 'FAIL' ELSE 'PASS' END
FROM invalid_statuses
UNION ALL
SELECT 'negative_prices', 'products', cnt,
       CASE WHEN cnt > 0 THEN 'FAIL' ELSE 'PASS' END
FROM negative_prices
UNION ALL
SELECT 'missing_payments', 'orders', cnt,
       CASE WHEN cnt > 0 THEN 'FAIL' ELSE 'PASS' END
FROM missing_payments;
