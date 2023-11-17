# A.High Level Sales Analysis
# What was the total quantity sold for all products?
select sum(qty) as total_quality_sold from sales;

# What is the total generated revenue for all products before discounts?
select sum(price*qty) as total_revenue from sales;

# What was the total discount amount for all products?
select round(sum((qty*price)*discount/100),2) as total_discount_amount from sales;


# B.Transaction Analysis
# How many unique transactions were there?
select count(distinct(txn_id)) as unique_transactions from sales;


# What is the average unique products purchased in each transaction?
with transactions_cte as (
select txn_id,count(distinct(prod_id)) as product_count from sales group by txn_id )
select round(avg(product_count)) as avg_uni_prod from transactions_cte;


# What is the average discount value per transaction?
with discount_cte as 
(select round(sum((qty*price)*discount/100),2) as total_discount_amount from sales group by txn_id)
select round(avg(total_discount_amount),2) as avg_discount from discount_cte;


# What is the percentage split of all transactions for members vs non-members?
with member_cte as 
(select member,round(count(member)/(select count(member) from sales)*100,2) as percentage from sales group by member)
select case when member=0 then 'member' else 'non-member' end as gender,percentage from member_cte;


# What is the average revenue for member transactions and non-member transactions?
select member,sum(qty*price) as revenue from sales group by member;


# C.Product Analysis
  
# What are the top 3 products by total revenue before discount?

with revenue_cte as 
(select product_name,sum(s.qty*s.price) as total_revenue from sales as s inner join product_details as d on s.prod_id=d.product_id group by product_name)
,rank_cte as 
(select product_name,rank() over(order by total_revenue) as revenue from revenue_cte)
select product_name,revenue from rank_cte where revenue <=3;

# What is the total quantity, revenue and discount for each segment?

select  p.segment_name,sum(qty) as total_Quantity,sum(s.qty*s.price) as total_revenue ,sum((s.qty*s.price*s.discount))/100 as discount from sales as s inner join product_details as 
p on p.product_id=s.prod_id group by p.segment_name  order by total_revenue desc ;


# What is the top selling product for each segment?

select product_name,segment_name from product_details;
with product_cte as 
(select segment_name ,product_name,rank() over(partition by segment_name order by sum(qty) desc) as quantity_rank from sales as s inner join product_details as p  on p.product_id=s.prod_id  group by segment_name,product_name)
select segment_name ,product_name from product_cte where quantity_rank = 1; 
