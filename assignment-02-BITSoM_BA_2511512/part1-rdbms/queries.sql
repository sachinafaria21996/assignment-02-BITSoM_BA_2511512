DROP DATABASE IF EXISTS Assignment;
CREATE DATABASE IF NOT exists Assignment;
SHOW databases;
USE Assignment;
-- Customer Data Table
CREATE TABLE Customer (

customer_id VARCHAR(50) PRIMARY KEY,
customer_name VARCHAR(200) NOT NULL,
customer_email VARCHAR(200) NOT NULL,
customer_city VARCHAR(200) NOT NULL
);

-- Product Data Table

CREATE TABLE Product (

product_id VARCHAR(50) PRIMARY KEY,
product_name VARCHAR(200) NOT NULL,
category VARCHAR(200) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL
);

-- Sales Rep Data Table

CREATE TABLE Sales_Rep (

sales_rep_id VARCHAR(50) PRIMARY KEY,
sales_rep_name VARCHAR(200) NOT NULL,
sales_rep_email VARCHAR(200) NOT NULL,
office_address TEXT NOT NULL

);
--  Order Data Table (It contains Order ID,the rep who sold and the customer who bought and on what date the txn took place)
CREATE TABLE Order_Data (

order_id VARCHAR(100) PRIMARY KEY,
customerid VARCHAR(50) NOT NULL,
salesrepid VARCHAR(50) NOT NULL,
order_date DATE,
foreign key (customerid) references Customer(customer_id),
foreign key (salesrepid) references Sales_Rep(sales_rep_id)

);
-- Order Items Table (It contains the product detail as per the order id. A Single order id can have multiple products in quantity. Thus we use a composite key here to avoid repetition of order id data for each product)
CREATE TABLE OrderItems (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Order_Data(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
    );
 
 INSERT INTO Customer (customer_id, customer_name,	customer_email,	customer_city)
 VALUES
 ('C001', 'Rohan Mehta' ,'rohan@gmail.com',	'Mumbai'), 
 ('C002','Priya Sharma','priya@gmail.com','Delhi'),
 ('C003','Amit Verma','amit@gmail.com','Bangalore'),
 ('C004','Sneha Iyer','sneha@gmail.com','Chennai'),
 ('C005','Vikram Singh','vikram@gmail.com','Mumbai');
 
 INSERT INTO Product VALUES 
('P001', 'Laptop', 'Electronics', 55000.00),
('P002', 'Mouse', 'Electronics', 800.00),
('P004', 'Notebook', 'Stationery', 120.00),
('P005', 'Headphones', 'Electronics', 3200.00),
('P007', 'Pen Set', 'Stationery', 250.00),
('P009', 'Tablet', 'Electronics', 15000.00);

INSERT INTO Sales_Rep VALUES 
('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
('SR02', 'Anita Desai', 'anita@corp.com', 'Delhi Office, Connaught Place, New Delhi - 110001'),
('SR03', 'Ravi Kumar', 'ravi@corp.com', 'South Zone, MG Road, Bangalore - 560001');

INSERT INTO Order_Data (order_id, customerid, salesrepid, order_date)
VALUES 
('ORD1000','C002','SR03','2023-05-21'),
('ORD1001','C004','SR03','2023-02-22'),	
('ORD1002','C002','SR02','2023-01-17'),	
('ORD1003','C005','SR01','2023-09-16'),	
('ORD1004','C005','SR01','2023-11-29');

INSERT INTO OrderItems(order_id, product_id, quantity)
VALUES 
('ORD1000', 'P001', 2),
('ORD1001', 'P002', 5),
('ORD1002', 'P005', 1),
('ORD1003', 'P002', 5),
('ORD1004', 'P005', 5);

-- Q1  List all customers from Mumbai along with their total order value

SELECT 
c.customer_name, 
SUM(p.unit_price * oi.quantity) as total_value
FROM Customer c
JOIN Order_Data o ON c.customer_id = o.customerid
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Product p ON oi.product_id = p.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name;

-- Q2 Find the top 3 products by total quantity sold

SELECT
p.product_name,
SUM(oi.quantity) as total_sale
FROM Product p
JOIN OrderItems oi ON p.product_id = oi.product_id
GROUP BY p.product_id,p.product_name
ORDER BY total_sale DESC;

-- Q3 List all sales representatives and the number of unique customers they have handled

SELECT 
sr.sales_rep_name,
COUNT(DISTINCT o.customerid) as unique_customer
FROM Sales_Rep sr
JOIN Order_Data o ON sr.sales_rep_id = o.salesrepid
GROUP BY sr.sales_rep_id
ORDER BY unique_customer DESC;

-- Q4 Find all orders where the total value exceeds 10,000, sorted by value descending

SELECT
o.order_id,
SUM(oi.quantity * p.unit_price) as order_totalamt
FROM Order_Data o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Product p ON oi.product_id = p.product_id
GROUP BY o.order_id
HAVING order_totalamt > 10000
ORDER BY order_totalamt DESC;

-- Q5  Identify any products that have never been ordered

SELECT
p.product_name
FROM Product p
LEFT JOIN OrderItems oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL
ORDER BY p.product_name;