-- DATA CLEANING

SELECT *
FROM layoffs;

-- STEPS TO DO TO CLEAN DATA!
# 1. Remove Duplicates
# 2. Standardize the Data
# 3. Null Values or blank Values (populates that or decide what to do with it)
# 4. Remove Any Columns - for example if it is completely blank and we know it is not useful. 
# !!!But in real work there is usualy protocol writen what to do... min what we should do everytime is work with copy!!!

# Copy of Table (layoffs to layoffs staging)
-- CREATE TABLE layoffs_staging
-- LIKE layoffs;

# SELECT table (copy of layoffs)
SELECT *
FROM layoffs_staging;

# Copy of Data (from layoffs to layoffs staging)
-- INSERT layoffs_staging
-- SELECT * 
-- FROM layoffs;

# SELECT new dataset (copy of layoffs dataset in the table)
SELECT *
FROM layoffs_staging;

-- STEP 1: Find duplicates and Remove them
###NOTES - ROW_NUMBER IS ADDING COLUMN WITH position of every row (with partition it starts again for every part)###
# a) create SELECT statement with window functions to see if there are any duplicates 
# - using functions ROW_NUMBER - to see numbers of every unique rows, then using OVER funciton partitioning by few collumns to see if there are duplicates 
# (if we see number 2 and more in row_num, we have duplicates)
# b) use CTE to add WHERE funciton to filter (see) row_num with number 2 and higher

WITH CTE_layoffs_duplicates AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
)
SELECT *
FROM CTE_layoffs_duplicates
WHERE row_num > 1;

# c) run select statement over a few duplicates to check if they actually are duplicates, 
# because we didnt use every single column in the query above and we can see, that those arent duplicates, so we have to change our query above
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

# d) change and run the CTE (ROW_NUMBER OVER PARTIOTION) query over all columns
WITH CTE_layoffs_duplicates AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM CTE_layoffs_duplicates
WHERE row_num > 1;

# e) run again select statement over a few duplicates to check if they actually are real duplicates (for example try some of these companies:'Casper', 'Cazoo', 'Hibob', 'Wildlife Studios' and 'Yahoo')
SELECT *
FROM layoffs_staging
WHERE company IN ('Casper', 'Cazoo', 'Hibob', 'Wildlife Studios', 'Yahoo')
ORDER BY company;

# e) removing the duplicates
	-- because we cant update (that means delete tables through CTEs as well), we have to at first we want to create table layoffs_staging2, 
    -- where we will delete that duplicates later (code underneath is copied from layoff_staging + we added column row_num)
    
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- now just selecting new table to check if it is ok
    
SELECT *
FROM layoffs_staging2;

	-- run the INSERT INTO statement with adding previous identified data in the new table
    
INSERT INTO layoffs_staging2    
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

	-- check new table layoffs_staging2 - all good
    
SELECT *
FROM layoffs_staging2;

	-- and check duplicates
    
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

	-- and then delete them
    
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

	-- and check duplicates again  -- good

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

	-- and whole table

SELECT *
FROM layoffs_staging2;

-- NEXT STEP IS: Standardize the Data -->