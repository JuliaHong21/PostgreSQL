/* Subquery */

/* q1. To find the average number of events for each day for each channel. */

SELECT channel, AVG(num_event)
FROM (SELECT DATE_TRUNC('day', occurred_at) event_day, channel, COUNT(*) num_event
	  FROM web_events
	  GROUP BY 1, 2) sub
GROUP BY 1
ORDER BY 2 DESC;


/* q2. The average amount of standard/gloss/poster paper sold and 
the total amount spent on all orders on the first month that 
any order was placed in the orders table (in terms of quantity). */
	 
SELECT AVG(standard_qty)standard, AVG(gloss_qty) gloss, AVG(poster_qty) poster, 
	   SUM(total_amt_usd) total_sales_usd
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
	(SELECT DATE_TRUNC('month', MIN(occurred_at))
	 FROM orders);
	 

/* q3. Provide the name of the sales_rep in each region with 
the largest amount of total_amt_usd sales. */

/* Solution
SUB1. I wanted to find the total_amt_usd totals associated with each sales rep, 
       and I also wanted the region in which they were located
SUB2. I pulled the max for each region, and then we can use this to pull those rows 
	   in our final result.
SUB3. This is a JOIN of these two tables, where the region and amount match. */

SELECT sub3.rep_name, sub3.region, sub3.total_sales_usd
FROM (SELECT region, MAX(total_sales_usd) total_sales_usd
	  FROM (SELECT s.id rep_id, s.name rep_name, r.name region, SUM(o.total_amt_usd) total_sales_usd
			FROM region r
			JOIN sales_reps s
			ON r.id = s.region_id
			JOIN accounts a
			ON a.sales_rep_id = s.id
			JOIN orders o
			ON o.account_id = a.id
			GROUP BY rep_id, rep_name, region) sub1
	  GROUP BY 1 ) sub2
JOIN (SELECT s.id rep_id, s.name rep_name, r.name region, SUM(o.total_amt_usd) total_sales_usd
	FROM region r
	JOIN sales_reps s
	ON r.id = s.region_id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY rep_id, rep_name, region
	ORDER BY total_sales_usd) sub3
ON sub2.region = sub3.region AND sub2.total_sales_usd = sub3.total_sales_usd;



/* q4. For the region with the largest (sum) of sales total_amt_usd, 
how many total (count) orders were placed? */

/* Solution
1. The first query I wrote was to pull the total_amt_usd for each region.
2. sub1: Then we just want the region with the max amount from this table. 
3. Finally, we want to pull the total orders for the region with this amount. */

SELECT r.name region, COUNT(o.total) num_sales
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY region
HAVING SUM(o.total_amt_usd) = (
		SELECT MAX(total_sales_usd)
		FROM (SELECT r.name region, SUM(o.total_amt_usd) total_sales_usd
				FROM region r
				JOIN sales_reps s
				ON r.id = s.region_id
				JOIN accounts a
				ON a.sales_rep_id = s.id
				JOIN orders o
				ON o.account_id = a.id
				GROUP BY region)sub1);

/* Without Subqueries */
SELECT r.name region, SUM(o.total_amt_usd) total_sales_usd, COUNT(*) Num_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY region
ORDER BY total_sales_usd DESC
LIMIT 1;


/* q5. How many accounts had more total purchases than the account name which 
has bought the most standard_qty paper throughout their lifetime as a customer? */

/* Solution
1. sub: The account which has bought the most standard_qty paper throughout their lifetime
		+ sum(total_qty)
2. Accounts that had more total purchases than 1.
3. To count the number of 2. */

SELECT COUNT(*)
FROM (SELECT a.name
		FROM accounts a
		JOIN orders o
		ON a.id = o.account_id
		GROUP by a.name
		HAVING SUM(o.total) > (
				SELECT total_qty
				FROM (SELECT a.name account, SUM(o.standard_qty) total_standard_qty, SUM(o.total) total_qty
						FROM accounts a
						JOIN orders o
						ON a.id = o.account_id
						GROUP BY account
						ORDER BY 2 DESC
						LIMIT 1)sub)
	  )counter;
		


/* q6. For the customer that spent the most (in total over their lifetime as a customer) 
total_amt_usd, how many web_events did they have for each channel? */

SELECT a.name, w.channel, COUNT(*) 
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.name, w.channel
HAVING a.name = (
				SELECT cust_name
				FROM (SELECT a.name cust_name, SUM(total_amt_usd) total_spent
						FROM accounts a
						JOIN orders o
						ON a.id = o.account_id
						GROUP BY a.name
					 	ORDER BY total_spent DESC
					 	LIMIT 1)sub)
ORDER BY 3 DESC;	


/* another ver. */
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;


/* q7. What is the lifetime average amount spent in terms of total_amt_usd for 
the top 10 total spending accounts? */

SELECT account_name, AVG(total_spent)
FROM (SELECT a.id account_id, a.name account_name, SUM(o.total_amt_usd) total_spent
		FROM accounts a
		JOIN orders o
		ON a.id = o.account_id
		GROUP BY 1, 2
		ORDER BY 3 DESC
		LIMIT 10)sub
GROUP BY account_name;


/* q8. What is the lifetime average amount spent in terms of total_amt_usd, including 
only the companies that spent more per order, on average, than the average of all orders. */

SELECT AVG(avg_sales)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_sales
		FROM orders o
		GROUP BY o.account_id
		HAVING AVG(o.total_amt_usd) > (SELECT AVG(total_amt_usd) avg_all
										FROM orders)) sub1;

/* WITH */

/* Template 
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;
*/


/* q1. You need to find the average number of events for each channel per day. */

/* Regular Subquery */
SELECT channel, AVG(num_event) avg_events
FROM (SELECT channel, DATE_TRUNC('day', occurred_at) event_day, COUNT(*) num_event
		FROM web_events
		GROUP BY channel, event_day) sub
GROUP BY channel
ORDER BY avg_events DESC;

/* WITH */
WITH events AS(
		SELECT channel, DATE_TRUNC('day', occurred_at) event_day, COUNT(*) num_event
		FROM web_events
		GROUP BY channel, event_day)

SELECT channel, AVG(num_event) avg_events
FROM events
GROUP BY channel
ORDER BY avg_events DESC;
		

/* q2. Provide the name of the sales_rep in each region with the largest amount of 
total_amt_usd sales. */

WITH t1 AS (
		SELECT s.id rep_id, s.name rep_name, r.name region, SUM(o.total_amt_usd) total_amt
		FROM region r
		JOIN sales_reps s
		ON r.id = s.region_id
		JOIN accounts a
		ON a.sales_rep_id = s.id
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY rep_id, rep_name, region),
	t2 AS (
		SELECT region, MAX(total_amt) top_amt
		FROM t1
		GROUP BY region)

SELECT t1.rep_name, t1.region, t1.total_amt
FROM t1
JOIN t2
ON t1.region = t2.region AND t1.total_amt = t2.top_amt;
		

/* q3. For the region with the largest sales total_amt_usd, how many total orders were placed? */

WITH t1 AS(
			SELECT r.name region, SUM(o.total_amt_usd) total_sales, COUNT(*) num_orders
			FROM region r
			JOIN sales_reps s
			ON r.id = s.region_id
			JOIN accounts a
			ON a.sales_rep_id = s.id
			JOIN orders o
			ON o.account_id = a.id
			GROUP BY r.name),
	t2 AS(
			SELECT region
			FROM t1
			WHERE total_sales = (
						SELECT MAX(total_sales)
						FROM t1)
		)

SELECT t1.region, t1.num_orders
FROM t1
JOIN t2
ON t1.region = t2.region;


/* q4. How many accounts had more total purchases than the account name which has bought 
the most standard_qty paper throughout their lifetime as a customer? */

WITH t1 AS(
		SELECT a.name, SUM(standard_qty) standard_sales, SUM(total) total_qty
		FROM accounts a
		JOIN orders o
		ON a.id = o.account_id
		GROUP BY a.name
		ORDER BY standard_sales DESC
		LIMIT 1),
	t2 AS(
		SELECT a.name 
		FROM accounts a
		JOIN orders o
		ON a.id = o.account_id
		GROUP BY a.name
		HAVING SUM(o.total) > (SELECT total_qty
							 	FROM t1))

SELECT COUNT(*) num_account
FROM t2;


/* q5. For the customer that spent the most (in total over their lifetime as a customer) 
total_amt_usd, how many web_events did they have for each channel? */

WITH t1 AS(
	SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	ORDER BY total_spent DESC
	LIMIT 1)

SELECT a.name, w.channel, COUNT(*) num_event
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (SELECT id FROM t1) 
GROUP BY a.name, channel
ORDER BY 3 DESC;


/* q6. What is the lifetime average amount spent in terms of total_amt_usd for 
the top 10 total spending accounts? */

WITH t1 AS (
	SELECT a.name, SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.name
	ORDER BY total_spent DESC
	LIMIT 10)

SELECT AVG(total_spent) 
FROM t1;


/* q7. What is the lifetime average amount spent in terms of total_amt_usd, including 
only the companies that spent more per order, on average, than the average of all orders. */

WITH t1 AS(
		SELECT AVG(o.total_amt_usd) avg_all
		FROM orders o
		JOIN accounts a
		ON a.id = o.account_id),
	t2 AS(
		SELECT o.account_id, AVG(o.total_amt_usd) avg_total
		FROM orders o
		GROUP BY 1
		HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1) )

SELECT AVG(avg_total)
FROM t2;
		
