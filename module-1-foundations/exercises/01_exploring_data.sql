-- ============================================================
-- MODULE 1 | Exercise 1: Exploring Your Data
-- Difficulty: ⭐ Easy  |  Estimated time: 8 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Run your first queries in DBeaver
-- 2. Understand what tables and columns exist
-- 3. Get a quick feel for the size and shape of the data
--
-- DBEAVER TIP:
-- Place your cursor inside any query below and press Ctrl+Enter
-- (Mac: Cmd+Enter) to run just that one query.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 1.1  Look at all the tables
-- ─────────────────────────────────────────────────────────────
-- Run each SELECT one at a time. Use the scrollbar at the
-- bottom of the results grid to see all columns.

SELECT * FROM customers   LIMIT 10;
SELECT * FROM products    LIMIT 10;
SELECT * FROM orders      LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM payments    LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- 1.2  How many rows are in each table?
-- ─────────────────────────────────────────────────────────────
-- Example — count all customers:
SELECT COUNT(*) AS total_customers FROM customers;

-- ✏️  YOUR TURN:
-- Write COUNT(*) queries for each of the other four tables.
-- Name each column clearly (e.g. total_orders, total_products…)

-- Write your answers below:



-- ─────────────────────────────────────────────────────────────
-- 1.3  What columns does each table have?
-- ─────────────────────────────────────────────────────────────
-- In SQLite you can see column names and types with PRAGMA:
PRAGMA table_info(customers);
PRAGMA table_info(orders);

-- ✏️  YOUR TURN:
-- Run PRAGMA table_info() on the order_items and payments tables.
-- What data type is the 'amount' column in payments?



-- ─────────────────────────────────────────────────────────────
-- 1.4  Preview specific columns
-- ─────────────────────────────────────────────────────────────
-- Instead of SELECT *, name only the columns you care about.
-- This is a good habit — SELECT * can pull hundreds of columns
-- on real data warehouses.

-- Example:
SELECT id, first_name, last_name, tier
FROM   customers
LIMIT  5;

-- ✏️  YOUR TURN:
-- Write a query that shows only the name, category, and price
-- columns from the products table. Limit to 10 rows.



-- ─────────────────────────────────────────────────────────────
-- 1.5  Spot the dirty data
-- ─────────────────────────────────────────────────────────────
-- Real data is rarely clean. Run this query and look closely
-- at the email and country columns.

SELECT id, first_name, email, country
FROM   customers;

-- ✏️  OBSERVE (no code needed):
-- Can you spot 3 different problems in the email or country columns?
-- Write your observations as SQL comments below:
--
-- Problem 1:
-- Problem 2:
-- Problem 3:
--
-- (You'll fix all of these in Exercise 3!)
