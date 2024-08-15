SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
ORDER BY 3, 4


SELECT *
FROM PortfolioProject..CovidVaccination$
WHERE 
    continent IS NOT NULL
ORDER BY 3, 4

--DATA SELECTION
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
ORDER BY 1, 2


--TOTAL CASES VS TOTAL DEATHS (DEATH_RATE)
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN NULL  -- or 0, or another appropriate value
        ELSE (total_deaths / total_cases) * 100 
    END AS death_rate
FROM 
    PortfolioProject..CovidDeaths$
	WHERE 
    continent IS NOT NULL
ORDER BY 
    location, date;

--CHECKING US CASES
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN NULL  -- or 0, or another appropriate value
        ELSE (total_deaths / total_cases) * 100 
    END AS death_rate
FROM 
    PortfolioProject..CovidDeaths$
	WHERE 
    continent IS NOT NULL
	AND location LIKE '%states%'
ORDER BY 
    location, date;

----TOTAL CASES VS POPULATION (%population with covid)
SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN total_cases = 0 THEN NULL  -- or 0, or another appropriate value
        ELSE (total_cases/population) * 100 
    END AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
    AND location LIKE '%NIGERIA%'
ORDER BY 
    location, date;



--looking at country with highest infection rate compared to pupolation
SELECT 
    location, 
    population,
    MAX(total_cases) AS HighestInfectedCount, 
    MAX(
        CASE 
            WHEN total_cases = 0 THEN NULL  -- or 0, or another appropriate value
            ELSE (total_cases / population) * 100 
        END
    ) AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    PercentPopulationInfected DESC;

--Country with highest death count per population
SELECT 
    location, 
    population,  
	MAX(total_deaths) AS TotalDeathCount 
FROM 
	PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    TotalDeathCount DESC;

--IF LESS ACCURATE CAST IT(CONVERT THE COLUMN TO INT)
SELECT 
    location, 
    population,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount   
FROM 
	PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
GROUP BY 
    location, population
ORDER BY 
    TotalDeathCount DESC;

--BY CONTINENT
SELECT 
    continent, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount   
FROM 
	PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;

--CHECKING FOR THE CORRECT NUMBER FOR CONTINENET
SELECT 
    location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount   
FROM 
	PortfolioProject..CovidDeaths$
	WHERE continent IS NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

--SHOWING CONTINENT WITH HIGHEST DEATHCOUNT
	SELECT 
    continent, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount   
FROM 
	PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;

-- BREAKING GLOBAL NUMBERS
SELECT 
    date, 
    SUM(new_cases) AS total_new_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_new_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL  -- or 0, or another appropriate value
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 
    END AS death_rate
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
GROUP BY 
	date
ORDER BY 
    1, 2;

--UPDATED CAUSE OF THE ERROR IN DATASET GIVINH 150%
SELECT 
    date, 
    SUM(new_cases) AS total_new_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_new_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL  -- Avoid division by zero
        ELSE 
            CASE 
                WHEN SUM(CAST(new_deaths AS INT)) > SUM(new_cases) THEN 100  -- Cap at 100%
                ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 
            END
    END AS death_rate
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1, 2;


-- ACROSS THE WORLD
SELECT 
    --date, 
    SUM(new_cases) AS total_new_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_new_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL  -- Avoid division by zero
        ELSE 
            CASE 
                WHEN SUM(CAST(new_deaths AS INT)) > SUM(new_cases) THEN 100  -- Cap at 100%
                ELSE SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 
            END
    END AS death_rate
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
--GROUP BY 
--    date
ORDER BY 
    1, 2;


--CHECKING THE SECOND TABLE(COVIDVACINNATION)
SELECT *
FROM PortfolioProject..CovidVaccination$

--JOINING THE TWO TABLES
SELECT *
FROM
	PortfolioProject..CovidDeaths$ AS DE
JOIN PortfolioProject..CovidVaccination$ AS VAC
	ON DE.location = VAC.location
	AND DE.date = VAC.date

--TOTAL POPULATION VS VACINATION
SELECT 
	DE.continent,
	DE.location,
	DE.date,
	DE.population,
	VAC.new_vaccinations
FROM
	PortfolioProject..CovidDeaths$ AS DE
JOIN PortfolioProject..CovidVaccination$ AS VAC
	ON DE.location = VAC.location
	AND DE.date = VAC.date
	WHERE DE.continent IS NOT NULL
	AND VAC.continent IS NOT NULL
ORDER BY 1, 2, 3

--USING PARTITION BY
SELECT 
	DE.continent,
	DE.location,
	DE.date,
	DE.population,
	VAC.new_vaccinations,
	SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER 
		(PARTITION BY 
			DE.location
		ORDER BY
			DE.location,
			DE.date) AS cumulative_vaccinations
FROM
	PortfolioProject..CovidDeaths$ AS DE
JOIN PortfolioProject..CovidVaccination$ AS VAC
	ON DE.location = VAC.location
	AND DE.date = VAC.date
WHERE 
	DE.continent IS NOT NULL
	AND VAC.continent IS NOT NULL
ORDER BY 1, 2, 3;


--USE OF CTE
WITH CTE_PV AS (
    SELECT 
        DE.continent,
        DE.location,
        DE.date,
        DE.population,
        VAC.new_vaccinations,
        SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER 
            (PARTITION BY 
                DE.location
            ORDER BY
                DE.location,
                DE.date) AS cumulative_vaccinations
    FROM
        PortfolioProject..CovidDeaths$ AS DE
    JOIN PortfolioProject..CovidVaccination$ AS VAC
        ON DE.location = VAC.location
        AND DE.date = VAC.date
    WHERE 
        DE.continent IS NOT NULL
        AND VAC.continent IS NOT NULL
)
SELECT 
    *,
    CASE 
        WHEN (cumulative_vaccinations / population) * 100 > 100 THEN 100
        ELSE (cumulative_vaccinations / population) * 100
    END AS vaccination_percentage
FROM 
    CTE_PV;



 --Create temporary table to hold intermediate data
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated (
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    cumulative_vaccinations numeric
);

 --Insert data into the temporary table with cumulative vaccination calculation
INSERT INTO #PercentagePopulationVaccinated
SELECT 
    DE.continent,
    DE.location,
    DE.date,
    DE.population,
    VAC.new_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER 
        (PARTITION BY DE.location
         ORDER BY DE.location, DE.date) AS cumulative_vaccinations
FROM
    PortfolioProject..CovidDeaths$ AS DE
JOIN 
    PortfolioProject..CovidVaccination$ AS VAC
    ON DE.location = VAC.location
    AND DE.date = VAC.date
WHERE 
    DE.continent IS NOT NULL
    AND VAC.continent IS NOT NULL;

 Select data from the temporary table and calculate vaccination percentage
SELECT 
    *,
    CASE 
        WHEN (cumulative_vaccinations / population) * 100 > 100 THEN 100
        ELSE (cumulative_vaccinations / population) * 100
    END AS vaccination_percentage
FROM 
    #PercentagePopulationVaccinated;



 --Drop the view if it exists
IF OBJECT_ID('PercentagePopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentagePopulationVaccinated;
GO

 --Create the view
CREATE VIEW PercentagePopulationVaccinated
AS
SELECT 
    DE.continent,
    DE.location,
    DE.date,
    DE.population,
    VAC.new_vaccinations,
    SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER 
        (PARTITION BY DE.location
         ORDER BY DE.location, DE.date) AS cumulative_vaccinations
FROM
    PortfolioProject..CovidDeaths$ AS DE
JOIN 
    PortfolioProject..CovidVaccination$ AS VAC
    ON DE.location = VAC.location
    AND DE.date = VAC.date
WHERE 
    DE.continent IS NOT NULL
    AND VAC.continent IS NOT NULL;
GO

SELECT *
FROM PercentagePopulationVaccinated




