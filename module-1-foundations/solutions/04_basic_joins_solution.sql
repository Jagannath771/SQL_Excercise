-- ============================================================
-- MODULE 1 | Exercise 4 SOLUTIONS: Basic Joins
-- ============================================================

-- 4.1  Count difference explained:
-- INNER JOIN returns one row per (customer, order) pair.
-- Customers with multiple orders appear multiple times.
-- Customers with no orders don't appear at all.
-- Customers 21-25 have no orders, so total rows < 25.

-- 4.2  Customers with no orders — IDs 21, 22, 23, 24, 25
SELECT c.id,
       c.first_name,
       c.last_name,
       o.id AS order_id
FROM   customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE  o.id IS NULL;

-- 4.3  Four-table join with customer name
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       o.id            AS order_id,
       o.status,
       p.name          AS product_name,
       p.category,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price         AS line_total
FROM   customers   c
INNER JOIN orders      o  ON o.customer_id  = c.id
INNER JOIN order_items oi ON oi.order_id    = o.id
INNER JOIN products    p  ON p.id           = oi.product_id
ORDER BY c.last_name, o.id, p.name;

-- 4.4  Orders missing a payment — 5 orders (46,47,48,49 + any others)
SELECT o.id       AS order_id,
       o.status,
       o.customer_id,
       p.amount,
       p.status   AS payment_status
FROM   orders   o
LEFT JOIN payments p ON p.order_id = o.id
WHERE  p.order_id IS NULL;

-- 4.5  Challenge: full order summary
SELECT o.id                                              AS order_id,
       c.first_name || ' ' || c.last_name               AS customer_name,
       o.status,
       o.region,
       COUNT(oi.id)                                      AS item_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2)       AS order_value,
       p.status                                          AS payment_status
FROM   orders      o
INNER JOIN customers   c  ON c.id        = o.customer_id
INNER JOIN order_items oi ON oi.order_id = o.id
LEFT  JOIN payments    p  ON p.order_id  = o.id
GROUP BY o.id, c.first_name, c.last_name, o.status, o.region, p.status
ORDER BY o.id;
