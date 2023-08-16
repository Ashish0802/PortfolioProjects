
-- Selecting necessary data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1, 2

-- Looking at Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location = 'India'
order by 1, 2

-- Looking at Total cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location = 'India'
order by 1, 2

-- Looking at Countries with Highes Infecton Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location = 'India'
Group by location, population
order by InfectedPercentage desc

-- Showing countries with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing continents with highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
Case
WHen Sum(new_cases) = 0 or Sum(new_deaths) = 0  then ''
Else SUM(new_deaths)/SUM(new_cases)*100 
END as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
--Group by date
order by 1, 2

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date)
as PeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 1,2
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 1,2

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create view to store data for later visualiztion

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 1,2

Select *
From PercentPopulationVaccinated