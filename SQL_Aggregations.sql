/* SQL Aggregations */

/* SUM */

/* Find the total amount of poster_qty paper ordered in the orders table.  */

SELECT SUM(poster_qty) total_poster_sales
FROM orders;


/* Find the total amount of standard_qty paper ordered in the orders table. */

SELECT SUM(standard_qty) total_standard_sales
FROM orders;


/* Find the total dollar amount of sales using the total_amt_usd in the orders table. */

SELECT SUM(total_amt_usd) total_dollar_sales
FROM orders;


/* Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order 
in the orders table. This should give a dollar amount for each order in the table. */

SELECT standard_amt_usd + gloss_amt_usd AS total_dollar_std_gls
FROM orders;


/* Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both 
an aggregation and a mathematical operator. */

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;


/* MIN, MAX, & AVERAGE */

/* When was the earliest order ever placed? You only need to return the date. */

SELECT MIN(occurred_at)
FROM orders;


/* Try performing the same query as in question 1 without using an aggregation function. */

SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

/* When did the most recent (latest) web_event occur? */

SELECT MAX(occurred_at)
FROM web_events;


/* Try to perform the result of the previous query without using an aggregation function. */

SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;


/* Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean
amount of each paper type purchased per order. Your final answer should have 6 values 
- one for each paper type for the average number of sales, as well as the average amount. */

SELECT AVG(standard_qty) AVG_standard_purchased, AVG(gloss_qty) AVG_gloss_purchased, 
		AVG(poster_qty) AVG_poster_purchased, AVG(standard_amt_usd) AVG_standard_spent, 
		AVG(gloss_amt_usd) AVG_gloss_spent, AVG(poster_amt_usd) AVG_Poster_spent
FROM orders;


/* Group By */

/* Which account (by name) placed the earliest order? Your solution should have the
 account name and the date of the order. */
 
SELECT a.name account, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;


/* Find the total sales in usd for each account. You should include two columns - the
 total sales for each company's orders in usd and the company name. */
 
SELECT a.name, SUM(o.total_amt_usd) total_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;


/* Via what channel did the most recent (latest) web_event occur, which account was 
associated with this web_event? Your query should return only three values - 
the date, channel, and account name. */ 

SELECT a.name, w.occurred_at, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;


/* Find the total number of times each type of channel from the web_events was used. 
Your final table should have two columns - the channel and the number of times 
the channel was used. */

SELECT channel, COUNT(*)
FROM web_events
GROUP BY channel;


/* Who was the primary contact associated with the earliest web_event? */

SELECT a.primary_poc, w.occurred_at
FROM accounts a
JOIN web_events w
ON a.id =  w.account_id
ORDER BY w.occurred_at
LIMIT 1;


/* What was the smallest order placed by each account in terms of total usd. Provide
 only two columns - the account name and the total usd. Order from smallest dollar 
amounts to largest. */

SELECT a.name, MIN(o.total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;


/* Find the number of sales reps in each region. Your final table should have two 
columns - the region and the number of sales_reps. Order from fewest reps to most 
reps. */

SELECT r.name region, count(*) num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;


/* GROUP BY Part 2 */

/* For each account, determine the average amount of each type of paper they purchased 
across their orders. Your result should have four columns - one for the account name 
and one for the average quantity purchased for each of the paper types for each account. */

SELECT a.name, AVG(standard_qty) standard_avg, 
	   AVG(gloss_qty) gloss_avg, AVG(poster_qty) poster_avg
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;


/* For each account, determine the average amount spent per order on each paper type. 
Your result should have four columns - one for the account name and one for the average 
amount spent on each paper type. */

SELECT a.name, AVG(standard_amt_usd) avg_standard_usd, AVG(gloss_amt_usd) avg_gloss_usd, 
	   AVG(poster_amt_usd) avg_poster_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

/* Determine the number of times a particular channel was used in the web_events table for 
each sales rep. Your final table should have three columns - the name of the sales rep, 
the channel, and the number of occurrences. Order your table with the highest number of 
occurrences first. */

SELECT s.name rep, w.channel, COUNT(w.occurred_at) num_used
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN web_events w
ON w.account_id = a.id
GROUP BY rep, w.channel
ORDER BY num_used DESC;


/* Determine the number of times a particular channel was used in the web_events table for 
each region. Your final table should have three columns - the region name, the channel, 
and the number of occurrences. Order your table with the highest number of occurrences 
first. */

SELECT r.name region, w.channel, COUNT(*) num_occurred
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN web_events w
ON a.id = w.account_id
GROUP BY region, w.channel
ORDER BY num_occurred DESC;


/* DISTINCT */

/* Q. Use DISTINCT to test if there are any accounts associated with more than one region.  */

SELECT DISTINCT a.id account_id, a.name account_name, r.id region_id, r.name region_name
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id;

SELECT DISTINCT id, name
FROM accounts;
/* Result: The above two queries have the same number of resulting rows (351), 
so we know that every account is associated with only one region. 
If each account was associated with more than one region, the first query 
should have returned more rows than the second query. */


/* Q. Have any sales reps worked on more than one account?  */

SELECT s.id, s.name, COUNT(*) num_accounts
FROM sales_reps s
JOIN accounts a
ON s.id =  a.sales_rep_id
GROUP BY s.id, s.name;
/* Result: All of the sales reps have worked on more than one account */

SELECT DISTINCT s.id, s.name
FROM sales_reps s;
/* Result: There are 50 sales reps, and they all have more than one account. */


/* Having */

/* How many of the sales reps have more than 5 accounts that they manage? */

SELECT s.id sales_id, s.name sales_name, COUNT(*) num_account
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
GROUP BY sales_id, sales_name
HAVING COUNT(*) > 5  /* Alias cannot be used on Having clause */
ORDER BY num_account;


/* How many accounts have more than 20 orders? */

SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;


/* Which account has the most orders? */

SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;


/* Which accounts spent more than 30,000 usd total across all orders? */

SELECT a.id, a.name, SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(total_amt_usd) > 30000
ORDER BY total_spent;


/* Which accounts spent less than 1,000 usd total across all orders? */

SELECT a.id, a.name, SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(total_amt_usd) < 1000
ORDER BY total_spent;


/* Which account has spent the most with us? */

SELECT a.id, a.name, SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;


/* Which account has spent the least with us? */

SELECT a.id, a.name, SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent 
LIMIT 1;


/* Which accounts used facebook as a channel to contact customers more than 6 times? */

SELECT a.id, a.name, w.channel, COUNT(*) num_contact
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING channel = 'facebook' AND COUNT(*) > 6
ORDER BY num_contact;


/* Which account used facebook most as a channel? */

SELECT a.id, a.name, w.channel, COUNT(*) num_contact
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE channel = 'facebook'  /* We don't use HAVING when there is only one row as an output */
GROUP BY a.id, a.name, w.channel
ORDER BY num_contact DESC
LIMIT 1;


/* Which channel was most frequently used by accounts? */

SELECT w.channel, COUNT(*) num_account
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY w.channel
ORDER BY num_account DESC
LIMIT 1;


/* Which channel was most frequently used by most accounts? */

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;


/* DATE Functions */

/* Q1. Find the sales in terms of total dollars for all orders in each year, 
ordered from greatest to least. Do you notice any trends in the yearly sales totals? */

SELECT DATE_PART('year', occurred_at) order_year, SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
/* Answer: Sales have been increasing year over year, 
with 2016 being the largest sales to date. */


/* Q2. Which month did Parch & Posey have the greatest sales in terms of total dollars? 
Are all months evenly represented by the dataset? */

/* To check if all months are evenly represented by the dataset */

SELECT DATE_TRUNC('month', occurred_at) order_month, SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 1, 2;
/* Answer 
When we look at the yearly totals, you might notice that 2013 and 2017 have much smaller 
totals than all other years. If we look at the monthly data, we see that for 
2013 and 2017 there is only one month of sales for each of these years 
(12 for 2013 and 1 for 2017). Therefore, neither of these are evenly represented. 
*/

SELECT DATE_PART('Month', occurred_at) order_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;
/* Answer
Sales have been increasing year over year, with 2016 being the largest sales to date. 
At this rate, we might expect 2017 to have the largest sales.
In order for this to be 'fair', we should remove the sales from 2013 and 2017. 
For the same reasons as discussed above. */


/* Q3. Which year did Parch & Posey have the greatest sales in terms of total number of 
orders? Are all years evenly represented by the dataset? */

SELECT DATE_PART('year', occurred_at) sales_year, COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
/* Answer: 2016 
again 2013 and 2017 are not evenly represented to the other years in the dataset.
*/


/* Q4. Which month did Parch & Posey have the greatest sales in terms of total number of 
orders? Are all months evenly represented by the dataset? */

SELECT DATE_PART('month', occurred_at) sales_year, COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;
/* Answer: December 
To make a fair comparison from one month to another 2017 and 2013 data were removed.
*/


/* Q5. In which month of which year did Walmart spend the most on gloss paper in terms of 
dollars? */

/* DATE_PART used */
SELECT DATE_PART('year', o. occurred_at) sales_year, DATE_PART('month', o. occurred_at) sales_month,
	   a.name account, SUM(o.gloss_amt_usd) gloss_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY 1, 2, 3
ORDER BY gloss_spent DESC;

/* DATE_TRUNC used */
SELECT DATE_TRUNC('month', o. occurred_at) sales_month,
	   a.name account, SUM(o.gloss_amt_usd) gloss_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY 1, 2
ORDER BY gloss_spent DESC;
/* Answer: May 2016 was when Walmart spent the most on gloss paper. */


/* CASE Statement */

/* To solve the division by zero issue */
SELECT id, account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                            ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;


/* Q1. Write a query to display for each order, the account ID, total amount of the order, 
and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or 
more, or smaller than $3000. */

SELECT account_id, total_amt_usd, 
	   CASE WHEN total_amt_usd >= 3000 THEN 'Large' ELSE 'small' END AS order_level
FROM orders;


/* Q2. Write a query to display the number of orders in each of three categories, based on 
the total number of items in each order. The three categories are: 'At Least 2000', 
'Between 1000 and 2000' and 'Less than 1000'. */

SELECT COUNT(*) num_orders,
CASE WHEN total >= 2000 THEN 'At Lease 2000'
			WHEN total < 2000 AND total >= 1000 THEN 'Between 1000 and 2000'
			WHEN total < 1000 THEN 'Less than 1000' END order_category
FROM orders
GROUP BY 2;


/* Q3. We would like to understand 3 different levels of customers based on the amount 
associated with their purchases. The top level includes anyone with a Lifetime Value 
(total sales of all orders) greater than 200,000 usd. The second level is between 
200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 
Provide a table that includes the level associated with each account. 
You should provide the account name, the total sales of all orders for the customer, 
and the level. Order with the top spending customers listed first. */

SELECT a.name account, SUM(o.total_amt_usd) total_spent,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'TOP'
	 WHEN SUM(o.total_amt_usd) between 200000 AND 100000 THEN 'MIDDLE'
	 ELSE 'LOW' END AS customer_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;


/* Q4. We would now like to perform a similar calculation to the first, but we want to 
obtain the total amount spent by customers only in 2016 and 2017. Keep the same levels 
as in the previous question. Order with the top spending customers listed first. */

SELECT a.name account, SUM(o.total_amt_usd) total_spent,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'TOP'
	 WHEN SUM(o.total_amt_usd) between 200000 AND 100000 THEN 'MIDDLE'
	 ELSE 'LOW' END AS customer_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE occurred_at >= '2016-01-01'
GROUP BY 1
ORDER BY total_spent DESC;


/* Q5. We would like to identify top performing sales reps, which are sales reps associated 
with more than 200 orders. Create a table with the sales rep name, the total number of 
orders, and a column with top or not depending on if they have more than 200 orders. 
Place the top sales people first in your final table. */

SELECT s.id rep_id, s.name rep_name, COUNT(*) num_orders, 
CASE WHEN COUNT(*) > 200 THEN 'Top' ELSE 'NOT' END sales_rep_level
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1, 2
ORDER BY num_orders DESC;


/* Q6. The previous didn't account for the middle, nor the dollar amount associated with 
the sales. Management decides they want to see these characteristics represented as well. 
We would like to identify top performing sales reps, which are sales reps associated with 
more than 200 orders or more than 750000 in total sales. The middle group has any rep with 
more than 150 orders or 500000 in sales. Create a table with the sales rep name, 
the total number of orders, total sales across all orders, and a column with top, 
middle, or low depending on this criteria. Place the top sales people based on dollar 
amount of sales first in your final table. You might see a few upset sales people by 
this criteria! */

SELECT s.id rep_id, s.name rep_name, COUNT(*) num_sales, SUM(total_amt_usd) total_sales, 
CASE WHEN COUNT(*) > 200 OR SUM(total_amt_usd) > 750000 THEN 'top'
	 WHEN COUNT(*) > 150 OR SUM(total_amt_usd) > 500000 THEN 'middle'  
	 ELSE 'low' END rep_level
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY rep_id, rep_name
ORDER BY 4 DESC;


