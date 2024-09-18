-- STEP 3: Deal with null and blank values (populates that or decide what to do with it)

	# COLUMN industry
    -- Checking if column industry has blank cells or NULL values - YES
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
	-- Checking companies with Airbnb name to find out their industry - found out it should be 'Travel'
SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Airbnb%';
	-- we found out it should be 'Travel'
    
	-- Do the same for other companies we found
SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Bally%' OR company LIKE '%Carvana%' OR company LIKE '%Juul%';
	-- we found out that Carvana should be 'Transportation' and Juul should be 'Consumer' and Bally's Interactive doesn't have more records
    
    -- there is also better way how to check that, because we can use JOIN and WHERE at the same time and prepare our code to fill/populate that blank cells
SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
ORDER BY t1.company;

	-- then, because there could be a issue when working with blank cells we want to set blank cells in industry column to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- AND now we can finally update that cells and fill them with right values
UPDATE layoffs_staging3 t1
JOIN layoffs_staging3 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;
    
# btw. underneath is code (other way) ho to populate industry column for companies, because we already know all the informations, but the code above is not that long
	-- And other way is, that if we use that transaction we didn't have to update and set industry to NULL where it was blank, because it's able to work with that
    -- but if there are thousands of different cells for thousands of different companies, then is that code in transaction underneath really bad
# BEGIN;
# UPDATE layoffs_staging2
# SET industry = 'Travel'
# WHERE company = 'Airbnb'
# AND industry IS NULL;
# UPDATE layoffs_staging2
# SET industry = 'Transportation'
# WHERE company = 'Carvana'
# AND industry IS NULL;
# UPDATE layoffs_staging2
# SET industry = 'Consumer'
# WHERE company = 'Juul'
# AND industry IS NULL;
# COMMIT;

-- Checking if column industry has still some blank cells or NULL values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Checking if column industry has blank cells or NULL values - still one
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
-- But because We know there wasn't anything to fill in (no more rows with Bally's Interactive company), than we are not able to populate that and leave it with NULL value
SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Bally%';
    
# COLUMN total_laid_off, percentage_laid_off and funds we are not able to populate, because we don't have any other informations about employees, etc.
	-- Checking if column total_laid_off has blank cells - NO
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = '';
-- Checking if column total_laid_off has NULL values - YES, a lot (we can check NULL values and blank cells (both of them) in the same code at the same time of course)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;
# We realized there are some rows with NULLS in total_laid_off and percentage_laid_off columns which could be useless for the next analysis and visualizations
	-- Checking columns total_laid_off and percentage_laid_off where are NULLS in the same rows
# Let's check percentage_laid_off for blank values as well to be sure what we have to do 
    -- AND the result is NO as well, so we have some NULL values in total_laid_off and percentage_laid_off, but no blank cells
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = '';

-- NEXT STEP IS: Remove Columns -->
    

