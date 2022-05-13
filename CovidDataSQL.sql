Select *
FROM PortfolioProjectCovid.dbo.CovidDeaths
WHERE continent is not null 
Order by 3,4;


Select *
From PortfolioProjectCovid.dbo.CovidVaccinations
WHERE continent is not null 
Order by 3,4

--Select Data that will be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjectCovid.dbo.CovidDeaths
ORDER BY 1,2

--total cases vs total deaths 
--shows liklihood of dying from covid if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProjectCovid.dbo.CovidDeaths
WHERE Location = 'Luxembourg'
ORDER BY 1,2

--continent death rate--
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as DeathsAsPercentageofPopulation
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is null and location not like '%income%'
GROUP BY location 
ORDER BY TotalDeathCount DESC

--north american--
SELECT location, MAX(total_deaths)
FROM PortfolioProjectCovid..CovidDeaths
WHERE location = 'united states' and total_deaths is not null
GROUP BY location

--total cases vs ICU incidence
SELECT location,date, total_cases, icu_patients, (icu_patients/total_cases)*100 as ICU_percentage
FROM PortfolioProjectCovid.dbo.CovidDeaths
WHERE  Location = 'United Kingdom'
ORDER BY 1,2

--total cases vs Population--
--shows what percentage of population contracted covid--
SELECT location, date, total_cases, population, (total_cases/population)*100 as Case_Percentage_Per_Pop
FROM PortfolioProjectCovid..CovidDeaths
WHERE Location = 'Ukraine'
ORDER BY 1,2

--looking at countries with highest infection rate vs population --
SELECT location, Population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Percent_of_Population_Infected
FROM PortfolioProjectCovid..CovidDeaths
GROUP BY Location, Population
ORDER BY Percent_of_Population_Infected DESC

--looking at countries with highest death rate vs population
SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as DeathsAsPercentageofPopulation
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null 
GROUP BY Location, population
ORDER BY TotalDeathCount DESC

--contient death--
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as DeathsAsPercentageofPopulation
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null and location not like '%income%'
GROUP BY continent 
ORDER BY TotalDeathCount DESC

--looking at continents with highest infection rate vs population --
SELECT continent, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Percent_of_Population_Infected
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Percent_of_Population_Infected DESC


-- Global figures--
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as Death_Percentage--
FROM PortfolioProjectCovid.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total World Pop vs Vaccinations
--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinatedCount) as
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) 
AS RollingPeopleVaccinatedCount

FROM PortfolioProjectCovid..CovidDeaths
JOIN PortfolioProjectCovid..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location 
	AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
)
Select* ,(RollingPeopleVaccinatedCount/Population)*100
FROM PopvsVac


--TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(bigint, CovidVaccinations.new_vaccinations)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) 
AS RollingPeopleVaccinatedCount

FROM PortfolioProjectCovid..CovidDeaths
JOIN PortfolioProjectCovid..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location 
	AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null



SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VIZ

Create View ContinentDeaths as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as DeathsAsPercentageofPopulation
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null and location not like '%income%'
GROUP BY continent 
--ORDER BY TotalDeathCount DESC

SELECT * 
FROM ContinentDeaths