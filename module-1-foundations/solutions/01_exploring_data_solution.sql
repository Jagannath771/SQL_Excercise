-- ============================================================
-- MODULE 1 | Exercise 1 SOLUTIONS: Exploring Your Data
-- ============================================================

-- 1.2  Row counts
SELECT COUNT(*) AS total_products   FROM products;
SELECT COUNT(*) AS total_orders     FROM orders;
SELECT COUNT(*) AS total_order_items FROM order_items;
SELECT COUNT(*) AS total_payments   FROM payments;

-- 1.3  PRAGMA for order_items and payments
PRAGMA table_info(order_items);
PRAGMA table_info(payments);
-- 'amount' in payments is type REAL

-- 1.4  Preview specific columns from products
SELECT name, category, price
FROM   products
LIMIT  10;

-- 1.5  Spot the dirty data
-- Problem 1: Rows 3 and 9 have extra whitespace in their email values
-- Problem 2: Rows 6 and 15 have NULL email
-- Problem 3: Rows 8 and 16 use 'USA' and 'US' instead of 'United States'
