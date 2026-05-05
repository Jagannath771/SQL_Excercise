# SQL That Actually Ships — DBeaver Workshop

A hands-on SQL workshop with three progressive modules, designed for the **San Antonio Data Community**.  
Fork this repo, open DBeaver, and work through the exercises at your own pace.

---

## Quick Start

### 1. Install DBeaver (free)
Download from [dbeaver.io](https://dbeaver.io/download/) — Community Edition is all you need.

### 2. Connect to a database
This workshop uses **SQLite** (zero setup — no server needed).

In DBeaver:
1. Click **Database → New Database Connection**
2. Choose **SQLite**
3. Click **Create** and name the file `workshop.db` anywhere on your machine
4. Click **Finish**

### 3. Load the data
Open DBeaver's SQL editor (press `Ctrl+]` / `Cmd+]` on the connection) and run these two files **in order**:

```
data/schema.sql     ← creates all tables
data/seed_data.sql  ← loads sample data
```

Paste the contents of each file and press **Ctrl+Enter** / **Cmd+Enter** to run.

### 4. Pick your module and start
```
module-1-foundations/   ← Start here if you're new to SQL
module-2-intermediate/  ← CTEs, window functions, data quality
module-3-advanced/      ← EXPLAIN, analytics patterns, production SQL
```

---

## The Dataset — ShopMetrics E-Commerce

You'll be working with a fictional e-commerce company's database:

| Table         | Rows | Description                              |
|---------------|------|------------------------------------------|
| `customers`   | 25   | Customer profiles (some with dirty data) |
| `products`    | 15   | Product catalog across 4 categories      |
| `orders`      | 50   | Orders with status, region, discounts    |
| `order_items` | 80   | Line items — multiple per order          |
| `payments`    | 45   | Payments (5 orders intentionally missing)|

The data includes **intentional imperfections** (NULLs, extra spaces, inconsistent values) so you can practice real-world data cleaning.

---

## Modules

| Module | Theme | Exercises | Est. Time |
|--------|-------|-----------|-----------|
| [Module 1 — Foundations](./module-1-foundations/) | SELECT, filter, join, aggregate | 5 | 45–60 min |
| [Module 2 — Intermediate](./module-2-intermediate/) | CTEs, windows, debugging, data quality | 5 | 60–90 min |
| [Module 3 — Advanced](./module-3-advanced/) | EXPLAIN, analytics, production patterns | 5 | 90–120 min |

---

## DBeaver Keyboard Shortcuts

| Action | Windows/Linux | Mac |
|--------|---------------|-----|
| Run current query | `Ctrl+Enter` | `Cmd+Enter` |
| Run entire script | `Ctrl+Alt+Enter` | `Cmd+Opt+Enter` |
| Format SQL | `Ctrl+Shift+F` | `Cmd+Shift+F` |
| Open SQL Editor | `Ctrl+]` | `Cmd+]` |
| View table data | `F4` | `F4` |
| Auto-complete | `Ctrl+Space` | `Ctrl+Space` |
| Comment line | `Ctrl+/` | `Cmd+/` |

---

## Resources
- [DBeaver Setup Guide](./resources/dbeaver_setup_guide.md)
- [SQL Cheat Sheet](./resources/sql_cheat_sheet.md)

---

*Built for "SQL That Actually Ships" — San Antonio Data Community, May 2026*
