/*

PROJECT: Sales Performance & Revenue Intelligence
PHASE 1: Executive Sales Overview


*/

-- Q1. What is the total revenue generated from the current orders?

SELECT
SUM(Sales) AS total_revenue
FROM Sales.Orders

-- Q2. How many orders are there?

SELECT
COUNT(*) AS number_of_orders
FROM Sales.Orders

-- Q3. What is the average revenue per order?

SELECT
AVG(Sales) AS average_revenue
FROM Sales.Orders

-- Q4. How much revenue comes from each order status
--     (Delivered vs Shipped)?

SELECT 
SUM(CASE WHEN OrderStatus='Delivered' THEN Sales ELSE 0 END ) AS Delivered_Revenue,
SUM(CASE WHEN OrderStatus='Shipped' THEN Sales ELSE 0 END ) AS Shipped_Revenue
FROM Sales.Orders


-- Q5. What percentage of total revenue comes from each
--     order status?

With Revenue AS 
(
SELECT 
SUM(SALES) AS Total_Revenue,
SUM(CASE WHEN OrderStatus='Delivered' THEN Sales ELSE 0 END ) AS Delivered_Revenue,
SUM(CASE WHEN OrderStatus='Shipped' THEN Sales ELSE 0 END ) AS Shipped_Revenue
FROM Sales.Orders)

SELECT 
 Delivered_Revenue*100/NULLIF(Total_Revenue,0) AS Delivered_Revenue_pct,
 Shipped_Revenue*100/NULLIF(Total_Revenue,0) AS Shipped_Revenue_pct
 FROM Revenue

-- Q6. What is the total quantity sold?

SELECT
	SUM(Quantity) AS Total_Quantity
FROM Sales.Orders

-- Q7. What is the average quantity per order?

SELECT
AVG(Quantity) AS Avg_Quantity
FROM Sales.Orders

-- Q8. Which month generated the highest revenue?

SELECT
MONTH(OrderDate) AS Month,
SUM(Sales) AS Monthly_Revenue
FROM Sales.Orders
WHERE OrderDate>='2025-01-01' AND OrderDate<'2026-01-01' 
GROUP BY MONTH(OrderDate) 
ORDER BY Monthly_Revenue DESC

-- Q9. Which month had the highest number of orders?

SELECT
MONTH(OrderDate) AS Month,
COUNT(OrderID) AS Monthly_Orders
FROM Sales.Orders
WHERE OrderDate>='2025-01-01' AND OrderDate<'2026-01-01' 
GROUP BY MONTH(OrderDate) 
ORDER BY Monthly_Orders DESC

-- Q10. How does revenue change from one month to the next
--      (Month-over-Month growth)?

WITH MonthlyRev AS
(SELECT 
MONTH(OrderDate) AS Month,
SUM(Sales) AS Current_Month_Revenue
FROM Sales.Orders
WHERE OrderDate>='2025-01-01' AND OrderDate<'2026-01-01' 
GROUP BY MONTH(OrderDate)),

Current_Previous_MonthlyRev AS 
(SELECT
Month,
Current_Month_Revenue,
LAG(Current_Month_Revenue)OVER(ORDER BY Month) AS Previous_Month_Revenue,
Current_Month_Revenue-LAG(Current_Month_Revenue)OVER(ORDER BY Month) AS Monthly_Revenue_Change
FROM MonthlyRev)

SELECT
  Month,
    Current_Month_Revenue,
    Previous_Month_Revenue,
    Monthly_Revenue_Change,
(Current_Month_Revenue-Previous_Month_Revenue)*100/NULLIF(Previous_Month_Revenue,0) AS MoM_Growth_pct
FROM Current_Previous_MonthlyRev
ORDER BY Month 



 

