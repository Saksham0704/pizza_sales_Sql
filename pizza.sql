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

