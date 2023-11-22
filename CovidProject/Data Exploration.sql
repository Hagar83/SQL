
select * from CovidDeaths
select * from CovidVaccinations


--describe for deaths table
-- Using sp_help stored procedure
EXEC sp_help 'CovidDeaths';

-- Using system catalog views
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'CovidDeaths'

--Describe for vaccinations table
-- Using sp_help stored procedure
EXEC sp_help 'CovidVaccinations';

-- Using system catalog views
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'CovidVaccinations'




select location , date , total_cases,total_deaths,new_cases,population
from CovidDeaths
order by 1,2

--Total Cases Vs Total Deaths: Examined the relationship between total COVID-19 cases and total deaths.

select location,total_cases ,total_deaths,(total_deaths/total_cases)*100 as 'Cases Vs Deaths'
from CovidDeaths
where total_deaths is not null


--Shows likelihood of dying if you contract covid in your country 
select location,continent,(new_deaths/ new_cases)*100 as 'Percentage of dying if contracted covid'
from CovidDeaths
where continent='Africa' AND location ='Egypt'  AND new_deaths is not null AND new_cases <> 0
order by 'Percentage of dying if contracted covid' desc

--Total cases Vs Population
select location,total_cases ,population ,(total_cases/population)*100 as 'Percent of Infected people'
from CovidDeaths

--Countries with the highest infection rate 
select location , Max(total_cases) as 'Highest infection rate'
from CovidDeaths
group by continent ,location
order by Max(total_cases) desc

--infection rate compared to popualtion
select location , Max(total_cases)as 'Highest infection rate' , Max((total_cases/population))*100 as 'Percent of Population Infected'
from CovidDeaths
group by location
order by  Max((total_cases/population))*100 desc

--Countries with the highest deathrate
select location , Max(total_deaths) as 'Highest death rate'
from CovidDeaths
group by location
order by Max(total_deaths) desc

--death rate compared to popualtion
select location , Max(total_deaths)as 'Highest deaths rate' , Max((total_deaths/population))*100 as 'Percent of Population died'
from CovidDeaths
group by location
order by  Max((total_deaths/population))*100 desc

--Break things down by Continent
select continent, sum(population  )as 'Total Population ', sum(cast(new_deaths as int) ) as 'Total death'
from CovidDeaths
where continent is not null 
group by continent

--Continents with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as 'Total Death Count'
From CovidDeaths
Where continent is not null 
Group by continent
order by 'Total Death Count' desc

--Continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as 'Total Death Count' , MAX(cast(Total_deaths as int)/population)*100 as 'Death per population'
From CovidDeaths
Where continent is not null 
Group by continent
order by 'Death per population' desc

--Global statistics 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as 'Death Percentage'
From CovidDeaths
where continent is not null 
order by 1,2


--select CD.continent,CD.location ,CD.population ,CV.new_vaccinations
--from CovidDeaths as CD
--join CovidVaccinations as CV on CD.iso_code=CV.iso_code

----population Vs vaccinations
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
From CovidDeaths CD
Join CovidVaccinations CV On CD.location = CV.location and CD.date = CV.date
where CD.continent is not null 
order by 2,3 desc

--CTE for previous query
With populationVsvaccinations (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.Location Order by CD.location, CD.Date) as RollingPeopleVaccinated
From CovidDeaths CD
Join CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From  populationVsvaccinations


















