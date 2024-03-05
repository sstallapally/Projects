-- COVID Data Exploration Project

Select *
From PortfolioDataExploration..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths (Likelihood of death when someone contracts COVID in India)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioDataExploration..CovidDeaths
Where location like '%india%'
Order by 1,2

-- Looking at the Total Cases vs Population (The percentage of population that got COVID in India)

Select Location, date, total_cases, population, (total_cases/population)*100 as EffectedPercentage
From PortfolioDataExploration..CovidDeaths
Where location like '%india%'
Order by 1,2

-- Looking at the Countries with the highest infection rate based on their population

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PercentageofPopulationInfected
From PortfolioDataExploration..CovidDeaths
Group by Location, Population
Order by PercentageofPopulationInfected desc

-- Looking for Countries with highest death count 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioDataExploration..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Looking for the Continent with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioDataExploration..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Looking at Total Cases vs Total Deaths (Without any location filter)

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
From PortfolioDataExploration..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Looking at the death data along with the vaccination data

Select *
From PortfolioDataExploration..CovidDeaths d
Join PortfolioDataExploration..CovidVaccinations v
  on d.location = v.location
  and d.date = v.date

-- Looking at Total Population vs Vaccinations (Using Common Table Expressions)

With PopvsVac (continent, location, data, population, new_vaccinations, RollingCountofVaccines)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) over (Partition by d.location Order by d.location, d.date) as RollingCountofVaccines
From PortfolioDataExploration..CovidDeaths d
Join PortfolioDataExploration..CovidVaccinations v
  on d.location = v.location
  and d.date = v.date
Where d.continent is not null
)
Select *, (RollingCountofVaccines/population)*100 as RollingCountPercentage
From PopvsVac

-- Looking at Total Population vs Vaccinations (Using Temp Table)

Drop Table if exists #PercentageofPopVaccinated
Create Table #PercentageofPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountofVaccines numeric
)
Insert into #PercentageofPopVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) over (Partition by d.location Order by d.location, d.date) as RollingCountofVaccines
From PortfolioDataExploration..CovidDeaths d
Join PortfolioDataExploration..CovidVaccinations v
  on d.location = v.location
  and d.date = v.date

Select *, (RollingCountofVaccines/population)*100 as RollingCountPercentage
From #PercentageofPopVaccinated

-- Creating a View to store data for future visualizations

Create View PercentageofPopVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) over (Partition by d.location Order by d.location, d.date) as RollingCountofVaccines
From PortfolioDataExploration..CovidDeaths d
Join PortfolioDataExploration..CovidVaccinations v
  on d.location = v.location
  and d.date = v.date
Where d.continent is not null
