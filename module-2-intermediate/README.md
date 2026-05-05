# Module 2 — Intermediate

**Difficulty:** ⭐⭐ Medium  
**Estimated time:** 60–90 minutes  
**Prerequisite:** Complete Module 1, or be comfortable with SELECT, WHERE, JOIN, GROUP BY.

---

## What You'll Learn

By the end of this module you'll be able to:
- Write CTEs (Common Table Expressions) to break complex queries into readable steps
- Use window functions for ranking, running totals, and period-over-period comparisons
- Detect and fix the most common join bug: row multiplication (fanouts)
- Build a multi-step data transformation pipeline
- Write a data quality check report that catches real problems

---

## Exercises

| # | File | Topic | Time |
|---|------|-------|------|
| 1 | [01_cte_patterns.sql](exercises/01_cte_patterns.sql) | WITH clauses, chaining CTEs | 12 min |
| 2 | [02_window_functions.sql](exercises/02_window_functions.sql) | ROW_NUMBER, RANK, LAG, SUM OVER | 15 min |
| 3 | [03_debugging_joins.sql](exercises/03_debugging_joins.sql) | Fanout detection, pre-join COUNT checks | 15 min |
| 4 | [04_data_transformation.sql](exercises/04_data_transformation.sql) | CAST, COALESCE, CASE WHEN pipeline | 15 min |
| 5 | [05_data_quality.sql](exercises/05_data_quality.sql) | NULL checks, uniqueness, referential integrity | 15 min |

---

## Key Concepts

**Why CTEs?**  
A CTE lets you name an intermediate result and reference it like a table. Instead of nesting subqueries 4 levels deep, you write one CTE per logical step — top to bottom, like a recipe.

**What's a fanout?**  
When you join a table that has multiple rows per key (e.g., `order_items` has many rows per `order_id`), your results get multiplied. A `COUNT(*)` before joining tells you how many duplicates to expect.

**Window functions vs GROUP BY:**  
`GROUP BY` collapses rows into one per group. Window functions *keep all rows* but add a new column computed over a partition. Use `GROUP BY` to aggregate; use window functions to rank, lag, or compute running totals.

---

## DBeaver Tips for This Module

**Explain plan:**  
Highlight a query → press `Ctrl+Shift+E` (or **SQL Editor → Explain Execution Plan**) to see how the database will run it.

**SQL history:**  
`Ctrl+Alt+H` opens your query history — useful when you accidentally close a tab.

**Multiple result tabs:**  
If you run several queries in one script, DBeaver shows each result in a separate tab below.
