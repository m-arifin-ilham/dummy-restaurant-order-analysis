-- Note: The following is not based on real world and only fictional.
-- The Situation: 	I've just been hired as a Data Analyst for the Taste of the World Cafe, 
-- 					a restaurant that has diverse menu offerings and serves generous portions
-- The Assignment: 	The Taste of the World Cafe debuted a new menu at the start of the year. 
-- 					I've been asked to dig into the customer data to see which menu items are 
-- 					doing well/not well and what the top customers seem to like best
USE restaurant_db;

-- First Objective: better understand the items table by finding the number of rows in the table, the least and most expensive items, and the item prices within each category.
-- a. View the menu_items table and write a query to find the number of items on the menu
SELECT * FROM menu_items;

SELECT COUNT(*) FROM menu_items;
-- There are 32 items on the menu

-- b. What are the least and most expensive items on the menu?
SELECT * FROM menu_items
ORDER BY price;

SELECT * FROM menu_items
ORDER BY price DESC;
-- The least and most expensive items on the menu, respectively, are Edamame and Shrimp Scampi

-- c. How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT COUNT(*) 
FROM menu_items
WHERE category = 'Italian';

SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price;

SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC;
-- There are 9 Italian dishes on the menu, with the least and most expensive, respectively, are Spaghetti and Fettuccine Alfredo, and Shrimp Scampi

-- d. How many dishes are in each category? What is the average dish price within each category?
SELECT category, COUNT(menu_item_id) AS num_dishes, AVG(price) AS avg_price
FROM menu_items
GROUP BY category;
-- There are 6 American, 8 Asian, 9 Mexican and 9 Italian dishes on the menu, with average price for each category are USD 10.07, 13.48, 11.80 and 16.75


-- Second Objective: better understand the orders table by finding the date range, the number of items within each order, and the orders with the highest number of items.
-- a. View the order_details table. What is the date range of the table?
SELECT * FROM order_details;

SELECT MIN(order_date), MAX(order_date) FROM order_details;
-- The order_details ranges from 2023-01-01 to 2023-03-31

-- b. How many orders were made within this date range? How many items were ordered within this date range?
SELECT
	COUNT(DISTINCT order_id) AS num_orders,
    COUNT(item_id) AS num_items_ordered,
    COUNT(*) AS num_rows
FROM order_details;
-- There are 5370 orders and 12097 ordered items, but there are 12097 records. This means that there are records (137 records) of order_details without any ordered items

-- c. Which orders had the most number of items?
SELECT
	order_id,
    COUNT(item_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC;
-- The orders with the most number of items, i.e. 14, are orders with the ids 1957, 2675, 330, 440, 443, 3473 and 4305

-- d. How many orders had more than 12 items?
SELECT COUNT(*) FROM
(SELECT
	order_id,
    COUNT(item_id) AS num_items
FROM order_details
GROUP BY order_id
HAVING num_items > 12) AS num_orders;
-- There are 20 orders which had its number of items more than 12, which are the orders with the ids 330, 440, 443, 1957, 2675, 3473, 4305, 1274, 1569, 1685, 1734, 2075, 2126, 2188, 2725, 3583, 4482, 4836, 5066 and 5200


-- Final Objective: combine the items and orders tables, find the least and most ordered categories, and dive into the details of the highest spend orders.
-- a. Combine the menu_items and order_details tables into a single table
SELECT *
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id;

-- b. What were the least and most ordered items? What categories were they in?
SELECT 
	mi.item_name,
    mi.category,
    COUNT(od.order_details_id) AS num_purchases
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id
GROUP BY mi.item_name, mi.category
ORDER BY num_purchases;
-- It seems that least ordered items were usually Mexican

SELECT 
	mi.item_name,
    mi.category,
    COUNT(od.order_details_id) AS num_purchases
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id
GROUP BY mi.item_name, mi.category
ORDER BY num_purchases DESC;
-- It seems that least ordered items were usually American and Asian.
-- The least and most ordered items, respectively, were Chicken Tacos (which was ordered for 123 items) and Hamburger (which was ordered for 622 items), which are Mexican and American dish

-- c. What were the top 5 orders that spent the most money?
SELECT
	od.order_id,
    SUM(mi.price) AS total_spend
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id
GROUP BY od.order_id
ORDER BY total_spend DESC
LIMIT 5;
-- The top 5 orders that spent the most money were orders with ids 440 which spent USD 192.15, 2075 which spent USD 191.05, 1957  which spent USD 190.10, 330 which spent USD 189.70 and 2675 which spent USD 185.10

-- d. View the details of the highest spend order. What insights can be gathered from the results?
SELECT
	mi.category,
    COUNT(od.item_id) AS num_items
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id
WHERE od.order_id = 440
GROUP BY mi.category;
-- The highest spend order purchased a lot of Italian foods, 
-- which is interesting since Italian foods weren't the most popular items on the menu 

-- BONUS: View the details of the top 5 highest spend orders. What insights can be gathered from the results?
SELECT
	mi.category,
    COUNT(od.item_id) AS num_items
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id
WHERE od.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY mi.category;
-- From here, the top 5 highest spend orders are ordering more Italian foods than the other type of foods

SELECT
	od.order_id,
    mi.category,
    COUNT(od.item_id) AS num_items
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id = mi.menu_item_id
WHERE od.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY od.order_id, mi.category;

-- From here, we can see that
-- in order_id 330, the majority of items are Asian and Mexican foods, 
-- in order_id 440, the majority of items are Italian foods,
-- order_id 1957 ordered a mix of foods, with Italian foods being the relative majority, 
-- order_id 2075 ordered a lot of Italian foods, 
-- order_id 2675 ordered a mix of foods, with Italian and Mexican foods being ordered a bit more

-- From those top 5 highest spend orders, we've seen that 
-- those highest spend orders tend to be spending a lot of Italian foods.

-- Insight:
-- 1. 	The most ordered items on the menu were American and Asian;
-- 		therefore we should keep those
-- 2. 	We should keep these relatively expensive Italian foods on the menu, 
--   	since people seem to be ordering them a lot, especially our 5 highest spend customers
-- 3. 	We may need to do something about Mexican foods, 
-- 		since these made up the least ordered items

/*
SELECT 
	*, 
    CASE
		WHEN order_details.order_id = 440 THEN "1"
        WHEN order_details.order_id = 2075 THEN "2"
        WHEN order_details.order_id = 1957 THEN "3"
        WHEN order_details.order_id = 330 THEN "4"
        WHEN order_details.order_id = 2675 THEN "5"
        ELSE "catchall"
	END AS spending_ranking
FROM order_details
	LEFT JOIN menu_items
		ON order_details.item_id = menu_items.menu_item_id
WHERE order_details.order_id IN (440, 2075, 1957, 330, 2675)
ORDER BY spending_ranking, order_details.item_id;

-- Analysis: the amount of food items ordered in those 5 highest spend orders
SELECT
	order_details.item_id AS food_id,
    menu_items.item_name AS food_name,
    COUNT(order_details.order_details_id) AS counts
FROM order_details
	LEFT JOIN menu_items
		ON order_details.item_id = menu_items.menu_item_id
WHERE order_details.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY food_id
ORDER BY counts DESC;
*/