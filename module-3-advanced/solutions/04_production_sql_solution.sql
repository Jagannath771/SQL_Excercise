-- ============================================================
-- MODULE 3 | Exercise 4 SOLUTIONS: Production SQL Patterns
-- ============================================================

-- 4.1  Readable rewrite
WITH non_cancelled_items AS (
    SELECT oi.product_id,
           oi.quantity,
           oi.unit_price,
           oi.quantity * oi.unit_price AS line_revenue
    FROM   order_items oi
    INNER JOIN orders o ON o.id = oi.order_id
    WHERE  o.status != 'cancelled'
),
product_revenue AS (
    SELECT product_id,
           COUNT(*)          AS line_items,
           SUM(line_revenue) AS total_revenue
    FROM   non_cancelled_items
    GROUP BY product_id
)
SELECT p.name,
       ROUND(COALESCE(pr.total_revenue, 0), 2) AS total_revenue,
       COALESCE(pr.line_items, 0)               AS line_items
FROM   products      p
LEFT JOIN product_revenue pr ON pr.product_id = p.id
ORDER BY total_revenue DESC
LIMIT 5;

-- 4.2  Defensive COALESCE for all three metrics
WITH order_stats AS (
    SELECT customer_id,
           COUNT(*)                                              AS total_orders,
           SUM(CASE WHEN status='delivered' THEN 1 ELSE 0 END)  AS delivered_orders,
           AVG(COALESCE(discount_pct, 0))                       AS avg_discount
    FROM   orders
    GROUP BY customer_id
),
payment_stats AS (
    SELECT o.customer_id, SUM(COALESCE(p.amount, 0)) AS total_revenue
    FROM   orders o
    INNER JOIN payments p ON p.order_id=o.id AND p.status='completed'
    GROUP BY o.customer_id
)
SELECT c.id,
       c.first_name,
       COALESCE(ps.total_revenue, 0.00)                         AS total_revenue,
       COALESCE(os.avg_discount,  0.00)                         AS avg_discount,
       CASE
           WHEN COALESCE(os.total_orders, 0) > 0
           THEN ROUND(COALESCE(os.delivered_orders,0)*1.0
                    / os.total_orders, 3)
           ELSE 0.0
       END                                                      AS delivery_rate
FROM   customers    c
LEFT JOIN order_stats   os ON os.customer_id = c.id
LEFT JOIN payment_stats ps ON ps.customer_id = c.id
ORDER BY total_revenue DESC;

-- 4.3  Assertions (with 3 more)
WITH assert_negative_payments AS (
    SELECT COUNT(*) AS cnt FROM payments WHERE amount <= 0
),
assert_orphaned_orders AS (
    SELECT COUNT(*) AS cnt
    FROM orders o LEFT JOIN customers c ON c.id=o.customer_id WHERE c.id IS NULL
),
assert_valid_tier AS (
    SELECT COUNT(*) AS cnt
    FROM customers WHERE tier NOT IN ('bronze','silver','gold')
),
assert_positive_quantity AS (
    SELECT COUNT(*) AS cnt FROM order_items WHERE quantity <= 0
),
assert_logical_dates AS (
    SELECT COUNT(*) AS cnt FROM orders
    WHERE updated_at IS NOT NULL AND updated_at < created_at
)
SELECT 'negative_payments'  AS check_name,
       (SELECT cnt FROM assert_negative_payments) AS failures,
       CASE WHEN (SELECT cnt FROM assert_negative_payments) > 0 THEN 'FAIL' ELSE 'PASS' END AS status
UNION ALL
SELECT 'orphaned_orders',
       (SELECT cnt FROM assert_orphaned_orders),
       CASE WHEN (SELECT cnt FROM assert_orphaned_orders)  > 0 THEN 'FAIL' ELSE 'PASS' END
UNION ALL
SELECT 'invalid_tier',
       (SELECT cnt FROM assert_valid_tier),
       CASE WHEN (SELECT cnt FROM assert_valid_tier)       > 0 THEN 'FAIL' ELSE 'PASS' END
UNION ALL
SELECT 'zero_quantity_items',
       (SELECT cnt FROM assert_positive_quantity),
       CASE WHEN (SELECT cnt FROM assert_positive_quantity)> 0 THEN 'FAIL' ELSE 'PASS' END
UNION ALL
SELECT 'dates_out_of_order',
       (SELECT cnt FROM assert_logical_dates),
       CASE WHEN (SELECT cnt FROM assert_logical_dates)    > 0 THEN 'FAIL' ELSE 'PASS' END;
