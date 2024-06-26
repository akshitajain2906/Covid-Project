select *
from CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from CovidDeaths
order by location, date 

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract the virus in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by location, date 

-- Looking at total cases vs population
-- shows what percentage of population got covid
select location, date,population, total_cases, cast((total_cases/population)*100 as decimal(38,2)) as PercentPopulationInfected
from CovidDeaths
--where location like 'India'
order by location, date

-- looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as MaxTotalCases, 
cast(max((total_cases/population)*100 )as decimal(38,2)) as PercentPopulationInfected
from CovidDeaths
--where location like 'India'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as MaxDeathCount
from CovidDeaths
--where location like 'India'
where continent is not null
group by location
order by MaxDeathCount desc

-- breaking details into continents
-- showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as MaxDeathCount
from CovidDeaths
--where location like 'India'
where continent is not null
group by continent
order by MaxDeathCount desc

-- global deaths
select  date, sum(new_cases), sum(cast (new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
 --re location like '%states%'
where continent is not null
group by date
order by date

-- total global deaths
select   sum(new_cases), sum(cast (new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
 --re location like '%states%'
where continent is not null
--oup by date
--der by date
 

-- looking at total population and vaccinations
-- using cte and window function
with popvsvac ( continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null )

select *, (rollingpeoplevaccinated/population)*100
from popvsvac

-- temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
( continent nvarchar (255), location nvarchar (255), date datetime, population numeric, new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--ere dea.continent is not null 

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

-- creating view to store data for later visualization 
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
