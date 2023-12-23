use Portfolio_Project

Select *  From Portfolio_Project.dbo.CovidDeaths
--where continent is not null
order by 3,4

--Select *  From Portfolio_Project.dbo.CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths, population
From Portfolio_Project.dbo.CovidDeaths
order by 1,2 

--Looking at Total cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
From Portfolio_Project.dbo.CovidDeaths
--where continent is not null
where location  like '%Pakistan%'
order by 1,2 

--Looking at Total case vs Population 
--shows what percentage of population got Covid 
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project.dbo.CovidDeaths
--where location  like '%Pakistan%'
order by 1,2 

--Looking at Countries with highhest infection Rate compared to population
select location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationinfected
From Portfolio_Project.dbo.CovidDeaths
Group By Location,population    
--where continent is not null
--where location  like '%Pakistan%'
order by PercentPopulationinfected DESC

---Shows countries with highest Death count Per Population
select location,Max(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project.dbo.CovidDeaths
where continent is not null
Group By Location    
--where location  like '%Pakistan%' 
order by HighestDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
---Showing continents with the highest death count per population
select location,Max(cast(total_deaths as int)) as TotalDeathsCount
From Portfolio_Project.dbo.CovidDeaths 
where continent is  not null
Group by location
order by TotalDeathsCount DESC


---GLOBAL NUMBERS 
SELECT SUM(new_cases) as TotalCases ,SUM(cast(new_deaths as int)) as TotalDeaths , SUM(cast(new_deaths as int))/SUM(new_cases)
* 100 as Deathpercentage
From Portfolio_Project.dbo.CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Population vs Vaccination

Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location ,dea.date) as 
RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/dea.population)*100
From Portfolio_Project.dbo.CovidDeaths dea
join Portfolio_Project.dbo.CovidVaccinations vac
ON dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,new_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location ,dea.date) as 
RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/dea.population)*100
From Portfolio_Project.dbo.CovidDeaths dea
join Portfolio_Project.dbo.CovidVaccinations vac
ON dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 From PopvsVac


----Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
population numeric,
new_vaccinations numeric ,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location ,dea.date) as 
RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/dea.population)*100
From Portfolio_Project.dbo.CovidDeaths dea
join Portfolio_Project.dbo.CovidVaccinations vac
ON dea.date = vac.date and dea.location = vac.location
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 From #PercentPopulationVaccinated

----creating views to store data for visualization

Create View PercentPopulationVaccinated as 

Select dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location ,dea.date) as 
RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/dea.population)*100
From Portfolio_Project.dbo.CovidDeaths dea
join Portfolio_Project.dbo.CovidVaccinations vac
ON dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2,3
	