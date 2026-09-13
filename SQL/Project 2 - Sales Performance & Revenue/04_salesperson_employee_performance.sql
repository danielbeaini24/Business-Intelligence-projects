/*

PROJECT: Sales Performance & Revenue Intelligence
PHASE 4: Salesperson & Employee Performance Intelligence

*/
SELECT * FROM Sales.Employees
SELECT * FROM Sales.Orders
-- Q1. Which salespeople generate the most revenue?

SELECT
E.EmployeeID,
COALESCE(E.FirstName+' '+E.LastName,E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales),0) AS Revenue
FROM Sales.Employees AS E 
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID=E.EmployeeID
GROUP BY E.EmployeeID , COALESCE(E.FirstName+' '+E.LastName,E.FirstName) 
ORDER BY Revenue DESC 

-- Q2. Which salespeople handle the most orders?

SELECT
E.EmployeeID,
COALESCE(E.FirstName+' '+E.LastName,E.FirstName) AS EmployeeName,
COALESCE(COUNT(DISTINCT O.OrderID),0) AS Number_Of_Ordders
FROM Sales.Employees AS E 
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID=E.EmployeeID
GROUP BY E.EmployeeID , COALESCE(E.FirstName+' '+E.LastName,E.FirstName) 
ORDER BY Number_Of_Ordders DESC 

-- Q3. Which salespeople generate the highest average revenue per order?

SELECT
E.EmployeeID,
COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName) AS EmployeeName,
SUM(O.Sales) * 1.0 / NULLIF(COUNT(DISTINCT O.OrderID), 0) AS Average_Revenue_Per_Order
FROM Sales.Employees AS E
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID = E.EmployeeID
GROUP BY
E.EmployeeID, COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName)
ORDER BY Average_Revenue_Per_Order DESC

-- Q4. How do salespeople rank by total revenue?

SELECT
E.EmployeeID,
COALESCE(E.FirstName+' '+E.LastName,E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales),0) AS Revenue,
RANK()OVER( ORDER BY COALESCE(SUM(O.Sales),0) DESC) AS Employee_Rank
FROM Sales.Employees AS E 
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID=E.EmployeeID
GROUP BY E.EmployeeID , COALESCE(E.FirstName+' '+E.LastName,E.FirstName) 



-- Q5. What percentage of total company revenue does each salesperson contribute?

WITH EmployeeRev AS 
(
SELECT
E.EmployeeID,
COALESCE(E.FirstName+' '+E.LastName,E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales),0) AS Revenue
FROM Sales.Employees AS E 
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID=E.EmployeeID
GROUP BY E.EmployeeID , COALESCE(E.FirstName+' '+E.LastName,E.FirstName)),

TotalRev AS 
( SELECT COALESCE(SUM(Sales),0) AS Total_Revenue FROM Sales.Orders)

SELECT 
EmployeeID,
EmployeeName,
Revenue*100.0/NULLIF(Total_Revenue,0) AS Employees_Pct_TotalRevenue
FROM EmployeeRev
CROSS JOIN TotalRev
ORDER BY Employees_Pct_TotalRevenue DESC

-- Q6. Which salespeople have the highest average order value?

SELECT
E.EmployeeID,
COALESCE(E.FirstName+' '+E.LastName,E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales),0) /NULLIF(COUNT(DISTINCT O.OrderID),0) AS Average_Order_Value
FROM Sales.Employees AS E 
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID=E.EmployeeID
GROUP BY E.EmployeeID , COALESCE(E.FirstName+' '+E.LastName,E.FirstName) 
ORDER BY Average_Order_Value DESC

-- Q7. Which salespeople generate high revenue with relatively few orders?

WITH EmployeeMetrics AS
(SELECT
E.EmployeeID,
COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales), 0) AS Revenue,
COUNT(DISTINCT O.OrderID) AS Number_Of_Orders
FROM Sales.Employees AS E
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID = E.EmployeeID
GROUP BY
E.EmployeeID, COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName)),

Benchmarks AS
(SELECT
*,
AVG(Revenue) OVER () AS Average_Revenue,
AVG(Number_Of_Orders) OVER () AS Average_Number_Of_Orders
FROM EmployeeMetrics)

SELECT
EmployeeID,
EmployeeName,
Revenue,
Number_Of_Orders
FROM Benchmarks
WHERE Revenue > Average_Revenue AND Number_Of_Orders < Average_Number_Of_Orders
ORDER BY Revenue DESC

-- Q8. Which salespeople generate high order volume but relatively low revenue?

WITH EmployeeMetrics AS
(
SELECT
E.EmployeeID,
COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales), 0) AS Total_Revenue,
COUNT(DISTINCT O.OrderID) AS Number_Of_Orders,
COALESCE(SUM(O.Sales), 0) * 1.0/ NULLIF(COUNT(DISTINCT O.OrderID), 0) AS Average_Order_Value
FROM Sales.Employees AS E
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID = E.EmployeeID
GROUP BY
E.EmployeeID,COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName)),

Benchmarks AS
(SELECT
*,
AVG(Total_Revenue) OVER () AS Average_Revenue,
AVG(Number_Of_Orders) OVER () AS Average_Number_Of_Orders
FROM EmployeeMetrics)

SELECT
EmployeeID,
EmployeeName,
Total_Revenue,
Number_Of_Orders,
Average_Order_Value
FROM Benchmarks
WHERE Total_Revenue < Average_Revenue
AND Number_Of_Orders > Average_Number_Of_Orders
ORDER BY Number_Of_Orders DESC



-- Q9. How does each salesperson's revenue compare with the average salesperson?

WITH EmployeeMetrics AS
(
SELECT
E.EmployeeID,
COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales), 0) AS Revenue
FROM Sales.Employees AS E
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID = E.EmployeeID
GROUP BY
E.EmployeeID, COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName)
),

Benchmarks AS
(SELECT
*,
AVG(Revenue) OVER () AS Average_Salesperson_Revenue
FROM EmployeeMetrics)

SELECT
EmployeeID,
EmployeeName,
Revenue,
Average_Salesperson_Revenue,
Revenue - Average_Salesperson_Revenue AS Difference_From_Average,
CASE
WHEN Revenue > Average_Salesperson_Revenue THEN 'Above Average'
WHEN Revenue < Average_Salesperson_Revenue THEN 'Below Average'
ELSE 'Average'
END AS Employee_Performance
FROM Benchmarks
ORDER BY Revenue DESC

-- Q10. Which salesperson has shown the strongest overall sales performance
-- when considering revenue, order volume, and average order value?

WITH EmployeeMetrics AS
(
SELECT
E.EmployeeID,
COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName) AS EmployeeName,
COALESCE(SUM(O.Sales), 0) AS Revenue,
COUNT(DISTINCT O.OrderID) AS Number_Of_Orders,
COALESCE(SUM(O.Sales), 0) * 1.0/ NULLIF(COUNT(DISTINCT O.OrderID), 0) AS Average_Order_Value
FROM Sales.Employees AS E
LEFT JOIN Sales.Orders AS O
ON O.SalesPersonID = E.EmployeeID
GROUP BY
E.EmployeeID,COALESCE(E.FirstName + ' ' + E.LastName, E.FirstName)
),

EmployeeRanks AS
(
SELECT
*,
RANK() OVER (ORDER BY Revenue DESC) AS Revenue_Rank,
RANK() OVER (ORDER BY Number_Of_Orders DESC) AS Order_Volume_Rank,
RANK() OVER (ORDER BY Average_Order_Value DESC) AS AOV_Rank
FROM EmployeeMetrics
)

SELECT
EmployeeID,
EmployeeName,
Revenue,
Number_Of_Orders,
Average_Order_Value,
Revenue_Rank,
Order_Volume_Rank,
AOV_Rank,
Revenue_Rank+Order_Volume_Rank+AOV_Rank AS Performance_Score
FROM EmployeeRanks
ORDER BY Performance_Score

/*

# END OF PHASE 4

*/
