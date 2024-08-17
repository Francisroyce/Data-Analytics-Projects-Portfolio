----DATA CLEANING

------CLEANING DATA IN SQL QUERY
SELECT *
FROM PortfolioProject..Nashville_housing_data


----STANDARDIZE DATE FORMAT
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..Nashville_housing_data


UPDATE Nashville_housing_data
SET SaleDate = CONVERT(DATE, SaleDate) --DIDN'T ACTUALLY WORK FOR ME

----LET'S TRY ANOTHER FORMAT (ALTER)
ALTER TABLE Nashville_housing_data
ADD SaleDateConverted DATE;

UPDATE Nashville_housing_data
SET SaleDateConverted = CONVERT(DATE, SaleDate) 

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..Nashville_housing_data


----POPULATE THE PROPERTY ADDRESS DATA
SELECT PropertyAddress
FROM PortfolioProject..Nashville_housing_data
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..Nashville_housing_data
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..Nashville_housing_data
--WHERE PropertyAddress IS NULL
ORDER BY [Parcel ID]

----HERE WE HAVE TO DO A SELF JOIN
SELECT 
	A.[Parcel ID], 
	B.PropertyAddress, 
	B.[Parcel ID], 
	B.PropertyAddress,
		ISNULL(A.PropertyAddress, 
		B.PropertyAddress)
FROM 
	PortfolioProject..Nashville_housing_data AS A
JOIN PortfolioProject..Nashville_housing_data AS B
	ON A.[Parcel ID] = B.[Parcel ID]
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL
AND B.PropertyAddress IS NOT NULL;


----LET'S UPDATE THE TABLE NOW
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, 
		B.PropertyAddress)
FROM 
	PortfolioProject..Nashville_housing_data AS A
JOIN PortfolioProject..Nashville_housing_data AS B
	ON A.[Parcel ID] = B.[Parcel ID]
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL
AND B.PropertyAddress IS NOT NULL;


----BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject..Nashville_housing_data
--WHERE PropertyAddress IS NULL
--ORDER BY [Parcel ID]

----spliting the address
SELECT
	SUBSTRING(PropertyAddress, 1, 
	CHARINDEX(',', PropertyAddress)) 
	AS Address
FROM PortfolioProject..Nashville_housing_data --HERE THERE IS NONE

----UPDATING NE ADRESS
SELECT PropertyAddress, Address, City
FROM Nashville_housing_data
WHERE PropertyAddress IS NOT NULL
AND Address IS NOT NULL


SELECT PropertyAddress, Address, City
FROM Nashville_housing_data
WHERE PropertyAddress <> Address

ALTER TABLE Nashville_housing_data
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashville_housing_data
SET PropertySplitAddress = COALESCE(PropertyAddress, Address)
WHERE PropertyAddress IS NOT NULL OR Address IS NOT NULL;

SELECT *
FROM Nashville_housing_data

----UPDATING NEW CITY WITHOUT NULL
SELECT PropertyCity, City
FROM Nashville_housing_data
WHERE PropertyCity IS NULL


ALTER TABLE Nashville_housing_data
ADD PropertySplitCity NVARCHAR(255);


UPDATE Nashville_housing_data
SET PropertySplitCity = COALESCE(PropertyCity, City)
WHERE PropertyCity IS NOT NULL OR CITY IS NOT NULL;

SELECT *
FROM Nashville_housing_data


SELECT 
    PropertyAddress, 
    Address
FROM 
    Nashville_housing_data
WHERE 
    (PropertyAddress IS NOT NULL AND Address IS NOT NULL AND PropertyAddress <> Address)
    OR (PropertyAddress IS NULL AND Address IS NOT NULL)
    OR (PropertyAddress IS NOT NULL AND Address IS NULL);

----NOTE: WE CAN USE PARSENAME FOR ADDRESS SEPARTION
---(PARSE(REPLACE(COLUMN NAME, '', '' 1)

-- Add the new column
ALTER TABLE Nashville_housing_data
ADD OwnerSplitCity NVARCHAR(255);

-- Update the new column based on the conditions
UPDATE Nashville_housing_data
SET OwnerSplitCity = COALESCE(PropertyAddress, Address)
WHERE 
    (PropertyAddress IS NOT NULL AND Address IS NOT NULL AND PropertyAddress <> Address)
    OR (PropertyAddress IS NULL AND Address IS NOT NULL)
    OR (PropertyAddress IS NOT NULL AND Address IS NULL);

UPDATE Nashville_housing_data
SET OwnerSplitCity = 'Unknown'
WHERE OwnerSplitCity IS NULL;

SELECT *
FROM Nashville_housing_data


SELECT Address, State
FROM Nashville_housing_data
WHERE State IS NOT NULL

ALTER TABLE Nashville_housing_data
ADD OwnerSplitState nvarchar(255);


UPDATE Nashville_housing_data
SET OwnerSplitState = COALESCE(State, Address)
WHERE STATE IS NOT NULL
AND Address IS NOT NULL

UPDATE Nashville_housing_data
SET OwnerSplitState = 'Unknown'
WHERE OwnerSplitState IS NULL;


----CHANGE Y AND N TO YES AND NO IN (SoldAsVacant)
SELECT SoldAsVacant
FROM Nashville_housing_data

SELECT DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant) AS 'NO/YES COUNT'
FROM Nashville_housing_data
	GROUP BY SoldAsVacant
	ORDER BY SoldAsVacant

SELECT SoldAsVacant,
	CASE				----CASE STATEMENT
		WHEN  SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE
			SoldAsVacant
		END
FROM Nashville_housing_data

UPDATE Nashville_housing_data
	SET 
		SoldAsVacant =
		CASE
		WHEN  SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE
			SoldAsVacant
		END

----REMOVE DUPLICATES
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY
		[Parcel ID],
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY UniqueID) AS Row_Num
FROM PortfolioProject..Nashville_housing_data
	ORDER BY [Parcel ID]

SELECT *
FROM Nashville_housing_data


----CTE
WITH RankedData AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                [Parcel ID], 
                PropertyAddress, 
                SalePrice, 
                SaleDate, 
                LegalReference 
            ORDER BY UniqueID
        ) AS Row_Num
    FROM PortfolioProject..Nashville_housing_data
)
SELECT *
FROM RankedData
WHERE Row_Num > 1
ORDER BY [Parcel ID];

---- LET'S DELETE THE DUPLICATE
----CTE
WITH RankedData AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                [Parcel ID], 
                PropertyAddress, 
                SalePrice, 
                SaleDate, 
                LegalReference 
            ORDER BY UniqueID
        ) AS Row_Num
    FROM PortfolioProject..Nashville_housing_data
)
DELETE		----DELETE DUPLICATE
FROM RankedData
WHERE Row_Num > 1
----ORDER BY [Parcel ID];


----DELETE UNUSED COLUMNS
SELECT *
FROM PortfolioProject..Nashville_housing_data

ALTER TABLE PortfolioProject..Nashville_housing_data
	DROP COLUMN
		Address,
		TaxDistrict,
		PropertyAddress,
		SaleDate


----ERROR
SELECT Address,
		TaxDistrict,
		PropertyAddress,
		SaleDate		  ----Error
FROM PortfolioProject..Nashville_housing_data		