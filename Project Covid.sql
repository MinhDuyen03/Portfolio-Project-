--TABLE CovidDeaths
SELECT *
FROM TESTD41..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM TESTD41..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM TESTD41..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total cases and total deaths in country: Deathprecentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PrecentageofDeath
FROM TESTD41..CovidDeaths
WHERE location like '%VietNam%' and continent is not null
ORDER BY 1,2

--Total case and population: PrecentagePopulation
SELECT location, date, total_cases, population, (total_cases/population)*100 as PrecentageofPopulation
FROM TESTD41..CovidDeaths
--WHERE location like '%VietNam%'
ORDER BY 1,2

--The countries with highest infection rate compared to popuplation
SELECT location, population,MAX(total_cases) as Highestinfection, MAX(total_cases/population)*100 as PopulationhPrecentageinfection
FROM TESTD41..CovidDeaths
--WHERE location like '%VietNam%'
GROUP BY location, population
ORDER BY PopulationhPrecentageinfection DESC

---The countries with highest death count per popuplation
SELECT continent,MAX(cast (total_deaths as INT)) as Totaldeathscount
FROM TESTD41..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Totaldeathscount DESC

 --Global number
SELECT SUM(new_cases) as Totalnewcases, SUM(cast(new_deaths as INT ))as Totalnewdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Totalnew
FROM TESTD41..CovidDeaths
WHERE continent is not null
--GROUP BY  date
ORDER BY 1,2

--TABLE CovidVaccination and JOIN
SELECT *
FROM TESTD41..CovidDeaths dea
JOIN TESTD41..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date

--Total population and Vaccination
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM TESTD41..CovidDeaths dea
JOIN TESTD41..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(cast (vac.new_vaccinations as int)) OVER(PARTITION BY dea.location order by dea.location, dea.date) as Totalnewvac
FROM TESTD41..CovidDeaths dea
JOIN TESTD41..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE
WITH PopandVac (Continent, Location, Date, Popluation, new_vaccinations,Totalnewvac)
AS 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location order by dea.location, dea.date) as Totalnewvac
FROM TESTD41..CovidDeaths dea
JOIN TESTD41..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *
FROM PopandVac

--TEMP TABLE
CREATE TABLE PerPopluationvaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Totalnewvac numeric
)

INSERT INTO PerPopluationvaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location order by dea.location, dea.date) as Totalnewvac
FROM TESTD41..CovidDeaths dea
JOIN TESTD41..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (Totalnewvac/Population)*100 as Totalpovac
FROM PerPopluationvaccinated

--Create view for data visualizations
Create view Populationvaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location order by dea.location, dea.date) as Totalnewvac
FROM TESTD41..CovidDeaths dea
JOIN TESTD41..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM Populationvaccinated