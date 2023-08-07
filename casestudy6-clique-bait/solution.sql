2. Digital Analysis

# How many users are there?
select * from users;
select count(distinct(user_id)) from users;

# How many cookies does each user have on average?
select round(avg(num)) from (select user_id,count(cookie_id) as num from users group by user_id)o;

# What is the unique number of visits by all users per month?
select monthname(event_time),count(distinct(visit_id)) from events  group by monthname(event_time);
select monthname(event_time) from events;

# What is the number of events for each event type?
select ed.event_name,count(*) as no_of_events from events as e inner join  event_identifier as ed on e.event_type=ed.event_type group by ed.event_name;
select * from event_identifier ;

# What is the percentage of visits which have a purchase event?
select((select count(distinct(visit_id)) from events where event_type = 3)/
(select count(distinct(visit_id)) from events))*100;


# What is the percentage of visits which view the checkout page but do not have a purchase event?
# checkout is page_name with page_id = 12 
# purchase is a event_type with event_id = 3
# view is a event_type with event_id = 1
# select distinct(event_type) from events where page_id =12;

with purchase_checkout_cte as 
(select visit_id,sum(case when event_type = 3 then 1 else 0 end )as purchase,sum(case when page_id =12 then 1 else 0 end )as check_out from events   group by visit_id)
select round(100 -((sum(purchase)/sum(check_out) )* 100 ),2) as percentage_checkout_without_purchase from purchase_checkout_cte ;


# What are the top 3 pages by number of views?
select * from events limit 5;
select page_name,count(event_type) as num_of_views from events  as e inner join page_hierarchy as p on e.page_id=p.page_id where event_type=1 group by p.page_id order by 
count(event_type) desc limit 3;


# What is the number of views and cart adds for each product category?
select distinct(product_category) from page_hierarchy;
select product_category,sum(case when event_type =1 then 1 else 0 end)as num_of_views,sum(case when event_type =2 then 1 else 0 end )as num_of_add_to_cart  from page_hierarchy as p
 inner join events as e on p.page_id=e.page_id where product_category is not null group by product_category order by num_of_views desc;


# What are the top 3 products by purchases?
with purchase_cte as 
(select page_id,event_type,visit_id from events where event_type=3 ) 
,cart_cte as 
(select page_name,visit_id from events  as e inner join page_hierarchy as ph on e.page_id=ph.page_id where event_type=2)
select page_name ,count(p.visit_id) as num_of_purchases from purchase_cte as p inner join cart_cte as c on p.visit_id=c.visit_id group by page_name order by count(p.visit_id) desc limit 3;



3.Product Funnel Analysis

# Using a single SQL query - create a new output table which has the following details:
# How many times was each product viewed?
# How many times was each product added to cart?
# How many times was each product added to a cart but not purchased (abandoned)? 
# How many times was each product purchased?

create table  product_info as 
with cart_vie_cte as 
(select visit_id,page_name,sum(case when event_type = 1 then 1 else 0 end) as num_of_view ,sum(case when event_type = 2 then 1 else 0 end) as num_add_cart 
from events as e inner join page_hierarchy as p on e.page_id=p.page_id  where product_id is not null group by visit_id,page_name ),
 purchase_cte as
(select distinct(visit_id) as purchase_id  from events as e inner join event_identifier as ed on e.event_type=ed.event_type where event_name ='purchase'),
visit_cte as 
(select *, 
(case when purchase_id is not null then 1 else 0 end) as purchase
from cart_vie_cte left join purchase_cte
on visit_id = purchase_id),
page_cte as 
(select page_name,sum(case when num_add_cart =1 and purchase =0 then 1 else 0 end) as abandoned ,sum(case when num_add_cart =1 and purchase =1 then 1 else 0 end) as 
purchased ,sum(num_of_view) as view ,sum(num_add_cart) as add_to_cart
from visit_cte group by page_name)
select * from page_cte;
select * from product_info;





# Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
 
create table  product_info as 
with cart_vie_cte as 
(select visit_id,product_category,sum(case when event_type = 1 then 1 else 0 end) as num_of_view ,sum(case when event_type = 2 then 1 else 0 end) as num_add_cart 
from events as e inner join page_hierarchy as p on e.page_id=p.page_id  where product_id is not null group by visit_id,product_category ),
 purchase_cte as
(select distinct(visit_id) as purchase_id  from events as e inner join event_identifier as ed on e.event_type=ed.event_type where event_name ='purchase'),
visit_cte as 
(select *, 
(case when purchase_id is not null then 1 else 0 end) as purchase
from cart_vie_cte left join purchase_cte
on visit_id = purchase_id),
sushant_cte as 
(select product_category,sum(case when num_add_cart =1 and purchase =0 then 1 else 0 end) as abandoned ,sum(case when num_add_cart =1 and purchase =1 then 1 else 0 end) as 
purchased ,sum(num_of_view) as view ,sum(num_add_cart) as add_to_cart
from visit_cte group by product_category)
select * from page_cte;
select * from product_info;

# Use your 2 new output tables - answer the following questions:
 
# Which product had the most views, cart adds and purchases?
 
select page_name from product_info order by view desc limit 1;
select page_name from product_info order by add_to_cart desc limit 1;
select page_name from product_info order by purchased desc limit 1;


# Which product was most likely to be abandoned?
select page_name from product_info order by abandoned desc limit 1;

# Which product had the highest view to purchase percentage?
select page_name,round((purchased/view)*100,2) as percentage from product_info order by percentage desc;


# What is the average conversion rate from view to cart add?
select * from product_info;
select round(avg((add_to_cart/view)*100),2) as conversion_rate from product_info;

# What is the average conversion rate from cart add to purchase?
select round(avg((purchased/add_to_cart)*100),2)  as conversion_rate from product_info;















