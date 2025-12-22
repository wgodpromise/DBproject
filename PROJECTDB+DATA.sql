CREATE TABLE Users (
    userid SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    balance NUMERIC(10, 2),
    reg_date DATE,
    email VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Lot (
    lot_id SERIAL PRIMARY KEY,
    lot_name VARCHAR(50) NOT NULL,
    lot_description TEXT NOT NULL,
    is_available BOOLEAN,
    userid INT NOT NULL,
    product_id INT,
    cost NUMERIC(10, 2),
    amount_products SMALLINT,
    FOREIGN KEY (userid) REFERENCES Users (userid),
    FOREIGN KEY (product_id) REFERENCES Products (product_id)
    
);

CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category (category_id)
);

CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE Supports (
    support_id SERIAL PRIMARY KEY,
    support_nickname VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(50) NOT NULL UNIQUE,
    reg_date DATE
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    userid INT,
    lot_id INT,
    order_date DATE,
    FOREIGN KEY (userid) REFERENCES Users (userid),
    FOREIGN KEY (lot_id) REFERENCES Lot (lot_id)
);

CREATE TABLE Support_Orders (
    support_id INT NOT NULL,
    order_id INT NOT NULL,
    FOREIGN KEY (support_id) REFERENCES Supports (support_id),
    FOREIGN KEY (order_id) REFERENCES Orders (order_id)
);

CREATE TABLE Rate (
    rate_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    review TEXT,
    star SMALLINT CHECK (star BETWEEN 1 AND 5) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders (order_id)
);

ALTER TABLE orders ADD COLUMN star SMALLINT;

ALTER TABLE orders DROP COLUMN STAR;

ALTER TABLE orders ADD COLUMN rate int;

ALTER TABLE orders DROP COLUMN rate;

ALTER Table orders ADD COLUMN rate_id INT;

ALTER TABLE Orders
ADD CONSTRAINT orders_rate FOREIGN KEY (rate_id) REFERENCES Rate (rate_id);

-- Код для наполнения таблиц фейковыми данными 

INSERT INTO Category (category_name) VALUES
('Game Keys'),
('In-game Skins'),
('In-game Currency'),
('DLC & Add-ons'),
('Game Accounts'),
('Battle Passes'),
('Boosting Services');

INSERT INTO Products (category_id)
SELECT (random() * 6 + 1)::int
FROM generate_series(1, 30);

INSERT INTO Users (username, balance, reg_date, email)
SELECT
    'user_' || i,
    round((random() * 1500 + 20)::numeric, 2),
    CURRENT_DATE - (random() * 800)::int,
    'user_' || i || '@gamemarket.com'
FROM generate_series(1, 50) i;

INSERT INTO Supports (support_nickname, email, reg_date)
SELECT
    'support_' || i,
    'support_' || i || '@support.com',
    CURRENT_DATE - (random() * 600)::int
FROM generate_series(1, 10) i;

INSERT INTO Lot (
    lot_name,
    lot_description,
    is_available,
    userid,
    product_id,
    cost,
    amount_products
)
SELECT
    CASE p.category_id
        WHEN 1 THEN 'Game Key: ' || (ARRAY['Elden Ring','GTA V','Cyberpunk 2077','Minecraft'])[ceil(random()*4)]
        WHEN 2 THEN 'Skin ' || (ARRAY['AK-47','AWP','M4A1-S','Dragon Lore'])[ceil(random()*4)]
        WHEN 3 THEN (ARRAY['V-Bucks','RP','WoW Gold','GTA$'])[ceil(random()*4)] || ' Pack'
        WHEN 4 THEN 'DLC: ' || (ARRAY['Expansion Pack','Bonus Missions','New Characters'])[ceil(random()*3)]
        WHEN 5 THEN 'Game Account (' || (ARRAY['CS2','WoW','Valorant'])[ceil(random()*3)] || ')'
        WHEN 6 THEN (ARRAY['Battle Pass','Season Pass'])[ceil(random()*2)]
        WHEN 7 THEN 'Rank Boosting Service'
    END,

    CASE p.category_id
        WHEN 1 THEN 'Official activation key. Instant delivery.'
        WHEN 2 THEN 'Tradable cosmetic item from trusted seller.'
        WHEN 3 THEN 'In-game currency for purchases and upgrades.'
        WHEN 4 THEN 'Adds new content to the base game.'
        WHEN 5 THEN 'Verified account. Safe transfer.'
        WHEN 6 THEN 'Unlocks seasonal rewards.'
        WHEN 7 THEN 'Safe and professional boosting service.'
    END,

    random() > 0.15,

    (random() * 49 + 1)::int,
    p.product_id,

    CASE p.category_id
        WHEN 1 THEN round((random()*50 + 10)::numeric,2)
        WHEN 2 THEN round((random()*300 + 5)::numeric,2)
        WHEN 3 THEN round((random()*120 + 5)::numeric,2)
        WHEN 4 THEN round((random()*70 + 10)::numeric,2)
        WHEN 5 THEN round((random()*250 + 50)::numeric,2)
        WHEN 6 THEN round((random()*40 + 10)::numeric,2)
        WHEN 7 THEN round((random()*200 + 30)::numeric,2)
    END,

    (random() * 40 + 1)::int
FROM Products p
JOIN generate_series(1, 2) g ON true;

INSERT INTO Orders (userid, lot_id, order_date)
SELECT
    (random() * 49 + 1)::int,
    (random() * (SELECT max(lot_id) FROM Lot))::int + 1,
    CURRENT_DATE - (random() * 120)::int
FROM generate_series(1, 40);

INSERT INTO Rate (order_id, review, star)
SELECT
    order_id,
    'Order completed successfully',
    (random() * 4 + 1)::int
FROM Orders;
UPDATE Orders o
SET rate_id = r.rate_id
FROM Rate r
WHERE o.order_id = r.order_id;

INSERT INTO Support_Orders (support_id, order_id)
SELECT
    (random() * 9 + 1)::int,
    order_id
FROM Orders;



--1 Сотрудник техподдержки с наибольшим кол-вом обрабатываемых заказов.

SELECT DISTINCT support_nickname, COUNT(so.support_id) AS orders_count FROM supports s
JOIN support_orders so ON so.support_id = s.support_id
JOIN orders o ON so.order_id = o.order_id
GROUP BY s.support_nickname
ORDER BY orders_count DESC
LIMIT 1;

--2 Топ 5 самых продаваемых товаров.

SELECT DISTINCT lot_name, count(l.lot_name) AS lot_count
FROM lot l
JOIN orders o ON l.lot_id = o.lot_id
GROUP BY l.lot_name
ORDER BY lot_count DESC
LIMIT 5;

--3 

SELECT sum(cost * amount_products) AS salary FROM lot l
JOIN orders o ON l.lot_id = o.lot_id
WHERE o.order_date BETWEEN '2025-09-01' AND '2025-12-31'


