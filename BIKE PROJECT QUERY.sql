SELECT TOP 200*
FROM bike_share_yr_0


-- 1ST DATASET
-- CHECKING HOW MANY SEASONS WE HAVE IN THE DATA
SELECT season
FROM bike_share_yr_0
GROUP BY season
ORDER BY season

-- 2ND DATASET
SELECT *
FROM [dbo].[bike_share_yr_1]

SELECT season
FROM bike_share_yr_1
GROUP BY season
ORDER BY season

-- 3RD DATASET
SELECT *
FROM [dbo].[cost_table]

-- JOINING THE  TABLES TOGETHER

SELECT *
FROM bike_share_yr_0
UNION ALL --DOESN'T DUPLICATE ROLLS
SELECT *
FROM bike_share_yr_1

SELECT *
FROM bike_share_yr_0
UNION --REMOVE DUPLICATED ROLLS
SELECT *
FROM bike_share_yr_1

-- TO JOUIN THE THREE, WE USE CTE(COMMON TABLE EXPRESSION)
WITH CTE AS(
	SELECT *
		FROM bike_share_yr_0
		UNION --REMOVE DUPLICATED ROLLS
	SELECT *
		FROM bike_share_yr_1
)
SELECT * FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr

-- TAKING THE MOST IMPORTANT COLUMNS TO USE
WITH CTE AS(
	SELECT *
		FROM bike_share_yr_0
		UNION --REMOVE DUPLICATED ROLLS
	SELECT *
		FROM bike_share_yr_1
)
SELECT 
	[dteday],
	[season],
	A.[yr],
	[weekday],
	[hr],
	[rider_type],
	[riders],
	[price],
	[COGS]
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr

-- CALCULATING THE REVENUE
WITH CTE AS(
	SELECT *
		FROM bike_share_yr_0
		UNION --REMOVE DUPLICATED ROLLS
	SELECT *
		FROM bike_share_yr_1
)
SELECT 
	(riders*price) AS Revenue	
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr


-- CALCULATING THE PROFIT
WITH CTE AS(
	SELECT *
		FROM bike_share_yr_0
		UNION --REMOVE DUPLICATED ROLLS
	SELECT *
		FROM bike_share_yr_1
)
SELECT 
	(riders*price)- COGS AS Profit
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr


-- Hourly Revenue
WITH CTE AS (
    SELECT *
    FROM bike_share_yr_0
    UNION --REMOVE DUPLICATED ROWS
    SELECT *
    FROM bike_share_yr_1
)
SELECT 
    hr AS Hour,
    ROUND(SUM(riders * price), 2) AS Hourly_Revenue
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr
GROUP BY hr
ORDER BY hr;


-- Seasonal Revenue
WITH CTE AS (
    SELECT *
    FROM bike_share_yr_0
    UNION --REMOVE DUPLICATED ROWS
    SELECT *
    FROM bike_share_yr_1
)
SELECT 
    season AS Season,
    ROUND(SUM(riders * price), 2) AS Seasonal_Revenue
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr
GROUP BY season
ORDER BY season;


--Revenue by Rider Type:
WITH CTE AS (
    SELECT *
    FROM bike_share_yr_0
    UNION --REMOVE DUPLICATED ROWS
    SELECT *
    FROM bike_share_yr_1
)
SELECT 
    rider_type AS Rider_Type,
    SUM(CAST(riders AS INT)) AS Total_Riders,
    SUM(CAST(riders AS INT) * CAST(price AS FLOAT)) AS Total_Revenue
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr
GROUP BY rider_type
ORDER BY Total_Riders DESC;

-- Combining All Insights
WITH CTE AS (
    SELECT *
    FROM bike_share_yr_0
    UNION -- REMOVE DUPLICATED ROWS
    SELECT *
    FROM bike_share_yr_1
)
SELECT 
    hr AS Hour,
    season AS Season,
    rider_type AS Rider_Type,
    SUM(CAST(riders AS INT) * CAST(price AS FLOAT)) AS Revenue,
    SUM(CAST(riders AS INT)) AS Total_Riders
FROM CTE A
LEFT JOIN cost_table B
ON A.yr = B.yr
GROUP BY hr, season, rider_type
ORDER BY hr, season, Total_Riders DESC;


-- COMBINNING ALL THE QUERY F
WITH CTE AS (
    SELECT *
    FROM bike_share_yr_0
    UNION -- REMOVE DUPLICATED ROWS
    SELECT *
    FROM bike_share_yr_1
),
BaseData AS (
    SELECT 
        [dteday],
        [season],
        A.[yr],
        [weekday],
        [hr],
        [rider_type],
        CAST(riders AS INT) AS Riders,
        CAST(price AS FLOAT) AS Price,
        CAST(COGS AS FLOAT) AS COGS,
        CAST(riders AS INT) * CAST(price AS FLOAT) AS Revenue,
        (CAST(riders AS INT) * CAST(price AS FLOAT)) - CAST(COGS AS FLOAT) * CAST(riders AS INT) AS Profit
    FROM CTE A
    LEFT JOIN cost_table B
    ON A.yr = B.yr
),
HourlyRevenue AS (
    SELECT 
        hr AS Hour,
        SUM(Revenue) AS Hourly_Revenue
    FROM BaseData
    GROUP BY hr
),
SeasonalRevenue AS (
    SELECT 
        season AS Season,
        SUM(Revenue) AS Seasonal_Revenue
    FROM BaseData
    GROUP BY season
),
RiderTypeRevenue AS (
    SELECT 
        rider_type AS Rider_Type,
        SUM(Riders) AS Total_Riders,
        SUM(Revenue) AS Total_Revenue
    FROM BaseData
    GROUP BY rider_type
)
SELECT 
    BD.dteday,
    BD.season AS Season,
    BD.yr AS Year,
    BD.weekday AS Weekday,
    BD.hr AS Hour,
    BD.rider_type AS Rider_Type,
    BD.Riders,
    BD.Price,
    BD.COGS,
    BD.Revenue,
    BD.Profit,
    HR.Hourly_Revenue,
    SR.Seasonal_Revenue,
    RTR.Total_Riders AS Riders_By_Type,
    RTR.Total_Revenue AS Revenue_By_Type
FROM BaseData BD
LEFT JOIN HourlyRevenue HR
    ON BD.hr = HR.Hour
LEFT JOIN SeasonalRevenue SR
    ON BD.season = SR.Season
LEFT JOIN RiderTypeRevenue RTR
    ON BD.rider_type = RTR.Rider_Type
ORDER BY BD.dteday, BD.hr, BD.rider_type;
