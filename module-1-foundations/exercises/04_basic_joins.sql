-- ============================================================
-- MODULE 1 | Exercise 4: Basic Joins
-- Difficulty: ⭐ Easy  |  Estimated time: 12 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Understand when to use INNER JOIN vs LEFT JOIN
-- 2. Avoid the most common join mistake (missing ON condition)
-- 3. Use table aliases to keep queries readable
-- 4. Identify rows that exist in one table but not another
--
-- KEY CONCEPT:
-- INNER JOIN  → only rows that match in BOTH tables
-- LEFT JOIN   → ALL rows from the left table,
--               plus matching rows from right (NULL if no match)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 4.1  Your first join: customers + orders
-- ─────────────────────────────────────────────────────────────
-- Join customers to their orders using INNER JOIN.
-- Only customers who HAVE at least one order will appear.

SELECT c.id,
       c.first_name,
       c.last_name,
       o.id         AS order_id,
       o.status,
       o.created_at
FROM   customers c
INNER JOIN orders o ON o.customer_id = c.id
ORDER BY c.id, o.created_at;

-- ✏️  YOUR TURN:
-- Count how many rows this query returns vs SELECT COUNT(*) FROM customers.
-- Why are they different? Write your explanation as a comment.

-- Explanation:



-- ─────────────────────────────────────────────────────────────
-- 4.2  Finding customers who have NEVER ordered
-- ─────────────────────────────────────────────────────────────
-- Switch to LEFT JOIN and look for NULLs in the orders columns.
-- This is one of the most common real-world queries.

SELECT c.id,
       c.first_name,
       c.last_name,
       o.id AS order_id   -- this will be NULL if no order exists
FROM   customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE  o.id IS NULL;      -- keep only the unmatched rows

-- ✏️  YOUR TURN:
-- Which customer IDs have never placed an order?
-- (Run the query above and list the IDs as a comment)

-- Customers with no orders:



-- ─────────────────────────────────────────────────────────────
-- 4.3  Three-table join: orders → order_items → products
-- ─────────────────────────────────────────────────────────────
-- Show each order line with the product name and total line value.

SELECT o.id            AS order_id,
       o.status,
       p.name          AS product_name,
       p.category,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM   orders o
INNER JOIN order_items oi ON oi.order_id   = o.id
INNER JOIN products    p  ON p.id          = oi.product_id
ORDER BY o.id, p.name;

-- ✏️  YOUR TURN:
-- Modify the query above to also include:
--   - The customer's first and last name
-- You'll need to add a 4th table join (customers).



-- ─────────────────────────────────────────────────────────────
-- 4.4  LEFT JOIN to find orders without payments
-- ─────────────────────────────────────────────────────────────
-- Not all orders have a payment record. Find the ones that don't.

SELECT o.id       AS order_id,
       o.status,
       o.customer_id,
       p.amount,
       p.status   AS payment_status
FROM   orders o
LEFT JOIN payments p ON p.order_id = o.id
WHERE  p.order_id IS NULL;

-- ✏️  YOUR TURN:
-- How many orders are missing a payment? Are any of them 'delivered'?
-- (This is a data quality issue — you'll explore it more in Module 2!)

-- Your observations:



-- ─────────────────────────────────────────────────────────────
-- 4.5  CHALLENGE: Full order summary
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a query that shows one row per ORDER with:
--   - order_id
--   - customer full name (first + ' ' + last)
--   - order status
--   - region
--   - number of items in the order (count of order_items rows)
--   - total order value (sum of quantity * unit_price)
--   - payment status (NULL if no payment)
--
-- Hint: you'll need GROUP BY and SUM/COUNT on order_items,
--       and a LEFT JOIN to payments.
