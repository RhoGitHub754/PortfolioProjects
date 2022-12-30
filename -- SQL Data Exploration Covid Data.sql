-- SQL Data Exploration Covid Data
-- Select Data that I'll be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeathss
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if contracting covid in US

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
FROM PortfolioProject..CovidDeathss
WHERE location = 'United Kingdom'
ORDER BY 1, 2


-- Total Cases vs Population
-- Shows percentage of population that got covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 as population_infected_percent
FROM PortfolioProject..CovidDeathss
WHERE location = 'United Kingdom'
ORDER BY 1, 2

-- Countries with highest infection rate vs population

SELECT location, population, max(total_cases) as highest_infection_count, max((total_cases/population)) * 100 as population_infected_percent
FROM PortfolioProject..CovidDeathss
GROUP BY location, population
ORDER BY population_infected_percent desc

-- Countries with highest death count per population

SELECT location, max(total_deaths) as total_death_count
FROM PortfolioProject..CovidDeathss
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count desc

-- Death count by continent
-- Continents  with highest death count per population

SELECT continent, max(total_deaths) as total_death_count
FROM PortfolioProject..CovidDeathss
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY total_death_count desc

-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 as death_percentage
FROM PortfolioProject..CovidDeathss
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Total global cases vs deaths

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 as death_percentage
FROM PortfolioProject..CovidDeathss
WHERE continent is NOT NULL
ORDER BY 1, 2

-- Total population vs vaccinations

SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION by d.location ORDER BY d.location, d.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeathss d
JOIN PortfolioProject..CovidVaccinationss v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent is not NULL
ORDER BY 2, 3

-- USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaxxed)

AS

(SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION by d.location ORDER BY d.location, d.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeathss d
JOIN PortfolioProject..CovidVaccinationss v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent is not NULL)

SELECT *
FROM popvsvac
ORDER BY 2, 3

-- TEMP TABLE

DROP TABLE IF EXISTS #percent_population_vaxxed
CREATE TABLE #percent_population_vaxxed
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vaxxed NUMERIC
)


INSERT INTO #percent_population_vaxxed
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION by d.location ORDER BY d.location, d.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeathss d
JOIN PortfolioProject..CovidVaccinationss v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent is not NULL
ORDER BY 2, 3

SELECT *, (rolling_people_vaxxed/population)*100
FROM #percent_population_vaxxed
ORDER BY 2, 3

-- Create view to store data for visulisations

CREATE VIEW percent_population_vaxxed as
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION by d.location ORDER BY d.location, d.date) as rolling_people_vaxxed
FROM PortfolioProject..CovidDeathss d
JOIN PortfolioProject..CovidVaccinationss v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent is not NULL

select * from percent_population_vaxxed