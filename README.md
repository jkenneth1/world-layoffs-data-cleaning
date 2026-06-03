# World Layoffs: End-to-End T-SQL Data Cleaning & Exploratory Data Analysis (EDA)

---

## 📌 Project Overview
Data professionals often spend up to 80% of their time cleaning data rather than analyzing it. This project addresses that reality by transforming a raw, unformatted dataset of global tech company layoffs into a structured, production-ready database schema using **Microsoft SQL Server (T-SQL)**, followed by an advanced Exploratory Data Analysis (EDA).

The project was executed in two major phases:
1. **Data Cleaning & Engineering:** Purging duplicate records, correcting malformed structural data schemas, standardizing erratic dimensional text, and dynamically healing missing parameters.
2. **Exploratory Data Analysis (EDA):** Authoring deep analytic queries to uncover business-critical trajectories, chronological momentum, funding vulnerabilities, and macroeconomic industry contractions.

* **Dataset Source:** [Kaggle - Tech Layoffs 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
* **SQL Dialect:** Microsoft SQL Server (T-SQL)
* **Core Skills Displayed:** Common Table Expressions (CTEs), Window Functions (`ROW_NUMBER`, `DENSE_RANK`), Self-Joins for Imputation, Explicit Transactions (`BEGIN/COMMIT`), Data Type Alterations (DDL), and Time-Series Rollups.

---

## 🛠️ Phase 1: Data Cleaning Process & Pipeline
The cleaning process was executed systematically across seven major milestones within explicit transaction blocks to guarantee database stability and absolute data integrity.

### 1. Table Architecture & Staging
* **The Challenge:** Modifying raw production tables directly is highly risky and violates standard database administration safety practices.
* **The Solution:** Generated a dedicated staging table (`layoffs_staging`) using a selective bulk insert technique. This isolates our cleaning modifications and enables instant rollback safety mechanisms.

### 2. Deduplication Framework
* **The Challenge:** The raw dataset contained completely identical duplicate rows across multiple entries without a unique primary key to distinguish them.
* **The Solution:** Implemented a Common Table Expression (CTE) paired with a `ROW_NUMBER()` window function. By partitioning the data across all major operational dimensions, every row received an indexing value. Duplicate entries with an index greater than 1 were targeted and purged.

### 3. Text & Dimensional Standardization
* **The Challenge:** Inconsistent string inputs, leading/trailing white spaces, and varying regional text inputs (e.g., `'Crypto'`, `'Crypto Currency'`, and `'United States.'`).
* **The Solution:** Applied mass data modifications utilizing `TRIM()` functions to truncate erratic spacing. Unified categorical fields using wildcards and stripped trailing periods dynamically.

### 4. Date Parsing & Normalization
* **The Challenge:** Temporal logs were stored natively as text fields (`VARCHAR`), making standard SQL date calculations and chronological time-series analysis impossible.
* **The Solution:** Deployed `TRY_CONVERT()` to parse raw text strings into a unified schema standard without crashing runtime execution, followed by a physical structural alteration to a true `DATE` data type.

### 5. Schema Type-Casting & Bug Resolution
* **The Challenge:** Quantitative mathematical aggregations failed or returned skewed results (e.g., `MAX()` processing text values alphabetically, identifying `"99"` as greater than `"1200"`). 
* **The Solution:** Scrubbed data entry anomalies (blank strings and literal `'NULL'` words) out of numeric parameters, transforming them into true database `NULL` tokens before casting columns to explicit integers (`INT`) and floating decimals (`FLOAT`).

### 6. Missing Data Imputation
* **The Challenge:** Crucial categorical entries, such as a firm’s `industry`, contained null values, creating systemic gaps in demographic reporting.
* **The Solution:** Authored a robust self-join framework linking matching corporate keys (`company` and `location`) to reference valid data lines and dynamically overwrite and populate missing values.

### 7. Strategic Row Stripping
* **The Challenge:** Retaining incomplete records where both primary analytical metrics (`total_laid_off` and `percentage_laid_off`) were completely missing skewed statistical outcomes and added storage overhead.
* **The Solution:** Executed an unconditional structural filter to drop these uninformative records, trimming the overall database footprint and optimizing storage engine lookups.

---

## 📊 Phase 2: Exploratory Data Analysis (EDA)
With a structurally sound, clean, and typed database, advanced analytical queries were structured to uncover deep industrial trends.

### 1. High-Level Aggregations & Extremes
* **Focus:** Identifying the peak thresholds of single-day corporate downsizings and isolating heavily capitalized companies facing total operational liquidation (100% layoff rates).

### 2. Macroeconomic Insights
* **Focus:** Aggregating total workforce reductions grouped by company, industry verticals, global geography, and the company's funding lifespan stage (Post-IPO, Series A, B, etc.).

### 3. Chronological Time-Series Momentum
* **Focus:** Creating a continuous month-over-month rolling metric of layoffs. By utilizing a windowed aggregation `SUM(...) OVER (ORDER BY Month_Year)`, static monthly figures were transformed into a rolling trend line reflecting the growth vector of workforce losses.
* **Technical Note:** Fixed a T-SQL byte-frame compilation error by casting the temporal string format explicitly to a tight `VARCHAR(7)` schema window.

### 4. Dense Rank Multi-Year Partitioning
* **Focus:** Answering sophisticated corporate questions by breaking down global records into separate calendar year buckets to cleanly rank and isolate the top 5 worst-hit companies for each individual year using `DENSE_RANK()`.

### 5. Capital Efficiency Metrics
* **Focus:** Looking at the "Funding-to-Layoff Efficiency Ratio" for well-funded organizations to determine if massive financial capitalization correlates with higher structural stability or accelerated workforce downsizing relative to capital raised.

---

## 🚀 How to Run This Project
1. Clone this repository to your local machine.
2. Download the source dataset from Kaggle and import it into your SQL Server instance as `layoffs_raw`.
3. Execute `Scripts/SQL Project - Data Cleaning.sql` in **SQL Server Management Studio (SSMS)** to generate the clean schema.
4. Open and run `Scripts/SQL Project - Layoffs Exploratory Data Analysis.sql` to execute the data explorations.

---

## 📈 Next Steps
Now that the entire end-to-end SQL pipeline is built, documented, and fully optimized, this database will serve as a clean source layer to connect directly to **Power BI** to build a dynamic executive analytics dashboard.

---

## 📬 Connect with me: 
Johnsonefekenneth@gmail.com
