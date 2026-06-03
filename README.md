# World Layoffs: Tech Industry Data Cleaning & Database Engineering (T-SQL)

---

## 📌 Project Overview
Data professionals often spend up to 80% of their time cleaning data rather than analyzing it. This project addresses that reality by transforming a raw, unformatted dataset of global tech company layoffs into a structured, optimized, and production-ready database schema using **Microsoft SQL Server (T-SQL)**. 

The primary objective was to take dirty data—containing completely identical duplicate rows, improper string padding, broken temporal configurations, and text-to-numeric type mismatches—and apply defensive SQL programming techniques to make it entirely safe for downstream business intelligence reporting and exploratory analysis.

* **Dataset Source:** [Kaggle - Tech Layoffs 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
* **SQL Dialect:** Microsoft SQL Server (T-SQL)
* **Core Skills Displayed:** Common Table Expressions (CTEs), Window Functions (`ROW_NUMBER`), Self-Joins for Data Imputation, Explicit Transactions (`BEGIN/COMMIT`), Data Type Alterations (DDL), and Advanced String Standardization.

---

## 🛠️ Data Cleaning Process & Pipeline
The cleaning process was executed systematically across seven major milestones within explicit transaction blocks to guarantee database stability and absolute data integrity.

### 1. Table Architecture & Staging
To ensure the raw source data remained completely untouched, a dedicated staging table (`layoffs_staging`) was generated. This approach safeguards the pipeline, allowing for seamless rollbacks if an error occurs.

### 2. Deduplication Framework
* **The Challenge:** The raw dataset contained completely identical duplicate rows without a unique primary key.
* **The Solution:** Implemented a Common Table Expression (CTE) combined with the `ROW_NUMBER()` window function. By partitioning the data across all major attributes—including `company`, `location`, `industry`, `total_laid_off`, and `date`—each unique row was assigned an index. Rows with an index greater than `1` were target-deleted instantly.
* **Optimization:** Used `ORDER BY (SELECT NULL)` to minimize sorting overhead and maximize execution speed during deduplication.

### 3. Text & Dimensional Standardization
* **Whitespace Trimming:** Applied `TRIM()` across critical text dimensions (`company`, `location`, `country`) to eradicate erratic leading or trailing white spaces that could break downstream dashboard filters or string joins.
* **Industry Alignment:** Standardized inconsistent industry naming conventions. For instance, multiple variations like `Crypto`, `Crypto Currency`, and `Cryptocurrency` were unified seamlessly under a single industry moniker: `'Crypto'`.
* **Country Cleanup:** Discovered and stripped trailing punctuation anomalies (e.g., converting `'United States.'` to `'United States'`) dynamically using `TRIM('.' FROM country)`.

### 4. Date Parsing & Normalization
* **The Challenge:** The original date column was imported as raw text strings, creating a blocker for standard time-series analysis.
* **The Solution:** Leveraged `TRY_CONVERT(DATE, [date], 101)` to safely parse standard `MM/DD/YYYY` text strings into actual database date types without throwing hard execution errors on edge cases. Once all anomalies were resolved, the column schema was permanently updated via `ALTER TABLE ... ALTER COLUMN DATE`.

### 5. Schema Type-Casting & Bug Resolution
* **The Challenge:** During initial exploratory queries, a standard `MAX(total_laid_off)` check returned an incorrect value of `99` instead of the true maximum (such as `12,000`). This occurred because the columns `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions` were implicitly imported as text data types (`VARCHAR/NVARCHAR`). SQL was performing alphabetical character-by-character evaluations (sorting `"99"` as greater than `"1200"` because 9 is greater than 1).
* **The Solution:** Implemented a robust defensive casting pipeline. Converted all empty strings (`''`), text literals (`'None'`, `'NULL'`), and blank fields into standard database `NULL` tokens to guarantee safe structural conversion. Then, permanently transformed the physical table schema using standard SQL DDL alterations to lock in accurate data types for math functions:
```sql
ALTER TABLE layoffs_staging ALTER COLUMN total_laid_off INT;
ALTER TABLE layoffs_staging ALTER COLUMN funds_raised_millions INT;
ALTER TABLE layoffs_staging ALTER COLUMN percentage_laid_off FLOAT;
```
### 6. Missing Data Imputation (Self-Join Framework)
* **The Logic:** Found rows where a company's industry value was completely missing, but the same company had valid industry records in other rows.

* **The Execution:** Implemented a robust self-join on matching company and location values to automatically populate and heal the missing industry data:

```SQL
UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2 
    ON t1.company = t2.company 
    AND t1.location = t2.location
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;
  ```

### 7. Strategic Row Stripping
Identified and deleted records where both total_laid_off and percentage_laid_off were simultaneously null. Because these rows lacked the fundamental metrics required for analytics, removing them optimized table performance and streamlined the data footprint.

## 🚀 How to Run This Project
Clone this repository to your local machine.

Download the source dataset from Kaggle and import it into your SQL Server instance as layoffs_raw.

Open the Scripts/SQL Project - Data Cleaning.sql script in SQL Server Management Studio (SSMS).

Execute the script to build the clean, production-ready layoffs_staging table.

## 📈 Next Steps
Now that the dataset is structurally sound, optimized, and verified, this project can be safely transitioned into:

Exploratory Data Analysis (EDA): Aggregating fields to calculate structural time-series data, yearly company rankings, and industry impact metrics.

Executive Visualization: Connecting the database directly to Power BI to build a clean dashboard tracking corporate layoffs globally.

## 📬 Connect with me: 
Johnsonefekenneth@gmail.com
