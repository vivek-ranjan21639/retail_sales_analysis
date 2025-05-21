# Retail_sales_analysis

## Project Description

**Name of the project:** retail_sales_analysis
**Database:** `retail_sales_analysis`

This project explores retail sales data and performs exploratory data analysis and data cleaning. Analysis on the cleaned data has also been performed to see various business insights. The purpose of the project is to showcase my skill in SQL and moreover my aptitude to ask the right and in-depth business questions. Even though the database contains only one data table titled 'retail_sales', some of the questions asked are complex and require the application of advanced SQL concepts. For any user who wants to get inspired and learn or perform similar analysis on this data, they can clone it and execute the same code or modify as per their understanding. In this reference, it is mentioned that the code here is written in PostgreSQL. Therefore, it is suggested that users may check the variability in the code if they are using any other platform.

## Objective:
1. **Setting up Database:** To set up a database for a retail sales business and populate it with data.
2. **Data Cleaning:** To clean data on retail sales to make it analysis-ready. 
3. **Perform basic EDA:**  Perform basic EDA to explore the data
4. **Data Analysis:** To analyse the data and get business insights

## Detailed Project

### Setting up of Database
- Created a database titled retail_sales_analysis
- Created a table titled 'retail_sales'.The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.
- Populate the data in the table

**Create Database named retail_sales_analysis**

```sql
CREATE DATABASE retail_sales_analysis;
```
**Create table**

```sql
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
```
***Note: data has been populated using pgadmin GUI***

### Perform Basic EDL and data cleaning

**Taking a glance at the data**

```sql
select *
from retail_sales
limit 10;
```

**Find the size of the data**

```sql
select count(*) from retail_sales;
```

**Checking all the columns of the retail_Sales table**
```sql
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'retail_sales'
order by ordinal_position;
```

**How many unique customers are there?**

```sql
select
	count(distinct(customer_id))
from retail_sales;
```

**Unique categories**

```sql
select
	distinct category
from retail_sales;
```

**no. of transactions for each product category**

```sql
select
	category,
	count(transactions_id) as No_of_orders
from retail_sales
group  by category;
```

**Find out the number of unique customers for each category?**

```sql
select
	category,
	count(distinct customer_id) as NO_of_unique_customers
from retail_sales
group by category;
```

**checking for null values**

```sql
select *
from retail_sales
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
```

***Note: There are null values in the age column, quantity, price_per_unit, cogs, and total_sale columns.
Null values of quantity, price_per_unit, cogs, and total_sale are in the same row. The no. of rows with Null Values in these columns is not very large concerning the size of the data (3 out of 2000). Therefore, we can simply delete these rows to clean the data.***

**Remove the data point where quantity was null**

```sql
delete from retail_sales where quantity is null;
```

***Note: For the purpose of handling the null values in the age column. Some exploratory steps, like checking the size of data points for males and females within each product category, have been performed.***


**checking  how many roes are there for males and females for each category.**

```sql
select category, 
		count(case when gender = 'Male' then 1 end) as Male_count,
		count(case when gender = 'Female' then 1 end) as Female_count
from retail_sales group by category;
```

***Note: the above query shows the no. of data for male and females in every product category is same and significant to be used for handling the null values in age column.***

***Note: For the purpose of Null values in age column first we will calculate average age of male and average age of female in each product categiry seperately. This average age will then be assigned to the correspomnding rows i.e. average age of male in product category clothing will be assigned only in the null value of male in the Clothing category***

**Assign average value in place where age is null**

```sql
update retail_sales rs
set age = sub.avg_age from 
		(select category, gender, 
		round(avg(age),0) as avg_age 
		from retail_sales where age is not null
		group by category, gender) sub
where rs.age is null 
	and rs.category = sub.category
	and rs.gender = sub.gender;
```


**Checking the updated table**

```sql
select * from retail_sales;
```


**Adding a new column titled age_category using the age column for analysis.**

```sql
Alter table retail_sales add column age_category varchar(10);

update retail_sales
set age_category =
	case when age between 18 and 26 then '18-26 yrs'
		when age between 27 and 34 then '27-34 yrs'
		when age between 35 and 44 then '35-44 yrs'
		when age between 45 and 54 then '45-55 yrs'
		else 'above 55'
		end;
```


### Data analysis as per business questions

1. Total sales for each category?

```sql
select 
    category, 
    sum(total_sale) as Total_sales 
    from retail_sales 
    group  by category 
    order by Total_sales desc;
```


2. Average age of customers who purchased items from the beauty category?

```sql
select round(avg(age),2) from retail_sales where category = 'Beauty';
```


3. Retrieve all columns for sales made on '2022-11-05'.

```sql
select *
from retail_sales
where sale_date = '2022-11-05';
```

4. Retrieve all transactions where the category is clothing and the quantity sold is more than 3 in the month of Nov-2022.

```sql
select transactions_id, quantity, category, sale_date 
from retail_sales
where category = 'Clothing' and
	quantity > 3 and 
	to_char(sale_date, 'YYYY-MM') = '2022-11';
```

5. Find all the transactions where the total sale is greater than 1000.

```sql
select * 
from retail_sales
where total_sale > 1000;
```

6. Find out the product with the highest sales.

```sql
select 
    category, 
    sum(total_sale) as Total_sales 
from retail_sales 
group by category;
```

7. Find out for each category which age_category has placed the highest sales order (in terms of total sales).

```sql
with ranked_sales as (
    select 
        category,  
        age_category, 
        sum(total_sale) as total_sales, 
        rank() over (partition by category order by sum(total_sale) desc) as rn  
    from retail_sales group by category, age_category order by category, rn 
)
select * from ranked_sales where rn = 1;
```

8. Find out for each category which group has placed the highest number of sales orders (in terms of the number of orders).

```sql
with cte as (
 select category, age_category, count(transactions_id) as no_of_orders,
 row_number() over (partition by category order by count(transactions_id) desc) as rnk 
 from retail_sales group by category, age_category order by category, rnk
)
select category, age_category, no_of_orders from cte where rnk = 1;
```

9. Calculate the sales order of various age groups for each category of product.

```sql
Select 
    category, 
    age_category,  
    sum(total_sale) as total_sales
from retail_sales 
group by category, age_category 
order by category, total_sales desc;
```

10. Is there any gender led difference in customers for the demand of any particular category?

```sql
select 
    category, 
    gender, 
    count(transactions_id) as no_of_orders, 
    sum(total_sale) as total_sales,
    row_number() over (partition by category order by count(transactions_id) desc) as rw
from retail_sales 
group by category, gender 
order by category, rw;
```


11. Which gender has placed the highest number of sales orders in each category?

```
With cte as (
	select category, gender, sum(total_sale) as total_sales,
		row_number() over(partition by category order by sum(total_sale) desc) as rw
	from retail_sales group by category,  gender order by  category, rw)
select  category, gender, total_sales from cte where rw = 1;
```

12. Which gender has placed the highest no. of orders in each category?

```sql
with cte as (
select category, gender, count(transactions_id) as no_of_orders, sum(total_sale) as total_sales,
row_number() over (partition by category order by count(transactions_id) desc) as rw
from retail_sales group by category, gender order by category, rw
)
select category, gender, no_of_orders from cte where rw = 1;
```

13. Find out the sales concerning various age categories. The order should be decreasing in terms of sales value.

```sql
select age_category, sum(total_sale) as net_sales
from retail_sales
group by age_category
order by sum(total_sale) desc;
```

14. Calculate total sales each month in each year.

```sql
select 
	extract(year from sale_date) as sale_year,
	extract(month from sale_date) as sale_month,
	count(total_sale) as net_sale
from retail_sales
group by sale_year, sale_month
order by sale_year, sale_month;
```

15. Find out the number of unique customers who purchased at least one product from each category.

```sql
with cte as (
	select customer_id
	from retail_sales
	group by customer_id
	having count(distinct category) = (select count(distinct category) from retail_sales)
)
select count(distinct customer_id) from cte;
```

16. Which is the highest revenue-generating category?

```sql
select 
	category, 
	sum(total_sale) as revenue 
from retail_sales
group by category
order by revenue desc
limit 1;
```

17. Find out the customers who placed orders higher than the average order value for each category.

```sql
WITH cat_avg as(
	select category, round(avg(total_sale):: numeric, 2) as avg_by_cat
	from retail_sales group by category
),
cust_avg as(
	select customer_id, category, round(avg(total_sale):: numeric, 2) as avg_by_cust
	from retail_sales group by customer_id, category
)
select customer_id, cust_avg.category, avg_by_cust, avg_by_cat 
from cat_avg right join cust_avg on cat_avg.category = cust_avg.category
where avg_by_cust > avg_by_cat
order by customer_id;
```

18. Find out the top 20% of the customers in terms of  sales value.

```sql
with cust_tab as (
	select customer_id, sum(total_sale) as total_spending
	from retail_sales
	group by customer_id
),
tiled_cust as(
	select *, Ntile(5) over (order by total_spending desc) as bucket_cat from cust_tab
)
select * from tiled_cust where bucket_cat = 1;
```

** Using percent_rank: howevere it is less efficient than ntile in this case**

```sql
with cust_tab as (
	select customer_id, sum(total_sale) as total_spending
	from retail_sales
	group by customer_id
),
ranked_cust as(
	select *, percent_rank() over(order by total_spending desc) as rnk
	from cust_tab
)
select customer_id, total_spending from ranked_cust where rnk < 0.2;
```


19. Find out any seasonality if exists for each product

```sql
with cte1 as(
	select
		category,
		extract(year from sale_date) as sale_yr, 
		extract(month from sale_date) as sale_month, 
		count(transactions_id) as no_of_transc
	from retail_sales
	group by category, sale_yr, sale_month
),
cte2 as (
	select *, 
	row_number() over(partition by category, sale_yr order by no_of_transc desc) as rn
	from cte1
)
select * 
from cte2
where rn in (1,2,3,4);
order by category, sale_yr;
```


20. Find out the time interval in which most of the orders are being placed.

```sql
with cte as(
select
	case when sale_time between '06:00:00' and '10:00:00' then 'Morning'
			when sale_time between '10:00:00' and '13:00:00' then 'Noon'
			when sale_time between '13:00:00' and '17:00:00' then 'evening'
			when sale_time between '17:00:00' and '20:00:00' then 'late evening'
			when sale_time between '20:00:00' and '23:00:00' then 'night'
			else 'late night'
			end as time_segment,
	count(transactions_id) as no_of_orders
from retail_sales
group by time_segment
order by no_of_orders desc
),
ranked as(
	select *, 
	sum(no_of_orders) over(order by no_of_orders desc) as cummulative_orders,
	sum(no_of_orders) over() as total_orders
	from cte
),
fin as(
select *, 
round((cummulative_orders*100)/total_orders,2) as cummulative_percent 
from ranked
)
select * 
from fin
where cummulative_percent <= 80;
```

### Summary of findings
This project focuses on various business insights like revenue from different product categories, the 
highest selling product, gender led sales differences in different product categories,
temporal sales trend etc. Some complex insights have also been drawn, like the time interval when the 
highest no. of orders are placed, seasonality of the product sales etc. 
Some of the insights answering these business questions are as follows:
- Electronics is the highest-selling product in terms of quantity and generates the highest revenue among the three product categories, followed by clothing and beauty.
- The average age of the customer who placed orders in the beauty category is 40 years. This insight is interesting as the common perception is that the young generation would care more about beauty products. However, the insights drawn from this dataset tell otherwise. This insight will help immensely in ad targeting.
- If we talk in terms of age category, 45-55 years old contributed the highest no. of sales in Beauty, in clothing, 18-26 years old had the highest contribution and for electronics above 55 years old had the highest contribution.
- For beauty and clothing, females contributed the highest sales, while in electronics, males contributed the highest sales.
- About 82% of the customers bought products from all three categories.
- Across each product category, the highest no. of orders were placed in September, October, November and December. Therefore, seasonality exists for these products. This information may be used for strategising to increase sales, like providing additional discounts, special offers, vouchers, etc.
- 5:00 PM to 11:00 PM is the time interval when the highest no. of orders are placed. These insights may be used for floating time-targeted digital ads.

Other than the above, there are several other insights, like customers who order values are more than from given values and the average sales of that category. Such insights are very useful from a business perspective to increase sales and thus boost business growth.

### Conclusion
This project aims to uncover insights about potential customers who could contribute to future growth, explore customer characteristics across different product categories, and analyse sales trends, seasonality, and customer purchasing behaviour. Although the dataset is small, it holds significant potential for deeper insights. Many questions have been intentionally left out to maintain focus on clear and specific business objectives. A separate project could be undertaken to explore additional insights without complicating the current analysis. 


**Any user may use this project for learning purposes. They may do so by cloning this repo.**
 
