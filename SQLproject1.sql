--SELECT *
--FROM PortfolioTut.dbo.CovidDeaths
--ORDER BY 3,4;



--SELECT *
--FROM PortfolioTut.dbo.CovidVaccinations
--ORDER BY 3,4;

SELECT location,
       date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
FROM PortfolioTut.dbo.CovidDeaths
ORDER BY 1,2


-- LOOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT location,
       date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioTut.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2 



-- LOOOKING AT TOTAL CASES VS POPULATION
-- Shows what percentage of population infected with Covid

SELECT location,
       date,
	   total_cases,
	   population,
	   (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioTut.dbo.CovidDeaths
-- WHERE location LIKE '%Europe%'
-- WHERE location LIKE '%Asia%'
-- WHERE location LIKE '%states%'
WHERE location LIKE '%india%'
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT location,
       population,
	   MAX(total_cases) AS HighestInfectionCount,
	   MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioTut.dbo.CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC






-- Showing Countries with Highest Death Count per Population

SELECT location,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioTut.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing Continent with Highest Death CounT


SELECT location,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioTut.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--another 


SELECT continent,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioTut.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers


-- GLOBAL NUMBERS

Select date, 
       SUM(new_cases) as total_cases, 
	   SUM(cast(new_deaths as int)) as total_deaths, 
	   SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioTut.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT d.continent,
       d.location,
	   d.date,
	   population,
	   v.new_vaccinations,
	   SUM(CAST(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM PortfolioTut.dbo.CovidDeaths d
JOIN PortfolioTut.dbo.CovidVaccinations v
    ON d.location = v.location
	AND d.date = v.date
where d.continent is not null 
order by 1,2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent,
       d.location,
	   d.date,
	   population,
	   v.new_vaccinations,
	   SUM(CAST(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM PortfolioTut.dbo.CovidDeaths d
JOIN PortfolioTut.dbo.CovidVaccinations v
    ON d.location = v.location
	AND d.date = v.date
where d.continent is not null 
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select d.continent,
       d.location,
	   d.date,
	   population,
	   v.new_vaccinations,
	   SUM(CAST(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM PortfolioTut.dbo.CovidDeaths d
JOIN PortfolioTut.dbo.CovidVaccinations v
    ON d.location = v.location
	AND d.date = v.date
--where d.continent is not null 
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select d.continent,
       d.location,
	   d.date,
	   population,
	   v.new_vaccinations,
	   SUM(CAST(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM PortfolioTut.dbo.CovidDeaths d
JOIN PortfolioTut.dbo.CovidVaccinations v
    ON d.location = v.location
	AND d.date = v.date
where d.continent is not null 
--order by 1,2,3