-- SQL Project - Data Cleaning
-- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

CREATE DATABASE world_layoffs;
GO
USE world_layoffs;
GO

-- 1. Create Staging Table
SELECT *
INTO layoffs_staging
FROM layoffs_raw;

-- ==========================================
-- STEP 1: REMOVE DUPLICATES
-- ==========================================
BEGIN TRANSACTION;

WITH DuplicateCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, [location], industry, total_laid_off,
                            percentage_laid_off, [date], stage, country, funds_raised_millions
               ORDER BY (SELECT NULL)
           ) AS row_num
    FROM layoffs_staging
)
DELETE FROM DuplicateCTE
WHERE row_num > 1;

COMMIT TRANSACTION;

-- ==========================================
-- STEP 2: STANDARDIZE TEXT & FIX ERRORS
-- ==========================================
BEGIN TRANSACTION;

-- Trim spaces from key text fields
UPDATE layoffs_staging
SET company = TRIM(company),
    [location] = TRIM([location]),
    country = TRIM(country);

-- Standardize Crypto industry names
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Clean trailing periods from country names (e.g., 'United States.')
UPDATE layoffs_staging
SET country = TRIM('.' FROM country)
WHERE country LIKE '%.';

COMMIT TRANSACTION;

-- ==========================================
-- STEP 3: STANDARDIZE & PARSE DATES
-- ==========================================
BEGIN TRANSACTION;

-- Convert text dates using style 101 (MM/DD/YYYY)
UPDATE layoffs_staging
SET [date] = TRY_CONVERT(DATE, [date], 101)
WHERE [date] IS NOT NULL AND [date] NOT IN ('', 'None', 'NULL');

-- Fallback: Use self-join on raw data to catch dynamically spaced strings
UPDATE staging
SET staging.[date] = TRY_CONVERT(DATE, raw.[date])
FROM layoffs_staging staging
JOIN layoffs_raw raw 
    ON staging.company = raw.company
    AND staging.location = raw.location
WHERE staging.[date] IS NULL
  AND raw.[date] IS NOT NULL 
  AND raw.[date] NOT IN ('', 'None', 'NULL');

-- Safely alter column to formal DATE type
ALTER TABLE layoffs_staging
ALTER COLUMN [date] DATE;

COMMIT TRANSACTION;

-- ==========================================
-- STEP 4: FIX NUMERIC DATA TYPES (CRITICAL FIX)
-- ==========================================
BEGIN TRANSACTION;

-- A. Fix total_laid_off (Convert from Text to Integer)
UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE total_laid_off IN ('', 'None', 'NULL') OR total_laid_off IS NULL;

ALTER TABLE layoffs_staging
ALTER COLUMN total_laid_off INT;

-- B. Fix funds_raised_millions (Convert from Text to Integer)
UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions IN ('', 'None', 'NULL') OR funds_raised_millions IS NULL;

ALTER TABLE layoffs_staging
ALTER COLUMN funds_raised_millions INT;

-- C. Fix percentage_laid_off (Convert from Text to Float for Decimals)
UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off IN ('', 'None', 'NULL') OR percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging
ALTER COLUMN percentage_laid_off FLOAT;

COMMIT TRANSACTION;

-- ==========================================
-- STEP 5: NULL HANDLING & IMPUTATION
-- ==========================================
BEGIN TRANSACTION;

-- Impute missing industries using known data from the same company/location
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2 
    ON t1.company = t2.company 
    AND t1.location = t2.location
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;

COMMIT TRANSACTION;

-- ==========================================
-- STEP 6: REMOVE UNNECESSARY DATA
-- ==========================================
BEGIN TRANSACTION;

-- Drop rows where both vital metrics are missing
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

COMMIT TRANSACTION;

-- Verify final clean dataset with proper structural schema
SELECT * FROM layoffs_staging;
