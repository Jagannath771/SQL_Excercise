-- ============================================================
-- MODULE 2 | Exercise 3 SOLUTIONS: Debugging Joins
-- ============================================================

-- 3.1  Explanation:
-- The broken query fans out because order_items has MULTIPLE rows
-- per order_id (some orders have 2-3 items). When you join payments
-- (1 payment per order) to order_items (many rows per order),
-- the payment amount gets added once per line item — inflated!
-- The correct query joins ONLY orders → payments (1:1 via UNIQUE).

-- 3.2  Revenue per category (fanout-safe)
WITH item_revenue AS (
    SELECT oi.order_id,
           oi.product_id,
           SUM(oi.quantity * oi.unit_price) AS line_revenue
    FROM   order_items oi
    GROUP BY oi.order_id, oi.product_id
),
category_orders AS (
    SELECT ir.order_id,
           p.category,
           ir.line_revenue
    FROM   item_revenue ir
    INNER JOIN products p ON p.id = ir.product_id
),
category_payments AS (
    SELECT co.category,
           SUM(p.amount) AS total_revenue
    FROM   category_orders co
    INNER JOIN payments p ON p.order_id = co.order_id
    WHERE  p.status = 'completed'
    GROUP BY co.category
)
SELECT * FROM category_payments
ORDER BY total_revenue DESC;

-- 3.3  Cardinality check for payments → orders
SELECT 'orders'   AS tbl, COUNT(DISTINCT id)       AS distinct_keys FROM orders
UNION ALL
SELECT 'payments' AS tbl, COUNT(DISTINCT order_id) AS distinct_keys FROM payments;
-- payments.order_id is UNIQUE → safe 1:1 join, no fanout.

-- 3.4  Orphaned checks
-- order_items without a matching product:
SELECT oi.id, oi.order_id, oi.product_id
FROM   order_items oi
LEFT JOIN products p ON p.id = oi.product_id
WHERE  p.id IS NULL;

-- orders without a matching customer:
SELECT o.id, o.customer_id
FROM   orders    o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE  c.id IS NULL;
-- Expected: 0 rows for both — data is referentially intact.

-- 3.5  Challenge: safe revenue by customer
WITH order_counts AS (
    SELECT customer_id,
           COUNT(*)                                          AS total_orders,
           SUM(CASE WHEN status='delivered' THEN 1 ELSE 0 END) AS delivered_orders
    FROM   orders
    GROUP BY customer_id
),
delivered_items AS (
    SELECT o.customer_id,
           SUM(oi.quantity)  AS total_items
    FROM   orders      o
    INNER JOIN order_items oi ON oi.order_id = o.id
    WHERE  o.status = 'delivered'
    GROUP BY o.customer_id
),
completed_spend AS (
    SELECT o.customer_id,
           SUM(p.amount) AS total_spent
    FROM   orders   o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT c.first_name,
       c.last_name,
       c.tier,
       COALESCE(oc.total_orders,    0)  AS total_orders,
       COALESCE(oc.delivered_orders,0)  AS delivered_orders,
       COALESCE(di.total_items,     0)  AS total_items_purchased,
       COALESCE(cs.total_spent,  0.00)  AS total_spent
FROM   customers       c
LEFT JOIN order_counts oc ON oc.customer_id = c.id
LEFT JOIN delivered_items di ON di.customer_id = c.id
LEFT JOIN completed_spend cs ON cs.customer_id = c.id
ORDER BY total_spent DESC;
