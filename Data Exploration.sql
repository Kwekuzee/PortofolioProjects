/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp tables, Windows Functions, Aggregate Functions Creating Views, Converting Data Types

*/






Select * 
From PortfolioProject..CovidDeaths$
Where continent is null


Select * 
From PortfolioProject..CovidVaccination$
order by 3,4

--Select Data that we are going to be starting with


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your countrt
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100) AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths$
Where 
     location like '%states%'
ORDER BY
    1,2;


--looking at the total cases vs Population
--Shows what percentage of population got covid
SELECT
    Location,
	date,
    Population,
    total_cases,
    (CONVERT(float, total_cases) / CONVERT(float,Population)*100) AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths$
Where 
     location like '%states%'
ORDER BY
    1,2;

--Looking at countries with highest infection rate compared to Population

SELECT
    Location,
    Population,
    MAX(total_cases) as HighestInfectionCount,
    (MAX(CONVERT(float, total_cases) / CONVERT(float,Population))*100) AS PercentPopulationInfected
FROM
    PortfolioProject..CovidDeaths$
--Where 
--     location like '%states%'
Group by location, Population 
ORDER BY
    PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%State%'
Where continent is not null
Group by Location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%State%'
Where continent is not null
Group by continent
order by  TotalDeathCount desc


--Showing continent with the highest ded count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%State%'
Where continent is not null
Group by continent
order by  TotalDeathCount desc



-- Global Numbers

Select date, SUM(new_cases) (cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%State%'
Where continent is not null
Group by continent
order by  TotalDeathCount desc




--looking at Total Population vs Vaccinations





Select dea.continent, dea.location, dea.date,dea.Population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location)
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date)
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3



IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


