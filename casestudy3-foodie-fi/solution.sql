use foodie_fi;

# A. Customer Journey
# Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
# Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
select * from plans;
select * from subscriptions;
select customer_id,plan_name,price,start_date from plans as p inner join subscriptions as s on p.plan_id=s.plan_id;

# B. Data Analysis Questions
# How many customers has Foodie-Fi ever had?
select count(distinct(customer_id)) as no_of_customers from subscriptions;


# What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select monthname(start_date) as Name_of_month,count(customer_id ) as No_of_customers from subscriptions as s inner join plans as p on p.plan_id=s.plan_id where 
plan_name ='trial'group by monthname(start_date) order by No_of_customers desc ;

# how many customers had trail plan by month?
# monthname() returns the monthname like January
# month() returns the month number like 1 for jan.


# What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
#how many customers had plan by plan _name after 2020
# No customers has signed up after 2020.
select plan_name,count(customer_id) as no_of_customers from plans  as p inner join subscriptions as s on p.plan_id=s.plan_id where year(start_date)>2020 group by plan_name order by no_of_customers;

What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

select count(distinct(customer_id)) as no_of_customers , (select count(customer_id) from subscriptions where plan_id=4)/
(select count(distinct(customer_id)) from subscriptions)*100 as percentage from plans  as p inner join subscriptions as s on p.plan_id=s.plan_id ;

 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
select (select count(customer_id) as no_of_churned_customers from (select customer_id,plan_id from (select customer_id ,plan_id,dense_rank() over(partition by customer_id order by start_date ) as r from subscriptions)f 
where r=2 and plan_id=4)l)
/(select count(distinct(customer_id)) from subscriptions)*100 as percentage;

# What is the number and percentage of customer plans after their initial free trial?

select plan_name,no_of_customers,no_of_customers/(select count(distinct(customer_id)) from subscriptions)*100 as percentage 
from (select plan_id ,count(customer_id)  as no_of_customers from subscriptions group by plan_id) as o inner join plans as p on p.plan_id=o.plan_id;


