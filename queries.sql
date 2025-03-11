#Project(Pizza)

create database pizza;
use pizza;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id VARCHAR(100) NOT NULL,
    quantity INT NOT NULL
);

#Tables are order_details, orders, pizza_types and pizzas

#Solved 3 categories of problems i.e. Basic, Intermediate and Advanced

#Category 1 - Basic

#1 - Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

#2 - Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
#3 - Identify the highest-priced pizza
SELECT 
    name AS highest_priced_pizza
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

#4 - Identify the most common pizza size ordered
SELECT 
    size AS 'Most Common Pizza Size'
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY SUM(quantity) DESC
LIMIT 1;

#5 - List the top 5 most ordered pizza types along with their quantities
SELECT 
    pizza_type_id AS 'Most common pizza type',
    SUM(quantity) AS 'Quantity'
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type_id
ORDER BY SUM(quantity) DESC
LIMIT 5;

#Category 2 - Intermediate

#1 - Join the necessary tables to find the total quantity of each pizza category ordered
SELECT 
    category, SUM(quantity) AS 'Quantity'
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY category;

#2 - Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS Hour_of_Day,
    COUNT(order_id) AS 'Number of Orders'
FROM
    orders
GROUP BY Hour_of_Day
ORDER BY Hour_of_Day;

#3 - Join relevant tables to find the category-wise distribution of pizzas
SELECT 
    category, COUNT(pizza_type_id) AS 'Number of Pizzas'
FROM
    pizza_types
GROUP BY category;

#4 - Group the orders by date and calculate the average number of pizzas ordered per day

#Grouping orders by date
SELECT 
    order_date AS Date,
    COUNT(orders.order_id) AS 'Orders per Day'
FROM
    orders
        JOIN
    (SELECT 
        order_id, SUM(quantity) AS quantity
    FROM
        order_details
    GROUP BY order_id) AS temp ON orders.order_id = temp.order_id
GROUP BY order_date;

#Calculating average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantitysum)) AS 'Average pizza orders per day'
FROM
    (SELECT 
        order_date AS Date,
            COUNT(orders.order_id) AS 'Orders per Day',
            SUM(quantity) AS quantitysum
    FROM
        orders
    JOIN (SELECT 
        order_id, SUM(quantity) AS quantity
    FROM
        order_details
    GROUP BY order_id) AS temp ON orders.order_id = temp.order_id
    GROUP BY order_date) AS temp1;

#5 - Determine the top 3 most ordered pizza types based on revenue    
SELECT 
    pizza_type_id AS 'Pizza Type', SUM(pricing) AS Revenue
FROM
    pizzas
        JOIN
    (SELECT 
        pizzas.pizza_id, SUM(quantity * price) AS pricing
    FROM
        pizzas
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_id) AS temp ON pizzas.pizza_id = temp.pizza_id
GROUP BY pizza_type_id
ORDER BY Revenue DESC
LIMIT 3;

#Category 3 - Advanced

#1 - Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_type_id AS 'Pizza Type',
    ROUND(pizzarevenue * 100 / (SELECT 
                    ROUND(SUM(quantity * price), 2) AS total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id),
            2) AS Percentage_Revenue
FROM
    (SELECT 
        pizza_type_id, SUM(pricing) AS pizzarevenue
    FROM
        pizzas
    JOIN (SELECT 
        pizzas.pizza_id, SUM(quantity * price) AS pricing
    FROM
        pizzas
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_id) AS temp ON pizzas.pizza_id = temp.pizza_id
    GROUP BY pizza_type_id) AS temp2;
    
#2 - Analyze the cumulative revenue generated over time
select order_date, round(sum(Revenue) over (order by order_date),2) 
as Cumulative_Revenue from (select order_date, sum(price*quantity) 
as Revenue from orders join order_details 
on orders.order_id=order_details.order_id join pizzas 
on order_details.pizza_id=pizzas.pizza_id group by order_date) as temp3;
#This query couldn't be beautified due to it's complexity

#3 - Determine the top 3 most ordered pizza types based on revenue for each pizza category
select Ranks, category, pizza_type_id, revenue from 
(select rank() over (partition by category order by sum(price*quantity) desc) 
as Ranks, category, pizzas.pizza_type_id, sum(price*quantity) as revenue 
from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id 
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id 
group by pizza_type_id, category order by revenue desc) as temp4 
where Ranks <4 order by category;
#This query also couldn't be beautified due to it's complexity

#END