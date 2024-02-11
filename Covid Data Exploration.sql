Select * 
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
Order by 3,4

--Select * 
--From ..CovidVaccinaton
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
AND continent IS NOT NULL
order by 1,2

--Looking at the total cases vs the population

Select location, date, total_cases, population, (total_cases/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2

--Looking at countries at highest infection rate

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as AffectedPercentage
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
group by location, population
order by AffectedPercentage DESC

--Looking at countries with highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
group by location
order by TotalDeathCount Desc

--Breaking things out by Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NULL
group by location
order by TotalDeathCount Desc

--Showing continents with highest Death Count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
group by continent
order by TotalDeathCount Desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
--(CumulativeVaccination/population) 
from
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinaton vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations,CumulativeVaccination)
as (
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
--(CumulativeVaccination/population)*100
from
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinaton vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3
)
Select * , (CumulativeVaccination/population)*100 as cumulativePercentage
from PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumulativeVaccination
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinaton vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (CumulativeVaccination/Population)*100
From #PercentPopulationVaccinated

--Creating and storing data for better vizualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinaton vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
