-- create table

CREATE TABLE retail_sales
		(
		transactions_id INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT,
		gender VARCHAR(10),
		age INT,
		category VARCHAR(20),
		quantity INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
		);

-- check whetther table is created or not;

select * from retail_sales limit 10;

--size of the data
select count(*) from retail_sales;

-- listing out alll the columns

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'retail_sales'
order by ordinal_position;

--  checking for null values

select * from retail_sales
where transactions_id is null or
	sale_date is null or
	sale_time is null or
	customer_id is null or
	gender is null or
	age is null or
	category is null or
	quantity is null or
	price_per_unit is null or
	cogs is null or
	total_sale is null;


-- remove the data point where qunatity was null

delete from retail_sales where quantity is null;

-- checking  how many data points are there for each pair of uniques values
-- for categiry and gender. 
select category, 
		count(case when gender = 'Male' then 1 end) as Male_count,
		count(case when gender = 'Female' then 1 end) as Female_count
from retail_sales group by category;

/* 
Assign average value in place where age is null.
values are assigned taking cattegory of product and gender
it may be tahe case that particular age group from particular 
gender buys a particular product more or less. so we factor in
for category and gender while fassigning the pseudo values for age.
*/
update retail_sales rs
set age = sub.avg_age from 
		(select category, gender, 
		round(avg(age),0) as avg_age 
		from retail_sales where age is not null
		group by category, gender) sub
where rs.age is null 
	and rs.category = sub.category
	and rs.gender = sub.gender;

-- checking the updated table

select * from retail_sales;
-- 
select category, round(avg(price_per_unit):: numeric,0) as avg_price from retail_sales group by category;

-- howmany uunique customer aree there?
select count(distinct(customer_id)) from retail_sales;

-- unique categories

select distinct category from retail_sales;

-- adding anew column in the table

Alter table retail_sales add column age_category varchar(10);

update retail_sales
set age_category =
	case when age between 18 and 26 then '18-26 yrs'
		when age between 27 and 34 then '27-34 yrs'
		when age between 35 and 44 then '35-44 yrs'
		when age between 45 and 54 then '45-55 yrs'
		else 'above 55'
		end;


/*
Business Quesions

-- Total sales for each category?
-- Average age of customers who purchased items from beauty category?
-- find out number of unique customers for each category?
-- find out the product with highest sales.
-- which age group of customers places the highest sales order? Also calculate sales order of various age groups for each category of product.
-- Is there any gender led difference in customers for demand of any particular category?
-- which gender has placed the highest amount of sales order in each category?
-- which gender has placed highest no. of orders in each category?
-- Customer age groups who placed highest no. of sales?
-- calculate total sales each month in each year.
-- Find out number of unique customers who purchased at least one product from each category?
-- which is the highest revenue generating category? 
-- find out the customers who placed orders higher than the average order value for each category?
-- find out the top 20% of the customer in terms of  sales value.
-- Find all the transaction where the total  sale is greater than 1000.
-- find out any seasonality if exist for each product.
-- find out the time interval iin which the most of the (80%) of the orders are being placed.
-- Retrieve all columns for sales made on '2022-11-05'.
-- Retriev all transactions where the category is clothing and the quantity sold id more than 10in the month of Nov-2022.


*/

-- Total sales for each category?

select category, sum(total_sale) as Total_sales from retail_sales group  by category order by Total_sales desc;

select category, count(transactions_id) as No_of_orders from retail_sales group  by category;

-- Average age of customers who purchased items from beauty category?

select * from retail_sales;

select round(avg(age),2) from retail_sales where category = 'Beauty';

select age_category, count(customer_id) as No_of_customer from retail_sales where category = 'Beauty' group by age_category order by No_of_customer desc;


-- find out number of unique customers for each category?
select category, count(distinct customer_id) as NO_of_unique_customers from retail_sales group by category;

-- find out the product with highest sales.

select category, sum(total_sale) as Total_sales from retail_sales group by category; 


-- find out for each category which group has placed highest sales order (in terms of total sales).
with ranked_sales as (
select category, age_category, sum(total_sale) as total_sales, 
rank() over (partition by category order by sum(total_sale) desc) as rn  
from retail_sales group by category, age_category order by category, rn 
)

select * from ranked_sales where rn = 1;

-- find out for each category which group has placed highest of no. sales order (in terms of no. of orders).

select * from retail_sales;

with cte as (
 select category, age_category, count(transactions_id) as no_of_orders,
 row_number() over (partition by category order by count(transactions_id) desc) as rnk 
 from retail_sales group by category, age_category order by category, rnk
)
select category, age_category, no_of_orders from cte where rnk = 1;

-- Calculate sales order of various age groups for each category of product.
select * from retail_sales;

Select category, age_category, sum(total_sale) as total_sales
from retail_sales group by category, age_category order by category, total_sales desc;

-- Is there any gender led difference in customers for demand of any particular category?

select category, gender, count(transactions_id) as no_of_orders, sum(total_sale) as total_sales,
row_number() over (partition by category order by count(transactions_id) desc) as rw
from retail_sales group by category, gender order by category, rw;


-- which gender has placed the highest amount of sales order in each category?

with cte as (
	select category, gender, sum(total_sale) as total_sales,
		row_number() over(partition by category order by sum(total_sale) desc) as rw
	from retail_sales group by category,  gender order by  category, rw)
select  category, gender, total_sales from cte where rw = 1;

-- which gender has placed highest no. of orders in each category?
with cte as (
select category, gender, count(transactions_id) as no_of_orders, sum(total_sale) as total_sales,
row_number() over (partition by category order by count(transactions_id) desc) as rw
from retail_sales group by category, gender order by category, rw
)
select category, gender, no_of_orders from cte where rw = 1;

-- Customer age groups who placed highest no. of sales?
-- calculate total sales each month in each year.
-- Find out number of unique customers who purchased at least one product from each category?
-- which is the highest revenue generating category? 
-- find out the customers who placed orders higher than the average order value for each category?
-- find out the top 20% of the customer in terms of  sales value.
-- Find all the transaction where the total  sale is greater than 1000.
-- find out any seasonality if exist for each product.
-- find out the time interval iin which the most of the (80%) of the orders are being placed.
-- Retrieve all columns for sales made on '2022-11-05'.
-- Retriev all transactions where the category is clothing and the quantity sold id more than 10in the month of Nov-2022.