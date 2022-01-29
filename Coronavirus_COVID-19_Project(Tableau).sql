SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows chances of dying in INDIA if infected by corona

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
order by 1,2


-- Looking at total cases vs population
-- Shows what % of population got covid in INDIA

SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'India'
order by 1,2


-- looking at countries with highest infecction rate compared to polulation

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'india'
Group by location,population
order by 4 desc


-- showing countries with highest death count per population

SELECT location,
MAX(cast(total_deaths as int)) AS HighestDeathCount,
MAX(total_deaths/population)*100 as PercentagePopulationDied,
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE Continent is not null
Group by location
order by 2 desc


-- BY CONTINENTS

SELECT continent,MAX(cast(total_deaths as int)) AS HighestDeathCount,MAX(total_deaths/population)*100 as PercentagePopulationDied
FROM PortfolioProject..CovidDeaths
--WHERE location like 'india'
WHERE Continent is not null
Group by continent
order by 2 DESC


--Global Numbers
SELECT SUM(new_cases) as total_cases 
,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'India'
WHERE new_cases <> 0
--GROUP BY date
order by 1,2



SELECT cd.location,cd.date,cd.population ,cv.new_vaccinations,
 SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location order by cd.location,
 cd.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS cd 
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location=cv.location
and cd.date = cv.date
order by 1,2,3


--Population vs vaccination

WITH Pop_vs_vac (location,date,population,NEW_vaccinations ,Rolling_people_vaccinated)
as(
SELECT cd.location,cd.date,cd.population ,cv.new_vaccinations,
 SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location order by cd.location,
 cd.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS cd 
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location=cv.location
and cd.date = cv.date
--order by 1,2,3
)
SELECT * , ( Rolling_people_vaccinated/population)*100
From Pop_vs_vac




--by temp table 
DROP table if exists #PercentPopulationVaccinated  
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT cd.continent , cd.location,cd.date,cd.population ,cv.new_vaccinations,
 SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location order by cd.location,
 cd.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS cd 
JOIN PortfolioProject..CovidVaccinations AS cv
ON cd.location=cv.location
and cd.date = cv.date
SELECT * , ( Rolling_people_vaccinated/population)*100
From #PercentPopulationVaccinated
order by 2,3

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT cd.continent , cd.location,cd.date,cd.population ,cv.new_vaccinations,
 SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location order by cd.location,
 cd.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS cd 
JOIN PortfolioProject..CovidVaccinations AS cv
	ON cd.location=cv.location
	and cd.date = cv.date
where cd.continent is not null

SELECT *
FROM PercentPopulationVaccinated 




/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

