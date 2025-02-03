USE Data_Analytics_Portfolio
GO

SELECT *
FROM df_orders

-- FIND TOP 10 HIGHEST REVENUE GENERATING PRODUCTS
SELECT TOP 10
	product_id,
	SUM(sale_price) SALES
FROM df_orders
	GROUP BY product_id
	ORDER BY SALES DESC;

WITH CTE AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS SALES
    FROM df_orders
    GROUP BY region, product_id
)
SELECT * FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY SALES DESC) AS RN
    FROM CTE
) A
WHERE RN <= 5;

-- FIND MONTH OVER MONTH GROWTH COMPARISON FOR 2022 AND 2023 SALES

WITH CTE AS (
    SELECT 
        YEAR(order_date) AS ORDER_YEAR,
        MONTH(order_date) AS ORDER_MONTH,
        SUM(sale_price) AS SALES
    FROM df_orders
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    ORDER_MONTH,
    SUM(CASE WHEN ORDER_YEAR = 2022 THEN SALES ELSE 0 END) AS SALES_2022,
    SUM(CASE WHEN ORDER_YEAR = 2023 THEN SALES ELSE 0 END) AS SALES_2023,
    CASE 
        WHEN SUM(CASE WHEN ORDER_YEAR = 2022 THEN SALES ELSE 0 END) = 0 
        THEN NULL
        ELSE 
            ROUND(
                (SUM(CASE WHEN ORDER_YEAR = 2023 THEN SALES ELSE 0 END) - 
                 SUM(CASE WHEN ORDER_YEAR = 2022 THEN SALES ELSE 0 END)) 
                * 100.0 / SUM(CASE WHEN ORDER_YEAR = 2022 THEN SALES ELSE 0 END), 2
            )
    END AS GROWTH_PERCENTAGE
FROM CTE
GROUP BY ORDER_MONTH
ORDER BY ORDER_MONTH;


-- FOR EACH CATEGORY WHICH MONTH HAS THE HIGHEST SALES

WITH MonthlySales AS (
    SELECT 
        category,
        DATENAME(MONTH, order_date) AS ORDER_MONTH,  -- Month name
        MONTH(order_date) AS ORDER_MONTH_NUM,  -- Month number (for ordering)
        SUM(sale_price) AS TOTAL_SALES  -- Total sales per month per category
    FROM df_orders
    GROUP BY category, DATENAME(MONTH, order_date), MONTH(order_date)
),
RankedSales AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY TOTAL_SALES DESC) AS RN
    FROM MonthlySales
)
SELECT category, ORDER_MONTH, TOTAL_SALES
FROM RankedSales
WHERE RN = 1
ORDER BY category;

-- WHICH SUB CATEGORY HAD THE HIGHEST GROWTH BY PROFIT IN 2023 COMPARE TO 2022

WITH YearlyProfit AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS ORDER_YEAR,
        SUM(profit) AS TOTAL_PROFIT
    FROM df_orders
    WHERE YEAR(order_date) IN (2022, 2023)  -- Filter for only 2022 and 2023
    GROUP BY sub_category, YEAR(order_date)
),
ProfitComparison AS (
    SELECT 
        sub_category,
        MAX(CASE WHEN ORDER_YEAR = 2022 THEN TOTAL_PROFIT ELSE 0 END) AS PROFIT_2022,
        MAX(CASE WHEN ORDER_YEAR = 2023 THEN TOTAL_PROFIT ELSE 0 END) AS PROFIT_2023
    FROM YearlyProfit
    GROUP BY sub_category
)
SELECT TOP 1 
    sub_category,
    PROFIT_2022,
    PROFIT_2023,
    (PROFIT_2023 - PROFIT_2022) AS PROFIT_GROWTH,
    ((PROFIT_2023 - PROFIT_2022) * 100.0 / NULLIF(PROFIT_2022, 0)) AS GROWTH_PERCENTAGE
FROM ProfitComparison
ORDER BY PROFIT_GROWTH DESC;





