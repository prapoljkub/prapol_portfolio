SELECT * 
FROM CovidDeaths
where continent is not null 
order by 3,4;


-- Select Data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2;

-- Looking at Total Cases vs. Total Deaths
-- Show likelihood of dying if you contract covid in your countries
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100  as DeathPercentage
from CovidDeaths
where location like 'Thailand'
order by 1,2;

-- Looking at Total Cases vs. population
-- Show what percentage got covid
SELECT location, date, total_cases, population, (cast(total_cases as float) / cast(population as float))*100  as CovidPopulationPercentage
from CovidDeaths
where location like 'Thailand'
order by 1,2;


-- Looking at Countries with Highest Infection Rate compared to population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((cast(total_cases as float) / cast(population as float))*100)  as CovidPopulationPercentage
from CovidDeaths
--where location like 'Thailand'
group by location, population
order by 1,2;

-- Looking at Countries with Highest Death Count compared to population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
--where location like 'Thailand'
where continent is not null 
group by location
order by TotalDeathCount desc;


-- Let's look at continent level

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
--where location like 'Thailand'
where continent is not null 
group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths as dea
Join CovidVaccinations as  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if EXISTS PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths as dea
Join CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

Select *, (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100
From PercentPopulationVaccinated
