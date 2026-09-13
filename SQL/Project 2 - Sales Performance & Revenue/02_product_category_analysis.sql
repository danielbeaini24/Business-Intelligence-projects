/*

PROJECT: Sales Performance & Revenue Intelligence
PHASE 2: Product & Category Intelligence


*/

-- Q1. Which products generate the most revenue?

SELECT
O.ProductID,
P.Product,
SUM(O.Sales) AS Revenue
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID=O.ProductID
GROUP BY O.ProductID,
P.Product
ORDER BY Revenue DESC

-- Q2. Which products sell the most units?

SELECT
O.ProductID,
P.Product,
SUM(O.Quantity) AS Units
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID=O.ProductID
GROUP BY O.ProductID,
P.Product
ORDER BY Units DESC

-- Q3. Which products generate the highest average revenue per order?

SELECT
O.ProductID,
P.Product,
AVG(Sales) AS Average_Revenue
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID=O.ProductID
GROUP BY O.ProductID,
P.Product
ORDER BY average_revenue DESC

-- Q4. How much revenue does each product category generate?

SELECT
P.Category,
SUM(O.Sales) AS Revenue
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID=O.ProductID
GROUP BY P.Category
ORDER BY Revenue DESC

-- Q5. What percentage of total revenue comes from each product category?

WITH CategoryRevenue AS
(SELECT
P.Category,
SUM(O.Sales) AS Revenue
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID = O.ProductID
GROUP BY P.Category)

SELECT
Category,
Revenue,
Revenue * 100.0 / SUM(Revenue) OVER () AS Revenue_Pct
FROM CategoryRevenue
ORDER BY Revenue DESC

-- Q6. Within each category, how does each product rank by revenue?

WITH ProductRev AS
(SELECT
P.Category,
P.Product,
SUM(O.Sales) AS Revenue
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID = O.ProductID
GROUP BY
P.Category,
P.Product)

SELECT
Category,
Product,
Revenue,
RANK() OVER( PARTITION BY Category ORDER BY Revenue DESC) AS Rank_Within_Category
FROM ProductRev
ORDER BY
Category,Rank_Within_Category

-- Q7. Which products contribute the largest share of total revenue?

WITH REV AS 
(SELECT 
SUM(Sales) AS total_revenue
FROM Sales.Orders)


SELECT 
Product,
SUM(Sales)*100/total_revenue AS product_revenue_share
FROM Sales.Orders AS O
CROSS JOIN REV
LEFT JOIN Sales.Products AS P 
ON O.ProductID=P.ProductID
GROUP BY Product, total_revenue
ORDER BY product_revenue_share DESC 

-- Q8. Which products have high revenue but relatively low sales volume?

WITH ProductMetrics AS (
SELECT
P.Product,
SUM(O.Sales) AS Revenue,
SUM(Quantity) AS Units
FROM Sales.Orders AS O
LEFT JOIN Sales.Products AS P
ON P.ProductID=O.ProductID
GROUP BY P.Product),

Ranking AS (
SELECT 
Product,
Revenue,
Units,
RANK()OVER(Order By Revenue DESC) AS Revenue_Rank,
RANK()OVER(Order By Units DESC ) AS Units_RANK
FROM ProductMetrics)

SELECT
Product,
Revenue,
Units,
Revenue_Rank,
Units_Rank
FROM Ranking
WHERE Revenue_Rank < Units_Rank
ORDER BY Revenue_Rank




