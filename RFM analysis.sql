create database rfm
use rfm
SET sql_safe_updates = 0;

describe sales

update sales
set orderdate = date(str_to_date(orderdate,' %m/%d/%Y %H:%i:%s UTC'))


ALTER TABLE sales
modify column orderdate date;

select * from sales

--inspecting the data--

select * from sales
select count(*) from sales
select distinct status from sales 
select distinct year_id from sales 
select distinct productline from sales 
select distinct country from sales 
select distinct dealsize from sales 
select distinct territory from sales 
select distinct month_id from sales
where year_id = 2005
order by 1 asc
select distinct month_id from sales
where year_id = 2004
order by 1 asc
select distinct month_id from sales
where year_id = 2003
order by 1 asc

select * from sales
select  productline , round(sum(sales),0) as total_sales
from sales
group by productline
order by total_sales desc


select  year_id , round(sum(sales),0) as total_sales
from sales
group by year_id
order by total_sales desc



select * from sales
select  dealsize , round(sum(sales),0) as total_sales
from sales
group by dealsize
order by total_sales desc


----What was the best month for sales in a specific year? How much was earned that month? 
select * from sales
select month_id , round(sum(sales),0) as revenue , count(ordernumber) as frequency
from sales
where year_id= 2003
group by 1
order by 1 asc 

select year_id , month_id , productline , round(sum(sales),0) as revenue , count(ordernumber) as frequency
from sales
group by 1 , 2 ,3
order by 4 desc 

---from above query we can see that classic cars from 2003 in November month earned highest revenue


----Who is our best customer??
select * from sales
select customername,
		round(sum(sales),0) as monetry_value,
        round(avg(sales),0) as avg_monetry_value,
        count(ordernumber) as frequency,
        max(orderdate) as last_order_date,
        (select max(orderdate) from sales )as max_order_date,
        timestampdiff(day,MAX(orderdate), (SELECT MAX(orderdate) FROM sales)) AS order_interval
from sales
group by 1
                            
                            OR 	
select
        customername,
		round(sum(sales),0) as monetry_value,
        round(avg(sales),0) as avg_monetry_value,
        count(ordernumber) as frequency,
        max(orderdate) as last_order_date,
        (select max(orderdate) from sales )as max_order_date,
        ABS(DATEDIFF(MAX(orderdate), (SELECT MAX(orderdate) FROM sales))) AS order_interval
		from sales
		group by 1    

WITH rfm_table AS (
    SELECT
        customername,
        ROUND(SUM(sales), 0) AS monetry_value,
        ROUND(AVG(sales), 0) AS avg_monetry_value,
        COUNT(ordernumber) AS frequency,
        MAX(orderdate) AS last_order_date,
        (SELECT MAX(orderdate) FROM sales) AS max_order_date,
        ABS(DATEDIFF(MAX(orderdate), (SELECT MAX(orderdate) FROM sales))) AS order_interval
    FROM sales
    GROUP BY 1
),

rfm_calc as
(
	SELECT * ,
		NTILE(4) OVER (ORDER BY order_interval ) AS rfm_recency,
		NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
		NTILE(4) OVER (ORDER BY monetry_value) AS rfm_monetary
	FROM rfm_table
)
SELECT
    *,
    rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
    CONCAT(CAST(rfm_recency AS CHAR(10)), CAST(rfm_frequency AS CHAR(10)), CAST(rfm_monetary AS CHAR(10))) AS rfm_cell_string
FROM rfm_calc;

WITH rfm_table AS (
    SELECT
        customername,
        ROUND(SUM(sales), 0) AS monetry_value,
        ROUND(AVG(sales), 0) AS avg_monetry_value,
        COUNT(ordernumber) AS frequency,
        MAX(orderdate) AS last_order_date,
        (SELECT MAX(orderdate) FROM sales) AS max_order_date,
        ABS(DATEDIFF(MAX(orderdate), (SELECT MAX(orderdate) FROM sales))) AS order_interval
    FROM sales
    GROUP BY 1
),

rfm_calc AS (
    SELECT 
        customername,
        monetry_value,
        avg_monetry_value,
        frequency,
        last_order_date,
        max_order_date,
        order_interval,
        NTILE(4) OVER (ORDER BY order_interval) AS rfm_recency,
        NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
        NTILE(4) OVER (ORDER BY monetry_value) AS rfm_monetary
    FROM rfm_table
)
SELECT
    *,
    rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
    CONCAT(CAST(rfm_recency AS CHAR(10)), CAST(rfm_frequency AS CHAR(10)), CAST(rfm_monetary AS CHAR(10))) AS rfm_cell_string
FROM rfm_calc;


