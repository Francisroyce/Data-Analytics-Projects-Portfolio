--ROAD ACCIDENT QUERIES

SELECT * FROM road_accident

-- CURRENT YEAR CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Casualties
FROM dbo.road_accident
WHERE YEAR(accident_date) = '2022' 

--CY YEAR ACCIDENT
SELECT COUNT(DISTINCT accident_index) AS CY_Accident
FROM dbo.road_accident
WHERE YEAR(accident_date) = '2022'

-- TOTAL CY FATAL CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM dbo.road_accident
--NO  FILTER APPLIED
WHERE accident_severity = 'Fatal'

-- CY FATAL CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Fatal_Casualties
FROM dbo.road_accident
-- FILTER APPLIED
WHERE YEAR(accident_date) = '2022' AND accident_severity = 'Fatal'

-- TOTAL CY SERIOUS CASUALTIES
SELECT SUM(number_of_casualties) AS CY_SERIOUS_Casualties
FROM dbo.road_accident
--NO FILTER APPLIED
WHERE accident_severity = 'Serious'

-- CY SERIOUS CASUALTIES
SELECT SUM(number_of_casualties) AS CY_SERIOUS_Casualties
FROM dbo.road_accident
--FILTER APPLIED
WHERE YEAR(accident_date) = '2022' AND accident_severity = 'Serious'


-- TOTAL CY Slight CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Slight_Casualties
FROM dbo.road_accident
--NO FILTER APPLIED
WHERE accident_severity = 'Slight'

-- CY Slight CASUALTIES
SELECT SUM(number_of_casualties) AS CY_Slight_Casualties
FROM dbo.road_accident
--FILTER APPLIED
WHERE YEAR(accident_date) = '2022' AND accident_severity = 'Slight'


-- PERCENTAGE OF TOTAL SLIGHT CASUALTIES
SELECT CAST(SUM(number_of_casualties) AS decimal (10, 2))
/ (SELECT CAST(SUM(number_of_casualties) AS decimal (10, 2))
FROM dbo.road_accident) * 100
FROM dbo.road_accident
--FILTER APPLIED
WHERE accident_severity = 'Slight'


-- PERCENTAGE OF TOTAL SERIOUS CASUALTIES
SELECT CAST(SUM(number_of_casualties) AS decimal (10, 2))
/ (SELECT CAST(SUM(number_of_casualties) AS decimal (10, 2))
FROM dbo.road_accident) * 100
FROM dbo.road_accident
--FILTER APPLIED
WHERE accident_severity = 'Serious'


-- PERCENTAGE OF TOTAL SLIGHT CASUALTIES
SELECT CAST(SUM(number_of_casualties) AS decimal (10, 2))
/ (SELECT CAST(SUM(number_of_casualties) AS decimal (10, 2))
FROM dbo.road_accident) * 100 
FROM dbo.road_accident
--FILTER APPLIED
WHERE accident_severity = 'Fatal'


-- CASULATIES BY VEHICLE TYPE
SELECT
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agriculture'
		WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle over 500cc', 'Motorcycle 125cc and under',
		'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 
		'Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods over 3.5t. and under 7.5t', 
		'Goods 7.5 tonnes mgw and over') THEN 'Van'
		ELSE 'Other'
	END AS vehicle_group,
SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
--FILTERED
WHERE YEAR (accident_date) = '2022'
GROUP BY
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agriculture'
		WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle over 500cc', 'Motorcycle 125cc and under',
		'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 
		'Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods over 3.5t. and under 7.5t', 
		'Goods 7.5 tonnes mgw and over') THEN 'Van'
		ELSE 'Other'
	END

-- TOATL CASULATIES BY VEHICLE TYPE
SELECT
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agriculture'
		WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle over 500cc', 'Motorcycle 125cc and under',
		'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 
		'Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods over 3.5t. and under 7.5t', 
		'Goods 7.5 tonnes mgw and over') THEN 'Van'
		ELSE 'Other'
	END AS vehicle_group,
SUM(number_of_casualties) AS Total_CY_Casualties
FROM road_accident
--WHERE YEAR (accident_date) = '2022'
GROUP BY
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agriculture'
		WHEN vehicle_type IN ('Car', 'Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle over 500cc', 'Motorcycle 125cc and under',
		'Motorcycle 50cc and under', 'Motorcycle over 125cc and up to 500cc') THEN 'Bike'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)', 
		'Minibus (8 - 16 passenger seats)') THEN 'Bus'
		WHEN vehicle_type IN ('Goods over 3.5t. and under 7.5t', 
		'Goods 7.5 tonnes mgw and over') THEN 'Van'
		ELSE 'Other'
	END


-- CY CASUALTIES VS PY CASUALTIES TREND
SELECT 
    DATENAME(MONTH, accident_date) AS Month_Name, 
    SUM(number_of_casualties) AS CY_Casualties
FROM 
    road_accident  
WHERE 
    YEAR(accident_date) = '2022'  
GROUP BY 
    DATENAME(MONTH, accident_date), 
    MONTH(accident_date)
ORDER BY 
    MONTH(accident_date);


--CY CASUALTIES VS PY CASUALTIES TREND
SELECT 
    DATENAME(MONTH, accident_date) AS Month_Name, 
    SUM(number_of_casualties) AS PY_Casualties
FROM 
    road_accident  
WHERE 
    YEAR(accident_date) = '2021'  
GROUP BY 
    DATENAME(MONTH, accident_date), 
    MONTH(accident_date)
ORDER BY 
    MONTH(accident_date);

-- CY CASUALTIES VS PY CASUALTIES TREND WITH DIFFERENCE
SELECT 
    DATENAME(MONTH, accident_date) AS Month_Name, 
    SUM(CASE WHEN YEAR(accident_date) = 2022 THEN number_of_casualties ELSE 0 END) AS CY_Casualties,
    SUM(CASE WHEN YEAR(accident_date) = 2021 THEN number_of_casualties ELSE 0 END) AS PY_Casualties,
    SUM(CASE WHEN YEAR(accident_date) = 2022 THEN number_of_casualties ELSE 0 END) - 
    SUM(CASE WHEN YEAR(accident_date) = 2021 THEN number_of_casualties ELSE 0 END) AS Casualty_Difference
FROM 
    road_accident  
WHERE 
    YEAR(accident_date) IN (2021, 2022)
GROUP BY 
    DATENAME(MONTH, accident_date), 
    MONTH(accident_date)
ORDER BY 
    MONTH(accident_date);


-- CSUALTIES BY ROAD TYPE
SELECT road_type, SUM(number_of_casualties) CY_Casualties_By_Road_type_2022
FROM road_accident
WHERE YEAR(accident_date) = '2022'
GROUP BY road_type


-- CASUALTIES BY ROAD TYPE
SELECT road_type, SUM(number_of_casualties) PY_Casualties_By_Road_type_2021
FROM road_accident
WHERE YEAR(accident_date) = '2021'
GROUP BY road_type


-- CASUALTIES BY RURAL/URBAN AREA
SELECT urban_or_rural_area, SUM(number_of_casualties) PY_Casualties_Urban_Rural
FROM road_accident
WHERE YEAR(accident_date) = '2021'
GROUP BY urban_or_rural_area


-- CASUALTIES BY RURAL/URBAN AREA
SELECT urban_or_rural_area, SUM(number_of_casualties) CY_Casualties_Urban_Rural
FROM road_accident
WHERE YEAR(accident_date) = '2022'
GROUP BY urban_or_rural_area


-- CASUALTIES BY RURAL/URBAN AREA PERCENTAGE
SELECT 
    urban_or_rural_area, 
    SUM(number_of_casualties) AS CY_Casualties_Urban_Rural,
    FORMAT(
        (SUM(number_of_casualties) * 100.0 / 
        (SELECT SUM(number_of_casualties) 
         FROM road_accident 
         WHERE YEAR(accident_date) = '2022')
    ), 'N2') AS Percentage
FROM 
    road_accident
WHERE 
    YEAR(accident_date) = '2022'
GROUP BY 
    urban_or_rural_area;


-- CASUALTIES BY RURAL/URBAN AREA PERCENTAGE
SELECT 
    urban_or_rural_area, 
    SUM(number_of_casualties) AS PY_Casualties_Urban_Rural,
    FORMAT(
        (SUM(number_of_casualties) * 100.0 / 
        (SELECT SUM(number_of_casualties) 
         FROM road_accident 
         WHERE YEAR(accident_date) = '2021')
    ), 'N2') AS Percentage
FROM 
    road_accident
WHERE 
    YEAR(accident_date) = '2022'
GROUP BY 
    urban_or_rural_area;

-- TOTAL PERCENTATGE
-- CASUALTIES BY RURAL/URBAN AREA PERCENTAGE (TOTAL CASUALTIES)
SELECT 
    urban_or_rural_area, 
    SUM(number_of_casualties) AS Total_Casualties_Urban_Rural,
    FORMAT(
        (SUM(number_of_casualties) * 100.0 / 
        (SELECT SUM(number_of_casualties) 
         FROM road_accident)
    ), 'N2') AS Percentage
FROM 
    road_accident
GROUP BY 
    urban_or_rural_area; 



-- CASUALTIES BY LIGHT CONDITIONS
SELECT
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
		'Darkness - lights lit', 'Darkness - lighting unknown',
		'Darkness - no lighting') THEN 'Dark'
	END AS Light_Cond,
SUM(number_of_casualties) AS Total_CY_Casualties
FROM road_accident
--WHERE YEAR (accident_date) = '2022'
GROUP BY
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
		'Darkness - lights lit', 'Darkness - lighting unknown',
		'Darkness - no lighting') THEN 'Dark'
	END


-- CASUALTIES BY LIGHT CONDITIONS CY YEAR
SELECT
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
		'Darkness - lights lit', 'Darkness - lighting unknown',
		'Darkness - no lighting') THEN 'Dark'
	END AS Light_Cond,
SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
WHERE YEAR (accident_date) = '2022'
GROUP BY
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
		'Darkness - lights lit', 'Darkness - lighting unknown',
		'Darkness - no lighting') THEN 'Dark'
	END


-- CASUALTIES BY LIGHT CONDITIONS PY YEAR
SELECT
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
		'Darkness - lights lit', 'Darkness - lighting unknown',
		'Darkness - no lighting') THEN 'Dark'
	END AS Light_Cond,
SUM(number_of_casualties) AS CY_Casualties
FROM road_accident
WHERE YEAR (accident_date) = '2021'
GROUP BY
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
		'Darkness - lights lit', 'Darkness - lighting unknown',
		'Darkness - no lighting') THEN 'Dark'
	END


	-- CASUALTIES BY LIGHT CONDITIONS WITH PERCENTAGE
SELECT
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
			'Darkness - lights lit', 'Darkness - lighting unknown',
			'Darkness - no lighting') THEN 'Dark'
	END AS Light_Cond,
	SUM(number_of_casualties) AS Total_Casualties,
    FORMAT(
        (SUM(number_of_casualties) * 100.0 / 
        (SELECT SUM(number_of_casualties) 
         FROM road_accident)
    ), 'N2') AS Percentage
FROM 
    road_accident
GROUP BY
	CASE
		WHEN light_conditions IN ('Daylight') THEN 'Day'
		WHEN light_conditions IN ('Darkness - lights unlit', 
			'Darkness - lights lit', 'Darkness - lighting unknown',
			'Darkness - no lighting') THEN 'Dark'
	END;

-- CASUALTIES BY LOCATION
SELECT TOP 10 local_authority,
	SUM(number_of_casualties) AS Total_Casualties
FROM road_accident
GROUP  
	BY local_authority
ORDER 
	BY local_authority DESC