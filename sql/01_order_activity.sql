-- Dashboard 1: order activity
-- One flat row per order line, joined to menu and delivery address. Feeds the Looker Studio page.
USE crust_metrics;

SELECT
    o.order_id,
    m.item_price,
    o.quantity,
    m.item_category,
    m.item_name,
    o.created_at,
    o.created_date,
    a.delivery_address1,
    a.delivery_address2,
    a.delivery_city,
    a.delivery_zipcode,
    o.delivery
FROM orders o
LEFT JOIN menu_items m ON o.item_id = m.item_id
LEFT JOIN addresses  a ON o.add_id  = a.address_id;
