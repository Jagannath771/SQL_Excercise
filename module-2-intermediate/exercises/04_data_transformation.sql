-- ============================================================
-- MODULE 2 | Exercise 4: Data Transformation Pipeline
-- Difficulty: ⭐⭐ Medium  |  Estimated time: 15 minutes
-- ============================================================
--
-- LEARNING OBJECTIVES:
-- 1. Build a multi-step transformation pipeline using chained CTEs
-- 2. Apply CAST to fix data type mismatches
-- 3. Use CASE WHEN for complex conditional logic
-- 4. Combine COALESCE, TRIM, UPPER for defensive data handling
-- 5. Output an analyst-ready "mart" table from raw data
--
-- THE PATTERN:
-- Raw → Clean → Enrich → Aggregate → Output
-- Each CTE does ONE job. Each step builds on the previous.
-- This is how production dbt models are structured.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- 4.1  CAST — fixing data types
-- ─────────────────────────────────────────────────────────────
-- In SQLite, dates are stored as TEXT. CAST or JULIANDAY converts them.
-- Check the raw types first:
SELECT typeof(created_at),
       typeof(discount_pct),
       created_at,
       CAST(SUBSTR(created_at, 1, 10) AS TEXT) AS date_only,
       JULIANDAY('now') - JULIANDAY(created_at) AS days_ago
FROM   orders
LIMIT 5;

-- ✏️  YOUR TURN:
-- Write a query that shows each product's:
--   - name
--   - price (as REAL — it already is, but be explicit with CAST)
--   - margin_pct: (price - cost) / price * 100, rounded to 1 decimal
--   - margin_tier: 'High' if > 40%, 'Medium' if > 20%, else 'Low'
-- Sort by margin_pct DESC.



-- ─────────────────────────────────────────────────────────────
-- 4.2  Step 1: Staging layer — clean raw data
-- ─────────────────────────────────────────────────────────────
-- Think of this as your stg_customers model in dbt.

WITH stg_customers AS (
    SELECT
        id,
        TRIM(first_name)                        AS first_name,
        TRIM(COALESCE(last_name, ''))           AS last_name,
        LOWER(TRIM(COALESCE(email,
            'unknown@shopmetrics.com')))        AS email,
        CASE country
            WHEN 'US'  THEN 'United States'
            WHEN 'USA' THEN 'United States'
            ELSE COALESCE(country, 'Unknown')
        END                                     AS country,
        COALESCE(city, 'Unknown')               AS city,
        signup_date,
        LOWER(tier)                             AS tier,
        CAST(COALESCE(age, 0) AS INTEGER)       AS age
    FROM customers
)
SELECT * FROM stg_customers ORDER BY id;

-- ✏️  YOUR TURN:
-- Write a similar stg_orders CTE that:
--   - Keeps all columns
--   - Replaces NULL updated_at with 'pending'
--   - Adds a column 'is_terminal': 1 if status in
--     ('delivered','cancelled','returned'), else 0
--   - Adds 'order_date': just the date part of created_at (SUBSTR)
-- Show the first 20 rows.



-- ─────────────────────────────────────────────────────────────
-- 4.3  Step 2: Enrichment layer — add derived columns
-- ─────────────────────────────────────────────────────────────
-- Build on top of the staging CTE to compute business metrics.

WITH stg_customers AS (
    SELECT id,
           TRIM(first_name)  AS first_name,
           TRIM(COALESCE(last_name, '')) AS last_name,
           CASE country
               WHEN 'US'  THEN 'United States'
               WHEN 'USA' THEN 'United States'
               ELSE COALESCE(country, 'Unknown')
           END AS country,
           tier, age
    FROM customers
),
order_stats AS (
    SELECT customer_id,
           COUNT(*)                                 AS total_orders,
           SUM(CASE WHEN status='delivered' THEN 1 ELSE 0 END) AS delivered_orders,
           MIN(created_at)                          AS first_order_at,
           MAX(created_at)                          AS last_order_at
    FROM orders
    GROUP BY customer_id
),
enriched_customers AS (
    SELECT sc.*,
           COALESCE(os.total_orders,    0)  AS total_orders,
           COALESCE(os.delivered_orders, 0) AS delivered_orders,
           os.first_order_at,
           os.last_order_at,
           CASE
               WHEN os.total_orders IS NULL THEN 'no_orders'
               WHEN os.total_orders  >= 3   THEN 'loyal'
               WHEN os.delivered_orders > 0 THEN 'active'
               ELSE 'inactive'
           END AS customer_segment
    FROM stg_customers sc
    LEFT JOIN order_stats os ON os.customer_id = sc.id
)
SELECT * FROM enriched_customers ORDER BY total_orders DESC;

-- ✏️  YOUR TURN:
-- Add a 4th CTE 'with_spend' that joins enriched_customers to
-- completed payment totals (sum of payments where status='completed').
-- Add columns: total_spent, avg_order_value (total_spent / total_orders).
-- Handle divide-by-zero with CASE WHEN total_orders > 0 THEN ... ELSE 0.



-- ─────────────────────────────────────────────────────────────
-- 4.4  CHALLENGE: Analyst-ready order mart
-- ─────────────────────────────────────────────────────────────
-- ✏️  YOUR TURN:
-- Build a mart_orders CTE chain that produces one row per order with:
--
--   From orders:    order_id, order_date, status, region, discount_pct
--   From customers: customer_name (first + last), tier, country
--   From payments:  payment_amount (0 if NULL), payment_status
--                   ('no_payment' if no row)
--   Derived:
--     - item_count   (from order_items)
--     - gross_value  (SUM of qty * unit_price from order_items)
--     - net_value    (gross_value * (1 - discount_pct/100))
--     - days_to_ship (JULIANDAY(updated_at) - JULIANDAY(created_at),
--                    NULL if not yet shipped)
--
-- Use at least 4 CTEs. Sort by order_date DESC.
