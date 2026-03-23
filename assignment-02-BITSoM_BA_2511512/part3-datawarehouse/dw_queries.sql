DROP DATABASE IF EXISTS WAREHOUSE;
CREATE DATABASE WAREHOUSE;
SHOW DATABASES;
USE WAREHOUSE;

-- Create Dimension: dim_date
-- I haave included a new variable quarter for any future requirements and drill down and ease to calculate trend by quarter.
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    year INT,
    quarter INT,
    month_name VARCHAR(20)
);

-- Create Dimension: dim_store
CREATE TABLE dim_store (
    store_key INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(100) NOT NULL
);

-- Create Dimension: dim_product
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Create Fact Table: fact_sales
CREATE TABLE fact_sales (
    transaction_id VARCHAR(50) PRIMARY KEY,
    date_key INT NOT NULL,
    store_key INT NOT NULL,
    product_key INT NOT NULL,
    units_sold INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_revenue DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- 1. Data insertion in dim_store (All 5 cities are included)
INSERT INTO dim_store (store_key, store_name, store_city) VALUES
(1, 'Chennai Anna', 'Chennai'),
(2, 'Delhi South', 'Delhi'),
(3, 'Bangalore MG', 'Bangalore'),
(4, 'Pune FC Road', 'Pune'),
(5, 'Mumbai Central', 'Mumbai')
ON DUPLICATE KEY UPDATE
store_city=VALUES(store_city),
 store_name=VALUES(store_name);

-- 2. Populate dim_product (Ensure keys 1-7 exist)
INSERT INTO dim_product (product_key, product_name, category) VALUES
(1, 'Speaker', 'Electronics'),
(2, 'Tablet', 'Electronics'),
(3, 'Phone', 'Electronics'),
(4, 'Smartwatch', 'Electronics'),
(5, 'Atta 10kg', 'Groceries'),
(6, 'Jeans', 'Clothing'),
(7, 'Biscuits', 'Groceries')
ON DUPLICATE KEY UPDATE 
category=VALUES(category),
product_name=VALUES(product_name);

-- 3. Populate dim_date (All 10 dates used in fact rows)
INSERT INTO dim_date (date_key, full_date, day, month, year, quarter, month_name) VALUES
(20230115, '2023-01-15', 15, 1, 2023, 1, 'January'),
(20230205, '2023-02-05', 05, 2, 2023, 1, 'February'),
(20230220, '2023-02-20', 20, 2, 2023, 1, 'February'),
(20230331, '2023-03-31', 31, 3, 2023, 1, 'March'),
(20230809, '2023-08-09', 09, 8, 2023, 3, 'August'),
(20230815, '2023-08-15', 15, 8, 2023, 3, 'August'),
(20230829, '2023-08-29', 29, 8, 2023, 3, 'August'),
(20231026, '2023-10-26', 26, 10, 2023, 4, 'October'),
(20231208, '2023-12-08', 08, 12, 2023, 4, 'December'),
(20231212, '2023-12-12', 12, 12, 2023, 4, 'December')
ON DUPLICATE KEY UPDATE 
day = VALUES(day),
month = VALUES(month),
year = VALUES(year),
quarter = VALUES(quarter),
month_name = VALUES(month_name),
full_date = VALUES(full_date);

INSERT INTO fact_sales (transaction_id, date_key, store_key, product_key, units_sold, unit_price, total_revenue) VALUES 
('TXN5000', 20230829, 1, 1, 3, 49262.78, 147788.34), 
('TXN5001', 20231212, 1, 2, 11, 23226.12, 255487.32), 
('TXN5002', 20230205, 1, 3, 20, 48703.39, 974067.80), 
('TXN5003', 20230220, 2, 2, 14, 23226.12, 325165.68), 
('TXN5004', 20230115, 1, 4, 10, 58851.01, 588510.10), 
('TXN5005', 20230809, 3, 5, 12, 52464.00, 629568.00), 
('TXN5006', 20230331, 4, 4, 6, 58851.01, 353106.06), 
('TXN5007', 20231026, 4, 6, 16, 2317.47, 37079.52), 
('TXN5008', 20231208, 3, 7, 9, 27469.99, 247229.91), 
('TXN5009', 20230815, 3, 4, 3, 58851.01, 176553.03);

-- Q1: Total sales revenue by product category for each month
SELECT d.year, d.month_name, p.category, SUM(f.total_revenue) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY d.year, d.month, d.month_name, p.category
ORDER BY d.year, d.month;

-- Q2: Top 2 performing stores by total revenue
SELECT s.store_name, s.store_city, SUM(f.total_revenue) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.store_name, s.store_city
ORDER BY total_revenue DESC LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
-- I am using LAG function to calculate the trend and a WITH command for using the alias created in the same statement.
WITH MonthlyStats AS (
    SELECT d.year, d.month, SUM(f.total_revenue) AS monthly_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.year, d.month
),
TrendStats AS (
    SELECT year, month, monthly_revenue,
           LAG(monthly_revenue) OVER (ORDER BY year, month) AS prev_month_revenue
    FROM MonthlyStats
)
SELECT year, month, monthly_revenue, prev_month_revenue,
       ((monthly_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0)) * 100 AS sales_trend
FROM TrendStats;