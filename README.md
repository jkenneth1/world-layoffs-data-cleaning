### 🛠️ Data Cleaning Process & Pipeline
The cleaning process was executed systematically across seven major milestones within explicit transaction blocks to guarantee database stability and absolute data integrity:

```sql
-- 1. TABLE ARCHITECTURE & STAGING
-- Generated a dedicated staging table (layoffs_staging) to safeguard raw data.
SELECT * INTO layoffs_staging FROM layoffs_raw;

-- 2. DEDUPLICATION FRAMEWORK
-- Used a CTE and ROW_NUMBER() partitioned across all attributes to delete duplicates.
WITH DuplicateCTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY company, [location], industry, total_laid_off,
    percentage_laid_off, [date], stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
    FROM layoffs_staging
)
DELETE FROM DuplicateCTE WHERE row_num > 1;

-- 3. TEXT & DIMENSIONAL STANDARDIZATION
-- Eradicated erratic whitespace and unified erratic variations like 'Crypto Currency' to 'Crypto'.
UPDATE layoffs_staging SET company = TRIM(company), [location] = TRIM([location]), country = TRIM(country);
UPDATE layoffs_staging SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';
UPDATE layoffs_staging SET country = TRIM('.' FROM country) WHERE country LIKE '%.';

-- 4. DATE PARSING & NORMALIZATION
-- Converted raw text strings into formal database DATE types using TRY_CONVERT.
UPDATE layoffs_staging SET [date] = TRY_CONVERT(DATE, [date], 101) WHERE [date] IS NOT NULL;
ALTER TABLE layoffs_staging ALTER COLUMN [date] DATE;

-- 5. SCHEMA TYPE-CASTING & BUG RESOLUTION
-- Permanently altered implicit text columns into integers and floats to fix math anomalies.
ALTER TABLE layoffs_staging ALTER COLUMN total_laid_off INT;
ALTER TABLE layoffs_staging ALTER COLUMN funds_raised_millions INT;
ALTER TABLE layoffs_staging ALTER COLUMN percentage_laid_off FLOAT;

-- 6. MISSING DATA IMPUTATION (SELF-JOIN)
-- Joined the table to itself on company and location to heal blank industry values.
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2 ON t1.company = t2.company AND t1.location = t2.location
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- 7. STRATEGIC ROW STRIPPING
-- Filtered out and destroyed rows where both primary metrics were completely missing.
DELETE FROM layoffs_staging WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
