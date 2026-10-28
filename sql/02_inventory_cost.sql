-- Dashboard 2: ingredient usage, cost and stock remaining
USE crust_metrics;

-- Step 1: units sold per menu item
SELECT o.item_id, m.item_sku, m.item_name, SUM(o.quantity) AS units_sold
FROM orders o
LEFT JOIN menu_items m ON o.item_id = m.item_id
GROUP BY o.item_id, m.item_sku, m.item_name
ORDER BY o.item_id;

-- Step 2: ingredient usage and cost per menu item, saved as a view
CREATE OR REPLACE VIEW v_ingredient_usage AS
SELECT
    u.item_name,
    u.ing_id,
    u.ing_name,
    u.ing_weight,
    u.ing_price,
    u.units_sold,
    u.recipe_quantity,
    u.units_sold * u.recipe_quantity                          AS used_quantity,
    u.ing_price / u.ing_weight                                AS unit_cost,
    u.units_sold * u.recipe_quantity * (u.ing_price / u.ing_weight) AS ingredient_cost
FROM (
    SELECT
        m.item_name,
        r.ing_id,
        ing.ing_name,
        ing.ing_weight,
        ing.ing_price,
        r.quantity       AS recipe_quantity,
        SUM(o.quantity)  AS units_sold
    FROM orders o
    LEFT JOIN menu_items  m   ON o.item_id   = m.item_id
    LEFT JOIN recipes     r   ON m.item_sku  = r.recipe_id
    LEFT JOIN ingredients ing ON r.ing_id    = ing.ing_id
    GROUP BY m.item_name, r.ing_id, ing.ing_name, ing.ing_weight, ing.ing_price, r.quantity
) u;

-- Step 3: stock remaining per ingredient
SELECT
    s.ing_name,
    s.used_quantity,
    ing.ing_weight * inv.quantity                        AS stocked_quantity,
    ing.ing_weight * inv.quantity - s.used_quantity      AS remaining_quantity,
    ROUND(100 * (ing.ing_weight * inv.quantity - s.used_quantity)
              / (ing.ing_weight * inv.quantity), 2)      AS pct_remaining
FROM (
    SELECT ing_id, ing_name, SUM(used_quantity) AS used_quantity
    FROM v_ingredient_usage
    GROUP BY ing_id, ing_name
) s
LEFT JOIN inventory   inv ON inv.item_id = s.ing_id
LEFT JOIN ingredients ing ON ing.ing_id  = s.ing_id
ORDER BY pct_remaining;

-- Step 4: ingredient cost of one pizza (feeds the "cost of pizza" table)
SELECT
    m.item_name,
    SUM(r.quantity * ing.ing_price / ing.ing_weight) AS cost_per_item
FROM menu_items m
JOIN recipes     r   ON r.recipe_id = m.item_sku
JOIN ingredients ing ON ing.ing_id  = r.ing_id
GROUP BY m.item_name
ORDER BY cost_per_item DESC;
