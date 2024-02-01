DROP IF EXISTS sales
CREATE TABLE IF NOT EXISTS sales (
	invoice_id VARCHAR(30) PRIMARY KEY,
	branch VARCHAR(30) NOT NULL,
	city VARCHAR(30) NOT NULL,
	customer_type VARCHAR(30) NOT NULL,
	gender VARCHAR(30) NOT NULL,
	product_line VARCHAR(30) NOT NULL,
	unit_price NUMERIC(10,2) NOT NULL,
	quantity INT NOT NULL,
	tax_pct NUMERIC (10,2) NOT NULL,
	total NUMERIC(15,2) NOT NULL,
	date TIMESTAMP NOT NULL,
	time TIME NOT NULL,
	payment VARCHAR(30) NOT NULL,
	cogs NUMERIC(10,2) NOT NULL,
	gross_margin_pct NUMERIC(10,2) NOT NULL,
	gross_income NUMERIC(12, 4),
    rating NUMERIC(10, 2)
);

SELECT * FROM sales;

-------------------------------------------- Feature Engineering --------------------------------------------

-- 1. Add a new column named time_of_day
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(30);

SELECT 
	(CASE WHEN time BETWEEN '00:00:00' AND '12:00:00' 
		THEN 'Morning'
		WHEN time BETWEEN '12:01:00' AND '16:00:00'
		THEN 'Afternoon'
		ELSE 'Evening'
	END) AS time_of_day
FROM sales

UPDATE sales SET time_of_day = (CASE WHEN time BETWEEN '00:00:00' AND '12:00:00' 
		THEN 'Morning'
		WHEN time BETWEEN '12:01:00' AND '16:00:00'
		THEN 'Afternoon'
		ELSE 'Evening'
	END)
	
-- 2. Add a new column named day_name
ALTER TABLE sales ADD COLUMN day_name VARCHAR(30);

select date, to_char(date,'Day') from sales;

UPDATE sales SET day_name = TO_CHAR(date,'Day');


-- 3. Add a new column named month_name

ALTER TABLE sales ADD COLUMN month_name VARCHAR(30);

UPDATE sales SET month_name = 	TO_CHAR(date,'Month')

---------------------------------------------------------------------------------------------------------------------------------------

										-- ### Generic Question ### --
										
-- 1.How many unique cities does the data have?
SELECT DISTINCT city FROM sales;


-- 2.In which city is each branch?
SELECT DISTINCT city, branch  from sales;


										-- ### Product ### --
								

SELECT product_line, quantity FROM sales;

-- 1. How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;


-- 2. What is the most common payment method?
SELECT payment, COUNT(payment) 
	FROM sales 
	GROUP BY payment
	ORDER BY COUNT(payment) DESC;
	

-- 3. What is the most selling product line?
SELECT product_line, COUNT(product_line) 
	FROM sales 
	GROUP BY product_line
	ORDER BY COUNT(product_line) DESC;
	
	
-- 4. What is the total revenue by month?
SELECT month_name AS Month,
	SUM(total) AS total_revenue
	FROM sales
	GROUP BY Month
	ORDER BY total_revenue DESC;
	
 
-- 5. What month had the largest COGS?
SELECT month_name AS Month,
	SUM(cogs) AS total_cogs
	FROM sales
	GROUP BY Month
	ORDER BY total_cogs DESC;
	
	
-- 6. What product line had the largest revenue?
SELECT product_line,
	SUM(total) AS total_revenue
	FROM sales
	GROUP BY product_line
	ORDER BY total_revenue DESC;
	
	
-- 5. What is the city with the largest revenue?
SELECT city,
	SUM(total) AS total_revenue
	FROM sales
	GROUP BY city
	ORDER BY total_revenue DESC;

-- 6. What product line had the largest VAT?
SELECT product_line,
	SUM(tax_pct) AS vat
	FROM sales
	GROUP BY product_line
	ORDER BY vat DESC;

-- 7. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

WITH AvgCTE AS (
    SELECT ROUND(AVG(quantity),2) AS overall_avg
    FROM sales
)

SELECT
    product_line,
    CASE
        WHEN ROUND(AVG(quantity),2) > (SELECT overall_avg FROM AvgCTE) THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM
    sales
GROUP BY
    product_line;

-- 8. Which branch sold more products than average product sold?

SELECT 
	branch,
	SUM(quantity) AS product_quantity
	FROM sales
	GROUP BY branch
	HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
	ORDER BY product_quantity DESC;

-- 9. What is the most common product line by gender?
SELECT  
	gender, 
	product_line,
	count(gender) AS total_gender
	FROM sales
	GROUP BY  gender, product_line
	ORDER BY total_gender DESC;

-- 12. What is the average rating of each product line?

SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
 FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


										-- ### Sales ### --

-- 1. Number of sales made in each time of the day per weekday
SELECT 
time_of_day, 
count(*) AS total_sale
FROM sales
WHERE day_name NOT IN ('Saturday', 'Sunday')
GROUP BY time_of_day
ORDER BY total_sale DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT city, ROUND(AVG(tax_pct),2) AS avg_tax_pct 
FROM sales
GROUP BY city
ORDER BY avg_tax_pct DESC;

-- 4. Which customer type pays the most in VAT?
SELECT customer_type, ROUND(AVG(tax_pct),2) AS avg_tax_pct 
FROM sales
GROUP BY customer_type
ORDER BY avg_tax_pct DESC;

										-- ### Customer ### --

-- 1. How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- 2. How many unique payment methods does the data have?
SELECT DISTINCT payment FROM sales;

-- 3. What is the most common customer type?
SELECT customer_type, count(*) AS total_sale 
FROM sales
GROUP BY customer_type
ORDER BY total_sale DESC;

-- 4. Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

-- 5. What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 6. What is the gender distribution per branch?
SELECT
	gender,
	branch,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender, branch
ORDER BY gender_cnt DESC;

-- 7. Which time of the day do customers give most ratings?
SELECT 
	time_of_day,
	ROUND(AVG(rating),2) AS total_rating
	FROM sales
	GROUP BY time_of_day
	ORDER BY total_rating DESC;

-- 8. Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,
	ROUND(AVG(rating),2) AS total_rating,
	branch
	FROM sales
	GROUP BY time_of_day, branch
	ORDER BY total_rating;
	
-- 9. Which day fo the week has the best avg ratings?
SELECT 
	day_name,
	ROUND(AVG(rating),2) AS total_rating
	FROM sales
	GROUP BY day_name
	ORDER BY total_rating DESC;

-- 10. Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	branch,
	ROUND(AVG(rating),2) AS total_rating
	FROM sales
	GROUP BY branch, day_name 
	ORDER BY total_rating DESC;
















