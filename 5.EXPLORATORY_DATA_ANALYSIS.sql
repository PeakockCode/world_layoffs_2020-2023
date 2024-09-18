-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM world_layoffs.layoffs_staging2;

# 1) Basic exploration and statistics - Initial data overview focused on total laid off

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;

-- Which companies had 1 and that is basically 100 percent of they company laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
	-- We see there are some companies with 100 % laid off
	-- it looks like these are mostly startups who all went out of business during this time
    
-- if we order by funds_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
	-- BritishVolt, BlockFi, Quibi! Volt Bank, etc. some kinda known companies /some of them with really big/
    
-- Companies with the biggest single Layoff in a single day
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging2
ORDER BY 2 DESC
LIMIT 5;


-- Companies with the most Total Layoffs, added column funds_raised_millions for comparison.
SELECT company, SUM(total_laid_off), SUM(funds_raised_millions)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
	-- we can see Twitter, Meta, Amazon, Google, etc.
    
-- We checked date range to be able to work with data properly (date range: 2020-03-11 - 2023-03-06)
SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoffs_staging2;    
    
-- the Total Layoffs by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- the Total Layoffs by country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- the Total Layoffs by industry
SELECT industry, SUM(total_laid_off), SUM(funds_raised_millions)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- the Total Layoffs by date
SELECT `date`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

-- 10 days with the highest layoffs
SELECT `date`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY `date`
ORDER BY 2 DESC
LIMIT 10;

-- the Total Layoffs by Year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
 -- worst was actually year 2022 and right after 2023

-- and the Total Layoffs by Months - the worst is January of course
SELECT MONTH(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY MONTH(`date`)
ORDER BY 2 DESC;

-- and the Total Layoffs by stage - the top is POST-IPO, where are mostly large companies at the top like Amazon, Google, Meta, etc.
SELECT stage, SUM(total_laid_off), SUM(funds_raised_millions)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- but if you add average percentage of laid off you see it was worst for companies in seed phase
SELECT stage, SUM(total_laid_off) AS total_laid_off, ROUND(AVG(percentage_laid_off),2) AS avg_percentage_laid_off, SUM(funds_raised_millions) AS total_funds_raised_millions
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 3 DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

# 2) Deeper exploration focused on Layoffs per Date

-- SELECT all just for refreshment
SELECT *
FROM world_layoffs.layoffs_staging2;

 -- I used "over" function (partition by company order by date) to check how times went in case of every company
SELECT company, `date`, total_laid_off,
SUM(total_laid_off) OVER(PARTITION BY company ORDER BY `date`) AS rolling_total
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NOT NULL;
 
-- Total of Layoffs Per YEAR AND MONTH - the worst dates are January 2023, November 2022 and February 2023. It seems that 2023 was kinda bad for employees!
SELECT YEAR(`date`) AS `YEAR`, MONTH(`date`) AS `MONTH`, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY `YEAR`, `MONTH`
ORDER BY total_laid_off DESC;

-- Total Layoffs Per Month to see as the time went
SELECT YEAR(`date`) AS `YEAR`, MONTH(`date`) AS `MONTH`, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY `YEAR`, `MONTH`
ORDER BY 1, 2;

-- The same thing like before, just concat year and month (we could use concat function in previous select ofc)
SELECT SUBSTRING(`date`, 1, 7) AS `YEAR_MONTH`, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `YEAR_MONTH`
ORDER BY 1 ASC;

-- And if we add CTE we can use over function to see rolling total of Layoffs per every month of the every year in dataset
-- as we know from that selections before we can just confirm that end of 2022 and first 2 months of 2023 were really devastating for employment
WITH Rolling_Total AS
(SELECT SUBSTRING(`date`, 1, 7) AS `YEAR_MONTH`, SUM(total_laid_off) AS laid_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `YEAR_MONTH`
ORDER BY 1 ASC
)
SELECT `YEAR_MONTH`, laid_off,
SUM(laid_off) OVER(ORDER BY `YEAR_MONTH`) AS rolling_total
FROM Rolling_Total;

-- Query to show layoffs by year per company, allowing us to compare the trends in layoffs across different companies.
WITH Company_Year_Laid_Off (Company, `Year`, Laid_Off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY Company, YEAR(`date`)
)
SELECT *,
SUM(Laid_Off) OVER (PARTITION BY Company ORDER BY Laid_Off DESC) AS ROLLING_TOTAL,
SUM(Laid_Off) OVER(PARTITION BY Company) AS TOTAL_LAID_OFF,
DENSE_RANK() OVER(PARTITION BY Company ORDER BY Laid_Off DESC) AS COMPANY_LAID_OFF_RANKING
FROM Company_Year_Laid_Off
WHERE `Year` IS NOT NULL
AND Laid_Off IS NOT NULL
ORDER BY TOTAL_LAID_OFF DESC, COMPANY_LAID_OFF_RANKING, `Year`;

-- The query shows the ranking of layoffs by year 
-- we first see the companies with the highest number of layoffs, followed by those in second place, and so on.
WITH Company_Year (Company, `Year`, Total_Laid_Off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *,
DENSE_RANK() OVER (PARTITION BY `Year` ORDER BY Total_Laid_Off DESC) AS LAID_OFF_RANKING
FROM Company_Year
WHERE `Year` IS NOT NULL
AND Total_Laid_Off IS NOT NULL
ORDER BY LAID_OFF_RANKING;

-- This query shows similar ranking (from first to fifth position) of layoffs for each individual year.
WITH Company_Year_laid_off (Company, `Year`, Total_Laid_Off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER (PARTITION BY `Year` ORDER BY Total_Laid_Off DESC) AS LAID_OFF_RANKING
FROM Company_Year_laid_off
WHERE `Year` IS NOT NULL
AND Total_Laid_Off IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE LAID_OFF_RANKING <=5
;