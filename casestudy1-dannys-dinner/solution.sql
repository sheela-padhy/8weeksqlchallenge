use dannys_diner;
select * from members;
select * from menu;
select * from sales;

# What is the total amount each customer spent at the restaurant?
   
SELECT 
    customer_id, SUM(price) AS total_amount_spent
FROM
    menu AS m
        INNER JOIN
    sales AS s ON m.product_id = s.product_id
GROUP BY customer_id;
# Each customer is asked in the question hence selected customer_id column and group by clause is applied to it so as to get different customer_id.
# Total amount spent is asked hence price column is selected and aggregate function sum() is applied to price column to get the total amount spent and the column is named as total_amount_spent.
# As customer_id and price columns were present in two different tables inner join is applied .

# How many days has each customer visited the restaurant?

SELECT 
    customer_id, COUNT(DISTINCT (order_date)) AS No_of_days
FROM
    sales
GROUP BY customer_id;
# Each customer is asked in the question hence selected customer_id column and group by clause is applied to it so as to get different customer_id.
# How many days are asked so count() function is applied to order_date.
# Distinct order date is calculated as customer  C has visited the store twice a day.


# What was the first item from the menu purchased by each customer?
   
select distinct(customer_id),product_name from(select customer_id,product_name from (select customer_id,s.product_id ,product_name, dense_rank() over(partition by customer_id order by order_date) as r 
from sales as s inner join menu as m on s.product_id=m.product_id )c where r=1)k;
 # First item purchased by each customer is asked ,first item denotes some kind of order or rank ,hence we can think of window function dense_rank().
 # Each customer is asked so partition by customer_id and order by order_date is done so as to give rank to the product_name and amongst them the product_name which has rank 1 was selected as it was first purchased by the customer.
 # once the output is ready we can select any column from the output table and alias name is given to each table.
 #Distinct customer_id was selected as customer C was repeating 2 times.
 
# What is the most purchased item on the menu and how many times was it purchased by all customers?
    
SELECT 
    product_name, COUNT(m.product_id) AS no_of_times_purchased
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY COUNT(m.product_id) DESC;
# Most purchased item has been asked hence count of product_id and order by(desc) product_id is done.
# Group by product_name will give the names of different products.



#  Which item was the most popular for each customer?
select customer_id,product_name , No_of_times_purchased from (select customer_id, product_name,count(s.product_id) as No_of_times_purchased,dense_rank() 
over(partition by customer_id order by count(s.product_id ) desc )  as  m from sales as s inner join menu as m on s.product_id=m.product_id
 group by customer_id,product_name)k where m=1;


# Which item was purchased first by the customer after they became a member?
   
SELECT 
    s.customer_id, product_name
FROM
    members AS m
        INNER JOIN
    sales AS s ON m.customer_id = s.customer_id
        INNER JOIN
    menu AS men ON s.product_id = men.product_id
WHERE
    order_date > join_date
GROUP BY product_name , customer_id
ORDER BY customer_id;
# The order_date should be greater than the joining date  to get the items puchased by the customer after they have became a member.



# Which item was purchased just before the customer became a member?
   
SELECT 
    s.customer_id, product_name
FROM
    members AS m
        INNER JOIN
    sales AS s ON m.customer_id = s.customer_id
        INNER JOIN
    menu AS men ON s.product_id = men.product_id
WHERE
    order_date < join_date
GROUP BY product_name , customer_id
ORDER BY customer_id;
# The order_date should be lesser than the joining date  to get the items puchased by the customer before they have became a member.



# What is the total items and amount spent for each member before they became a member?
   
SELECT 
    s.customer_id,
    COUNT(product_name) AS no_of_items,
    SUM(price) AS amount_spent
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
        INNER JOIN
    members AS mb ON mb.customer_id = s.customer_id
WHERE
    join_date > order_date
GROUP BY customer_id
ORDER BY customer_id;
# count of product name will guve total_items.
# sum of price will give amount spent .


# If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
   
SELECT 
    customer_id, product_name, SUM(points) AS total_points
FROM
    (SELECT 
        customer_id,
            product_name,
            CASE
                WHEN product_name = 'sushi' THEN 2 * (price) * 10
                ELSE 10 * (price)
            END AS points
    FROM
        menu AS m
    INNER JOIN sales AS s ON m.product_id = s.product_id) f
GROUP BY customer_id;
# Case when is used .



# In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
   
SELECT 
    customer_id, SUM(product_details) AS points
FROM
    (SELECT 
        s.customer_id,
            order_date,
            product_name,
            CASE
                WHEN order_date BETWEEN join_date AND ADDDATE(join_date, INTERVAL 7 DAY) THEN price * 2
                WHEN s.product_id = 1 THEN price
                ELSE 2 * (price)
            END AS product_details
    FROM
        menu AS m
    INNER JOIN sales AS s ON m.product_id = s.product_id
    INNER JOIN members AS mb ON mb.customer_id = s.customer_id) k
WHERE
    customer_id IN ('A' , 'B')
        AND order_date < '2021-01-31'
GROUP BY k.customer_id
ORDER BY k.customer_id;

