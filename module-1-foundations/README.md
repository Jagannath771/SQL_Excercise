# Module 1 — Foundations

**Difficulty:** ⭐ Easy  
**Estimated time:** 45–60 minutes  
**Prerequisite:** Run `data/schema.sql` and `data/seed_data.sql` first.

---

## What You'll Learn

By the end of this module you'll be able to:
- Navigate DBeaver's interface and explore a database you've never seen before
- Filter, sort, and limit query results
- Clean messy string data using built-in functions
- Combine tables with INNER and LEFT JOINs
- Summarize data with GROUP BY and aggregation functions

---

## Exercises

| # | File | Topic | Time |
|---|------|-------|------|
| 1 | [01_exploring_data.sql](exercises/01_exploring_data.sql) | SELECT, LIMIT, schema browsing | 8 min |
| 2 | [02_filtering_and_sorting.sql](exercises/02_filtering_and_sorting.sql) | WHERE, ORDER BY, IN, BETWEEN, LIKE | 10 min |
| 3 | [03_string_functions.sql](exercises/03_string_functions.sql) | TRIM, UPPER, COALESCE, REPLACE | 10 min |
| 4 | [04_basic_joins.sql](exercises/04_basic_joins.sql) | INNER JOIN, LEFT JOIN | 12 min |
| 5 | [05_aggregations.sql](exercises/05_aggregations.sql) | GROUP BY, COUNT, SUM, AVG, HAVING | 12 min |

Solutions are in the `solutions/` folder — try the exercise first!

---

## DBeaver Tips for This Module

**Exploring tables visually:**  
Right-click any table in the left panel → **View Data** (or press `F4`).  
This shows data in a spreadsheet-like grid without writing any SQL.

**Schema diagram:**  
Right-click the database → **View Diagram** to see all tables and relationships visually.

**Auto-complete:**  
Press `Ctrl+Space` while typing a table or column name for suggestions.

**Run just one query:**  
Place your cursor inside a query and press `Ctrl+Enter` — DBeaver only runs the statement your cursor is in, not the whole file.
