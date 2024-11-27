use Data_Analytics_Portfolio
go

select *
from [Coffee Shop Sales]

select *
from [Coffee Shop Sales]
where transaction_date is null

select count(transaction_id)
from [Coffee Shop Sales]


SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Coffee Shop Sales'
  AND COLUMN_NAME = 'transaction_date';

--procedure provides detailed information about a table, 
--including column names, data types, and more.

EXEC sp_help 'Coffee Shop Sales';

--This is a standard way to get column information in SQL Server.
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Coffee Shop Sales';

 --Using sys.columns System View
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('Coffee Shop Sales');


SELECT *
FROM [Coffee Shop Sales]

--CONVERTING OUR TRANSACTION DATE TO DATE FORMAT

SELECT transaction_date
FROM [Coffee Shop Sales]
WHERE TRY_CONVERT(DATE, CAST(transaction_date AS VARCHAR(MAX)), 105) IS NULL;

--Add a New Column
ALTER TABLE [Coffee Shop Sales] ADD transaction_date_new DATE;

--Populate the new column with valid converted dates
UPDATE [Coffee Shop Sales]
SET transaction_date_new = TRY_CONVERT(DATE, CAST(transaction_date AS VARCHAR(MAX)), 105);

--Check for rows where the conversion failed
SELECT transaction_date
FROM [Coffee Shop Sales]
WHERE TRY_CONVERT(DATE, CAST(transaction_date AS VARCHAR(MAX)), 105) IS NULL;

--Drop the Old Column and Rename the New One(RENAMING BACK TO transaction_date)
ALTER TABLE [Coffee Shop Sales] DROP COLUMN transaction_date;
EXEC sp_rename '[Coffee Shop Sales].transaction_date_new', 'transaction_date', 'COLUMN';


--RECHECKING THE DATA TYPE
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Coffee Shop Sales'
  AND COLUMN_NAME = 'transaction_date';

--This is a standard way to get column information in SQL Server.
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Coffee Shop Sales';


--ANALYSIS
-- TOTAL SALES
SELECT
	ROUND (SUM(unit_price * transaction_qty), 2) AS total_sales
FROM [Coffee Shop Sales];

-- 1. Total Sales Analysis FOR EACH MONTH
SELECT 
    MONTH(transaction_date) AS month, 
   ROUND (SUM(unit_price * transaction_qty), 2) AS total_sales
FROM 
    [Coffee Shop Sales]
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    month;



--month-on-month increase or decrease in sales:
WITH monthly_sales AS (
    SELECT 
        MONTH(transaction_date) AS month, 
       ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales
    FROM 
       [Coffee Shop Sales]
    GROUP BY 
        MONTH(transaction_date)
)
SELECT 
    month, 
    total_sales, 
    total_sales - LAG(total_sales) OVER (ORDER BY month) AS sales_difference
FROM 
    monthly_sales;

-- Month-on-month increase or decrease in sales with percentage:
WITH monthly_sales AS (
    SELECT 
        MONTH(transaction_date) AS month, 
        ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales
    FROM 
        [Coffee Shop Sales]
    GROUP BY 
        MONTH(transaction_date)
)
SELECT 
    month, 
    total_sales, 
    total_sales - LAG(total_sales) OVER (ORDER BY month) AS sales_difference,
    -- Calculate the MoM percentage change:
    CASE 
        WHEN LAG(total_sales) OVER (ORDER BY month) = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND((total_sales - LAG(total_sales) OVER (ORDER BY month)) / 
		LAG(total_sales) OVER (ORDER BY month) * 100, 2)
    END AS mom_percentage_change
FROM 
    monthly_sales;

-- Difference in sales between the selected month and the previous month:
SELECT 
    current_month.month, 
    current_month.total_sales AS selected_month_sales, 
    previous_month.total_sales AS previous_month_sales,
    current_month.total_sales - previous_month.total_sales AS sales_difference
FROM 
    (SELECT MONTH(transaction_date) AS month, 
            SUM(unit_price * transaction_qty) AS total_sales 
     FROM [Coffee Shop Sales] 
     GROUP BY MONTH(transaction_date)) current_month
LEFT JOIN 
    (SELECT MONTH(transaction_date) AS month, 
            SUM(unit_price * transaction_qty) AS total_sales 
     FROM [Coffee Shop Sales] 
     GROUP BY MONTH(transaction_date)) previous_month
ON 
    current_month.month = previous_month.month + 1
    OR (current_month.month = 1 AND previous_month.month = 12) -- Handle December to January transition
ORDER BY 
    current_month.month;


--2. Total Orders Analysis

SELECT 
    MONTH(transaction_date) AS month, 
    COUNT(transaction_id) AS total_orders
FROM 
    [Coffee Shop Sales]
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    month;
--TOTAL ORDERS GENERALLY
SELECT
	COUNT(transaction_id) AS Total_orders
FROM [Coffee Shop Sales];


--month-on-month increase or decrease in the number of orders:
WITH monthly_orders AS (
    SELECT 
        MONTH(transaction_date) AS month, 
        COUNT(transaction_id) AS total_orders
    FROM 
        [Coffee Shop Sales]
    GROUP BY 
        MONTH(transaction_date)
)
SELECT 
    month, 
    total_orders, 
    total_orders - LAG(total_orders) OVER (ORDER BY month) AS orders_difference
FROM 
    monthly_orders;


-- Month-on-month increase or decrease in the number of orders with percentage:
WITH monthly_orders AS (
    SELECT 
        MONTH(transaction_date) AS month, 
        COUNT(transaction_id) AS total_orders
    FROM 
        [Coffee Shop Sales]
    GROUP BY 
        MONTH(transaction_date)
)
SELECT 
    month, 
    total_orders, 
    total_orders - LAG(total_orders) OVER (ORDER BY month) AS orders_difference,
    -- Calculate the MoM percentage change:
    CASE 
        WHEN LAG(total_orders) OVER (ORDER BY month) IS NULL THEN NULL  -- Avoid division by NULL for the first month
        WHEN LAG(total_orders) OVER (ORDER BY month) = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND((total_orders - LAG(total_orders) OVER (ORDER BY month)) * 100.0 / LAG(total_orders) OVER (ORDER BY month), 2)
    END AS mom_percentage_change
FROM 
    monthly_orders
ORDER BY 
    month;


--Difference in the number of orders between the selected month and the previous month:
SELECT 
    current_month.month, 
    current_month.total_orders AS selected_month_orders, 
    previous_month.total_orders AS previous_month_orders,
    current_month.total_orders - previous_month.total_orders AS orders_difference
FROM 
    (SELECT MONTH(transaction_date) AS month, COUNT(transaction_id) AS total_orders FROM [Coffee Shop Sales] GROUP BY MONTH(transaction_date)) current_month
LEFT JOIN 
    (SELECT MONTH(transaction_date) AS month, COUNT(transaction_id) AS total_orders FROM [Coffee Shop Sales] GROUP BY MONTH(transaction_date)) previous_month
ON 
    current_month.month = previous_month.month + 1
ORDER BY
	current_month.month;
--3. Total Quantity
SELECT SUM(transaction_qty) AS Total_qty_sold
FROM [Coffee Shop Sales]

--3. Total Quantity Sold Analysis
SELECT 
    MONTH(transaction_date) AS month, 
    SUM(transaction_qty) AS total_quantity_sold
FROM 
    [Coffee Shop Sales]
GROUP BY 
    MONTH(transaction_date)
ORDER BY
	month;


--month-on-month increase or decrease in the total quantity sold:
WITH monthly_quantity AS (
    SELECT 
        MONTH(transaction_date) AS month, 
        SUM(transaction_qty) AS total_quantity_sold
    FROM 
        [Coffee Shop Sales]
    GROUP BY 
        MONTH(transaction_date)
)
SELECT 
    month, 
    total_quantity_sold, 
    total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month) AS quantity_difference
FROM 
    monthly_quantity;


-- Month-on-month increase or decrease in the total quantity sold with percentage:
WITH monthly_quantity AS (
    SELECT 
        MONTH(transaction_date) AS month, 
        SUM(transaction_qty) AS total_quantity_sold
    FROM 
        [Coffee Shop Sales]
    GROUP BY 
        MONTH(transaction_date)
)
SELECT 
    month, 
    total_quantity_sold, 
    total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month) AS quantity_difference,
    -- Calculate the MoM percentage change:
    CASE 
        WHEN LAG(total_quantity_sold) OVER (ORDER BY month) IS NULL THEN NULL  -- Avoid division by NULL for the first month
        WHEN LAG(total_quantity_sold) OVER (ORDER BY month) = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND((total_quantity_sold - LAG(total_quantity_sold) OVER (ORDER BY month)) * 100.0 /
		LAG(total_quantity_sold) OVER (ORDER BY month), 2)
    END AS mom_percentage_change
FROM 
    monthly_quantity
ORDER BY 
    month;

--Difference in the total quantity sold between the selected month and the previous month:
SELECT 
    current_month.month, 
    current_month.total_quantity_sold AS selected_month_quantity, 
    previous_month.total_quantity_sold AS previous_month_quantity,
    current_month.total_quantity_sold - previous_month.total_quantity_sold AS quantity_difference
FROM 
    (SELECT MONTH(transaction_date) AS month, SUM(transaction_qty) AS total_quantity_sold FROM [Coffee Shop Sales] GROUP BY MONTH(transaction_date)) current_month
LEFT JOIN 
    (SELECT MONTH(transaction_date) AS month, SUM(transaction_qty) AS total_quantity_sold FROM [Coffee Shop Sales] GROUP BY MONTH(transaction_date)) previous_month
ON 
    current_month.month = previous_month.month + 1
ORDER BY
	current_month.month;

--REQUIRED METRICS
SELECT
	ROUND(SUM(unit_price*transaction_qty), 2) AS Total_Sales,
	sum(transaction_qty) AS Total_quantity_Sold,
	count(transaction_id) AS Total_Orders
FROM [Coffee Shop Sales]

WHERE transaction_date = '2023-05-18'

--DISPLAYING IN FORM OF K
SELECT
    CAST(ROUND(SUM(unit_price * transaction_qty) / 1000.0, 1) AS VARCHAR) + 'k' AS Total_Sales,
    CAST(ROUND(SUM(transaction_qty) / 1000.0,1) AS varchar) + 'k' AS Total_Quantity_Sold,
    CAST(ROUND(COUNT(transaction_id) / 1000.0, 1) AS varchar) + 'k' AS Total_Orders
FROM [Coffee Shop Sales]
WHERE transaction_date = '2023-05-18';


--To avoid unnecessary trailing zeros
SELECT
    FORMAT(SUM(unit_price * transaction_qty) / 1000.0, '0.#') + 'k' AS Total_Sales,
    FORMAT(SUM(transaction_qty) / 1000.0, '0.#') + 'k' AS Total_Quantity_Sold,
    FORMAT(COUNT(transaction_id) / 1000.0, '0.#') + 'k' AS Total_Orders
FROM [Coffee Shop Sales]
WHERE transaction_date = '2023-05-18';


--DISPLAYING IN FORM OF K
SELECT
    CAST(ROUND(SUM(unit_price * transaction_qty) / 1000.0, 1) AS VARCHAR) + 'k' AS Total_Sales,
    CAST(ROUND(SUM(transaction_qty) / 1000.0,1) AS varchar) + 'k' AS Total_Quantity_Sold,
    CAST(ROUND(COUNT(transaction_id) / 1000.0, 1) AS varchar) + 'k' AS Total_Orders
FROM [Coffee Shop Sales]
WHERE transaction_date = '2023-05-18';


--To avoid unnecessary trailing zeros
SELECT
    FORMAT(SUM(unit_price * transaction_qty) / 1000.0, '0.#') + 'k' AS Total_Sales,
    FORMAT(SUM(transaction_qty) / 1000.0, '0.#') + 'k' AS Total_Quantity_Sold,
    FORMAT(COUNT(transaction_id) / 1000.0, '0.#') + 'k' AS Total_Orders
FROM [Coffee Shop Sales]
WHERE transaction_date = '2023-03-27';


-- Sales analysis by weekdays and weekends
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    COUNT(transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM 
    [Coffee Shop Sales]

-- USE FILTER TO GET YOUR MONTHS
--WHERE MONTH(transaction_date) = 4
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END;

--FILTERING BY DAY
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    COUNT(transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM 
    [Coffee Shop Sales]
WHERE 
    DAY(transaction_date) = 5
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END;

--FILTERING BY SPECIFIC DATE
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    COUNT(transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM 
    [Coffee Shop Sales]
WHERE 
    transaction_date = '2023-05-05'  -- Replace with the desired date
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END;


--FILTERINFG BY MONTH
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    COUNT(transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM 
    [Coffee Shop Sales]
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END;


--CHECKING THE NUMBER OF STORE LOCATIONS
SELECT store_location,
	ROUND(SUM(unit_price * transaction_qty),2) AS Total_Sales
FROM [Coffee Shop Sales]
GROUP BY store_location;

-- Sales analysis by store location with MOM AND MoM difference
WITH monthly_sales_by_location AS (
    SELECT 
        Store_Location, 
        MONTH(transaction_date) AS month, 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        [Coffee Shop Sales]
    GROUP BY 
        Store_Location, 
        MONTH(transaction_date)
),
sales_with_mom_difference AS (
    SELECT 
        Store_Location,
        month,
        total_sales,
        total_sales - LAG(total_sales) OVER (PARTITION BY Store_Location ORDER BY month) AS sales_difference,
        CASE 
            WHEN LAG(total_sales) OVER (PARTITION BY Store_Location ORDER BY month) IS NULL THEN NULL
            ELSE ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY Store_Location ORDER BY month)) * 100.0 / LAG(total_sales) OVER (PARTITION BY Store_Location ORDER BY month), 2)
        END AS mom_percentage
    FROM 
        monthly_sales_by_location
)
SELECT 
    Store_Location, 
    month,
    total_sales,
    sales_difference,
    mom_percentage
FROM 
    sales_with_mom_difference
ORDER BY 
    Store_Location, 
    month;

--NUMBER OF PRODUCTS SOLD WITH ITS PRICESS
SELECT 
	product_type,
	COUNT(product_type) AS Number_Sold,
	ROUND(SUM(unit_price *transaction_qty),1) AS Total_Sales
FROM [Coffee Shop Sales]
	GROUP BY
		product_type
ORDER BY
	Number_Sold DESC

 --Daily Sales Analysis with Average Line
 SELECT 
    transaction_date,
    ROUND(SUM(unit_price * transaction_qty), 2) AS daily_sales,
    AVG(ROUND(SUM(unit_price * transaction_qty), 2)) OVER () AS average_sales,
    CASE 
        WHEN ROUND(SUM(unit_price * transaction_qty), 2) > 
		AVG(ROUND(SUM(unit_price * transaction_qty), 2)) OVER () THEN 'Above Average'
        ELSE 'Below Average'
    END AS sales_status
FROM 
    [Coffee Shop Sales]
-- filter for the months
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    transaction_date
ORDER BY
 transaction_date


--Sales Analysis by Product Category
SELECT 
    product_category,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    SUM(transaction_qty) AS total_quantity,
    COUNT(DISTINCT transaction_id) AS total_orders
FROM 
    [Coffee Shop Sales]
WHERE MONTH(transaction_date) = 5
GROUP BY 
    product_category
ORDER BY 
    total_sales DESC;


--NUMBER OF PRODUCTS SOLD WITH ITS PRICESS
SELECT TOP 10
	product_type,
	COUNT(product_type) AS Number_Sold,
	ROUND(SUM(unit_price *transaction_qty),1) AS Total_Sales
FROM [Coffee Shop Sales]
	GROUP BY
		product_type
ORDER BY
	Number_Sold DESC;

--Top 10 Products by Sales
SELECT TOP 10 
    product_type,
    product_category,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    SUM(transaction_qty) AS total_quantity,
    COUNT(transaction_id) AS total_orders,
	COUNT(product_type) AS Number_Sold
FROM 
    [Coffee Shop Sales]
WHERE MONTH(transaction_date) = 5
GROUP BY 
    product_type, product_category
ORDER BY 
    total_sales DESC;

SELECT 
	product_category,
	SUM(unit_price*transaction_qty) AS Total_Sales
FROM [Coffee Shop Sales]
WHERE MONTH(transaction_date) = 5
GROUP BY
	product_category
ORDER BY
	SUM(unit_price*transaction_qty)
	DESC


--Sales Analysis by Days and Hours
SELECT 
    DATENAME(WEEKDAY, transaction_date) AS day_of_week,
    DATEPART(HOUR, transaction_time) AS hour_of_day,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales,
    COUNT(transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM 
    [Coffee Shop Sales]
GROUP BY 
    DATENAME(WEEKDAY, transaction_date), 
    DATEPART(HOUR, transaction_time)
ORDER BY 
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Monday' THEN 1
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Tuesday' THEN 2
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Wednesday' THEN 3
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Thursday' THEN 4
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Friday' THEN 5
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Saturday' THEN 6
        WHEN DATENAME(WEEKDAY, transaction_date) = 'Sunday' THEN 7
    END, 
    hour_of_day;



