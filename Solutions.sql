USE pizza_sales;

#Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders FROM orders;

#Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
FROM order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id;

#Identify the highest-priced pizza.

SELECT pizza_types.name, pizzas.price
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

#Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

#List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category, SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

#Determine the distribution of orders by hour of the day.

SELECT HOUR(order_time) AS HOUR, COUNT(order_id) AS ORDERS FROM orders
GROUP BY HOUR(order_time);

#find the category-wise distribution of pizzas.

SELECT category, COUNT(NAME) FROM pizza_types
GROUP BY category;

#Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT AVG(quantity) AS Avg_orders FROM (SELECT orders.order_date, SUM(order_details.quantity) as quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS Order_perdate;

#Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY REVENUE DESC
LIMIT 3;

#Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category, ROUND(SUM(order_details.quantity * pizzas.price)  / 
(SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
FROM order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id) * 100,2) AS REVENUE
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY REVENUE DESC;


#Analyze the cumulative revenue generated over time.

SELECT order_date, SUM(REVENUE) OVER(ORDER BY order_date) AS CUM_REV FROM
(SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS REV;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,REVENUE FROM
(SELECT category, name, REVENUE,
RANK() OVER(PARTITION BY category ORDER BY REVENUE DESC) AS RN
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) AS REVENUE
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS A ) AS B
WHERE RN <= 3
