 /*

PROJECT: Sales Performance & Revenue Intelligence
PHASE 3: Customer Revenue & Customer Behavior Intelligence

*/

-- Q1. Which customers generate the most revenue?
SELECT 
O.CustomerID,
COALESCE(C.FirstName+' '+C.LastName,C.FirstName) AS CustomerName,
C.Country,
SUM(O.Sales) AS Total_Revenue
FROM Sales.Orders AS O 
LEFT JOIN Sales.Customers AS C 
ON C.CustomerID=O.CustomerID
GROUP BY O.CustomerID,
COALESCE(C.FirstName+' '+C.LastName,C.FirstName),
C.Country
ORDER BY Total_Revenue DESC

-- Q2. Which customers place the most orders and purchase the most units?

SELECT
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName) AS CustomerName,
COUNT(DISTINCT O.OrderID) AS Number_of_Orders,
SUM(O.Quantity) AS Total_Units_Purchased
FROM Sales.Orders AS O
LEFT JOIN Sales.Customers AS C
ON C.CustomerID = O.CustomerID
GROUP BY
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName)
ORDER BY
Number_of_Orders DESC,
Total_Units_Purchased DESC

-- Q3. What is the average revenue per order for each customer?

SELECT
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName) AS Customer,
COUNT(DISTINCT O.OrderID) AS Number_of_Orders,
SUM(O.Sales) AS Total_Revenue,
SUM(O.Sales) / NULLIF(COUNT(DISTINCT O.OrderID), 0) AS Average_Order_Value
FROM Sales.Orders AS O
LEFT JOIN Sales.Customers AS C
ON C.CustomerID = O.CustomerID
GROUP BY
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName)
ORDER BY
Average_Order_Value DESC

-- Q4. How do customers rank by total revenue?

SELECT
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName) AS Customer,
SUM(O.Sales) AS Revenue,
RANK() OVER (ORDER BY SUM(O.Sales) DESC) AS Revenue_Rank
FROM Sales.Orders AS O
LEFT JOIN Sales.Customers AS C
ON C.CustomerID = O.CustomerID
GROUP BY
O.CustomerID, COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName)
ORDER BY Revenue_Rank

-- Q5. What percentage of total company revenue does each customer contribute?

WITH CustomerRevenue AS
(SELECT
COALESCE(C.FirstName+' '+C.LastName,C.FirstName) AS Customer,
SUM(Sales) AS Customer_Revenue
FROM Sales.Orders AS O 
LEFT JOIN Sales.Customers AS C 
ON C.CustomerID=O.CustomerID
GROUP BY COALESCE(C.FirstName+' '+C.LastName,C.FirstName)),

TotalRevenue AS 
( SELECT SUM(Sales) AS Total_Revenue FROM Sales.Orders)

SELECT
Customer,
Customer_Revenue*100/Total_Revenue AS Customer_pct_of_TotalRevenue
FROM  CustomerRevenue
CROSS JOIN TotalRevenue
ORDER BY  Customer_pct_of_TotalRevenue DESC

-- Q6. Which customers are repeat customers?
-- Identify customers who have placed more than one order.

SELECT
COALESCE(C.FirstName+' '+C.LastName,C.FirstName) AS Customer,
COUNT(O.OrderID) AS Number_of_orders,
SUM(O.Sales) AS Total_Revenue
FROM Sales.Orders AS O 
LEFT JOIN Sales.Customers AS C 
ON C.CustomerID=O.CustomerID
GROUP BY COALESCE(C.FirstName+' '+C.LastName,C.FirstName)
HAVING COUNT(O.OrderID)>1

-- Q7. How can customers be segmented into High Value,
-- Medium Value, and Low Value based on their total revenue?

WITH Customer_Metrics AS 
(
SELECT
COALESCE(C.FirstName+' '+C.LastName,C.FirstName) AS Customer,
SUM(O.Sales) AS Customer_Revenue
FROM Sales.Orders AS O 
LEFT JOIN Sales.Customers AS C 
ON C.CustomerID=O.CustomerID
GROUP BY COALESCE(C.FirstName+' '+C.LastName,C.FirstName))

SELECT 
Customer,
Customer_Revenue,
CASE WHEN Customer_Revenue >120 THEN 'High Value'
WHEN Customer_Revenue BETWEEN 60 AND 120 THEN 'Medium Value' 
ELSE 'Low Value' END AS Customer_Segment 
FROM Customer_Metrics 
ORDER BY Customer_Revenue DESC

-- Q8. Who is the highest-revenue customer in each country?

SELECT
COALESCE(C.FirstName+' '+C.LastName,C.FirstName) AS Customer,
C.Country,
SUM(O.Sales) AS Customer_Revenue,
RANK()OVER(Partition BY C.Country ORDER BY SUM(O.Sales) DESC) AS Customer_Revenueper_Country
FROM Sales.Orders AS O 
LEFT JOIN Sales.Customers AS C 
ON C.CustomerID=O.CustomerID
GROUP BY COALESCE(C.FirstName+' '+C.LastName,C.FirstName), C.Country


-- Q9. Which customers have high total revenue but low order frequency,
-- and which customers have frequent orders but relatively low average order value?

WITH CustomerMetrics AS
(
SELECT
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName) AS Customer,
COUNT(DISTINCT O.OrderID) AS Number_of_Orders,
SUM(O.Sales) AS Total_Revenue,
SUM(O.Sales) * 1.0 / NULLIF(COUNT(DISTINCT O.OrderID), 0) AS Average_Order_Value
FROM Sales.Orders AS O
LEFT JOIN Sales.Customers AS C
ON C.CustomerID = O.CustomerID
GROUP BY
O.CustomerID,
COALESCE(C.FirstName + ' ' + C.LastName, C.FirstName)
),

Benchmarks AS
(
SELECT
*,
AVG(Total_Revenue) OVER () AS Avg_Customer_Revenue,
AVG(Number_of_Orders) OVER () AS Avg_Customer_Orders,
AVG(Average_Order_Value) OVER () AS Avg_Customer_AOV
FROM CustomerMetrics
)

SELECT
Customer,
Number_of_Orders,
Total_Revenue,
Average_Order_Value,
CASE
WHEN Total_Revenue > Avg_Customer_Revenue
AND Number_of_Orders < Avg_Customer_Orders
THEN 'High Revenue - Low Frequency'

WHEN Number_of_Orders > Avg_Customer_Orders
AND Average_Order_Value < Avg_Customer_AOV
THEN 'High Frequency - Low AOV'

ELSE 'Other'
END AS Customer_Profile
FROM Benchmarks
ORDER BY Total_Revenue DESC

 /*

# END OF PHASE 3

*/
