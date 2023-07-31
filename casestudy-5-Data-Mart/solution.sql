1. Data Cleansing Steps
  
#In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
#Convert the week_date to a DATE format
#Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
#Add a month_number with the calendar month for each week_date value as the 3rd column
#Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
#Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
#Add a new demographic column using the following mapping for the first letter in the segment values:
#Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
#Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

create table  clean_weekly_sales  as 
SELECT * , 
DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%Y-%m-%d') AS formatted_date ,
week(DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%Y-%m-%d') ) as week_number ,
month(DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%Y-%m-%d')) as month_number ,
year(DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%Y-%m-%d')) as calendar_year ,
case when substr(segment,2,1) =1 then 'young_adults'
when substr(segment,2,1) =2 then 'middle_aged'
when substr(segment,2,1) =3 then 'retirees'else 'unknown' end as age_band ,
case when substr(segment,1,1) = 'C' then 'Couples'
when substr(segment,1,1) = 'F' then 'Families' else 'unknowm' end as demographic ,
round((sales/transactions),2) as avg_transaction
from weekly_sales;
select * from clean_weekly_sales;


# What day of the week is used for each week_date value?
select dayname(week_date) from clean_weekly_sales;

# What range of week numbers are missing from the dataset?
select distinct(week_number) from clean_weekly_sales order by week_number;

# How many total transactions were there for each year in the dataset?
select calendar_year,sum(transactions) as total_transactions from clean_weekly_sales group by calendar_year;

# What is the total sales for each region for each month?
select region,month_number,sum(sales) as total_sales  from clean_weekly_sales group by region,month_number;

# What is the total count of transactions for each platform
select platform ,sum(transactions) as total_count  from clean_weekly_sales group by platform ;

# What is the percentage of sales for Retail vs Shopify for each month?
create table  percentage_table as
SELECT calendar_year,
          month_number,
          SUM(CASE
                  WHEN platform="Retail" THEN sales
              END) AS retail_sales,
          SUM(CASE
                  WHEN platform="Shopify" THEN sales
              END) AS shopify_sales,
          sum(sales) AS total_sales
   FROM clean_weekly_sales
   GROUP BY calendar_year,
          month_number;

select * from percentage_table;
select calendar_year,month_number,(retail_sales/total_sales)*100 as retail_percentage ,(shopify_sales/total_sales)*100 as shopify_percentage from percentage_table group by month_number,calendar_year;
