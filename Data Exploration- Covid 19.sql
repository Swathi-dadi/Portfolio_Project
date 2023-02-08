SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM [dbo].[CovidVaccinations]
--ORDER BY 3,4

----Select the data which we want

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

---Looking at total cases vs total deaths
---Shows percentage of people died
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%States%'
ORDER BY 1,2

---Looking at total cases vs population
---Shows percentage of population got covid
SELECT location,date,Population,total_cases,(total_cases/population)*100 as Cases_Percentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%States%' AND continent IS NOT NULL
ORDER BY 1,2
	
--Highest infection rate compared to population

SELECT location,Population,MAX(total_cases) AS Highest_infct_count,MAX((total_cases/population)*100) AS Cases_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY location,Population
ORDER BY Cases_Percentage DESC

--Highest Death count By population

SELECT location,MAX(CAST(total_deaths AS int)) AS Highest_death_count
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Highest_death_count DESC

--Highest Death count By Continent

	SELECT continent,MAX(CAST(total_deaths AS int)) AS Highest_death_count
	FROM PortfolioProject..CovidDeaths
	--WHERE Location like '%INDIA%'
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY Highest_death_count DESC

--Cases and deaths globally based on date
SELECT SUM(new_cases) AS Total_Cases,SUM(cast(new_deaths as int)) AS Total_Deaths,
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%INDIA%'
WHERE continent IS NOT NULL
--GROUP BY date	
ORDER BY 1,2


-- Looking for vacciantions vs Population

SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations FROM 
PortfolioProject..CovidDeaths Dea
JOIN 
PortfolioProject..CovidVaccinations Vac
ON Dea.location=Vac.location AND
   Dea.date=Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3

-- Looking for Rolling count on vaccinated

SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations , 
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location ORDER BY Dea.location,Dea.date) AS Rollingcount_Vaccination
FROM 
PortfolioProject..CovidDeaths Dea
JOIN 
PortfolioProject..CovidVaccinations Vac
ON Dea.location=Vac.location AND
   Dea.date=Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3

----using CTE(Common Table Expression) for vaccination percentage based on population

WITH popvsvac(continent,location,date,population,new_vaccinations,Rollingcount_Vaccination)
AS
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, 
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location ORDER BY Dea.location,Dea.date) AS Rollingcount_Vaccination
FROM 
PortfolioProject..CovidDeaths Dea
JOIN 
PortfolioProject..CovidVaccinations Vac
ON Dea.location=Vac.location AND
	Dea.date=Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(Rollingcount_Vaccination/population)*100 AS Vaccination_Percentage
FROM popvsvac

--Creating Table
DROP TABLE IF EXISTS #PercentPopulationVaccianted
CREATE TABLE #PercentPopulationVaccianted
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccianted	
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, 
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
FROM 
PortfolioProject..CovidDeaths Dea
JOIN 
PortfolioProject..CovidVaccinations Vac
ON Dea.location=Vac.location AND
	Dea.date=Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM #PercentPopulationVaccianted

---Creating View for Visualization
CREATE VIEW PercentPeopleVaccianted AS
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations, 
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeople_Vaccination
FROM 
PortfolioProject..CovidDeaths Dea
JOIN 
PortfolioProject..CovidVaccinations Vac
ON Dea.location=Vac.location AND
	Dea.date=Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPeopleVaccianted