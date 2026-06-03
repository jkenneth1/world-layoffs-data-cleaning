-- ==========================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- Dataset: Global Tech Layoffs https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Cleaned and structured data in the 'layoffs_staging' table https://github.com/jkenneth1/world-layoffs-data-cleaning
-- Objective: Uncover trends, patterns, and severe impacts
-- ==========================================

USE world_layoffs;
GO

-- Quick verification of our clean staging table
SELECT * 
FROM layoffs_staging;

-- ==========================================
-- 1.CORE FOUNDATIONAL QUERIES
-- ==========================================

-- Look at the maximums to find the scale of single-day layoffs
SELECT 
    MAX(total_laid_off) AS max_laid_off, 
    MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging;

-- Companies that completely shut down (100% laid off / 1.0 percentage) ordered by highest funding and total laid off
SELECT company, industry, stage, funds_raised_millions
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, industry, stage, total_laid_off
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Top 10 Companies with the highest absolute total layoffs
SELECT TOP 10 company, SUM(total_laid_off) AS total_losses
FROM layoffs_staging
GROUP BY company
ORDER BY total_losses DESC;

-- Top 10 Industries hardest hit by layoffs
SELECT TOP 10 industry, SUM(total_laid_off) AS total_losses
FROM layoffs_staging
GROUP BY industry
ORDER BY total_losses DESC;

-- Top 10 Countries with the highest layoffs
SELECT TOP 10 country, SUM(total_laid_off) AS total_losses
FROM layoffs_staging
GROUP BY country
ORDER BY total_losses DESC;

-- Total layoffs broken down by Year
SELECT YEAR([date]) AS [Year], SUM(total_laid_off) AS total_losses
FROM layoffs_staging
WHERE [date] IS NOT NULL
GROUP BY YEAR([date])
ORDER BY [Year] DESC;

-- Layoffs broken down by funding stage (Post-IPO, Series A, B, etc.)
SELECT stage, SUM(total_laid_off) AS total_losses
FROM layoffs_staging
GROUP BY stage
ORDER BY total_losses DESC;


-- ==========================================
-- 2. ADVANCED EXPLORATIONS 
-- (Adding deep analytics beyond the basics)
-- ==========================================


-- A. ROLLING TOTAL OF LAYOFFS BY MONTH (Time Series Analysis)
-- Shows the momentum of layoffs over time using a window function
-- Fixed byte-size restriction by casting the month string to VARCHAR(7)
WITH MonthlyLayoffs AS (
    SELECT 
        CAST(FORMAT([date], 'yyyy-MM') AS VARCHAR(7)) AS [Month_Year],
        SUM(total_laid_off) AS monthly_losses
    FROM layoffs_staging
    WHERE [date] IS NOT NULL
    GROUP BY FORMAT([date], 'yyyy-MM')
)
SELECT 
    [Month_Year],
    monthly_losses,
    SUM(monthly_losses) OVER (
        ORDER BY [Month_Year]
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rolling_total_layoffs
FROM MonthlyLayoffs
ORDER BY [Month_Year];


-- B. COMPANY LAYOFF RANKINGS PER YEAR (Using DENSE_RANK)
-- Find which top 5 companies laid off the most people each calendar year
WITH CompanyYearRanking AS (
    SELECT 
        company,
        YEAR([date]) AS [Year],
        SUM(total_laid_off) AS total_losses,
        DENSE_RANK() OVER (PARTITION BY YEAR([date]) ORDER BY SUM(total_laid_off) DESC) AS ranking
    FROM layoffs_staging
    WHERE [date] IS NOT NULL AND total_laid_off IS NOT NULL
    GROUP BY company, YEAR([date])
)
SELECT company, [Year], total_losses, ranking
FROM CompanyYearRanking
WHERE ranking <= 5
ORDER BY [Year] ASC, total_losses DESC;


-- C. FUNDING TO LAYOFF EFFICIENCY RATIO
-- Exploring if high-funded companies were more prone to massive layoffs
SELECT TOP 10
    company,
    SUM(funds_raised_millions) AS total_funding_millions,
    SUM(total_laid_off) AS total_losses,
    ROUND((SUM(total_laid_off) / CAST(SUM(funds_raised_millions) AS FLOAT)) * 100, 2) AS layoffs_per_100m_funded
FROM layoffs_staging
WHERE funds_raised_millions IS NOT NULL AND total_laid_off IS NOT NULL
GROUP BY company
HAVING SUM(funds_raised_millions) > 500 -- Focusing on well-funded tech entities
ORDER BY layoffs_per_100m_funded DESC;
