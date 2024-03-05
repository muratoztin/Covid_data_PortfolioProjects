select * from Covid_Data_Projects..CovidDeaths where continent is not null order by 3,4

--select * from Covid_Data_Projects..CovidVaccinations order by 3,4

-- select Data that we are going to be using

Select location, date, total_cases, new_cases,
 total_deaths, population 
 from Covid_Data_Projects..CovidDeaths
 order by 1,2

 -- Looking at Total Cases vs Total Deaths

 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from Covid_Data_Projects..CovidDeaths
 where location like '%states'
 order by 1,2

 -- Looking at Total Cases vs Population
Select Location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
 from Covid_Data_Projects..CovidDeaths
 where location like '%rkey'
 order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount,
 MAX((total_cases/population))*100 as PercentPopulationInfected
 from Covid_Data_Projects..CovidDeaths
 Group by Location, population
 order by PercentPopulationInfected desc

 -- Showing Countries with Highest Death Count per Population

 Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from Covid_Data_Projects..CovidDeaths
 where continent is not null
 Group by Location
 order by TotalDeathCount desc

 --LET'S BREAK THINGS DOWN BY CONTINENT


 -- Showing continents with the highest death count per population
  Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from Covid_Data_Projects..CovidDeaths
 where continent is not null
 Group by continent
 order by TotalDeathCount desc


 -- Global Numbers

 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From Covid_Data_Projects..CovidDeaths
 --where location like '%states'
 where continent is not null
 Group by date
 order by 1,2

 --Total Global Numbers

 Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From Covid_Data_Projects..CovidDeaths
 --where location like '%states'
 where continent is not null
 
 order by 1,2


 ---------------------------------------------------------

 --Looking at Total Population vs Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Cast(vac.new_vaccinations as int)) over 
 (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
 
 from Covid_Data_Projects..CovidDeaths dea
 join Covid_Data_Projects..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 order by 2,3

 -- USE CTE

 with PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
 as
 (Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Cast(vac.new_vaccinations as int)) over 
 (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
 
 from Covid_Data_Projects..CovidDeaths dea
 join Covid_Data_Projects..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated/population)*100
  from PopvsVac



  -- Temp Table

  Drop table if exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

 
  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Cast(vac.new_vaccinations as int)) over 
 (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
 
 from Covid_Data_Projects..CovidDeaths dea
 join Covid_Data_Projects..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null 
 --order by 2,3
 
 Select *, (RollingPeopleVaccinated/population)*100
  from #PercentPopulationVaccinated



  --Creating View to store data for later visualizations

  
  Create View PercentPopulationVaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Cast(vac.new_vaccinations as int)) over 
 (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
 
 from Covid_Data_Projects..CovidDeaths dea
 join Covid_Data_Projects..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 --order by 2,3


 Select *
 From PercentPopulationVaccinated