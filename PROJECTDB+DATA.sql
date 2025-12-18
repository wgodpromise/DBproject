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


-- Жанры и типы
INSERT INTO Category (category_name) VALUES 
('Скины CS2'), ('Игровые ключи'), ('Внутриигровая валюта'), ('Аккаунты'), ('DLC');

-- Конкретные шаблоны продуктов
INSERT INTO Products (category_id) VALUES 
(1), (1), (1), -- Скины
(2), (2), (2), -- Ключи
(3), (3), (4); -- Валюта и Аккаунты

INSERT INTO Users (username, balance, reg_date, email)
SELECT 
    (ARRAY['ShadowStep', 'DragonSlayer', 'CyberPunk', 'NoobMaster', 'EliteGamer', 'SniperWolf', 'FrostByte', 'PixelLord'])[floor(random()*8)+1] || i, 
    (random() * 5000)::numeric(10,2), 
    CURRENT_DATE - (random() * 500 * INTERVAL '1 day'),
    'player_' || i || '@gaming.net'
FROM generate_series(1, 50) AS i;

INSERT INTO Lot (lot_name, lot_description, is_available, userid, product_id, amount_products)
SELECT 
    (ARRAY[
        'AK-47 | Огненный змей (FT)', 
        'Elden Ring: Shadow of the Erdtree (Global Key)', 
        'Нож-бабочка | Градиент (FN)', 
        '10 000 V-Bucks Card', 
        'Cyberpunk 2077 Ultimate Edition',
        'Перчатки спецназа | Кровавая паутина',
        'Minecraft Java + Bedrock Edition',
        '1000 Карт Таро (Phasmophobia)',
        'Battle Pass Season 12',
        'Личный аккаунт Steam (100+ игр)'
    ])[floor(random()*10)+1],
    'Моментальная доставка после оплаты. Гарантия чистоты сделки и поддержка 24/7.',
    (random() > 0.1), -- Большинство лотов в наличии
    (random() * 49 + 1)::int,
    (random() * 8 + 1)::int,
    (random() * 5 + 1)::int
FROM generate_series(1, 40) AS i;

-- Служба поддержки
INSERT INTO Supports (support_nickname, email, reg_date)
SELECT 
    'GameAdmin_' || i, 
    'support' || i || '@gamestore.io', 
    CURRENT_DATE - (i * INTERVAL '20 days')
FROM generate_series(1, 5) AS i;

-- Создаем 40 заказов
INSERT INTO Orders (userid, lot_id)
SELECT 
    (random() * 49 + 1)::int,
    (random() * 39 + 1)::int
FROM generate_series(1, 45) AS i;

-- Генерируем геймерские отзывы
INSERT INTO Rate (order_id, review, star)
SELECT 
    i, 
    (ARRAY[
        'Всё пришло быстро, продавец топ!', 
        'Скин с крутым флоатом, спасибо!', 
        'Ключ активировался без проблем.', 
        'Долго ждал ответа, но товар получил.', 
        'Лучший магазин скинов!'
    ])[floor(random()*5)+1], 
    (random() * 2 + 3)::int -- Оценки в основном 3, 4 и 5
FROM generate_series(1, 45) AS i;

-- Связываем заказы с отзывами
UPDATE Orders SET rate_id = order_id;

-- Некоторые спорные заказы отправляем в поддержку
INSERT INTO Support_Orders (support_id, order_id)
SELECT 
    (random() * 4 + 1)::int, 
    i
FROM generate_series(1, 15) AS i;