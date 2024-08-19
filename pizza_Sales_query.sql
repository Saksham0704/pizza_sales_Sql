-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT
ROUND(SUM(price*quantity),2) as total_revenue
FROM 
order_details JOIN pizzas 
ON
order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT pizzas.size, count(order_details.order_details_id) as order_count
FROM
pizzas JOIN order_details
ON
pizzas.pizza_id=order_details.pizza_id
group by pizzas.size
order by order_count desc
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, sum(order_details.quantity) as quantity

from pizza_types JOIN pizzas
ON
pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN order_details
ON
order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name 
order by quantity desc
limit 5;





-- Join the necessary tables to find the total quantity of each pizza category ordered.
-- Determine the distribution of orders by hour of the day.
-- Join relevant tables to find the category-wise distribution of pizzas.
-- Group the orders by date and calculate the average number of pizzas ordered per day.
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.category, sum(order_details.quantity) as quantity
FROM pizza_types JOIN pizzas
ON
pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity desc;


SELECT hour(order_time),count(order_id) from orders
group by hour(order_time);

SELECT category,count(name) from pizza_types
group by category;

SELECT round(avg(quantity),0) from 
(SELECT orders.order_date , count(order_details.quantity) as quantity
FROM orders JOIN order_details
ON orders.order_id=order_details.order_id
GROUP BY orders.order_date) as order_quantity;

SELECT pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
-- Analyze the cumulative revenue generated over time.
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select pizza_types.category,
round(sum(order_details.quantity*pizzas.price) / (SELECT sum(order_details.quantity * pizzas.price) FROM order_details JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id)*100,2) as revenue
from pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc;


SELECT order_date,sum(revenue) over(order by order_date) as cum_revenue FROM
(select orders.order_date,
sum(order_details.quantity*pizzas.price) as revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON order_details.order_id = orders.order_id
group by orders.order_date) as sales;


SELECT name, revenue
FROM
(select category, name,  revenue,
rank() over(partition by category order by revenue desc) as rn
from
(SELECT pizza_types.category,pizza_types.name,
round(sum((order_details.quantity) * pizzas.price),0) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
order_details
ON
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category , pizza_types.name) as a) as b
WHERE rn <= 3;