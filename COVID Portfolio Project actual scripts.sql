SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortofolioProject..CovidDeaths
--ORDER BY 3,4


-- SELECT data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in ur country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE  location LIKE '%state%'
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows  what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE  location LIKE '%state%'
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) HighestInfectionCount, MAX(total_cases/population)*100 
	PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE  location LIKE '%state%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE  location LIKE '%state%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's Break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE  location LIKE '%state%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE  location LIKE '%state%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Glolbal Numbers
SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_death, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE  location LIKE '%state%' 
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- creating view to store data for later visualization

CREATE VIEW PercentPoppulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *
FROM PercentPoppulationVaccinated