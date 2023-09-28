select*
from [PortfolioProject ]..CovidDeaths
order by 3,4

select *
from [PortfolioProject ]..CovidVaccination
order by 3,4

--select data we will be using

select location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject ]..COvidDeaths
order by 1,2

--looking for total cases vs total deaths and Death percentage
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
order by 1,2


--looking for total cases vs total deaths and Death percentage in nigeria 
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like 'Nigeria'
order by 1,2


--looking at total cases vs Population
--shows what percentage of population got covid

select location, date, population, total_cases, 
(nullif(convert(float,total_cases),0))/(convert(float,population))*100 as infectionratepercentage
from [PortfolioProject ]..CovidDeaths
where location like'%nigeria'
order by 1,2


--looking at countries with highest infection rate compared to the population
select location, population, max(total_cases)as highestinfectioncount, 
max(nullif(convert(float,total_cases),0))/(convert(float,population))*100 as percpopinfected
from [PortfolioProject ]..CovidDeaths
group by location, population
order by percpopinfected desc


--looking at the countries with highest death count per population
-- where continent is not null removes the continents and leaves the country alone
select location, max(total_deaths) as totaldeathcount
from [PortfolioProject ]..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

-- breaking down by continent with highest deathcount
select location, max(total_deaths) as totaldeathcount
from [PortfolioProject ]..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc

--global numbers: everyday no of cases, no of icu patients, no of deaths, deathpercentage

select date,nullif(sum(new_cases),0) as totalcases, nullif(sum(icu_patients),0) as totalicupatients, nullif(sum(new_deaths),0) as totaldeaths,
nullif(sum(convert(float,new_deaths)),0 )/nullif(sum(convert(float,new_cases)),0)* 100 as deathratepercentage
from [PortfolioProject ]..CovidDeaths
group by date
order by date,totalcases

--global numbers: everyday no of cases, no of icu patients, no of deaths, deathpercentage
select nullif(sum(new_cases),0) as totalcases, nullif(sum(icu_patients),0) as totalicupatients, nullif(sum(new_deaths),0) as totaldeaths,
nullif(sum(convert(float,new_deaths)),0 )/nullif(sum(convert(float,new_cases)),0)* 100 as deathratepercentage
from [PortfolioProject ]..CovidDeaths
where continent is not null
order by 1,2


--joing vaccination and death tables on location and date tables from CovidDeath Table
select *
from [PortfolioProject ]..CovidDeaths as dea 
join [PortfolioProject ]..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  
order by 1,2,3


--selecting continent, location, date and population from coviddeath, newvaccines from vaccination tables
--and using partiton by to roll sum the new vaccinations by location and date

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [PortfolioProject ]..CovidDeaths as dea 
join [PortfolioProject ]..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  
order by 1,2,3

-- USE CTE to find the rolling people vacinated rate
With PopvsVac (Continent, location,Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths as dea 
join [PortfolioProject ]..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null  
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
as RollingPeopleVaccintedpercentage
from PopvsVac

--or use Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths as dea 
join [PortfolioProject ]..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null  
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualization

create view PercentageVaccination as

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths as dea 
join [PortfolioProject ]..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null  
--order by 2,3

create view DeathPercentage as 

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--order by 1,2

select * from PercentageVaccination

create view percentagepopulationinfected as 

select location, population, max(total_cases)as highestinfectioncount, 
max(nullif(convert(float,total_cases),0))/(convert(float,population))*100 as percpopinfected
from [PortfolioProject ]..CovidDeaths
group by location, population
--order by percpopinfected desc

create view continenttotaldeathcount as

select location, max(total_deaths) as totaldeathcount
from [PortfolioProject ]..CovidDeaths
where continent is null
group by location
--order by totaldeathcount desc

create view NigeriaPercentagedeathcount
as
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
where location like 'Nigeria'
--order by 1,2