/* Phase 4 — Commercial Strategy  */




/* Q1. What is the monthly revenue trend? */

SELECT
YEAR(order_date) AS sales_year,
MONTH(order_date) AS sales_month,
SUM(sales_amount) AS total_revenue
FROM fact_sales
GROUP BY
YEAR(order_date),
MONTH(order_date)
ORDER BY
sales_year,
sales_month


/* Q2. What is the monthly gross profit and margin? */

SELECT
YEAR(f.order_date) AS sales_year,
MONTH(f.order_date) AS sales_month,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost)) AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100 AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY
YEAR(f.order_date),
MONTH(f.order_date)
ORDER BY
sales_year,
sales_month


/* Q3. What is the month-over-month revenue change? */

WITH monthly_revenue AS
(
SELECT
YEAR(order_date) AS sales_year,
MONTH(order_date) AS sales_month,
SUM(sales_amount) AS total_revenue
FROM fact_sales
GROUP BY
YEAR(order_date),
MONTH(order_date)
),
revenue_with_previous_month AS
(
SELECT
sales_year,
sales_month,
total_revenue,
LAG(total_revenue) OVER (
ORDER BY sales_year, sales_month
) AS previous_month_revenue
FROM monthly_revenue
)
SELECT
sales_year,
sales_month,
total_revenue,
previous_month_revenue,
total_revenue - previous_month_revenue
AS revenue_change,
(total_revenue - previous_month_revenue)
/ NULLIF(previous_month_revenue, 0) * 100
AS revenue_change_percentage
FROM revenue_with_previous_month
ORDER BY
sales_year,
sales_month


/* Q4. Who are our top customers by revenue ranking? */

WITH customer_revenue AS
(
SELECT
f.customer_key,
SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
GROUP BY f.customer_key
)
SELECT
cr.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
cr.total_revenue,
RANK() OVER (
ORDER BY cr.total_revenue DESC
) AS revenue_rank
FROM customer_revenue cr
JOIN dim_customers c
ON cr.customer_key = c.customer_key
ORDER BY revenue_rank


/* Q5. Which customers are high-value but low-margin?

These customers should be considered for pricing review.
*/

WITH customer_analysis AS
(
SELECT
f.customer_key,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost))
AS gross_profit
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY f.customer_key
)
SELECT TOP 20
ca.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
ca.total_revenue,
ca.total_cost,
ca.gross_profit,
ca.gross_profit
/ NULLIF(ca.total_revenue, 0) * 100
AS gross_margin_percentage
FROM customer_analysis ca
JOIN dim_customers c
ON ca.customer_key = c.customer_key
ORDER BY
ca.total_revenue DESC,
gross_margin_percentage ASC


/* Q6. Which countries have strong revenue but weak profitability? */

SELECT
c.country,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost))
AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100
AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY
gross_margin_percentage ASC


/* Q7. Which product categories have high volume but weak margins? */

SELECT
p.category,
SUM(f.quantity) AS total_quantity,
SUM(f.sales_amount) AS total_revenue,
SUM(f.sales_amount - (f.quantity * p.cost))
AS gross_profit,
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100
AS gross_margin_percentage
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY
gross_margin_percentage ASC,
total_quantity DESC


/* Q8. Which customers contribute the most to total revenue?

Cumulative revenue analysis.
*/

WITH customer_revenue AS
(
SELECT
customer_key,
SUM(sales_amount) AS total_revenue
FROM fact_sales
GROUP BY customer_key
),
ranked_customers AS
(
SELECT
customer_key,
total_revenue,
SUM(total_revenue) OVER (
ORDER BY total_revenue DESC
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW
) AS cumulative_revenue,
SUM(total_revenue) OVER ()
AS overall_revenue
FROM customer_revenue
)
SELECT TOP 50
customer_key,
total_revenue,
cumulative_revenue,
cumulative_revenue
/ NULLIF(overall_revenue, 0) * 100
AS cumulative_revenue_percentage
FROM ranked_customers
ORDER BY total_revenue DESC


/* Q9. Identify customers that may require a pricing review.

High revenue + margin below 20%.
*/

WITH customer_profitability AS
(
SELECT
f.customer_key,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost))
AS gross_profit
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY f.customer_key
)
SELECT
cp.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
cp.total_revenue,
cp.gross_profit,
cp.gross_profit
/ NULLIF(cp.total_revenue, 0) * 100
AS gross_margin_percentage,
CASE
WHEN cp.gross_profit
/ NULLIF(cp.total_revenue, 0) * 100 < 10
THEN 'Critical Pricing Review'

WHEN cp.gross_profit
/ NULLIF(cp.total_revenue, 0) * 100 < 20
THEN 'Pricing Review'

ELSE 'Healthy'
END AS pricing_status
FROM customer_profitability cp
JOIN dim_customers c
ON cp.customer_key = c.customer_key
WHERE cp.total_revenue > 0
ORDER BY
gross_margin_percentage ASC


/* Q10. Which products should be prioritized for commercial review?

High revenue + low margin.
*/

WITH product_analysis AS
(
SELECT
p.product_key,
p.product_name,
p.category,
SUM(f.sales_amount) AS total_revenue,
SUM(f.quantity * p.cost) AS total_cost,
SUM(f.sales_amount - (f.quantity * p.cost))
AS gross_profit
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY
p.product_key,
p.product_name,
p.category
)
SELECT TOP 20
product_key,
product_name,
category,
total_revenue,
total_cost,
gross_profit,
gross_profit
/ NULLIF(total_revenue, 0) * 100
AS gross_margin_percentage,
CASE
WHEN gross_profit
/ NULLIF(total_revenue, 0) * 100 < 10
THEN 'High Priority'

WHEN gross_profit
/ NULLIF(total_revenue, 0) * 100 < 20
THEN 'Review'

ELSE 'Healthy'
END AS commercial_status
FROM product_analysis
ORDER BY
total_revenue DESC,
gross_margin_percentage ASC


/* Q11. What is the overall customer portfolio distribution?

Classify customers based on revenue.
*/

WITH customer_revenue AS
(
SELECT
customer_key,
SUM(sales_amount) AS total_revenue
FROM fact_sales
GROUP BY customer_key
)
SELECT
CASE
WHEN total_revenue >= 10000 THEN 'High Value'
WHEN total_revenue >= 5000 THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment,
COUNT(*) AS customer_count,
SUM(total_revenue) AS segment_revenue
FROM customer_revenue
GROUP BY
CASE
WHEN total_revenue >= 10000 THEN 'High Value'
WHEN total_revenue >= 5000 THEN 'Medium Value'
ELSE 'Low Value'
END
ORDER BY segment_revenue DESC


/* Q12. Final commercial opportunity list

Customers with significant revenue and below-average margin.
*/

WITH customer_profitability AS
(
SELECT
f.customer_key,
SUM(f.sales_amount) AS total_revenue,
SUM(f.sales_amount - (f.quantity * p.cost))
AS gross_profit
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY f.customer_key
),
overall_margin AS
(
SELECT
SUM(f.sales_amount - (f.quantity * p.cost))
/ NULLIF(SUM(f.sales_amount), 0) * 100
AS average_margin
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
)
SELECT TOP 20
cp.customer_key,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.country,
cp.total_revenue,
cp.gross_profit,
cp.gross_profit
/ NULLIF(cp.total_revenue, 0) * 100
AS customer_margin,
om.average_margin,
'Pricing Review Candidate' AS recommendation
FROM customer_profitability cp
JOIN dim_customers c
ON cp.customer_key = c.customer_key
CROSS JOIN overall_margin om
WHERE
cp.gross_profit
/ NULLIF(cp.total_revenue, 0) * 100
< om.average_margin
ORDER BY
cp.total_revenue DESC