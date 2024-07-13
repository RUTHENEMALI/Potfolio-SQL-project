select*
from potfolioproject2..CovidDeaths$
where continent is not null
order by 3,4

--select*
--from potfolioprojet..vacinations$
--where continent is not null
--order by 3,4

--select data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from potfolioprojet..CovidDeaths$
where continent is not null
order by 1,2

-- get total cases by total deaths
--show the likelyhood of dying  if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from potfolioprojet..CovidDeaths$
where location like '%states%'
order by 1,2;


--total cases vs population
--show what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from potfolioprojet..CovidDeaths$
--where location like '%states%'
order by 1,2;


--looking at country with highest infection rate compare to population
select location, population, MAX(total_cases) as highestinfection, MAX(total_cases/population)*100 as percentpopulationinfected
from potfolioprojet..CovidDeaths$
--where location like '%states%'
group by population, location
order by percentpopulationinfected desc

--showing countries with highest death coucnt of population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from potfolioprojet..CovidDeaths$
--where location like '%states%'
where continent is not null
group by population, location
order by TotalDeathCount desc

--include null
--let's break things down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from potfolioprojet..CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


--let's break things down by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from potfolioprojet..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continent with the highest deaths count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from potfolioprojet..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeath, SUM(cast(new_deaths as int))/SUM(new_cases) as Deathpercentage
from potfolioprojet..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2;

--
--JOINS

--looking at total population vs vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevacinated
from potfolioproject2..CovidDeaths$ dea
join potfolioproject2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
With popvsVac (Continent, Location, Date, Population, New_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from potfolioproject2..CovidDeaths$ dea
join potfolioproject2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (Rollingpeoplevaccinated/Population)*100
from popvsVac


-- you can use teptable instead of CTE

create table #percentagepopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rollingpeoplevaccinated numeric
)

Insert into #percentagepopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from potfolioproject2..CovidDeaths$ dea
join potfolioproject2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select*, (Rollingpeoplevaccinated/Population)*100
from #percentagepopulationVaccinated

--to drop the temptable,  use
--drop table if exist #percentagepopulationVaccinated


--creating view to store dat for later
Create View percentagepopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from potfolioproject2..CovidDeaths$ dea
join potfolioproject2..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

