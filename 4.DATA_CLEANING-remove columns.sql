-- STEP 4: Remove Columns - for example if it is completely blank and we know it is not useful. 

	-- Still working with total_laid_off and percentage_laid_off because we have some doubts about that data
    -- let's select total_laid_off and percentage_laid_off to check NULL values (we know there are some)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
	-- We found out that's 361 rows with NULL values in both columns in the same rows.
    -- And we are not able to use them... because we want to try to do some analysis or visualizations about the numbers, not just about the locations or industry, 
    -- which means those data are useless for us.
    -- The other thing is there are some data in funds_raised_millions column, but leaving the data in the table would negatively affect/manipulate/ the final results 
    -- because total_laid_off and percentage_laid_off cells are filled with NULL values.
    
    -- So we are deleted those rows (with NULL values in total_laid_off and percentage_laid_off columns).
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

	-- We selected table to check data and realized we want to get rid off the column called row_num, because we don't need that anymore.
SELECT *
FROM layoffs_staging2;
	-- Deleted column row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final selection 
		-- cleaning done, we removed duplicates, standardized data, populated empty cells with values (if we were able) 
        -- or filled blank cells with NULL values, we checked NULL values and removed unusable data 
        -- (for example rows with total_laid_off and percentage_laid_off columns filled just with NULL values)
SELECT *
FROM layoffs_staging2;

-- JOB IS DONE!