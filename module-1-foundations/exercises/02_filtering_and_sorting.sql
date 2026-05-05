-- ============================================================
-- MODULE 1 | Exercise 2: Filtering & Sorting
-- Difficulty: ⭐ Easy  |  Estimated time: 10 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Filter rows with WHERE (=, !=, >, <, AND, OR, NOT)
-- 2. Match patterns with LIKE and lists with IN
-- 3. Filter ranges with BETWEEN
-- 4. Sort results with ORDER BY
-- 5. Limit and page results with LIMIT / OFFSET
--
-- DBEAVER TIP:
-- Use Ctrl+/ (Mac: Cmd+/) to toggle a line as a comment.
-- This lets you quickly disable one WHERE condition to test.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 2.1  Basic equality filtering
-- ─────────────────────────────────────────────────────────────
-- Find all gold-tier customers:
SELECT id, first_name, last_name, tier, country
FROM   customers
WHERE  tier = 'gold';

-- ✏️  YOUR TURN:
-- Find all silver-tier customers who are from the United States.
-- (Hint: use AND to combine two conditions)



-- ─────────────────────────────────────────────────────────────
-- 2.2  Multiple values with IN
-- ─────────────────────────────────────────────────────────────
-- Find all orders that are either 'shipped' or 'processing':
SELECT id, customer_id, status, region
FROM   orders
WHERE  status IN ('shipped', 'processing');

-- ✏️  YOUR TURN:
-- Find all orders that are NOT delivered and NOT cancelled.
-- Write it two ways: using NOT IN, and using != with AND.



-- ─────────────────────────────────────────────────────────────
-- 2.3  Range filtering with BETWEEN
-- ─────────────────────────────────────────────────────────────
-- Find products priced between $40 and $100:
SELECT name, category, price
FROM   products
WHERE  price BETWEEN 40 AND 100
ORDER BY price;

-- ✏️  YOUR TURN:
-- Find all customers who signed up in the year 2023.
-- (Hint: signup_date is stored as text 'YYYY-MM-DD' —
--  BETWEEN works on text comparisons alphabetically too!)



-- ─────────────────────────────────────────────────────────────
-- 2.4  Pattern matching with LIKE
-- ─────────────────────────────────────────────────────────────
-- % matches any sequence of characters, _ matches exactly one.
-- Find all products in a category containing 'Electronics':
SELECT name, category, price
FROM   products
WHERE  category LIKE '%Electronics%';

-- ✏️  YOUR TURN:
-- Find all customers whose email ends with '@email.com'.
-- Then find customers whose first name starts with the letter 'A'.



-- ─────────────────────────────────────────────────────────────
-- 2.5  Sorting results
-- ─────────────────────────────────────────────────────────────
-- Show the 5 most expensive products:
SELECT name, category, price
FROM   products
ORDER BY price DESC
LIMIT  5;

-- ✏️  YOUR TURN:
-- Show the 10 most recent orders (newest first).
-- Columns to show: id, customer_id, status, created_at



-- ─────────────────────────────────────────────────────────────
-- 2.6  Filtering on NULL values
-- ─────────────────────────────────────────────────────────────
-- NULL means "unknown". You can NOT use = NULL — you must use IS NULL.

-- Find customers who have no email on record:
SELECT id, first_name, last_name, email
FROM   customers
WHERE  email IS NULL;

-- ✏️  YOUR TURN:
-- Find all orders where updated_at is NULL (i.e. not yet updated).
-- How many are there? (Use COUNT(*) in a subquery or separate query)



-- ─────────────────────────────────────────────────────────────
-- 2.7  CHALLENGE: Combining it all
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Write a single query that returns:
--   - All delivered orders from the 'South' or 'Online' region
--   - Created in 2024
--   - Sorted newest first
--   - Showing: order id, customer_id, status, region, created_at
