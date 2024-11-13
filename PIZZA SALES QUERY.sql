CREATE DATABASE Data_Analytics_Portfolio;

use [Data_Analytics_Portfolio]
go

SELECT *
FROM [dbo].[pizza_sales]
--KPI 1
--TOTATL REVENUE
SELECT
	 ROUND(SUM(total_price), 2) AS Total_Revenue
FROM pizza_sales

--AVERAGE ORDER VALUE
SELECT
	 SUM(total_price) / 
	 COUNT(DISTINCT order_id) AS Average_Order_Value
FROM pizza_sales

--TOTAL PIZZA SOLD
SELECT
	SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales

--TOTAL ORDER
SELECT 
	COUNT( DISTINCT order_id) AS Total_Order 
FROM pizza_sales


--AVERAGE PIZZA PER ORDER
SELECT
	CAST(
	CAST(SUM(quantity) AS decimal(10, 2)) /
	CAST(COUNT(DISTINCT order_id) AS decimal (10, 2)) 
	AS decimal (10, 2))
	AS Average_Pizza_Per_Order
FROM pizza_sales

 --2
--DAILY TREND FOR TOTAL ORDERS

SELECT 
	DATENAME(DW, order_date) AS Order_Day,
		COUNT(DISTINCT order_id) AS Total_Orders

FROM pizza_sales
GROUP BY DATENAME(DW, order_date)
order by DATENAME(DW, order_date)

--TO MAKE THE WEEK START ON MONDAY NO MATTER THE TOTAL ORDERS
SELECT 
    DATENAME(DW, order_date) AS Order_Day,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY DATENAME(DW, order_date), DATEPART(WEEKDAY, order_date)
ORDER BY 
    CASE DATEPART(WEEKDAY, order_date)
        WHEN 2 THEN 1  -- Monday
        WHEN 3 THEN 2  -- Tuesday
        WHEN 4 THEN 3  -- Wednesday
        WHEN 5 THEN 4  -- Thursday
        WHEN 6 THEN 5  -- Friday
        WHEN 7 THEN 6  -- Saturday
        WHEN 1 THEN 7  -- Sunday
    END;

--MONTHLY TREND FOR TOTAL ORDERS
SELECT 
	DATENAME(MONTH, order_date) AS Order_Month,
		COUNT(DISTINCT order_id) AS Total_Orders

FROM pizza_sales
GROUP BY DATENAME(MONTH, order_date)

--FOR THE MONTH TO START FROM JANUARY
SELECT 
    DATENAME(MONTH, order_date) AS Order_Month,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY DATENAME(MONTH, order_date), DATEPART(MONTH, order_date)
ORDER BY DATEPART(MONTH, order_date);

--PERCENTAGE OF SALES BY PIZZA CATEGORY
SELECT pizza_category
FROM pizza_sales
GROUP BY pizza_category

SELECT 
	pizza_category, ROUND(SUM(total_price) * 100 /
	(SELECT SUM(total_price) FROM pizza_sales), 2 )AS Percentage_Of_Pizza_Sales
FROM pizza_sales
GROUP BY pizza_category

-- or
WITH Total_Sales AS (
    SELECT SUM(total_price) AS Total_Price
    FROM pizza_sales
)
SELECT 
    pizza_category, 
    SUM(pizza_sales.total_price) * 100.0 / Total_Sales.Total_Price AS Percentage_Of_Pizza_Sales
FROM pizza_sales
CROSS JOIN Total_Sales
GROUP BY pizza_category, Total_Sales.Total_Price;

--ROUNDING IT UP
SELECT 
    pizza_category, ROUND(SUM(total_price), 2) AS Total_Price,
	ROUND(SUM(total_price) * 100.0 / 
	(SELECT SUM(total_price) FROM pizza_sales WHERE  MONTH(order_date) = 1), 2) 
	AS Percentage_Of_Pizza_Sales
FROM pizza_sales
--FILTER
WHERE  MONTH(order_date) = 1 --JANUARY
GROUP BY pizza_category;

-- PERCENTAGE OF SALES BY PIZZA SIZE
SELECT 
	pizza_size, ROUND(SUM(total_price), 2) Total_Sales, ROUND(SUM(total_price) * 100 /
	(SELECT SUM(total_price) FROM pizza_sales WHERE DATEPART(QUARTER, order_date) = 1), 2 )
	AS Percentage_Of_Pizza_Sales
FROM pizza_sales
WHERE DATEPART(QUARTER, order_date) = 1
GROUP BY pizza_size
ORDER BY Percentage_Of_Pizza_Sales DESC

-- TOP 5 BEST SELLERS BY REVENUE, TOTAL QUANTITY AND TOTAL ORDERS
-- TOP 5 REVENUE
SELECT TOP 5
	SUM(quantity) AS Total_quantitieS,
	pizza_name,
	COUNT(DISTINCT order_id) AS Total_Order,
	SUM(total_price) AS Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Revenue desc

--FOR BOTTOM
-- TOP 5 BEST SELLERS BY REVENUE, TOTAL QUANTITY AND TOTAL ORDERS
SELECT TOP 5
	SUM(quantity) AS Total_quantities,
	pizza_name,
	COUNT(DISTINCT order_id) AS Total_Order,
	SUM(total_price) AS Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Revenue ASC


-- BY QUANTITY
SELECT TOP 5
	pizza_name,
	COUNT(DISTINCT order_id) AS Total_Order,
	SUM(quantity) AS Total_quantities
FROM pizza_sales
GROUP BY pizza_name
ORDER BY SUM(quantity) desc

--BY TOTAL ORDER
SELECT TOP 5
	pizza_name,
	COUNT(DISTINCT order_id) AS Total_Order
FROM pizza_sales
GROUP BY pizza_name
ORDER BY COUNT(DISTINCT order_id) DESC





