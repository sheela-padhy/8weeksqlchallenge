Part A - Pizza Metrics 

use pizza_runner;

# How many pizzas were ordered?
select count(order_id) as total_order from customer_orders;

# How many unique customer orders were made?
select count(distinct(customer_id)) as customers from customer_orders;

# Display no.of orders by each customers.
select customer_id,count(customer_id) as customers from customer_orders group by customer_id;

# Display count of unique orders by eacg customer
select customer_id,count(distinct(order_id)) as orders from customer_orders group by customer_id;

# How many successful orders were delivered by each runner?
select runner_id ,count(*) as successful_orders from runner_orders where cancellation is  NULL group by runner_id; 

# How many of each type of pizza was delivered?
select pizza_name ,count(*) as no_of_orders from customer_orders  as c inner join pizza_names as p on c.pizza_id =p.pizza_id group by pizza_name ;


# How many Vegetarian and Meatlovers were ordered by each customer?
select  customer_id,pizza_name,count(pizza_name) as no_of_orders from pizza_names as p inner join customer_orders as c on p.pizza_id=c.pizza_id group by customer_id,pizza_name;

# What was the maximum number of pizzas delivered in a single order?
select order_id ,count(*)as no_of_orders  from customer_orders group by order_id order by  no_of_orders desc limit 1;

# For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select count(*) from (select order_id from customer_orders where exclusions is null and extras is null union 
select order_id from customer_orders where exclusions >=1 and extras>=1)f ;

# CTE WITH CLAUSE
with piz_cte as (select order_id from customer_orders where exclusions is null and extras is null union 
select order_id from customer_orders where exclusions >=1 and extras>=1)
select count(*) from piz_cte ;


# How many pizzas were delivered that had both exclusions and extras?
select count(*) from customer_orders where exclusions  is not NULL and extras is not NULL;

# What was the total volume of pizzas ordered for each hour of the day?(busiest hour of the day)
select hour(order_time),count(*) from customer_orders group by hour(order_time);

# What was the volume of orders for each day of the week?(busiest day of the week)
select dayname(order_time) as name ,count(*)from customer_orders group by dayname(order_time);


#PART 2 - Runner and Customer Experience

# How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select count(runner_id )as no_of_runners ,week(registration_date) as week_num from runners group by week_num;


# What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
    runner_id, AVG(difference_minutes)
FROM
    (SELECT 
        runner_id,
            TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS difference_minutes
    FROM
        customer_orders AS c
    INNER JOIN runner_orders AS r ON c.order_id = r.order_id) f
GROUP BY runner_id;


# Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT 
    count_of_order, AVG(difference_minutes)
FROM
    (SELECT 
        c.order_id,
            COUNT(c.order_id) AS count_of_order,
            TIMESTAMPDIFF(MINUTE, order_time, pickup_time) AS difference_minutes
    FROM
        customer_orders AS c
    INNER JOIN runner_orders AS r ON c.order_id = r.order_id
    GROUP BY order_id) f
GROUP BY count_of_order;


# What was the average distance travelled for each customer?
select customer_id,round(avg(distance),2) from customer_orders as c inner join runner_orders as r on c.order_id=r.order_id group by customer_id;


# What was the difference between the longest and shortest delivery times for all orders?
select (max(duration)-min(duration)) as difference  from runner_orders where duration != 'null' ;


# What was the average speed for each runner for each delivery and do you notice any trend for these values?
# speed=distance /time....
select runner_id , order_id ,avg(distance/ (duration/60)) as speed from runner_orders group by runner_id ,order_id;


# What is the successful delivery percentage for each runner?
select runner_id, ((select count(order_id) from runner_orders where cancellation is null)/ (select count(order_id) from runner_orders))* 100 as percentage from runner_orders where runner_id=3 group by runner_id;
