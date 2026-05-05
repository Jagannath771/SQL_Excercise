-- ============================================================
-- ShopMetrics Sample Data
-- ============================================================
-- Run AFTER schema.sql.
-- Intentional data issues are marked with -- [DIRTY] comments
-- so you know what to look for in the cleaning exercises.
-- ============================================================

-- ── customers ────────────────────────────────────────────────
INSERT INTO customers (id, first_name, last_name, email, country, city, signup_date, tier, age) VALUES
(1,  'Alice',    'Johnson',   'alice.johnson@email.com',    'United States', 'New York',    '2023-01-15', 'gold',   34),
(2,  'Bob',      'Smith',     'bob.smith@email.com',        'United States', 'Los Angeles', '2023-02-20', 'silver', 28),
(3,  'Carol',    'Williams',  '  carol.w@email.com  ',      'United States', 'Chicago',     '2023-03-10', 'bronze', 45), -- [DIRTY] extra spaces in email
(4,  'David',    'Brown',     'david.brown@email.com',      'UK',            'London',      '2023-01-05', 'gold',   52),
(5,  'Emma',     'Davis',     'emma.davis@email.com',       'Germany',       'Berlin',      '2023-04-18', 'silver', 31),
(6,  'Frank',    'Miller',    NULL,                         'Canada',        'Toronto',     '2023-05-22', 'bronze', 27), -- [DIRTY] NULL email
(7,  'Grace',    'Wilson',    'grace.wilson@email.com',     'Australia',     'Sydney',      '2023-06-30', 'gold',   38),
(8,  'Henry',    'Moore',     'henry.moore@email.com',      'USA',           'San Antonio', '2023-07-14', 'silver', 41), -- [DIRTY] 'USA' vs 'United States'
(9,  'Isabella', 'Taylor',    '   isabella.t@email.com',    'France',        'Paris',       '2023-08-08', 'bronze', 29), -- [DIRTY] leading spaces
(10, 'James',    'Anderson',  'james.anderson@email.com',   'UK',            'Manchester',  '2023-09-01', 'gold',   55),
(11, 'Kate',     'Thomas',    'kate.thomas@email.com',      'United States', 'Houston',     '2023-10-12', 'silver', 33),
(12, 'Liam',     'Jackson',   'liam.jackson@email.com',     'Canada',        'Vancouver',   '2023-11-05', 'bronze', 22),
(13, 'Mia',      'White',     'mia.white@email.com',        'Germany',       'Munich',      '2023-12-20', 'gold',   44),
(14, 'Noah',     'Harris',    'noah.harris@email.com',      'Australia',     'Melbourne',   '2024-01-08', 'silver', 36),
(15, 'Olivia',   'Martin',    NULL,                         'United States', 'Dallas',      '2024-02-14', 'bronze', 25), -- [DIRTY] NULL email
(16, 'Peter',    'Garcia',    'peter.garcia@email.com',     'US',            'Miami',       '2024-03-05', 'gold',   48), -- [DIRTY] 'US'
(17, 'Quinn',    'Martinez',  'quinn.m@email.com',          'United States', 'Seattle',     '2024-04-19', 'silver', 30),
(18, 'Rachel',   'Robinson',  'rachel.r@email.com',         'UK',            'Birmingham',  '2024-05-02', 'bronze', 37),
(19, 'Samuel',   'Clark',     'samuel.clark@email.com',     'India',         'Bangalore',   '2024-06-15', 'gold',   43),
(20, 'Tina',     'Rodriguez', 'tina.r@email.com',           'United States', 'Boston',      '2024-07-28', 'silver', 26),
-- Customers 21-25 have NO orders (useful for LEFT JOIN exercises)
(21, 'Uma',      'Lewis',     'uma.lewis@email.com',        'France',        'Lyon',        '2024-08-10', 'bronze', 32),
(22, 'Victor',   'Lee',       'victor.lee@email.com',       'United States', 'Denver',      '2024-09-03', 'gold',   50),
(23, 'Wendy',    'Walker',    'wendy.walker@email.com',     'Canada',        'Montreal',    '2024-10-17', 'silver', 35),
(24, 'Xavier',   'Hall',      'xavier.h@email.com',         'India',         'Mumbai',      '2024-11-21', 'bronze', 28),
(25, 'Yara',     'Allen',     'yara.allen@email.com',       'United States', 'Phoenix',     '2024-12-05', 'gold',   39);

-- ── products ─────────────────────────────────────────────────
INSERT INTO products (id, name, category, price, cost, stock_quantity, is_active) VALUES
(1,  'Laptop Pro 15',               'Electronics',   1299.99, 850.00, 45,  1),
(2,  'Wireless Keyboard',           'Electronics',     89.99,  35.00, 200, 1),
(3,  'USB-C Hub',                   'Electronics',     49.99,  18.00, 150, 1),
(4,  'Running Shoes',               'Clothing',        129.99,  55.00,  80, 1),
(5,  'Winter Jacket',               'Clothing',        199.99,  90.00,  60, 1),
(6,  'SQL Mastery Book',            'Books',            39.99,  12.00, 300, 1),
(7,  'Python Cookbook',             'Books',            44.99,  15.00, 250, 1),
(8,  'Data Science Fundamentals',   'Books',            54.99,  18.00, 180, 1),
(9,  'Smart Speaker',               'Electronics',      79.99,  32.00, 120, 1),
(10, 'Coffee Maker',                'Home & Garden',   149.99,  65.00,  75, 1),
(11, 'Standing Desk',               'Home & Garden',   449.99, 220.00,  30, 1),
(12, 'Yoga Mat',                    'Clothing',         34.99,  12.00, 200, 1),
(13, 'Mechanical Keyboard',         'Electronics',     159.99,  72.00,  90, 1),
(14, 'Desk Lamp',                   'Home & Garden',    59.99,  22.00, 110, 1),
(15, 'Noise Cancelling Headphones', 'Electronics',     299.99, 140.00,  55, 0); -- [DIRTY] is_active=0, discontinued

-- ── orders ───────────────────────────────────────────────────
INSERT INTO orders (id, customer_id, status, created_at, updated_at, region, discount_pct) VALUES
-- Alice (gold) — 3 orders
(1,  1,  'delivered',  '2023-02-10 09:15:00', '2023-02-18 14:30:00', 'North',  0),
(2,  1,  'delivered',  '2023-07-22 11:00:00', '2023-07-30 16:45:00', 'North',  10),
(41, 1,  'delivered',  '2024-03-15 10:00:00', '2024-03-23 14:00:00', 'North',  0),
-- Bob (silver) — 2 orders + 1 unpaid
(3,  2,  'delivered',  '2023-03-05 14:22:00', '2023-03-12 10:00:00', 'West',   0),
(4,  2,  'cancelled',  '2023-09-15 08:30:00', '2023-09-15 09:00:00', 'West',   0),
(46, 2,  'shipped',    '2024-11-15 09:00:00', NULL,                  'West',   0), -- [DIRTY] no payment
-- Carol (bronze, dirty email) — 2 orders
(5,  3,  'delivered',  '2023-04-01 16:45:00', '2023-04-10 12:00:00', 'North',  5),
(6,  3,  'shipped',    '2024-01-20 10:00:00', NULL,                  'North',  0),
-- David (gold) — 2 orders + 1 unpaid
(7,  4,  'delivered',  '2023-02-28 12:00:00', '2023-03-07 15:30:00', 'East',   0),
(8,  4,  'returned',   '2023-11-15 14:00:00', '2023-11-25 11:00:00', 'East',   0),
(47, 4,  'processing', '2024-11-20 10:00:00', NULL,                  'East',   0), -- [DIRTY] no payment
-- Emma (silver) — 2 orders
(9,  5,  'delivered',  '2023-05-10 09:00:00', '2023-05-18 14:00:00', 'Online', 0),
(10, 5,  'processing', '2024-03-01 11:30:00', NULL,                  'Online', 15),
-- Frank (bronze, NULL email) — 2 orders
(11, 6,  'delivered',  '2023-06-15 08:00:00', '2023-06-23 16:00:00', 'North',  0),
(12, 6,  'pending',    '2024-04-10 14:00:00', NULL,                  'North',  0),
-- Grace (gold) — 3 orders
(13, 7,  'delivered',  '2023-07-01 10:00:00', '2023-07-09 14:30:00', 'Online', 0),
(14, 7,  'delivered',  '2023-12-20 15:00:00', '2023-12-28 10:00:00', 'Online', 0),
(42, 7,  'returned',   '2024-05-01 11:00:00', '2024-05-11 14:00:00', 'Online', 0),
-- Henry (silver, USA country) — 2 orders
(15, 8,  'shipped',    '2024-01-05 09:30:00', NULL,                  'South',  0),
(16, 8,  'delivered',  '2023-08-20 11:00:00', '2023-08-28 15:00:00', 'South',  0),
-- Isabella (bronze, dirty email) — 2 orders
(17, 9,  'cancelled',  '2023-09-05 13:00:00', '2023-09-05 13:30:00', 'East',   0),
(18, 9,  'delivered',  '2024-02-14 10:00:00', '2024-02-22 14:00:00', 'East',   0),
-- James (gold) — 3 orders
(19, 10, 'delivered',  '2023-10-01 08:00:00', '2023-10-10 16:00:00', 'East',   0),
(20, 10, 'shipped',    '2024-04-05 12:00:00', NULL,                  'East',   0),
(43, 10, 'delivered',  '2024-08-20 09:00:00', '2024-08-28 14:00:00', 'East',   0),
-- Kate (silver) — 2 orders + 1 unpaid
(21, 11, 'delivered',  '2023-11-01 09:00:00', '2023-11-09 14:00:00', 'South',  10),
(22, 11, 'delivered',  '2024-05-20 11:00:00', '2024-05-28 16:00:00', 'South',  0),
(48, 11, 'pending',    '2024-12-05 11:00:00', NULL,                  'South',  0), -- [DIRTY] no payment
-- Liam (bronze) — 2 orders
(23, 12, 'cancelled',  '2023-12-10 14:00:00', '2023-12-10 15:00:00', 'West',   0),
(24, 12, 'processing', '2024-06-01 10:00:00', NULL,                  'West',   0),
-- Mia (gold) — 3 orders
(25, 13, 'delivered',  '2024-01-15 09:00:00', '2024-01-23 14:30:00', 'Online', 0),
(26, 13, 'delivered',  '2024-06-10 11:00:00', '2024-06-18 15:00:00', 'Online', 0),
(44, 13, 'delivered',  '2024-09-25 10:00:00', '2024-10-03 15:00:00', 'Online', 0),
-- Noah (silver) — 2 orders
(27, 14, 'returned',   '2024-02-20 12:00:00', '2024-03-01 10:00:00', 'East',   0),
(28, 14, 'pending',    '2024-07-15 09:00:00', NULL,                  'East',   0),
-- Olivia (bronze, NULL email) — 2 orders
(29, 15, 'delivered',  '2024-03-05 10:00:00', '2024-03-13 14:00:00', 'South',  0),
(30, 15, 'shipped',    '2024-08-10 12:00:00', NULL,                  'South',  0),
-- Peter (gold, US country) — 2 orders + 1 unpaid
(31, 16, 'delivered',  '2024-04-01 08:30:00', '2024-04-09 14:00:00', 'South',  0),
(32, 16, 'delivered',  '2024-09-05 10:00:00', '2024-09-13 16:00:00', 'South',  0),
(49, 16, 'shipped',    '2024-12-10 12:00:00', NULL,                  'South',  0), -- [DIRTY] no payment
-- Quinn (silver) — 2 orders
(33, 17, 'processing', '2024-04-20 11:00:00', NULL,                  'West',   0),
(34, 17, 'delivered',  '2024-10-01 09:00:00', '2024-10-09 14:00:00', 'West',   0),
-- Rachel (bronze) — 2 orders
(35, 18, 'cancelled',  '2024-05-10 13:00:00', '2024-05-10 14:00:00', 'East',   0),
(36, 18, 'delivered',  '2024-10-15 10:00:00', '2024-10-23 15:00:00', 'East',   0),
-- Samuel (gold) — 3 orders
(37, 19, 'delivered',  '2024-06-01 09:00:00', '2024-06-09 14:00:00', 'Online', 0),
(38, 19, 'delivered',  '2024-11-10 11:00:00', '2024-11-18 16:00:00', 'Online', 0),
(45, 19, 'processing', '2024-12-15 11:00:00', NULL,                  'Online', 0),
-- Tina (silver) — 2 orders
(39, 20, 'delivered',  '2024-07-15 10:00:00', '2024-07-23 14:00:00', 'North',  0),
(40, 20, 'pending',    '2024-12-01 09:00:00', NULL,                  'North',  0);
-- Customers 21-25 (Uma, Victor, Wendy, Xavier, Yara) have NO orders

-- ── order_items ──────────────────────────────────────────────
-- Note: many orders have 2+ items — this creates fanouts (Module 2, Exercise 3)
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price) VALUES
-- Single-item orders
(1,  1,  1,  1, 1299.99), -- order 1:  Laptop Pro
(2,  3,  9,  1,   79.99), -- order 3:  Smart Speaker
(3,  7,  11, 1,  449.99), -- order 7:  Standing Desk
(4,  9,  8,  1,   54.99), -- order 9:  Data Science Book
(5,  11, 6,  1,   39.99), -- order 11: SQL Mastery Book
(6,  18, 9,  1,   79.99), -- order 18: Smart Speaker
(7,  19, 13, 1,  159.99), -- order 19: Mechanical Keyboard
(8,  25, 10, 1,  149.99), -- order 25: Coffee Maker
(9,  29, 9,  1,   79.99), -- order 29: Smart Speaker
(10, 37, 11, 1,  449.99), -- order 37: Standing Desk
-- Two-item orders
(11, 2,  6,  2,   39.99), -- order 2:  2× SQL Book
(12, 2,  7,  1,   44.99), -- order 2:  Python Cookbook
(13, 4,  2,  1,   89.99), -- order 4:  Keyboard (CANCELLED)
(14, 4,  12, 1,   34.99), -- order 4:  Yoga Mat  (CANCELLED)
(15, 5,  4,  2,  129.99), -- order 5:  2× Running Shoes
(16, 5,  12, 1,   34.99), -- order 5:  Yoga Mat
(17, 6,  7,  1,   44.99), -- order 6:  Python Cookbook (SHIPPED)
(18, 6,  8,  1,   54.99), -- order 6:  Data Science Book
(19, 8,  5,  1,  199.99), -- order 8:  Winter Jacket (RETURNED)
(20, 8,  12, 1,   34.99), -- order 8:  Yoga Mat
(21, 10, 3,  1,   49.99), -- order 10: USB-C Hub (PROCESSING)
(22, 10, 6,  1,   39.99), -- order 10: SQL Book
(23, 12, 2,  1,   89.99), -- order 12: Keyboard (PENDING)
(24, 12, 14, 1,   59.99), -- order 12: Desk Lamp
(25, 13, 1,  1, 1299.99), -- order 13: Laptop Pro
(26, 13, 2,  1,   89.99), -- order 13: Wireless Keyboard
(27, 14, 10, 1,  149.99), -- order 14: Coffee Maker
(28, 14, 14, 2,   59.99), -- order 14: 2× Desk Lamp
(29, 15, 1,  1, 1299.99), -- order 15: Laptop Pro
(30, 15, 3,  2,   49.99), -- order 15: 2× USB-C Hub
(31, 16, 4,  1,  129.99), -- order 16: Running Shoes
(32, 16, 5,  1,  199.99), -- order 16: Winter Jacket
(33, 17, 6,  1,   39.99), -- order 17: SQL Book (CANCELLED)
(34, 17, 8,  1,   54.99), -- order 17: Data Science Book
(35, 20, 2,  2,   89.99), -- order 20: 2× Keyboard (SHIPPED)
(36, 20, 14, 1,   59.99), -- order 20: Desk Lamp
(37, 21, 7,  2,   44.99), -- order 21: 2× Python Cookbook
(38, 21, 8,  1,   54.99), -- order 21: Data Science Book
(39, 22, 4,  1,  129.99), -- order 22: Running Shoes
(40, 22, 12, 2,   34.99), -- order 22: 2× Yoga Mat
(41, 26, 10, 1,  149.99), -- order 26: Coffee Maker
(42, 26, 14, 1,   59.99), -- order 26: Desk Lamp
(43, 27, 5,  1,  199.99), -- order 27: Winter Jacket (RETURNED)
(44, 27, 12, 1,   34.99), -- order 27: Yoga Mat
(45, 30, 7,  1,   44.99), -- order 30: Python Cookbook (SHIPPED)
(46, 30, 8,  1,   54.99), -- order 30: Data Science Book
(47, 31, 1,  1, 1299.99), -- order 31: Laptop Pro
(48, 31, 2,  1,   89.99), -- order 31: Wireless Keyboard
(49, 32, 10, 1,  149.99), -- order 32: Coffee Maker
(50, 32, 11, 1,  449.99), -- order 32: Standing Desk
(51, 34, 1,  1, 1299.99), -- order 34: Laptop Pro
(52, 34, 9,  1,   79.99), -- order 34: Smart Speaker
(53, 36, 13, 1,  159.99), -- order 36: Mechanical Keyboard
(54, 36, 2,  2,   89.99), -- order 36: 2× Wireless Keyboard
(55, 38, 1,  1, 1299.99), -- order 38: Laptop Pro
(56, 38, 3,  1,   49.99), -- order 38: USB-C Hub
(57, 41, 9,  1,   79.99), -- order 41: Smart Speaker
(58, 41, 10, 1,  149.99), -- order 41: Coffee Maker
(59, 43, 13, 1,  159.99), -- order 43: Mechanical Keyboard
(60, 43, 2,  2,   89.99), -- order 43: 2× Wireless Keyboard
(61, 44, 1,  1, 1299.99), -- order 44: Laptop Pro
(62, 44, 11, 1,  449.99), -- order 44: Standing Desk
-- Three-item orders
(63, 23, 3,  1,   49.99), -- order 23: USB-C Hub (CANCELLED)
(64, 24, 2,  1,   89.99), -- order 24: Keyboard (PROCESSING)
(65, 24, 14, 2,   59.99), -- order 24: 2× Desk Lamp
(66, 28, 6,  1,   39.99), -- order 28: SQL Book (PENDING)
(67, 33, 3,  2,   49.99), -- order 33: 2× USB-C Hub (PROCESSING)
(68, 35, 4,  1,  129.99), -- order 35: Running Shoes (CANCELLED)
(69, 39, 7,  3,   44.99), -- order 39: 3× Python Cookbook
(70, 39, 8,  2,   54.99), -- order 39: 2× Data Science Book
(71, 40, 2,  1,   89.99), -- order 40: Keyboard (PENDING)
(72, 42, 1,  1, 1299.99), -- order 42: Laptop Pro (RETURNED)
(73, 45, 6,  1,   39.99), -- order 45: SQL Book (PROCESSING)
-- Orders without payments (46-49)
(74, 46, 9,  2,   79.99), -- order 46: 2× Smart Speaker (no payment)
(75, 47, 2,  1,   89.99), -- order 47: Keyboard (no payment)
(76, 47, 14, 2,   59.99), -- order 47: 2× Desk Lamp
(77, 48, 7,  1,   44.99), -- order 48: Python Cookbook (no payment)
(78, 49, 1,  1, 1299.99), -- order 49: Laptop Pro (no payment)
(79, 37, 6,  2,   39.99), -- order 37: 2× SQL Book
(80, 19, 2,  2,   89.99); -- order 19: 2× Keyboard

-- ── payments ─────────────────────────────────────────────────
-- Orders 46-49 have NO payment record (data quality issue)
INSERT INTO payments (id, order_id, amount, payment_method, paid_at, status) VALUES
(1,  1,  1299.99, 'credit_card',    '2023-02-10 09:20:00', 'completed'),
(2,  2,   155.96, 'paypal',         '2023-07-22 11:10:00', 'completed'), -- 2×book + cookbook, 10% off
(3,  3,    79.99, 'credit_card',    '2023-03-05 14:30:00', 'completed'),
(4,  4,   124.98, 'paypal',         '2023-09-15 08:35:00', 'refunded'),  -- cancelled order
(5,  5,   293.97, 'credit_card',    '2023-04-01 17:00:00', 'completed'),
(6,  6,    99.98, 'bank_transfer',  '2024-01-20 10:15:00', 'completed'),
(7,  7,   449.99, 'credit_card',    '2023-02-28 12:10:00', 'completed'),
(8,  8,   234.98, 'paypal',         '2023-11-15 14:10:00', 'refunded'),  -- returned order
(9,  9,    54.99, 'credit_card',    '2023-05-10 09:10:00', 'completed'),
(10, 10,   89.98, 'paypal',         '2024-03-01 11:40:00', 'pending'),
(11, 11,   39.99, 'cash',           '2023-06-15 08:10:00', 'completed'),
(12, 12,  149.98, 'credit_card',    '2024-04-10 14:10:00', 'pending'),
(13, 13, 1389.98, 'credit_card',    '2023-07-01 10:10:00', 'completed'),
(14, 14,  269.97, 'bank_transfer',  '2023-12-20 15:10:00', 'completed'),
(15, 15, 1399.97, 'credit_card',    '2024-01-05 09:40:00', 'completed'),
(16, 16,  329.98, 'paypal',         '2023-08-20 11:10:00', 'completed'),
(17, 17,   94.98, 'credit_card',    '2023-09-05 13:10:00', 'refunded'),  -- cancelled
(18, 18,   79.99, 'paypal',         '2024-02-14 10:10:00', 'completed'),
(19, 19,  339.97, 'credit_card',    '2023-10-01 08:10:00', 'completed'),
(20, 20,  239.97, 'bank_transfer',  '2024-04-05 12:10:00', 'completed'),
(21, 21,  134.97, 'credit_card',    '2023-11-01 09:10:00', 'completed'),
(22, 22,  199.97, 'paypal',         '2024-05-20 11:10:00', 'completed'),
(23, 23,   49.99, 'credit_card',    '2023-12-10 14:10:00', 'refunded'),  -- cancelled
(24, 24,  209.97, 'bank_transfer',  '2024-06-01 10:10:00', 'pending'),
(25, 25,  149.99, 'credit_card',    '2024-01-15 09:10:00', 'completed'),
(26, 26,  209.98, 'paypal',         '2024-06-10 11:10:00', 'completed'),
(27, 27,  234.98, 'credit_card',    '2024-02-20 12:10:00', 'refunded'),  -- returned
(28, 28,   39.99, 'cash',           '2024-07-15 09:10:00', 'pending'),
(29, 29,   79.99, 'credit_card',    '2024-03-05 10:10:00', 'completed'),
(30, 30,   99.98, 'paypal',         '2024-08-10 12:10:00', 'completed'),
(31, 31, 1389.98, 'credit_card',    '2024-04-01 08:40:00', 'completed'),
(32, 32,  599.98, 'bank_transfer',  '2024-09-05 10:10:00', 'completed'),
(33, 33,   99.98, 'credit_card',    '2024-04-20 11:10:00', 'failed'),
(34, 34, 1379.98, 'paypal',         '2024-10-01 09:10:00', 'completed'),
(35, 35,  129.99, 'credit_card',    '2024-05-10 13:10:00', 'refunded'),  -- cancelled
(36, 36,  339.97, 'bank_transfer',  '2024-10-15 10:10:00', 'completed'),
(37, 37,  529.97, 'credit_card',    '2024-06-01 09:10:00', 'completed'),
(38, 38, 1349.98, 'paypal',         '2024-11-10 11:10:00', 'completed'),
(39, 39,  244.95, 'credit_card',    '2024-07-15 10:10:00', 'completed'),
(40, 40,   89.99, 'bank_transfer',  '2024-12-01 09:10:00', 'pending'),
(41, 41,  229.98, 'credit_card',    '2024-03-15 10:10:00', 'completed'),
(42, 42, 1299.99, 'paypal',         '2024-05-01 11:10:00', 'refunded'),  -- returned
(43, 43,  339.97, 'credit_card',    '2024-08-20 09:10:00', 'completed'),
(44, 44, 1749.98, 'bank_transfer',  '2024-09-25 10:10:00', 'completed'),
(45, 45,   39.99, 'credit_card',    '2024-12-15 11:10:00', 'pending');
-- Orders 46, 47, 48, 49 have NO payment rows — find them in Module 2!
