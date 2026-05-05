-- ============================================================
-- MODULE 1 | Exercise 5: Aggregations
-- Difficulty: ⭐ Easy  |  Estimated time: 12 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Summarize data with COUNT, SUM, AVG, MIN, MAX
-- 2. Group results with GROUP BY
-- 3. Filter groups with HAVING (not WHERE)
-- 4. Combine aggregations with JOINs
-- 5. Alias aggregated columns with AS
--
-- KEY RULE:
-- Any column in SELECT that is NOT inside an aggregate function
-- (COUNT, SUM, AVG…) MUST appear in GROUP BY.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 5.1  Count orders by status
-- ─────────────────────────────────────────────────────────────
SELECT status,
       COUNT(*) AS order_count
FROM   orders
GROUP BY status
ORDER BY order_count DESC;

-- ✏️  YOUR TURN:
-- Count how many customers are in each tier (bronze/silver/gold).
-- Sort by count descending.



-- ─────────────────────────────────────────────────────────────
-- 5.2  Revenue by region
-- ─────────────────────────────────────────────────────────────
-- Calculate total revenue (payments) per region.
-- Note: join orders to payments to get the region.

SELECT o.region,
       COUNT(p.id)       AS payment_count,
       SUM(p.amount)     AS total_revenue,
       AVG(p.amount)     AS avg_order_value
FROM   orders o
INNER JOIN payments p ON p.order_id = o.id
WHERE  p.status = 'completed'
GROUP BY o.region
ORDER BY total_revenue DESC;

-- ✏️  YOUR TURN:
-- Modify the query above to also show:
--   - min_order_value  (minimum payment amount)
--   - max_order_value  (maximum payment amount)
-- Round all monetary values to 2 decimal places with ROUND(value, 2).



-- ─────────────────────────────────────────────────────────────
-- 5.3  HAVING — filter after grouping
-- ─────────────────────────────────────────────────────────────
-- WHERE filters rows BEFORE grouping.
-- HAVING filters groups AFTER aggregation.

-- Find products that appear in more than 3 order_items rows:
SELECT p.name,
       p.category,
       COUNT(oi.id)              AS times_ordered,
       SUM(oi.quantity)          AS total_units_sold
FROM   products p
INNER JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id, p.name, p.category
HAVING COUNT(oi.id) > 3
ORDER BY times_ordered DESC;

-- ✏️  YOUR TURN:
-- Find all customers who have placed MORE than 2 orders.
-- Show: customer_id, first_name, order_count
-- Hint: JOIN customers to orders, GROUP BY customer, HAVING COUNT > 2.



-- ─────────────────────────────────────────────────────────────
-- 5.4  Revenue per customer
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Find the top 5 customers by total completed payment amount.
-- Show: customer first_name, last_name, total_spent, order_count.
-- Only count payments with status = 'completed'.
-- Hint: customers → orders → payments (3-table join)



-- ─────────────────────────────────────────────────────────────
-- 5.5  Aggregations by category
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- For each product CATEGORY, calculate:
--   - number of products in the category
--   - average product price
--   - total stock_quantity
--   - number of active products (is_active = 1)
-- Sort by average price descending.



-- ─────────────────────────────────────────────────────────────
-- 5.6  CHALLENGE: Monthly order trend
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Show how many orders were placed each month.
-- Columns: year, month, order_count, total_revenue (from payments)
-- Hint: Use SUBSTR(created_at, 1, 7) to get 'YYYY-MM' from a datetime.
-- Only include months that had at least 3 orders (HAVING).
-- Sort chronologically.
