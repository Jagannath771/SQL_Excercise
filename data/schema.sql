-- ============================================================
-- ShopMetrics Workshop Schema
-- Compatible with: SQLite 3.x | PostgreSQL 12+
-- ============================================================
-- Run this file FIRST, then run seed_data.sql.
-- In DBeaver: paste contents → Ctrl+Alt+Enter (run all)
-- ============================================================

-- Drop in reverse dependency order (safe to re-run)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- ── customers ────────────────────────────────────────────────
-- NOTE: email and city are intentionally nullable — real-world
--       data is messy. Some rows also have extra whitespace in
--       email to give you cleaning practice.
CREATE TABLE customers (
    id          INTEGER PRIMARY KEY,
    first_name  TEXT    NOT NULL,
    last_name   TEXT,
    email       TEXT,               -- nullable: some rows are NULL
    country     TEXT,               -- inconsistent: 'US','USA','United States'
    city        TEXT,
    signup_date TEXT,               -- YYYY-MM-DD
    tier        TEXT DEFAULT 'bronze', -- bronze | silver | gold
    age         INTEGER
);

-- ── products ─────────────────────────────────────────────────
CREATE TABLE products (
    id             INTEGER PRIMARY KEY,
    name           TEXT    NOT NULL,
    category       TEXT,            -- Electronics | Clothing | Books | Home & Garden
    price          REAL    NOT NULL,
    cost           REAL,
    stock_quantity INTEGER  DEFAULT 0,
    is_active      INTEGER  DEFAULT 1  -- 1 = active, 0 = discontinued
);

-- ── orders ───────────────────────────────────────────────────
CREATE TABLE orders (
    id           INTEGER PRIMARY KEY,
    customer_id  INTEGER,
    status       TEXT,   -- pending|processing|shipped|delivered|cancelled|returned
    created_at   TEXT,   -- YYYY-MM-DD HH:MM:SS
    updated_at   TEXT,   -- NULL when order hasn't been updated yet
    region       TEXT,   -- North | South | East | West | Online
    discount_pct REAL    DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- ── order_items ──────────────────────────────────────────────
-- One order can have MANY items — this is where fanouts happen!
CREATE TABLE order_items (
    id         INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL DEFAULT 1,
    unit_price REAL    NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ── payments ─────────────────────────────────────────────────
-- NOTE: 5 orders intentionally have NO payment record.
--       This is a data quality issue you'll find in Module 2.
CREATE TABLE payments (
    id             INTEGER PRIMARY KEY,
    order_id       INTEGER UNIQUE,
    amount         REAL,
    payment_method TEXT,  -- credit_card | paypal | bank_transfer | cash
    paid_at        TEXT,  -- YYYY-MM-DD HH:MM:SS
    status         TEXT,  -- completed | failed | refunded | pending
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
