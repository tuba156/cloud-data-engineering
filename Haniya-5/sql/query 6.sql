-- ============================================================
-- HOMEWORK: Indexes & Stored Procedures (Solution)
-- Database: BikeStores
-- ============================================================

-- ============================================================
-- PART A: INDEXES
-- ============================================================

-- Q1.
-- Create a non-clustered index on last_name.
-- Then write a query that benefits from it.

CREATE INDEX idx_customer_last_name
ON sales.customers(last_name);

SELECT *
FROM sales.customers
WHERE last_name = 'Fisher';

-- ============================================================

-- Q2.
-- Create a composite index on customer_id and order_date.

CREATE INDEX idx_customer_orderdate
ON sales.orders(customer_id, order_date);

SELECT *
FROM sales.orders
WHERE customer_id = 10
AND order_date = '2016-01-03';

-- ============================================================

-- Q3.

-- A UNIQUE INDEX allows only unique values.
-- If duplicate phone numbers already exist,
-- SQL Server will not create the index.
-- It is safe only if every customer has a unique phone number.
-- NULL values should also be considered depending on the data.

-- ============================================================

-- Q4.

-- order_id
-- YES
-- Primary Key automatically creates a clustered index.

-- status
-- NO
-- Only a few values (Pending, Shipped, Delivered).
-- Low selectivity, so indexing is usually not useful.

-- customer_id
-- YES
-- Foreign Key and frequently used in WHERE and JOIN.

-- notes
-- NO
-- Free-text column and rarely searched.

-- ============================================================

-- Q5.

EXEC sp_helpindex 'production.products';

-- Output:
-- index_name         = Name of the index
-- index_description  = Clustered / Nonclustered / Unique
-- index_keys         = Columns included in the index

-- ============================================================
-- PART B: STORED PROCEDURES
-- ============================================================

-- Q6.
-- Create procedure to return customer orders.

CREATE PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN

    SELECT
        order_id,
        order_date,
        order_status
    FROM sales.orders
    WHERE customer_id = @CustomerID
    ORDER BY order_date;

END;

-- Execute

EXEC sp_GetCustomerOrders 5;

-- ============================================================

-- Q7.
-- Return message if customer has no orders.

ALTER PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM sales.orders
        WHERE customer_id = @CustomerID
    )

    BEGIN

        SELECT
            order_id,
            order_date,
            order_status
        FROM sales.orders
        WHERE customer_id = @CustomerID
        ORDER BY order_date;

    END

    ELSE

    BEGIN

        SELECT 'No orders found for this customer' AS Message;

    END

END;

-- Execute

EXEC sp_GetCustomerOrders 9999;

-- ============================================================

-- Q8.
-- Products by Category

CREATE PROCEDURE sp_ProductsByCategory

    @CategoryID INT,
    @MaxPrice DECIMAL(10,2) = 9999

AS

BEGIN

    SELECT
        product_id,
        product_name,
        list_price
    FROM production.products
    WHERE category_id = @CategoryID
    AND list_price <= @MaxPrice
    ORDER BY list_price ASC;

END;

-- Execute

EXEC sp_ProductsByCategory 2;

EXEC sp_ProductsByCategory 2,2000;

-- ============================================================
-- PART C: MIXED QUESTIONS
-- ============================================================

-- Q9.

-- 1. Create an index on (store_id, order_date)
-- because the procedure filters using these columns.

-- Example:

CREATE INDEX idx_store_orderdate
ON sales.orders(store_id, order_date);

-- 2. Improve the stored procedure by selecting only
-- required columns and avoid using SELECT *.
-- This reduces I/O and improves performance.

-- ============================================================

-- Q10.

-- Creating indexes on every column is not a good idea.
-- Every INSERT, UPDATE and DELETE must also update all indexes,
-- which slows down data modification.
-- Indexes also consume extra disk space.
-- Only columns that are frequently used in WHERE, JOIN,
-- ORDER BY or GROUP BY should be indexed.

-- ============================================================
-- END OF HOMEWORK
-- ============================================================