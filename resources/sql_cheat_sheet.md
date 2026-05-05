# SQL Cheat Sheet

A quick reference for everything covered in this workshop.

---

## Anatomy of a SELECT

```sql
SELECT  column1, column2, AGG(column3)   -- what to return
FROM    table_name                        -- source table
JOIN    other_table ON ...               -- add related data
WHERE   condition                        -- filter rows (before grouping)
GROUP BY column1, column2               -- collapse to groups
HAVING  AGG(column3) > value            -- filter groups (after grouping)
ORDER BY column1 DESC                   -- sort
LIMIT   10                              -- max rows to return
OFFSET  20;                             -- skip first N rows (pagination)
```

---

## Filtering (WHERE)

```sql
WHERE status = 'delivered'
WHERE status != 'cancelled'
WHERE price BETWEEN 10 AND 100
WHERE country IN ('US', 'UK', 'Germany')
WHERE country NOT IN ('spam', 'test')
WHERE email LIKE '%@gmail.com'        -- ends with
WHERE name  LIKE 'A%'                 -- starts with
WHERE name  LIKE '_ohn'               -- _ = any single char
WHERE email IS NULL
WHERE email IS NOT NULL
WHERE age > 30 AND tier = 'gold'
WHERE tier = 'gold' OR tier = 'silver'
WHERE NOT (status = 'cancelled')
```

---

## String Functions

```sql
TRIM(col)                    -- remove leading & trailing spaces
LTRIM(col) / RTRIM(col)      -- remove left or right only
UPPER(col) / LOWER(col)      -- change case
LENGTH(col)                  -- number of characters
SUBSTR(col, start, length)   -- extract substring (1-indexed)
INSTR(col, 'search')         -- position of 'search' in col
REPLACE(col, 'old', 'new')   -- replace all occurrences
col1 || ' ' || col2          -- concatenate strings
COALESCE(col, 'fallback')    -- first non-NULL value
```

---

## Date Functions (SQLite)

```sql
DATE('now')                                -- today
DATE('now', '-30 days')                    -- 30 days ago
DATE(col, '+1 month')                      -- add one month
JULIANDAY(col)                             -- convert to Julian day number
JULIANDAY(a) - JULIANDAY(b)               -- days between two dates
STRFTIME('%Y',    col)                     -- extract year
STRFTIME('%Y-%m', col)                     -- year-month  e.g. '2024-03'
STRFTIME('%Y-%m-%d', col)                  -- date only
SUBSTR(col, 1, 7)                          -- also gets 'YYYY-MM'
```

---

## Aggregate Functions

```sql
COUNT(*)           -- count all rows (including NULLs)
COUNT(col)         -- count non-NULL values
COUNT(DISTINCT col) -- count unique non-NULL values
SUM(col)           -- total
AVG(col)           -- average (ignores NULLs)
MIN(col)           -- minimum
MAX(col)           -- maximum
ROUND(val, 2)      -- round to 2 decimal places
```

---

## CASE WHEN

```sql
-- Simple form
CASE col
    WHEN 'gold'   THEN 3
    WHEN 'silver' THEN 2
    ELSE               1
END

-- Searched form (more flexible)
CASE
    WHEN price > 500  THEN 'Premium'
    WHEN price > 100  THEN 'Mid-range'
    ELSE                   'Budget'
END

-- Inline aggregation (very useful!)
SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered_count
```

---

## JOINs

```sql
-- INNER JOIN: only matching rows from both tables
SELECT * FROM orders o
INNER JOIN customers c ON c.id = o.customer_id;

-- LEFT JOIN: all rows from left, NULLs where no match on right
SELECT * FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id;

-- Find rows that DON'T match (anti-join)
SELECT * FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;   -- customers with no orders

-- Three-table join
SELECT c.first_name, o.id, p.name
FROM   customers   c
INNER JOIN orders      o  ON o.customer_id  = c.id
INNER JOIN order_items oi ON oi.order_id    = o.id
INNER JOIN products    p  ON p.id           = oi.product_id;
```

---

## CTEs (Common Table Expressions)

```sql
-- Single CTE
WITH active_customers AS (
    SELECT * FROM customers WHERE tier != 'bronze'
)
SELECT * FROM active_customers;

-- Chained CTEs
WITH step_one AS (
    SELECT ...
),
step_two AS (
    SELECT ... FROM step_one ...
),
step_three AS (
    SELECT ... FROM step_two ...
)
SELECT * FROM step_three;

-- Recursive CTE (date series)
WITH RECURSIVE dates AS (
    SELECT DATE('2024-01-01') AS d
    UNION ALL
    SELECT DATE(d, '+1 day') FROM dates WHERE d < DATE('2024-01-07')
)
SELECT d FROM dates;
```

---

## Window Functions

```sql
-- Syntax
function() OVER (
    PARTITION BY group_col   -- reset for each group
    ORDER BY sort_col        -- ordering within window
    ROWS BETWEEN ...         -- optional frame
)

-- Ranking
ROW_NUMBER() OVER (PARTITION BY tier ORDER BY signup_date)
RANK()        OVER (ORDER BY total_spent DESC)
DENSE_RANK()  OVER (ORDER BY total_spent DESC)  -- no gaps in rank

-- Aggregates as windows (keep all rows)
SUM(amount)   OVER (PARTITION BY customer_id)         -- total per customer
SUM(amount)   OVER (ORDER BY paid_at)                 -- running total
AVG(amount)   OVER (ORDER BY paid_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) -- rolling avg

-- Lag / Lead
LAG(col)  OVER (ORDER BY date)  -- previous row value
LEAD(col) OVER (ORDER BY date)  -- next row value
LAG(col, 2) OVER (ORDER BY date) -- 2 rows back
```

---

## Data Quality Checks

```sql
-- NULL check
SELECT COUNT(*) FROM table WHERE col IS NULL;

-- Uniqueness check
SELECT col, COUNT(*) FROM table GROUP BY col HAVING COUNT(*) > 1;

-- Accepted values check
SELECT col FROM table WHERE col NOT IN ('val1','val2','val3');

-- Range check
SELECT * FROM table WHERE amount <= 0;

-- Referential integrity
SELECT child.id FROM child_table child
LEFT JOIN parent_table parent ON parent.id = child.parent_id
WHERE parent.id IS NULL;

-- UNION ALL quality report
SELECT 'check_name' AS check, COUNT(*) AS failures FROM ...
UNION ALL
SELECT 'another_check',        COUNT(*) FROM ...;
```

---

## EXPLAIN (SQLite)

```sql
EXPLAIN QUERY PLAN
SELECT ...;

-- What to look for:
-- SCAN TABLE x            → full table scan (add an index!)
-- SEARCH TABLE x USING INDEX idx  → index lookup (good)
-- USING COVERING INDEX    → fastest (no table read needed)

-- Create an index
CREATE INDEX IF NOT EXISTS idx_name ON table(column);

-- Composite index (order matters — put equality columns first)
CREATE INDEX IF NOT EXISTS idx_status_region ON orders(status, region);
```

---

## Common Patterns

```sql
-- Top N per group (e.g., latest order per customer)
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
    FROM orders
)
SELECT * FROM ranked WHERE rn = 1;

-- Period-over-period growth
WITH monthly AS (SELECT month, SUM(amount) AS revenue FROM ... GROUP BY month)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev,
       revenue - LAG(revenue) OVER (ORDER BY month) AS change
FROM monthly;

-- Fanout-safe: aggregate before joining
WITH items_per_order AS (
    SELECT order_id, SUM(quantity * unit_price) AS total
    FROM order_items GROUP BY order_id
)
SELECT o.id, ioo.total, p.amount
FROM orders o
LEFT JOIN items_per_order ioo ON ioo.order_id = o.id
LEFT JOIN payments        p   ON p.order_id   = o.id;
```
