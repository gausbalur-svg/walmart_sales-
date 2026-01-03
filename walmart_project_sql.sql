select * from walmart_sales;
--drop table  walmart_sales;
-- counts
select  count(*) from walmart_sales;

select distinct payment_method from walmart_sales;

select 
	 payment_method,
	 count(*)
from walmart_sales
group by payment_method ;

-- retreive the total number of store and
select 
	count(distinct branch)
	from walmart_sales;

-- Business Problems

-- Q.1 Find the different payments method and number of transctions, number of qty sold
select 
	payment_method ,
	count(*) as on_transaction,
	sum(quantity)as qty_sold 
from walmart_sales
group by payment_method;

-- Q2. Identify the highest_rate category in each branch, displaying the branch, category , avg rating 
select *
from(
 select
	branch ,
	category ,
	avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating)desc )as ranks
from walmart_sales
group by 1,2 )
where ranks =1 ;

-- Q3. Identify the busiest day for each branch based on the number of transactions 
SELECT * from
(
select  branch , 
 TO_CHAR(TO_date(date,'DD/MM/YY'),'Day') AS Day_name,
 count(*)as no_transaction ,
 rank () over(partition by branch order by count(*) desc ) AS busiest
 FROM walmart_sales
 group by 1,2)
 WHERE busiest =1;

 --Q4.calculate the total quantity of items sold per payment method List payment method and total quantity
 
 select 
	 payment_method,
	 count(*)
from walmart_sales
group by payment_method ;

--Q5 Determind the average , minimum and maximum rating of product for each city 
--  List the city average rating ,min rating ,max rating .
select 
	category ,
	city ,
	avg(rating) as avg_rating,
	min(rating)as min_rating,
	max(rating) as max_rating
from walmart_sales
group by 1,2;

/*Q6 Calculate the total profit for each category by considering total_profit 
as(unit_profit* quantity * profit_margin).List category and total_profit ,ordered form 
highest kto lowest profit.*/
select 
category ,sum(total) as revenue,
sum(total*profit_margin)as profit
from walmart_sales
group by 1;

/* Q7. Determind the most common payment method for each branch 
Display Branch and the preferrened payment method*/
select * from (
select 
	branch,
	payment_method,
	count(*)as transaction_no,
	rank() over(partition by branch order by count(*) desc)as ranks
from walmart_sales
group by 1,2)
where ranks = 1;

/*Q8. categorize sale into 3 group morning , afternoon , evening
find out which of shift number of invoices*/

select branch,
case 
 	when extract (hour from (time::time ))< 12 then 'morning'
	when   extract (hour from( time :: time))between 12 and 17 then 'afternoon'
	else 'evening'
	end day_time,
	count(*) as total_invoices
from walmart_sales
group by 1,2
order by 1,3 desc;

/*Q9.Identify 5 branch decrese ratio in revenues compare to last year 
(current year 2023 and last year2022)
*/

with revenue_2022
as 
(	select 
		branch ,
		sum(total) as last_revenues
	from walmart_sales
	where extract(year from TO_date( date,'dd/mm/yy') )=2022
	group by 1
),
revenue_2023 as 
(
select 
		branch ,
		sum(total) as current_revenues
	from walmart_sales
	where extract(year from TO_date( date,'dd/mm/yy') )=2023
	group by 1
)
select
	ls.branch ,
	ls.last_revenues,
	cs.current_revenues ,
	
	(ls.last_revenues-cs.current_revenues)::numeric/
		  ls.last_revenues* 100 AS ratio
from revenue_2022 as ls
join 
revenue_2023 cs
on ls.branch = cs.branch
where ls.last_revenues >cs.current_revenues
order by 4 desc limit 5;
