# World Layoffs 2022: Data Cleaning & Standardization Project (T-SQL)

## 📌 Project Overview
Data professionals often spend up to 80% of their time cleaning data rather than analyzing it. This project addresses that reality by transforming a raw, unformatted dataset of global tech company layoffs (2022 onwards) into a structured, production-ready database schema using **Microsoft SQL Server (T-SQL)**. 

The primary goal was to take dirty data—containing duplicates, inconsistent text formatting, improper data types, and missing values—and apply defensive SQL programming techniques to make it entirely safe for downstream Exploratory Data Analysis (EDA) and business intelligence reporting.

* **Dataset Source:** [Kaggle - Tech Layoffs 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
* **SQL Dialect:** Microsoft SQL Server (T-SQL)
* **Core Skills Displayed:** Common Table Expressions (CTEs), Window Functions (`ROW_NUMBER`), Self-Joins for Imputation, Explicit Transactions (`BEGIN/COMMIT`), Data Type Alterations, and Advanced String Standardization.

---

## 🛠️ Data Cleaning Process & Pipeline
The cleaning process was executed systematically across five major milestones to ensure absolute data integrity.

### 1. Staging Environment Setup
To ensure the raw source data remained completely untouched, a dedicated staging table (`layoffs_staging`) was generated. This approach safeguards the pipeline, allowing for seamless rollbacks if an error occurs.

### 2. Deduplication via Window Functions
* **The Challenge:** The raw dataset contained completely identical duplicate rows without a unique primary key.
* **The Solution:** Implemented a Common Table Expression (CTE) combined with the `ROW_NUMBER()` window function. By partitioning the data across all major attributes—including `company`, `location`, `industry`, `total_laid_off`, and `date`—each unique row was assigned an index. Rows with an index greater than `1` were target-deleted instantly.
* **Optimization:** Used `ORDER BY (SELECT NULL)` to minimize sorting overhead and maximize execution speed during deduplication.

### 3. Text Standardization & Error Fixing
* **Whitespace Trimming:** Applied `TRIM()` across critical text dimensions (`company`, `location`, `country`) to eradicate erratic leading or trailing white spaces that could break downstream dashboard filters or string joins.
* **Industry Alignment:** Standardized inconsistent industry naming conventions. For instance, multiple variations like `Crypto`, `Crypto Currency`, and `Cryptocurrency` were unified seamlessly under a single industry moniker: `'Crypto'`.
* **Country Cleanup:** Discovered and stripped trailing punctuation anomalies (e.g., converting `'United States.'` to `'United States'`) dynamically using `TRIM('.' FROM country)`.

### 4. Date Type Parsing & Optimization
* **The Challenge:** The original date column was imported as raw text strings, creating a blocker for standard time-series analysis.
* **The Solution:** Leveraged `TRY_CONVERT(DATE, [date], 101)` to safely parse standard `MM/DD/YYYY` text strings into actual database date types without throwing hard execution errors on edge cases.
* **Fallback Logic via Self-Join:** Implemented a defensive fallback query joining back to the raw source data to resolve dynamically spaced string dates that failed initial parsing. Once all anomalies were resolved, the column schema was permanently updated via `ALTER TABLE ... ALTER COLUMN DATE`.

### 5. Null Value Handling & Data Imputation
* **String to Database Nulls:** Standardized literal string values (like text `'NULL'`) into genuine database `NULL` markers for numeric fields such as `funds_raised_millions`.
* **Industry Imputation (Self-Join Framework):** Found rows where a company's `industry` value was completely missing, but the same company had valid industry records in other rows. Implemented a robust self-join on matching `company` and `location` values to automatically populate and heal the missing industry data:
```sql
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2 
    ON t1.company = t2.company 
    AND t1.location = t2.location
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;
