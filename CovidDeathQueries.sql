USE ProjectCovid -- Set the DB to be active
---------------------------------------------------------------------------------------
--Show global number of infections and deaths 

SELECT		SUM (DISTINCT(population))  as Total_Population,
			SUM(new_cases) AS Total_Infected_People,
			SUM(CAST(new_deaths as INT)) as Total_Death,
			ROUND((SUM(new_cases)/SUM (DISTINCT(population)))*100,2) as 'Total Infected (%)',
			ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100,2) as 'Total Death (%)'
			
FROM		coviddeaths
WHERE		continent IS NOT NULL
			--Dataset contains a grouping by continent therefore we will consider only
			--individual countries that have a continent 

---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
--Compare highest infection and death rate in all continents

SELECT		CAST(date AS DATE) as Date,continent,location,population,MAX(total_cases) AS TotalInfections,
			ROUND(MAX((total_cases/population))*100,2) as PercentInfectedPeople,
			MAX(total_deaths) AS TotalDeaths,
			ROUND(MAX((total_deaths/total_cases))*100,2) as DeathRate
FROM		coviddeaths
WHERE		continent IS NOT NULL and location not in ('World', 'European Union', 'International')
			--Dataset contains a grouping by continent in the location column 
			--and those have null values for the continent column 
			--therefore we will only consider locations with null as continent 
GROUP BY	location,population,continent,date
ORDER BY	DeathRate DESC,PercentInfectedPeople DESC,TotalDeaths;

---------------------------------------------------------------------------------------
--Compare highest infection rate in all countries

SELECT		location,population,MAX(total_cases) AS TotalInfections,
			ROUND(MAX((total_cases/population))*100,2) as PercentInfectedPeople,continent
FROM		coviddeaths
WHERE		continent IS NOT NULL
			--Dataset contains a grouping by continent therefore we will consider only
			--individual countries that have a continent 
GROUP BY	location,population,continent
ORDER BY	location,continent ,PercentInfectedPeople DESC;
---------------------------------------------------------------------------------------
--Compare highest death rate in all countries

SELECT		location,population,MAX(total_cases) AS TotalInfections,
			MAX(total_deaths) AS TotalDeaths,
			ROUND(MAX((total_deaths/total_cases))*100,2) as DeathRate
FROM		coviddeaths
WHERE		continent IS NOT NULL
			--Dataset contains a grouping by continent therefore we will consider only
			--individual countries that have a continent 
GROUP BY	location,population
ORDER BY	DeathRate DESC,TotalDeaths DESC,TotalInfections DESC,population DESC;
---------------------------------------------------------------------------------------
--Compare only data overt time from Germany and Honduras.
--Select  total cases, total deaths,population and the death percentage 


SELECT		location,CAST(Date AS Date) as Date,total_cases,total_deaths,population, 
			--We are using cast to remove time data from the date column 
			--the first "Date" is the name of the column the second "Date" is the data type
			--the last "as Date" is the final name that column will display in results
			(total_deaths/total_cases)*100 AS DeathPercentage
FROM		coviddeaths
WHERE		location like '%Honduras%' OR location like '%Germany%'
Order by	1,2;

---------------------------------------------------------------------------------------

--Compare highest death rate and infection rate in Germany and Honduras

SELECT		location,population,MAX(total_cases) AS TotalInfections,
			MAX(CAST(total_deaths AS INT)) AS TotalDeaths,
			--We used the cast function to solve data inconsistencies
			--as the maximum number of total deaths for Honduras was capped at only 99. 
			ROUND(MAX((total_cases/population))*100,2) as PercentInfectedPeople,
			ROUND(MAX((total_deaths/total_cases))*100,2) as DeathRate
FROM		coviddeaths
WHERE		location LIKE '%Honduras%' OR location='Germany'
GROUP BY	location,population
ORDER BY	DeathRate DESC,TotalInfections DESC,population DESC;
---------------------------------------------------------------------------------------
