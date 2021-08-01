
--Final queries for visualization in Tableau--


--1. Total of columns

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_19_Project..CovidDeaths$
--Where location = 'India'
where continent is not null 
--Group By date
order by 1,2

--2. Total death count by population in a continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid_19_Project..CovidDeaths$
--Where location = 'India'
Where continent is null 
and location not in ('World', 'European Union', 'International')  --This query is adding to divide data into continents
Group by location
order by TotalDeathCount desc

-- 3. Percentage population infected by location & population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From Covid_19_Project ..CovidDeaths$
--Where location = 'India'
Group by Location, Population
order by Percent_Population_Infected desc

--4 Percentage population infected by location, population & date

Select Location, Population,date, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From Covid_19_Project..CovidDeaths$
--Where location = 'India'
Group by Location, Population, date
order by Percent_Population_Infected desc




-- Queies for analysis of data



select * from Covid_19_Project..CovidDeaths$
where continent is not null           -- In this dataset some countries are not the part of continents like marine countries hence this statement is important
order by 3,4;       -- To get data with proper order

select * from Covid_19_Project..CovidVaccination$
order by 3,4

-- selecting the neccesary data from the table CovidDeaths1
select location, date, population, total_cases, new_cases,total_deaths
from Covid_19_Project..CovidDeaths$
where continent is not null
order by 1,2  

--calculation for the deathrate in percentge for total_cases vs total_deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathrate_by_total_deaths
from Covid_19_Project..CovidDeaths$
where location = 'India'
order by 1,2

--calculation for the deathrate in percentge for total_cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as Deathrate_by_population
from Covid_19_Project..CovidDeaths$
where location = 'India'
& where continent is not null
order by 1,2


--calculation for the deathrate in percentge for infection rate
select location, max(total_cases) as Highest_Infection_count, population, max((total_cases/population))*100 as Percentage_population_infected
from Covid_19_Project..CovidDeaths$   -- In this query remove date or it will throw an error
--where location = 'India'
where continent is not null
group by location, population
order by Percentage_population_infected desc

--How many people died ? or calculating highest deaths 
select location, max(cast(total_deaths as int)) as Highest_Death_count   --Here need to change the type of total_death column from varchar to integer
from Covid_19_Project..CovidDeaths$  
--where location = 'India'
where continent is not null
group by location
order by Highest_Death_count desc


-- for calculating global numbers i.e. total numbers by dates & by without dates
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int))  as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage   
from Covid_19_Project..CovidDeaths$  
--where location = 'India'
where continent is not null
group by date
order by 1,2

-- for total without date same as above
select sum(new_cases) as total_cases, sum(cast(new_deaths as int))  as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage   
from Covid_19_Project..CovidDeaths$  
--where location = 'India'
where continent is not null
order by 1,2


--Now, Working for the Covid_19_vaccination1 table 
select dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations,
sum(convert(int, vca.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) --it creates a new partition window and last query add up every value according to location in a new column
as cummulative_vaccination
from Covid_19_Project..CovidDeaths$ dea
join Covid_19_Project..CovidVaccination$ vca
on dea.location = vca.location
and dea.date = vca.date
where dea.continent is not null
order by 1, 2, 3

--common table expression (CTE) this allows the calculations in new created column i.e. cummulative_vaccination

with PopvsVac(continent, location, date, population, new_vaccinations, cummulative_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations,
sum(convert(int, vca.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as cummulative_vaccination
from Covid_19_Project..CovidDeaths$ dea
join Covid_19_Project..CovidVaccination$ vca
on dea.location = vca.location
and dea.date = vca.date
where dea.continent is not null
)
select *,(cummulative_vaccination/population)*100 as Percent_Vaccination
from PopvsVac

