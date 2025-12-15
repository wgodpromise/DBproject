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