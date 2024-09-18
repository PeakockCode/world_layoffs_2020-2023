-- STEP 2: Standardize the Data - finding issuses in data and then fixing it

SELECT *
FROM layoffs_staging2;

# a) get rid off the spaces at the beginnings and ends of text (for example we found out that in column company some text is with that white spaces) 

	# we need to delete some spaces in company column at the beginning and end of every company name - so we will use the trim
	-- at first just use trim to see if it looks better
SELECT company, TRIM(company)
FROM layoffs_staging2;

	-- after that update the column (remove that spaces in company column)
UPDATE layoffs_staging2 
SET company = TRIM(company);

# b) update duplicate or similar categories
# (for example in industry are categories Crypto, Crypto Currency and CryptoCurrency, so we have to choose just one and use that across of them)

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;
	-- SELECT everything with Crypto category to find out what to do next (in Postgers would be better to use ILIKE because all the categories beggin with UPPERCASE)
SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';
	-- We found that mostly is the category called Crypto and all the companies are definitely from Crypto industry, co let's update Crypto Currency and CryptoCurrency (both) to Crypto
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('CryptoCurrency', 'Crypto Currency');
	-- SELECT Crypto industry again to check if it's all done - and all is good
SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%'
ORDER BY industry;
	-- but if we SELECT industry again we still have the whitespaces and nulls - BUT WE WILL WORK WITH THAT IN STEP 3
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY industry;

SELECT industry
FROM layoffs_staging2
ORDER BY industry;    

# c) deal with unreadeble (fonts) names
	-- if you run the code underneath you find for example in location are DÃ¼sseldorf, FlorianÃ³polis and MalmÃ¶ (at the same time we found that MalmÃ¶ is probably duplicate of Malmo)¶
SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

	-- We found out through the code, that DÃ¼sseldorf = Düsseldorf in Germany, [Malmo, MalmÃ¶] = Malmö (in Sweden) and FlorianÃ³polis = Florianópolis in Brazil
SELECT *
FROM layoffs_staging2
WHERE location IN ('DÃ¼sseldorf', 'FlorianÃ³polis', 'MalmÃ¶', 'Malmo')
ORDER BY 1;

	-- Lets update table and to be sure everything is gonna be ok I will use TRANSACTION
BEGIN;
UPDATE layoffs_staging2
SET location = 'Düsseldorf'
WHERE location = 'DÃ¼sseldorf';
UPDATE layoffs_staging2
SET location = 'Florianópolis'
WHERE location = 'FlorianÃ³polis';
UPDATE layoffs_staging2
SET location = 'Malmö'
WHERE location IN ('MalmÃ¶', 'Malmo');
COMMIT;
	-- Check location again - all is good
SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

# d) deal with similar names (Czech republic vs Czech Rep., Germany vs germany)
	-- Checked country and found out there is issue with USA (United States vs United States.)
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;
	-- OR we can use TRIM(Trailing '.' FROM country) to see comparison between how it look like and how it will be if we use TRIM(TRAILING '.' FROM country) - it is gonna fix that bug
    -- TRAILING '.' is for something where we are not looking for white spaces
SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
	-- Checked just the wrong name to be sure and found 4 records
SELECT *
FROM layoffs_staging2
WHERE country = 'United States.'
ORDER BY country;
    
	-- updated United States. to United States and it affected all 4 rows
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
	-- we could easily use SET country = 'United States' WHERE country = 'United States.'

	-- select and check country again - all good
SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

# e) deal with dates (our date column is text type, but if we want to do timeseries exploratory and visualization, we need to change that type to date type

SELECT *
FROM layoffs_staging2;
SELECT `date`
FROM layoffs_staging2;

	-- Deal with dates (our date column is text type, but if we want to do timeseries exploratory and visualization, we need to change that type to date type).
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

	-- We didn't use CAST because the data was not originally in the correct date format ('YYYY/MM/DD'); it was in 'DD/MM/YYYY', which could lead to errors. 
	-- On the other hand, STR_TO_DATE is well-suited for this conversion!
    -- SO UPDATE column date to new type
UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y');

	-- check if it is all good - ok
SELECT `date`
FROM layoffs_staging2;

	-- modify column to new data type 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2;

-- NEXT STEP IS: Deal with null and blank values -->
