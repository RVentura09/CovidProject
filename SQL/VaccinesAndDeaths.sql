USE ProjectCovid --Select the DB as active

------------------------------------------------------------------
--Show data of total vaccinations per continent
SELECT		cde.location AS Continent,MAX(cva.total_vaccinations) AS Total_Vaccinations,
			MAX(cde.population) AS Population
FROM		CovidVaccinations cva
JOIN		UpdatedCovidDeaths cde ON cde.location=cva.location 
			AND cde.date=cva.date
WHERE		(cde.continent IS NULL)  AND (cde.location!='International')
			AND (cde.location!='European Union')
GROUP BY	cde.location
ORDER BY	cde.location,total_vaccinations
------------------------------------------------------------------
--Show data of total vaccinations per country 
SELECT		cva.continent,cva.location,MAX(cva.total_vaccinations) AS Total_Vaccinations,
			MAX(cde.population) AS Population
FROM		CovidVaccinations cva
JOIN		UpdatedCovidDeaths cde ON cde.location=cva.location 
			AND cde.date=cva.date
WHERE		cde.continent IS NOT NULL
GROUP BY	cva.continent,cva.location
ORDER BY	location,continent,total_vaccinations
-------------------------------------------------------------------
--Show rolling sum of vaccinations per continent
SELECT		cde.location,cde.date,	MAX(cde.population) AS population,  -- Aggregate population per date
			SUM(CAST(cva.new_vaccinations AS INT)) AS daily_vaccinations,  -- Sum daily vaccinations
			SUM(SUM(CAST(cva.new_vaccinations AS INT))) OVER (
			PARTITION BY cde.location 
			ORDER BY cde.date 
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS RollSum
FROM		ProjectCovid..CovidVaccinations cva
JOIN		UpdatedCovidDeaths cde
			ON cde.location = cva.location 
			AND cde.date = cva.date
WHERE
			cde.continent IS  NULL  
			AND cde.location NOT IN ('World', 'European Union (27)', 'International', 
			'Lower-middle-income countries', 'Upper-middle-income countries', 
			'High-income countries', 'Low-income countries'
    )
GROUP BY
    cde.location, cde.date
ORDER BY
    cde.location, cde.date;
-------------------------------------------------------------------
--Show rolling sum of vaccinations per country
SELECT		cde.location,cde.date,	MAX(cde.population) AS population,  -- Aggregate population per date
			SUM(CAST(cva.new_vaccinations AS INT)) AS daily_vaccinations,  -- Sum daily vaccinations
			SUM(SUM(CAST(cva.new_vaccinations AS INT))) OVER (
			PARTITION BY cde.location 
			ORDER BY cde.date 
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS RollSum
FROM		ProjectCovid..CovidVaccinations cva
JOIN		UpdatedCovidDeaths cde
			ON cde.location = cva.location 
			AND cde.date = cva.date
WHERE
			cde.continent IS NOT NULL  
			AND cde.location NOT IN ('World', 'European Union (27)', 'International', 
			'Lower-middle-income countries', 'Upper-middle-income countries', 
			'High-income countries', 'Low-income countries'
    )
GROUP BY
    cde.location, cde.date
ORDER BY
    cde.location, cde.date;
-------------------------------------------------------------------
--Show data of total vaccinations for Germany and Honduras only
SELECT		cva.continent,cva.location,MAX(cva.total_vaccinations) AS Total_Vaccinations,
			MAX(cde.population) AS Population
FROM		CovidVaccinations cva
JOIN		UpdatedCovidDeaths cde ON cde.location=cva.location 
			AND cde.date=cva.date
WHERE		cde.continent IS NOT NULL 
			AND (cde.location='Germany' OR cde.location='Honduras')
GROUP BY	cva.continent,cva.location
ORDER BY	location,continent,total_vaccinations
-------------------------------------------------------------------
--View for Rolling sum of PopulationVaccinated
DROP VIEW IF EXISTS RollPopulationVaccinated;
GO  -- End the batch

CREATE VIEW	RollPopulationVaccinated AS
SELECT		cde.continent,cde.location,cde.date,cde.population,
			cva.new_vaccinations,SUM(CAST(cva.new_vaccinations AS INT)) 
			OVER (PARTITION BY cde.location) AS RollSum
FROM		UpdatedCovidDeaths cde
JOIN		CovidVaccinations cva ON cva.location=cde.location AND cva.date=cde.date
WHERE		cde.continent IS NOT NULL ;
-------------------------------------------------------------------
