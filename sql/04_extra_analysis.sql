-- Extra analysis (added on top of the three dashboard queries)
USE crust_metrics;

-- Revenue by menu category
SELECT m.item_category, SUM(o.quantity * m.item_price) AS revenue
FROM orders o JOIN menu_items m ON m.item_id = o.item_id
GROUP BY m.item_category
ORDER BY revenue DESC;

-- Ten best-selling items by revenue
SELECT m.item_name, SUM(o.quantity) AS units, SUM(o.quantity * m.item_price) AS revenue
FROM orders o JOIN menu_items m ON m.item_id = o.item_id
GROUP BY m.item_name
ORDER BY revenue DESC
LIMIT 10;

-- Delivery versus pick-up: orders and average order value
SELECT t.delivery, COUNT(*) AS orders, ROUND(AVG(t.order_value), 2) AS avg_order_value
FROM (
    SELECT o.order_id, o.delivery, SUM(o.quantity * m.item_price) AS order_value
    FROM orders o JOIN menu_items m ON m.item_id = o.item_id
    GROUP BY o.order_id, o.delivery
) t
GROUP BY t.delivery;

-- Revenue by hour of day (MySQL: HOUR(); SQLite: strftime('%H', created_at))
SELECT HOUR(o.created_at) AS hour_of_day, SUM(o.quantity * m.item_price) AS revenue
FROM orders o JOIN menu_items m ON m.item_id = o.item_id
GROUP BY HOUR(o.created_at)
ORDER BY hour_of_day;

-- Gross margin per item: price minus ingredient cost
SELECT m.item_name, m.item_price,
       ROUND(SUM(r.quantity * ing.ing_price / ing.ing_weight), 2)                AS ingredient_cost,
       ROUND(m.item_price - SUM(r.quantity * ing.ing_price / ing.ing_weight), 2) AS margin
FROM menu_items m
JOIN recipes r       ON r.recipe_id = m.item_sku
JOIN ingredients ing ON ing.ing_id  = r.ing_id
GROUP BY m.item_name, m.item_price
ORDER BY margin DESC;
