## ETL Decisions

### Decision 1 — Date Standardization
**Problem:** The raw data contained three different date formats (`DD/MM/YYYY`, `DD-MM-YYYY`, and `YYYY-MM-DD`), making it impossible to perform chronological sorting or extract time components reliably.

**Resolution:** I converted all entries to a standard format (`YYYY-MM-DD`). This allowed for the generation of a consistent `date_key` (YYYYMMDD) for the `dim_date` table.

### Decision 2 — Category Casing and Normalization

**Problem:** The `category` column had inconsistent casing (e.g., 'electronics' vs 'Electronics') and naming variations (e.g., 'Grocery' vs 'Groceries'). This would lead to duplicated entries in dimension tables and split revenue reporting.

**Resolution:** I applied a standardization during the ETL process.

 All strings were transformed to Title Case, and synonyms (Grocery/Groceries) were mapped to a single standard value ('Groceries') before inserting in `dim_product`.

### Decision 3 — Handling Missing Store City Data

**Problem:** The `store_city` column contained NULL values. However, the `store_name` (e.g., "Chennai Anna") was always present and provided a high-confidence indicator of the missing city.

**Resolution:** For any record missing a city, during the ETL process. I looked up the city associated with that specific store name to impute the missing value before inserting it into `dim_store`.