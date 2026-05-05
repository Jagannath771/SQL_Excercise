# DBeaver Setup Guide

## 1. Install DBeaver Community Edition

Download from [dbeaver.io/download](https://dbeaver.io/download/) — choose the version for your OS.

- **macOS**: Download the `.dmg`, drag to Applications
- **Windows**: Download the `.exe` installer, run it
- **Linux**: Use the `.deb`/`.rpm` package or AppImage

DBeaver Community Edition is **free and open-source**. You don't need DBeaver Pro for this workshop.

---

## 2. Create a SQLite Connection

SQLite is a file-based database — no server needed. DBeaver includes the SQLite driver.

1. Open DBeaver
2. Click **Database** → **New Database Connection** (or `Ctrl+Shift+N`)
3. In the "Connect to a database" dialog, select **SQLite**
4. Click **Next**
5. Under **Path**, click **Create** and save a new file named `shopmetrics_workshop.db` anywhere (e.g., your Desktop)
6. Click **Finish**

Your new database appears in the **Database Navigator** panel on the left.

---

## 3. Load the Workshop Data

1. Right-click your new SQLite connection → **SQL Editor** → **Open SQL Script** (or press `Ctrl+]`)
2. In the SQL editor, click **File** → **Open File** and open `data/schema.sql` from this repo
3. Press `Ctrl+Alt+Enter` to run the entire script
4. You should see "5 statements executed" in the status bar
5. Repeat with `data/seed_data.sql`
6. **Refresh** the connection (right-click → Refresh) — you'll now see the 5 tables in the tree

**Verify the data loaded:**
```sql
SELECT 'customers'   AS tbl, COUNT(*) FROM customers   UNION ALL
SELECT 'products',            COUNT(*) FROM products    UNION ALL
SELECT 'orders',              COUNT(*) FROM orders      UNION ALL
SELECT 'order_items',         COUNT(*) FROM order_items UNION ALL
SELECT 'payments',            COUNT(*) FROM payments;
-- Should show: 25, 15, 50, 80, 45
```

---

## 4. DBeaver Interface Overview

```
┌────────────────────────────────────────────────────────────────┐
│  Menu Bar                                                      │
├──────────────┬─────────────────────────────────────────────────┤
│ Database     │   SQL Editor                                    │
│ Navigator    │   ┌──────────────────────────────────────────┐  │
│              │   │ SELECT * FROM customers LIMIT 10;        │  │
│ ▾ workshop   │   └──────────────────────────────────────────┘  │
│   ▾ Tables   │   Results Grid                                  │
│     customers│   ┌──────────────────────────────────────────┐  │
│     orders   │   │ id │ first_name │ email │ ...             │  │
│     products │   │  1 │ Alice      │ alice@│ ...             │  │
│     ...      │   └──────────────────────────────────────────┘  │
└──────────────┴─────────────────────────────────────────────────┘
```

**Key panels:**
- **Database Navigator** (left): Browse tables, columns, indexes
- **SQL Editor** (center top): Write and run SQL
- **Results** (center bottom): See query output
- **Properties** (bottom): Column metadata, row counts

---

## 5. Essential DBeaver Tricks

### Run a single query (not the whole file)
Place your cursor anywhere inside a query and press `Ctrl+Enter` (Mac: `Cmd+Enter`).

### Format SQL automatically
Select your SQL (or `Ctrl+A`) then press `Ctrl+Shift+F`.

### Browse table data without writing SQL
Right-click any table in the navigator → **View Data** (or press `F4`).

### See column data types
Right-click a table → **View Table** → click the **Columns** tab.

### Visual ER Diagram
Right-click the database → **View Diagram** — see all tables and their relationships.

### Explain a query visually
Highlight your query → right-click → **Explain Execution Plan** (shows a tree view).  
Or prefix your query with `EXPLAIN QUERY PLAN` and run it like normal SQL.

### SQL history
`Ctrl+Alt+H` — see all previously run queries. Never lose a query again.

### Auto-complete
Press `Ctrl+Space` while typing a table or column name.

### Comment/uncomment a line
`Ctrl+/` (Mac: `Cmd+/`) toggles the current line as a comment.

---

## 6. Common Issues

| Problem | Solution |
|---------|----------|
| "No suitable driver found" | DBeaver → Help → Install New Software → search for SQLite driver |
| Query runs entire file instead of one statement | Use `Ctrl+Enter` (not `F5` or `Ctrl+Alt+Enter`) |
| Can't see the tables after loading data | Right-click connection → Refresh |
| Results show "[BLOB]" instead of data | The column is a BLOB type — for this workshop all columns are text/number, so this shouldn't happen |
| "table already exists" error | You ran schema.sql twice — the `DROP TABLE IF EXISTS` lines handle this; re-run |

---

## 7. Connecting to PostgreSQL (optional)

If you have PostgreSQL installed and want a production-grade environment:

1. **New Database Connection** → select **PostgreSQL**
2. Fill in: host (`localhost`), port (`5432`), database name, username, password
3. Click **Test Connection** — DBeaver will prompt to download the JDBC driver automatically
4. Note: a few SQLite-specific functions differ in PostgreSQL:
   - `STRFTIME('%Y-%m', col)` → `TO_CHAR(col, 'YYYY-MM')`
   - `JULIANDAY()` → `EXTRACT(EPOCH FROM col)`
   - `SUBSTR(col, 1, 4)` → `SUBSTRING(col FROM 1 FOR 4)` or `LEFT(col, 4)`
   - `WITH RECURSIVE` → same syntax ✓
   - `EXPLAIN QUERY PLAN` → `EXPLAIN ANALYZE` (more detail)
