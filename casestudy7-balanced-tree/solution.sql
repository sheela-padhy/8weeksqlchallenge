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
select case when member=0 then 'male' else 'female' end as gender,percentage from member_cte;


# What is the average revenue for member transactions and non-member transactions?
select member,sum(qty*price) as revenue from sales group by member;
