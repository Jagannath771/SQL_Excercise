-- ============================================================
-- MODULE 3 | Exercise 2 SOLUTIONS: EXPLAIN & Query Performance
-- ============================================================

-- 2.1  Observations:
-- SELECT * WHERE id=5     → SEARCH TABLE customers USING INTEGER PRIMARY KEY (rowid=?)
--                           Primary key lookup is O(log n) — very fast
-- SELECT * WHERE customer_id=1 → SCAN TABLE orders
--                           No index → reads all 50 rows

-- 2.2  Create indexes (idempotent with IF NOT EXISTS)
CREATE INDEX IF NOT EXISTS idx_orders_status       ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id  ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id   ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_oi_order_id         ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_oi_product_id       ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_customers_tier      ON customers(tier);

-- After indexes: the 3-table join will use:
-- SEARCH TABLE customers USING INDEX idx_customers_tier (tier=?)
-- SEARCH TABLE orders USING INDEX idx_orders_customer_id
-- SEARCH TABLE payments USING INDEX idx_payments_order_id

-- 2.3  Correlated subquery → pre-aggregated join rewrite
EXPLAIN QUERY PLAN
SELECT id, name, price,
       COALESCE(s.total_sold, 0) AS total_sold
FROM   products p
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM   order_items
    GROUP BY product_id
) s ON s.product_id = p.id;
-- Much faster: aggregation runs once, join is indexed.

-- 2.4  Composite covering index
CREATE INDEX IF NOT EXISTS idx_orders_status_region ON orders(status, region);
EXPLAIN QUERY PLAN
SELECT status, region, COUNT(*) AS cnt
FROM   orders
WHERE  status = 'delivered'
GROUP BY region;
-- Should show: SEARCH TABLE orders USING COVERING INDEX

-- 2.5  Challenge: optimized LTV query
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_status    ON payments(status);

WITH order_stats AS (
    SELECT customer_id,
           COUNT(id)       AS order_count,
           MIN(created_at) AS first_order,
           MAX(created_at) AS last_order
    FROM   orders
    GROUP BY customer_id
),
payment_totals AS (
    SELECT o.customer_id,
           SUM(p.amount) AS ltv
    FROM   orders   o
    INNER JOIN payments p ON p.order_id = o.id
    WHERE  p.status = 'completed'
    GROUP BY o.customer_id
)
SELECT c.id,
       c.first_name,
       c.tier,
       COALESCE(pt.ltv,         0.00) AS ltv,
       COALESCE(os.order_count, 0)    AS order_count,
       os.first_order,
       os.last_order
FROM   customers    c
LEFT JOIN order_stats    os ON os.customer_id = c.id
LEFT JOIN payment_totals pt ON pt.customer_id = c.id
ORDER BY ltv DESC;
