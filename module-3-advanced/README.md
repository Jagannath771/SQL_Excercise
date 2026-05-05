# Module 3 — Advanced

**Difficulty:** ⭐⭐⭐ Hard  
**Estimated time:** 90–120 minutes  
**Prerequisite:** Complete Module 2, or be comfortable with CTEs, window functions, and JOIN debugging.

---

## What You'll Learn

By the end of this module you'll be able to:
- Write recursive CTEs for hierarchical or sequence-based data
- Read and interpret an EXPLAIN plan to find performance bottlenecks
- Build cohort analysis, funnel metrics, and period-over-period comparisons
- Write production-grade SQL that is defensive, readable, and maintainable
- Answer open-ended business questions end-to-end (capstone)

---

## Exercises

| # | File | Topic | Time |
|---|------|-------|------|
| 1 | [01_advanced_ctes.sql](exercises/01_advanced_ctes.sql) | Recursive CTEs, sequence generation | 20 min |
| 2 | [02_query_explain.sql](exercises/02_query_explain.sql) | EXPLAIN QUERY PLAN, indexes, performance | 20 min |
| 3 | [03_analytics_patterns.sql](exercises/03_analytics_patterns.sql) | Cohort, funnel, running totals, percentiles | 25 min |
| 4 | [04_production_sql.sql](exercises/04_production_sql.sql) | Defensive SQL, audit columns, readable patterns | 20 min |
| 5 | [05_capstone.sql](exercises/05_capstone.sql) | Open-ended business dashboard (all skills) | 30 min |

---

## Key Concepts

**Recursive CTEs:**  
A recursive CTE references itself. You define a base case (starting rows) and a recursive step (how to expand). SQLite and PostgreSQL both support `WITH RECURSIVE`.

**EXPLAIN QUERY PLAN (SQLite):**  
Prefix any query with `EXPLAIN QUERY PLAN` to see *which index* (if any) SQLite uses, whether it does a full table scan, and how joins are ordered. The goal: no `SCAN TABLE` on large tables without an index.

**Cohort analysis:**  
Group users by when they first did something (signup month, first order month), then measure how they behave over subsequent periods. The result is a retention matrix — one of the most powerful tables in product analytics.

**Production SQL principles:**
- Every nullable column gets a `COALESCE` default before downstream aggregation
- Every CTE is named after what it *contains*, not what it *does* (`active_customers` not `step_1`)
- Every query that touches > 1 table has a join key count-check in a comment or assertion CTE

---

## DBeaver Tips for This Module

**Bookmark complex queries:**  
Right-click inside the SQL editor → **Bookmarks → Add Bookmark**. Access later from the Bookmarks panel.

**Export results:**  
Right-click any result grid → **Export Resultset** → CSV/Excel. Useful for sharing the capstone output.

**Script tabs:**  
Open multiple SQL editor tabs (`Ctrl+]` again on same connection) to compare queries side by side.
