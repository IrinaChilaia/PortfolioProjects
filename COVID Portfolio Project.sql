-- This DATA was downloaded on Sept. 19, 2022
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject..CovidDeaths
	ORDER BY 1,2


-- Looking at total cases vs. total deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
	FROM PortfolioProject..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2 

-- Looking at total cases vs population 
-- Shows what percentage of population got COVID

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS percent_population_infected
	FROM PortfolioProject..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 1,2

--Lookin at total cases vs population as of today in the United States turns out over 28% have been infected
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS percent_population_infected
	FROM PortfolioProject..CovidDeaths
	WHERE location like '%states%'
	ORDER BY 5 DESC

-- I am originally from Georgia so I also checked total cases vs population and turns out close to 47% of the population have been infected
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS percent_population_infected
	FROM PortfolioProject..CovidDeaths
	WHERE location like 'Georgia'
	ORDER BY 5 DESC


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS hightest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
	FROM PortfolioProject..CovidDeaths
	GROUP BY location,population
	ORDER BY percent_population_infected DESC


-- Showing counties with highest death count per population

SELECT location,  MAX(CAST(total_deaths AS INT)) AS total_death_count
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY total_death_count DESC

--LET's BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count per population

SELECT continent,  MAX(CAST(total_deaths AS INT)) AS total_death_count
	FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY total_death_count DESC

-- Global numbers
-- Global numbers by date

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%states%'
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2

-- Total death globally as of Sept. 19, 2022

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%states%'
	WHERE continent IS NOT NULL
	--GROUP BY date
	ORDER BY 1,2

-- Looking at total population vs vaccination
-- PLEASE NOTE: I had to change "INT" into "BIGINT" to fix the arithmetic overflow error


-- USE CTE
WITH pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY location, date
)
	SELECT *, (rolling_people_vaccinated/population)*100 AS persentage_vaccinated
	FROM pop_vs_vac

-- TEMP TABLE

DROP TABLE if exists #percent_population_vaccinated

CREATE TABLE #percent_population_vaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	rolling_people_vaccinated NUMERIC
	)

INSERT INTO #percent_population_vaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (rolling_people_vaccinated/population)*100 AS persentage_vaccinated
	FROM #percent_population_vaccinated 
	
-- Creating View to store data for later vizs
DROP VIEW percent_population_vaccinated 

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--SELECT * FROM sys.views

SELECT * FROM
percent_population_vaccinated