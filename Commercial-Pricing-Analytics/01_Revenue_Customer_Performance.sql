/*  PHASE 1 — REVENUE & CUSTOMER PERFORMANCE */




/* Q1. What is our total revenue? */

SELECT
SUM(sales_amount) AS total_revenue
FROM fact_sales


/* Q2. How does revenue develop by year? */

SELECT
YEAR(order_date) AS sales_year,
SUM(sales_amount) AS total_revenue
FROM fact_sales
GROUP BY YEAR(order_date)
ORDER BY sales_year


/* Q3. Which customers generate the most revenue? */

SELECT TOP 20
f.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
SUM(f.sales_amount) AS total_revenue,
COUNT(*) AS transaction_count
FROM fact_sales f
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
f.customer_key,
c.first_name,
c.last_name,
c.country
ORDER BY total_revenue DESC


/* Q4. Which countries generate the most revenue? */

SELECT
c.country,
SUM(f.sales_amount) AS total_revenue,
COUNT(DISTINCT f.customer_key) AS customer_count,
COUNT(*) AS transaction_count
FROM fact_sales f
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC


/*  Q5. Which product categories generate the most revenue? */

SELECT
p.category,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity) AS total_quantity,
COUNT(DISTINCT f.customer_key) AS customer_count
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC


/* Q6. Which products generate the most revenue? */

SELECT TOP 20
p.product_key,
p.product_name,
p.category,
p.subcategory,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY
p.product_key,
p.product_name,
p.category,
p.subcategory
ORDER BY total_revenue DESC


/* Q7. How concentrated is revenue among customers? */

WITH customer_revenue AS
(
SELECT
customer_key,
SUM(sales_amount) AS customer_revenue
FROM fact_sales
GROUP BY customer_key
),
ranked_customers AS
(
SELECT
customer_key,
customer_revenue,
ROW_NUMBER() OVER (
    ORDER BY customer_revenue DESC
) AS customer_rank
FROM customer_revenue
)
SELECT
customer_rank,
customer_key,
customer_revenue,
customer_revenue /
(SELECT SUM(sales_amount)
    FROM fact_sales) * 100 AS revenue_percentage
FROM ranked_customers
WHERE customer_rank <= 10
ORDER BY customer_rank


/* Q8. What percentage of total revenue comes from the Top 10 customers? */

WITH customer_revenue AS
(
SELECT
customer_key,
SUM(sales_amount) AS customer_revenue
FROM fact_sales
GROUP BY customer_key
),
ranked_customers AS
(
SELECT
customer_key,
customer_revenue,
ROW_NUMBER() OVER (
    ORDER BY customer_revenue DESC
) AS customer_rank
FROM customer_revenue
)
SELECT
SUM(customer_revenue) AS top_10_revenue,

(SELECT SUM(sales_amount)
FROM fact_sales) AS total_revenue,

SUM(customer_revenue) /
(SELECT SUM(sales_amount)
    FROM fact_sales) * 100
AS top_10_revenue_percentage

FROM ranked_customers
WHERE customer_rank <= 10


/* Q9. Which customers have high transaction volume? */

SELECT TOP 20
f.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
COUNT(*) AS transaction_count,
SUM(f.quantity) AS total_quantity,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
f.customer_key,
c.first_name,
c.last_name,
c.country
ORDER BY transaction_count DESC


/* Q10. What is the average revenue per transaction? */

SELECT
COUNT(*) AS total_transactions,
SUM(sales_amount) AS total_revenue,
AVG(sales_amount) AS average_revenue_per_transaction
FROM fact_sales




