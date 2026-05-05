-- ============================================================
-- ShopMetrics Workshop Schema
-- Compatible with: SQLite 3.x | PostgreSQL 12+
-- ============================================================
-- Run this file FIRST, then run seed_data.sql.
-- In DBeaver: paste contents → Ctrl+Alt+Enter (run all)
--
-- PostgreSQL note:
--   This script creates and uses a dedicated 'workshop' schema
--   to avoid the "permission denied for schema public" error
--   that appears in PostgreSQL 15+ for non-superuser accounts.
--   All tables live in the 'workshop' schema.
--
-- SQLite note:
--   SQLite ignores the CREATE SCHEMA and SET search_path lines
--   harmlessly — everything still works.
-- ============================================================

-- ── PostgreSQL: create a dedicated schema ────────────────────
-- (SQLite silently ignores these two statements)
CREATE SCHEMA IF NOT EXISTS workshop;
SET search_path TO workshop;

-- Alternative fix (requires a superuser to run once):
--   GRANT CREATE ON SCHEMA public TO <your_username>;
-- The CREATE SCHEMA approach above is preferred because it works
-- without superuser access.

-- Drop in reverse dependency order (safe to re-run)
DROP TABLE IF EXISTS workshop.payments;
DROP TABLE IF EXISTS workshop.order_items;
DROP TABLE IF EXISTS workshop.orders;
DROP TABLE IF EXISTS workshop.products;
DROP TABLE IF EXISTS workshop.customers;

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
    price          NUMERIC(10,2) NOT NULL,
    cost           NUMERIC(10,2),
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
    discount_pct NUMERIC(5,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- ── order_items ──────────────────────────────────────────────
-- One order can have MANY items — this is where fanouts happen!
CREATE TABLE order_items (
    id         INTEGER PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ── payments ─────────────────────────────────────────────────
-- NOTE: 5 orders intentionally have NO payment record.
--       This is a data quality issue you'll find in Module 2.
CREATE TABLE payments (
    id             INTEGER PRIMARY KEY,
    order_id       INTEGER UNIQUE,
    amount         NUMERIC(10,2),
    payment_method TEXT,  -- credit_card | paypal | bank_transfer | cash
    paid_at        TEXT,  -- YYYY-MM-DD HH:MM:SS
    status         TEXT,  -- completed | failed | refunded | pending
    FOREIGN KEY (order_id) REFERENCES orders(id)
);
