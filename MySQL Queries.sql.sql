USE walmart;
select *from walmart_cleaned;

 select distinct Branch 
 from walmart_cleaned;
 select max(quantity)from walmart_cleaned;

 -- Business Problems


 -- 1)Find different payment method and number of transaction , number of qty sold  
select distinct payment_method ,count(*)as no_payment ,sum(quantity) as no_of_sold
from walmart_cleaned
group by payment_method
order by count(quantity) desc ;


-- 2) Identity the highest- rated category in each branch , displaying branch , category,AVG rating??
select Branch , category, avg(rating) as avg_rating , 
RANK() OVER (
        PARTITION BY Branch
        ORDER BY AVG(rating) DESC
        )
from walmart_cleaned
group by Branch ,category;


-- 3)Identify the busiest day for each branch based on the number of transactions???

select * from
(SELECT 
    Branch,
    DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
COUNT(*) AS no_of_transaction ,
RANK()  OVER(PARTITION BY Branch  ORDER BY  COUNT(*) DESC )as rank_in_branch
FROM walmart_cleaned
GROUP BY 
    Branch,
    DAYNAME(STR_TO_DATE(date, '%d/%m/%y'))
) as t
where rank_in_branch=1;


-- 4) Calculate the total quantity of items sold per payment method . list payment_method and total_quantity??
 select
 payment_method,
 sum(quantity) as no_qty_sold
 from walmart_cleaned
 group by payment_method
order by count(quantity) desc;


-- 5) Determine the average , and maximum ,minimum rating of caterogy for each  city
select  city, category, 
min(rating) as min_rating, 
max(rating) as max_rating, 
AVG(rating) as avg_rating
from walmart_cleaned
group by city,category;


-- 6) Calculate the total profit for each caterogy by considering total_profit as 
-- (unit_price +quantity + profit_margin).
-- list category and total_profit , ordered from highest to lowest profit . 

select category,
sum(total)as total_revenue,
sum(total * profit_margin) as profit
from walmart_cleaned
group by category;


-- 7) Determine the most common payment method for each branch.
-- Display Branch and the preferred _payment_method.alter
select * from 
(select 
Branch, payment_method,
count(*) as total_trans,
rank() over(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank_as
from walmart_cleaned
group by Branch , payment_method
) as t 
where rank_as=1;


-- 8) Categories sales into 3 group Morning ,afternoon , evening 
-- find out which of the shift and number of invoices??
SELECT
    Branch,
    CASE 
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) < 12 THEN 'Morning'
        WHEN HOUR(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_transactions
FROM walmart_cleaned
GROUP BY 
    Branch,
    day_time;


-- 9) Identity 5 branch with highest decrese ratio in revenue compare to last year (current year 2023 and last year2022)
WITH yearly_revenue AS (
    SELECT
        Branch,
        YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS year,
        SUM(Total) AS revenue
    FROM walmart_cleaned
    GROUP BY Branch, year
),
comparison AS (
    SELECT
        y23.Branch,
        y22.revenue AS revenue_2022,
        y23.revenue AS revenue_2023,
        (y22.revenue - y23.revenue) / y22.revenue AS decrease_ratio
    FROM yearly_revenue y22
    JOIN yearly_revenue y23
        ON y22.Branch = y23.Branch
    WHERE y22.year = 2022
      AND y23.year = 2023
)
SELECT *
FROM comparison
WHERE revenue_2023 < revenue_2022
ORDER BY decrease_ratio DESC
LIMIT 5;




