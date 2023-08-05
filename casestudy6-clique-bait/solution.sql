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
