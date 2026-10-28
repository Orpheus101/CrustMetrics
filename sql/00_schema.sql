-- CrustMetrics: relational schema (MySQL 8)
-- Ten tables covering sales, recipes/stock and staffing for a takeout + delivery pizza shop.

CREATE DATABASE IF NOT EXISTS crust_metrics;
USE crust_metrics;

CREATE TABLE customers (
    customer_id          INT          NOT NULL,
    customer_first_name  VARCHAR(50)  NOT NULL,
    customer_last_name   VARCHAR(50)  NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE addresses (
    address_id         INT          NOT NULL,
    delivery_address1  VARCHAR(200) NOT NULL,
    delivery_address2  VARCHAR(200) NULL,
    delivery_city      VARCHAR(50)  NOT NULL,
    delivery_zipcode   VARCHAR(20)  NOT NULL,
    PRIMARY KEY (address_id)
);

CREATE TABLE menu_items (
    item_id        VARCHAR(15)  NOT NULL,
    item_sku       VARCHAR(50)  NOT NULL UNIQUE,
    item_name      VARCHAR(50)  NOT NULL,
    item_category  VARCHAR(50)  NOT NULL,
    item_size      VARCHAR(20)  NOT NULL,
    item_price     DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (item_id)
);

CREATE TABLE ingredients (
    ing_id            VARCHAR(20)  NOT NULL,
    ing_name          VARCHAR(50)  NOT NULL,
    ing_weight        INT          NOT NULL,   -- pack size
    ing_measurements  VARCHAR(20)  NOT NULL,   -- unit of the pack size
    ing_price         DECIMAL(5,2) NOT NULL,   -- price per pack
    PRIMARY KEY (ing_id)
);

CREATE TABLE recipes (
    row_id     INT         NOT NULL,
    recipe_id  VARCHAR(50) NOT NULL,           -- matches menu_items.item_sku
    ing_id     VARCHAR(20) NOT NULL,
    quantity   INT         NOT NULL,           -- amount of ingredient per item
    PRIMARY KEY (row_id)
);

CREATE TABLE inventory (
    inv_id    INT         NOT NULL,
    item_id   VARCHAR(20) NOT NULL,            -- an ingredient id (ingredients.ing_id)
    quantity  INT         NOT NULL,            -- packs on hand
    PRIMARY KEY (inv_id)
);

CREATE TABLE orders (
    row_id        INT         NOT NULL,
    order_id      VARCHAR(10) NOT NULL,
    cust_id       INT         NOT NULL,
    created_date  DATE        NOT NULL,
    created_at    TIME        NOT NULL,
    item_id       VARCHAR(15) NOT NULL,
    quantity      INT         NOT NULL,
    delivery      BOOLEAN     NOT NULL,
    add_id        INT         NOT NULL,
    PRIMARY KEY (row_id)
);

CREATE TABLE staff (
    staff_id     VARCHAR(10)  NOT NULL,
    first_name   VARCHAR(30)  NOT NULL,
    last_name    VARCHAR(30)  NOT NULL,
    position     VARCHAR(20)  NOT NULL,
    hourly_rate  DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (staff_id)
);

CREATE TABLE shifts (
    shift_id         VARCHAR(10) NOT NULL,
    day_of_the_week  VARCHAR(10) NOT NULL,
    start_time       TIME        NOT NULL,
    end_time         TIME        NOT NULL,
    PRIMARY KEY (shift_id)
);

CREATE TABLE rotations (
    row_id    INT         NOT NULL,
    rota_id   VARCHAR(10) NOT NULL,
    `date`    DATETIME    NOT NULL,
    shift_id  VARCHAR(10) NOT NULL,
    staff_id  VARCHAR(10) NOT NULL,
    PRIMARY KEY (row_id)
);

-- Foreign keys (added after the data is loaded in most workflows; safe to apply up front too)
ALTER TABLE orders    ADD CONSTRAINT fk_orders_customer  FOREIGN KEY (cust_id)   REFERENCES customers (customer_id);
ALTER TABLE orders    ADD CONSTRAINT fk_orders_item      FOREIGN KEY (item_id)   REFERENCES menu_items (item_id);
ALTER TABLE orders    ADD CONSTRAINT fk_orders_address   FOREIGN KEY (add_id)    REFERENCES addresses (address_id);
ALTER TABLE recipes   ADD CONSTRAINT fk_recipes_item     FOREIGN KEY (recipe_id) REFERENCES menu_items (item_sku);
ALTER TABLE recipes   ADD CONSTRAINT fk_recipes_ing      FOREIGN KEY (ing_id)    REFERENCES ingredients (ing_id);
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_ing    FOREIGN KEY (item_id)   REFERENCES ingredients (ing_id);
ALTER TABLE rotations ADD CONSTRAINT fk_rotations_shift  FOREIGN KEY (shift_id)  REFERENCES shifts (shift_id);
ALTER TABLE rotations ADD CONSTRAINT fk_rotations_staff  FOREIGN KEY (staff_id)  REFERENCES staff (staff_id);
