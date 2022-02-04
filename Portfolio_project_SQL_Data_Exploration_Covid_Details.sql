select * from CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccinations
--order by 3,4

-- selecte data that we are goin to useing

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths order by 1,2

-- looking at Total Cases vs Total Deaths

select location,date,total_cases,new_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like '%States%'
And continent is not null
order by 1,2

--show the percentage of population got Covid
select location,date,total_cases,population,
(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
where location like '%States%'
And continent is not null
order by 1,2

-- Looking at Countries with Highest Infecation Rate Compared to Population
select location,population,MAX (total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths 
where continent is not null
--where location like '%States%'
group by location,population
order by PercentPopulationInfected desc

-- showing Countries with Highest Death Count Per Population
select location,Max(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%States%'
where continent is not null
group by location
order by TotalDeathCount desc

-- lets Break Things Down By Continent
select Continent,Max(cast(Total_deaths as int)) as TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%States%'
where continent is not  null
group by Continent
order by TotalDeathCount desc

-- global number of Percentage
select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths 
where continent is not null
--where location like '%States%'
--group by location,population
order by 1,2

-- Looking at Total Population Vs Vaccination
--Temp Table
With PopvsVac (continent , Location , Date , Population , new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,
Vac.new_vaccinations,
sum(convert(float,Vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
   on dea.location=Vac.location
  and dea.date=Vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- create Table
Drop table if exists percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent Nvarchar(225), 
Location Nvarchar(225),
Date Datetime, 
Population numeric ,
new_vaccinations  numeric, 
RollingPeopleVaccinated numeric
)
insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,
Vac.new_vaccinations,
sum(convert(float,Vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
   on dea.location=Vac.location
  and dea.date=Vac.date
where dea.continent is not null

-- Creating view to store data for	later visualization
 Create View percentPopulationVaccinated
 as 
 select dea.continent,dea.location,dea.date,dea.population,
Vac.new_vaccinations,
sum(convert(float,Vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
   on dea.location=Vac.location
  and dea.date=Vac.date
where dea.continent is not null

select * from percentPopulationVaccinated
