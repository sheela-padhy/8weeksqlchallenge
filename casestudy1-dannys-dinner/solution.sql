use dannys_diner;
SELECT 
    *
FROM
    members;
SELECT 
    *
FROM
    menu;
SELECT 
    *
FROM
    sales;
SELECT 
    customer_id, SUM(price) AS Amount_spent
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY customer_id;

SELECT 
    customer_id, (COUNT(DISTINCT (order_date))) AS No_of_days
FROM
    sales
GROUP BY customer_id;

# What was the first item from the menu purchased by each customer?
select customer_id from (select customer_id,product_id ,dense_rank() over(partition by customer_id order by order_date) as r from sales)c where r=1 ;

select distinct customer_id,product_name from (select  customer_id,product_name from (select customer_id ,product_name ,dense_rank() over(partition by customer_id order by order_date) as r from sales as s inner join menu as m on s.product_id=m.product_id )c where r=1 )v;


SELECT 
    product_name, COUNT(product_name) AS No_of_times_purchased
FROM
    menu AS m
        INNER JOIN
    sales AS s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY No_of_times_purchased DESC
LIMIT 1;

# Which item was the most popular for each customer?
 select customer_id,product_name , No_of_times_purchased from (select customer_id, product_name,count(s.product_id) as No_of_times_purchased,dense_rank() over(partition by customer_id order by count(s.product_id ) desc )  as  m from sales as s inner join menu as m on s.product_id=m.product_id group by customer_id,product_name)k where m=1;
 
 
SELECT 
    s.customer_id, product_name
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
        INNER JOIN
    members AS mb ON mb.customer_id = s.customer_id
WHERE
    order_date > join_date
GROUP BY customer_id
ORDER BY order_date , customer_id;

SELECT 
    s.customer_id, product_name
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
        INNER JOIN
    members AS mb ON mb.customer_id = s.customer_id
WHERE
    order_date < join_date
GROUP BY customer_id
ORDER BY order_date , customer_id;

SELECT 
    s.customer_id,
    COUNT(s.product_id) AS No_of_items,
    SUM(price) AS Amount_spent
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
        INNER JOIN
    members AS mb ON mb.customer_id = s.customer_id
WHERE
    order_date < join_date
GROUP BY customer_id
ORDER BY customer_id;


SELECT 
    customer_id, SUM(price) AS Amount_spent
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY customer_id;
SELECT 
    customer_id, COUNT(DISTINCT (order_date)) AS no_of_days
FROM
    sales
GROUP BY customer_id;


# What was the first item from the menu purchased by each customer?
select distinct customer_id,product_name from (select customer_id,product_name from (select customer_id,product_name ,dense_rank() over(partition by customer_id order by order_date) as r  from  
sales  as s inner join menu as m on s.product_id=m.product_id )s where r =1)v;
SELECT 
    product_name, COUNT(product_name) AS no_of_times
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY no_of_times DESC
LIMIT 1;


# Which item was the most popular for each customer?
select customer_id,product_name ,no_of_times_purchased from (select customer_id,product_name,count(s.product_id) as no_of_times_purchased,dense_rank() over(partition by customer_id 
order by count(s.product_id) desc ) as r from sales as s inner join menu as m on s.product_id=m.product_id group by customer_id,product_name)v where r=1;

select customer_id,product_name , No_of_times_purchased from (select customer_id, product_name,count(s.product_id) as No_of_times_purchased,dense_rank() 
over(partition by customer_id order by count(s.product_id ) desc )  as  m from sales as s inner join menu as m on s.product_id=m.product_id
 group by customer_id,product_name)k where m=1;



SELECT 
    s.customer_id, product_name
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
        INNER JOIN
    members AS mb ON mb.customer_id = s.customer_id
WHERE
    order_date > join_date
GROUP BY customer_id , product_name
ORDER BY customer_id;


SELECT 
    s.customer_id, product_name
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
        INNER JOIN
    members AS mb ON mb.customer_id = s.customer_id
WHERE
    join_date > order_date
GROUP BY customer_id , product_name
ORDER BY customer_id;

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

