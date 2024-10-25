USE ProjectCovid -- Set the DB to be active

----------------------------Tableau Queries--------------------------------------------

--DateCountryInfectedSummary.CSV-------------------------------------
Select continent,Location, Population,CAST(date AS DATE) AS Date,  MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From UpdatedCovidDeaths

Group by Location, Population,date,continent
order by PercentPopulationInfected desc
------------------------------------------------------------------
--Globalsummary.csv 

SELECT		SUM (DISTINCT(population))  as Total_Population,
			SUM(new_cases) AS Total_Infected_People,
			SUM(CAST(new_deaths as INT)) as Total_Death,
			ROUND((SUM(new_cases)/SUM (DISTINCT(population)))*100,2) as 'Total Infected (%)',
			ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as 'Total Death (%)'
			
FROM		UpdatedCovidDeaths
WHERE		continent IS NOT NULL
			--Dataset contains a grouping by continent therefore we will consider only
			--individual countries that have a continent 
---------------------------------------------------------------------------
--Continentsummary.csv

SELECT		continent,location,population,MAX(total_cases) AS TotalInfections,
			ROUND(MAX((total_cases/population))*100,2) as PercentInfectedPeople,
			SUM(cast(new_deaths as int)) AS TotalDeaths,
			ROUND(MAX((total_deaths/total_cases))*100,2) as DeathRate
FROM		UpdatedCovidDeaths
WHERE		continent IS  NULL and location not in ('World', 'European Union (27)', 'International','Lower-middle-income countries',
			'Upper-middle-income countries','High-income countries','Low-income countries') AND population>0 AND total_cases>0

			--Dataset contains a grouping by continent in the location column 
			--and those have null values for the continent column 
			--therefore we will only consider locations with null as continent 
GROUP BY	location,population,continent
ORDER BY	DeathRate DESC,PercentInfectedPeople DESC,TotalDeaths;

---------------------------------------------------------------------------
---CountryInfectedsummary.csv

SELECT		location,population,MAX(total_cases) AS TotalInfections,
			ROUND(MAX((total_cases/population))*100,2) as PercentInfectedPeople,continent
FROM		UpdatedCovidDeaths
WHERE		continent IS NOT NULL
			--Dataset contains a grouping by continent therefore we will consider only
			--individual countries that have a continent 
GROUP BY	location,population,continent
ORDER BY	location ,PercentInfectedPeople DESC;



