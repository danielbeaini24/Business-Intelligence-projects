/* PHASE 2 — Profitability & Pricing Analysis */



/* Q1. What is our total revenue, total cost, and gross profit? */

SELECT
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS total_gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key


/* Q2. Which customers generate the highest gross profit? */

SELECT TOP 20
f.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
f.customer_key,
c.first_name,
c.last_name,
c.country
ORDER BY gross_profit DESC


/* Q3. Which customers generate high revenue but low margins? */

SELECT TOP 20
f.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
f.customer_key,
c.first_name,
c.last_name,
c.country
HAVING SUM(f.sales_amount) > 0
ORDER BY gross_margin_percentage ASC


/* Q4. Which customers are loss-making? */

SELECT
f.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY
f.customer_key,
c.first_name,
c.last_name,
c.country
HAVING SUM(f.sales_amount - (f.quantity * p.cost)) < 0
ORDER BY gross_profit ASC


/* Q5. Which products have the highest gross profit? */

SELECT TOP 20
p.product_key,
p.product_name,
p.category,
p.subcategory,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY
p.product_key,
p.product_name,
p.category,
p.subcategory
ORDER BY gross_profit DESC


/* Q6. Which products have the lowest margins? */

SELECT TOP 20
p.product_key,
p.product_name,
p.category,
p.subcategory,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY
p.product_key,
p.product_name,
p.category,
p.subcategory
ORDER BY gross_margin_percentage ASC


/* Q7. Which categories are most profitable? */

SELECT
p.category,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY gross_profit DESC


/* Q8. What is the average selling price versus product cost? */

SELECT
p.category,
AVG(f.price) AS average_selling_price,
AVG(p.cost) AS average_product_cost,
AVG(f.price - p.cost) AS average_unit_profit,
AVG(f.price - p.cost)
/ NULLIF(AVG(f.price), 0) * 100 AS average_unit_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY average_unit_margin_percentage DESC


/* Q9. Which products have high sales volume but low margins? */

SELECT TOP 20
p.product_key,
p.product_name,
p.category,
SUM(f.quantity) AS total_quantity,
SUM(f.sales_amount) AS total_revenue,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY
p.product_key,
p.product_name,
p.category
HAVING SUM(f.quantity) > 0
ORDER BY
gross_margin_percentage ASC,
total_quantity DESC


/* Q10. Which customers represent potential pricing opportunities? */

WITH customer_profitability AS
(
SELECT
f.customer_key,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY f.customer_key
)
SELECT TOP 20
cp.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
cp.total_revenue,
cp.total_cost,
cp.gross_profit,
cp.gross_profit
/ NULLIF(cp.total_revenue, 0) * 100 AS gross_margin_percentage
FROM customer_profitability cp
JOIN dim_customers c
ON cp.customer_key = c.customer_key
ORDER BY
cp.total_revenue DESC,
gross_margin_percentage ASC