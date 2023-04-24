--To look at all data within CovidDeaths
Select *
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Order by 3,4

--To look at all data within CovidVacc
Select *
From ATA_CovidPortfolioProject_Apr2023..CovidVacc
Order by 3,4

--To look at data that I want to use
Select
	location
	,date
	,total_cases
	,new_cases
	,total_deaths
	,population
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Order by 1,2

--Total Cases vs Total Deaths
--Likelihood to pass away if contract Covid in your country
Select 
	location
	,date
	,CAST(total_deaths AS float) AS total_deaths
	,total_cases
	,population
	,(CAST(total_deaths AS float)/total_cases)*100 as DeathOverCases
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Order by location, date

--Total Cases vs Total Deaths by Country
Select 
	location
	,continent
	,MAX(CAST(total_deaths AS float)) AS max_deaths
	,MAX(population) AS max_pop
	,(MAX(CAST(total_deaths AS float)) / MAX(population) * 100) AS TotalDeathoverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null
Group by location, continent
Order by TotalDeathoverPop desc

--Total Cases vs Population
Select 
	location
	,date
	,total_cases
	,population
	,(total_cases/population)*100 as cases_over_pop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Order by location, date

--Total Cases vs Population by Country
--Total Deaths vs Population by Country
Select 
	location
	,continent
	,FORMAT(MAX(CAST(total_deaths AS BIGINT)), '#,##0.00') AS max_deaths
	,FORMAT(MAX(CAST(total_cases AS BIGINT)), '#,##0.00') AS max_cases
	,FORMAT(MAX(CAST(population AS BIGINT)), '#,##0.00') AS max_pop
	,ROUND(MAX(CAST(total_cases AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalCasesOverPop
	,ROUND(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalDeathsOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null
Group by location, continent
--Order by MAX(CAST(total_cases AS BIGINT)) DESC
Order by TotalDeathsOverPop DESC

--To look at Deaths and Cases by Continent
Select 
	location
	,continent
	,FORMAT(MAX(CAST(total_deaths AS BIGINT)), '#,##0.00') AS max_deaths
	,FORMAT(MAX(CAST(total_cases AS BIGINT)), '#,##0.00') AS max_cases
	,FORMAT(MAX(CAST(population AS BIGINT)), '#,##0.00') AS max_pop
	,ROUND(MAX(CAST(total_cases AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalCasesOverPop
	,ROUND(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalDeathsOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is null and location not like '%income%'
Group by continent, location
--Order by MAX(CAST(total_cases AS BIGINT)) DESC
Order by TotalCasesOverPop DESC

Select 
	location
	,MAX(CAST(total_deaths AS BIGINT)) AS max_deaths
	,ROUND(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalDeathsOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is null and location not like '%income%'
Group by location
Order by TotalDeathsOverPop DESC

Select 
	continent
	,MAX(CAST(total_deaths AS BIGINT)) AS max_deaths
	,ROUND(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalDeathsOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null and location not like '%income%'
Group by continent
Order by TotalDeathsOverPop DESC

--Global numbers
--Total Cases, Deaths and Population
Select 
--Cannot use max total_cases because it will pick the highest number of cases, instead of Sum it all up
	--MAX(CAST(total_cases AS float)) AS TotalCases
	--,MAX(CAST(total_deaths AS float)) AS TotalDeaths
	date
	,SUM(new_cases) AS TotalNewCases
	,SUM(new_deaths) AS TotalNewDeaths
	,SUM(population) AS TotalPop
	,CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(new_deaths)/SUM(new_cases)*100 END AS NewDeathsOverCases
	,CASE WHEN SUM(population) = 0 THEN NULL ELSE SUM(new_cases)/SUM(population)*100 END AS TotalCasesOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null 
Group by date
Order by date

Select 
	FORMAT(SUM(new_cases), '#,##0') AS TotalNewCases
	,FORMAT(SUM(new_deaths), '#,##0') AS TotalNewDeaths
	,FORMAT(SUM(population), '#,##0') AS TotalPop
	,CASE 
		WHEN SUM(new_cases) = 0 THEN NULL 
		ELSE ROUND(SUM(new_deaths)/SUM(new_cases)*100, 5)
	END AS NewDeathsOverCases
	,CASE 
		WHEN SUM(population) = 0 THEN NULL 
		ELSE ROUND(SUM(new_cases)/SUM(population)*100, 5)
	END AS TotalCasesOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null 

--Join with Covid Vaccinations Table
Select *
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date

--Total Population vs Vaccinations
Select 
	dea.continent
	,dea.location
	,dea.date
	,FORMAT(dea.population, '#,##0') as Pop
	,FORMAT(CAST(vac.total_vaccinations AS FLOAT), '#,##0') AS TotalVaccByLoc
	,ROUND(CAST(vac.total_vaccinations AS FLOAT)/dea.population*100, 5) AS TotVaccOverPop
	,FORMAT(CAST(vac.new_vaccinations AS FLOAT), '#,##0') AS TotalNewVaccByLoc
	,ROUND(CAST(vac.new_vaccinations AS FLOAT)/dea.population*100, 5) AS TotNewVaccOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like 'canada'
Order by 2,3

Select 
	dea.continent
	,dea.location
	,SUM(dea.population) AS TotalPop
	,MAX(CAST(vac.total_vaccinations AS FLOAT)) AS TotalVaccByLoc
	,SUM(CAST(vac.new_vaccinations AS FLOAT)) AS TotalNewVaccByLoc
	,ROUND(MAX(CAST(vac.total_vaccinations AS FLOAT))/SUM(dea.population)*100, 5) AS TotVaccOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Group by dea.location, dea.continent
Order by TotVaccOverPop desc

Select 
	dea.continent
	,SUM(dea.population) AS TotalPop
	,SUM(CAST(vac.new_vaccinations AS FLOAT)) AS TotalNewVaccByLoc
	,ROUND(SUM(CAST(vac.new_vaccinations AS FLOAT))/SUM(dea.population)*100, 5) AS TotNewVaccOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.location is null
Group by dea.continent
Order by TotNewVaccOverPop desc

--To look at Rolling Count of New Vaccinations
Select 
	dea.continent
	,dea.location
	,dea.date
	,FORMAT(dea.population, '#,##0') as Pop
	,FORMAT(CAST(vac.total_vaccinations AS FLOAT), '#,##0') AS TotalVaccByLoc
	,ROUND(CAST(vac.total_vaccinations AS FLOAT)/dea.population*100, 5) AS TotVaccOverPop
	,FORMAT(CAST(vac.new_vaccinations AS FLOAT), '#,##0') AS TotalNewVaccByLoc
	,ROUND(CAST(vac.new_vaccinations AS FLOAT)/dea.population*100, 5) AS TotNewVaccOverPop

	,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER 
		(Partition by dea.location
		Order by dea.location, dea.date) AS RollingNewVacc
	
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and dea.location like 'albania'
Order by 2,3

--Using CTE
--Need to call the CTE at the end, otherwise will cause syntax error
With PopvsVac (continent, location, date, population, new_vaccinations, RollingNewVacc)
AS
(
Select 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations

	,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (
		Partition by dea.location
		Order by dea.location, dea.date
	) AS RollingNewVacc
	
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingNewVacc/Population)*100 AS RollNewVaccOverPop
From PopvsVac

--Temp Tables, # signifying temporarily
DROP Table if exists #PercentPopVaccinated

Create Table #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingNewVacc numeric
)

Insert Into #PercentPopVaccinated

Select 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations

	,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (
		Partition by dea.location
		Order by dea.location, dea.date
	) AS RollingNewVacc
	
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingNewVacc/Population)*100 AS RollNewVaccOverPop
From #PercentPopVaccinated

--Creating View to store for later visualizations
--Cannot use # at the front
USE ATA_CovidPortfolioProject_Apr2023
GO
Create View PercentPopulationVaccinated AS
Select 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations

	,SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (
		Partition by dea.location
		Order by dea.location, dea.date
	) AS RollingNewVacc
	
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths dea
Join ATA_CovidPortfolioProject_Apr2023..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

USE ATA_CovidPortfolioProject_Apr2023
GO
Create View TotCases_Deaths_ByLoc AS
Select 
	location
	,continent
	,FORMAT(MAX(CAST(total_deaths AS BIGINT)), '#,##0.00') AS max_deaths
	,FORMAT(MAX(CAST(total_cases AS BIGINT)), '#,##0.00') AS max_cases
	,FORMAT(MAX(CAST(population AS BIGINT)), '#,##0.00') AS max_pop
	,ROUND(MAX(CAST(total_cases AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalCasesOverPop
	,ROUND(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalDeathsOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null
Group by location, continent
----Order by MAX(CAST(total_cases AS BIGINT)) DESC
--Order by TotalDeathsOverPop DESC

USE ATA_CovidPortfolioProject_Apr2023
GO
Create View TotCases_Deaths_ByContinent AS
Select 
	location
	,continent
	,FORMAT(MAX(CAST(total_deaths AS BIGINT)), '#,##0.00') AS max_deaths
	,FORMAT(MAX(CAST(total_cases AS BIGINT)), '#,##0.00') AS max_cases
	,FORMAT(MAX(CAST(population AS BIGINT)), '#,##0.00') AS max_pop
	,ROUND(MAX(CAST(total_cases AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalCasesOverPop
	,ROUND(MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(population AS FLOAT))* 100, 5) AS TotalDeathsOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is null and location not like '%income%'
Group by continent, location
--Order by MAX(CAST(total_cases AS BIGINT)) DESC
--Order by TotalCasesOverPop DESC

USE ATA_CovidPortfolioProject_Apr2023
GO
Create View Global_DeathsCasesPop AS
Select 
	FORMAT(SUM(new_cases), '#,##0') AS TotalNewCases
	,FORMAT(SUM(new_deaths), '#,##0') AS TotalNewDeaths
	,FORMAT(SUM(population), '#,##0') AS TotalPop
	,CASE 
		WHEN SUM(new_cases) = 0 THEN NULL 
		ELSE ROUND(SUM(new_deaths)/SUM(new_cases)*100, 5)
	END AS NewDeathsOverCases
	,CASE 
		WHEN SUM(population) = 0 THEN NULL 
		ELSE ROUND(SUM(new_cases)/SUM(population)*100, 5)
	END AS TotalCasesOverPop
From ATA_CovidPortfolioProject_Apr2023..CovidDeaths
Where continent is not null 