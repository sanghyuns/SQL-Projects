SELECT *
FROM SQLTutorial..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM SQLTutorial..CovidVaccinations
--ORDER BY 3, 4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM SQLTutorial..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From SQLTutorial..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
From SQLTutorial..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases), MAX((total_cases/population))*100 as PercentPopulationInfected
From SQLTutorial..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Looking at Countries with Highest death count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLTutorial..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLTutorial..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From SQLTutorial..CovidDeaths
--WHERE location like '%states%'
where continent is not null
Group by date
order by 1,2

--Total Cases vs Total Deaths Worldwide
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From SQLTutorial..CovidDeaths
--WHERE location like '%states%'
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCntPeopleVaccinated,
--(RollingCntPeopleVaccinated/population)*100
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCntPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCntPeopleVaccinated
--(RollingCntPeopleVaccinated/population)*100
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingCntPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCntPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCntPeopleVaccinated
--(RollingCntPeopleVaccinated/population)*100
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingCntPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCntPeopleVaccinated
--(RollingCntPeopleVaccinated/population)*100
From SQLTutorial..CovidDeaths dea
Join SQLTutorial..CovidVaccinations vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FRom PercentPopulationVaccinated
