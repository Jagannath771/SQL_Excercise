-- ============================================================
-- MODULE 3 | Exercise 5: Capstone — Business Dashboard
-- Difficulty: ⭐⭐⭐ Hard  |  Estimated time: 30 minutes
-- ============================================================
--
-- CONGRATULATIONS on reaching the capstone!
--
-- This exercise is open-ended. You are the data engineer.
-- A fictitious VP of Revenue has sent you five business questions.
-- Your job: write clean, production-quality SQL to answer each one.
--
-- There are no "MY TURN" prompts here — every question is yours.
-- Each answer should be a standalone, well-structured query.
--
-- GROUND RULES (write SQL that earns its place in production):
--   ✓ Use CTEs — no deeply nested subqueries
--   ✓ COALESCE every nullable aggregation
--   ✓ Name columns clearly (no "COUNT(*)" without an alias)
--   ✓ Add a one-line comment per CTE explaining what it contains
--   ✓ Include at least one data quality assertion per answer
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- QUESTION 1 — Revenue Performance
-- ─────────────────────────────────────────────────────────────
-- "Show me completed revenue by month for 2023 and 2024,
--  with month-over-month growth rate and a 3-month rolling average.
--  Flag any month where growth dropped more than 20% (highlight it)."
--
-- Expected columns:
--   year_month | revenue | prev_month | mom_growth_pct |
--   rolling_3m_avg | flag ('⚠ Drop' or 'OK')

-- Write your answer below:



-- ─────────────────────────────────────────────────────────────
-- QUESTION 2 — Customer Health
-- ─────────────────────────────────────────────────────────────
-- "Give me a customer health scorecard. For each customer show:
--  their tier, total lifetime spend, number of orders, average
--  order value, days since their last order, and classify them as:
--    'Champion'  — gold tier, 3+ orders, last order within 180 days
--    'At Risk'   — had 2+ orders but last order > 180 days ago
--    'New'       — only 1 order
--    'Prospect'  — signed up but never ordered
--  Sort champions and at-risk customers to the top."
--
-- Expected columns:
--   full_name | tier | health_label | total_spent | order_count |
--   avg_order_value | days_since_last_order

-- Write your answer below:



-- ─────────────────────────────────────────────────────────────
-- QUESTION 3 — Product Performance
-- ─────────────────────────────────────────────────────────────
-- "Which products are actually making us money?
--  Show each product with:
--    - Units sold (from delivered orders only)
--    - Gross revenue from order_items (qty × unit_price)
--    - Total cost of goods sold (qty × product.cost)
--    - Gross profit (revenue - cogs)
--    - Gross margin % ((revenue - cogs) / revenue * 100)
--  Rank products within their category by gross profit.
--  Flag discontinued products (is_active=0) even if they have sales."
--
-- Expected columns:
--   category | product_name | units_sold | gross_revenue |
--   cogs | gross_profit | margin_pct | category_rank | status_flag

-- Write your answer below:



-- ─────────────────────────────────────────────────────────────
-- QUESTION 4 — Operations Quality
-- ─────────────────────────────────────────────────────────────
-- "I need a data quality report before our board presentation.
--  Check the following and tell me pass/fail for each:
--    1. Are all customer emails unique (ignoring NULLs)?
--    2. Are there any orders with invalid statuses?
--    3. Are there delivered orders with no payment?
--    4. Are there any payment amounts <= 0?
--    5. Are there order_items with no matching product?
--    6. What % of customers have a missing email?
--  Format as a single table with columns: check_name, result, count, detail."

-- Write your answer below:



-- ─────────────────────────────────────────────────────────────
-- QUESTION 5 — Strategic Insight (open ended)
-- ─────────────────────────────────────────────────────────────
-- "If you could show me ONE metric that tells the health of
--  the business at a glance, what would it be and why?
--  Write the SQL for it."
--
-- This is your chance to be creative. Think about:
--   - Repeat purchase rate
--   - Revenue concentration (do 20% of customers drive 80% of revenue?)
--   - Average time between orders
--   - Payment completion rate
--   - Any other insight hiding in this dataset
--
-- Write your chosen metric below with a comment explaining why
-- you think it's the most important signal:



-- ─────────────────────────────────────────────────────────────
-- BONUS — Share your work
-- ─────────────────────────────────────────────────────────────
-- If you finish early or want a challenge:
--   • Export your Question 3 results to CSV via DBeaver
--     (right-click result grid → Export Resultset)
--   • Build the cohort retention matrix from Module 3, Exercise 1
--   • Try running one of your queries against PostgreSQL if available
--     (syntax changes: STRFTIME → DATE_TRUNC, JULIANDAY → AGE/EXTRACT)
