-- ================================================================================
-- INTERVIEW PREP: BikeStores Database - SOLUTIONS
-- ================================================================================

-- ================================================================================
-- QUESTION 1
-- Show product_name, model_year, list_price
-- Order by highest price
-- ================================================================================

SELECT
    product_name,
    model_year,
    list_price
FROM production.products
ORDER BY list_price DESC;

-- ================================================================================
-- QUESTION 2
-- Customers from NY
-- ================================================================================

SELECT
    first_name,
    last_name,
    city,
    state
FROM sales.customers
WHERE state = 'NY';

-- ================================================================================
-- QUESTION 3
-- Orders with customer names
-- ================================================================================

SELECT
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name
FROM sales.orders o
INNER JOIN sales.customers c
ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- ================================================================================
-- QUESTION 4
-- Count customers by state
-- ================================================================================

SELECT
    state,
    COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state
ORDER BY customer_count DESC;

-- ================================================================================
-- QUESTION 5
-- Total Sales by Store
-- ================================================================================

SELECT
    s.store_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM sales.orders o
INNER JOIN sales.order_items oi
ON o.order_id = oi.order_id
INNER JOIN sales.stores s
ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_sales DESC;

-- ================================================================================
-- QUESTION 6
-- Brands with average price > 2000
-- ================================================================================

SELECT
    b.brand_name,
    AVG(p.list_price) AS average_price
FROM production.products p
INNER JOIN production.brands b
ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING AVG(p.list_price) > 2000
AND COUNT(*) >= 3
ORDER BY average_price DESC;

-- ================================================================================
-- QUESTION 7
-- ROW_NUMBER()
-- ================================================================================

SELECT
    product_name,
    list_price,
    ROW_NUMBER() OVER(ORDER BY list_price ASC) AS price_rank
FROM production.products;

-- ================================================================================
-- QUESTION 8
-- ROW_NUMBER() PARTITION BY Brand
-- ================================================================================

SELECT
    b.brand_name,
    p.product_name,
    p.list_price,

    ROW_NUMBER() OVER
    (
        PARTITION BY p.brand_id
        ORDER BY p.list_price DESC
    ) AS rank_in_brand

FROM production.products p
INNER JOIN production.brands b
ON p.brand_id = b.brand_id;

-- ================================================================================
-- QUESTION 9
-- Running Total of Orders
-- ================================================================================

WITH DailyOrders AS
(
    SELECT
        order_date,
        COUNT(*) AS daily_orders
    FROM sales.orders
    GROUP BY order_date
)

SELECT
    order_date,
    daily_orders,

    SUM(daily_orders)
    OVER(ORDER BY order_date) AS running_total

FROM DailyOrders;

-- ================================================================================
-- QUESTION 10
-- ROW_NUMBER() vs RANK()
-- ================================================================================

SELECT
    product_name,
    list_price,

    ROW_NUMBER() OVER(ORDER BY list_price DESC) AS row_number,

    RANK() OVER(ORDER BY list_price DESC) AS product_rank

FROM production.products;

-- Difference:
-- ROW_NUMBER() always gives unique numbers.
-- RANK() gives same rank to duplicate values and skips numbers.

-- ================================================================================
-- QUESTION 11
-- Multiple JOINs
-- ================================================================================

SELECT
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.list_price

FROM sales.orders o

INNER JOIN sales.order_items oi
ON o.order_id = oi.order_id

INNER JOIN production.products p
ON oi.product_id = p.product_id

WHERE YEAR(o.order_date) = 2023;

-- ================================================================================
-- QUESTION 12
-- CASE Statement
-- ================================================================================

SELECT
    product_name,
    list_price,

    CASE
        WHEN list_price < 500 THEN 'Budget'
        WHEN list_price <= 2000 THEN 'Regular'
        ELSE 'Premium'
    END AS price_category

FROM production.products;

-- ================================================================================
-- QUESTION 13
-- LAG()
-- ================================================================================

SELECT
    customer_id,
    order_id,
    order_date,

    LAG(order_date)
    OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order_date

FROM sales.orders;

-- ================================================================================
-- QUESTION 14
-- Top 3 Products in each Category
-- ================================================================================

WITH ProductRanks AS
(
    SELECT

        c.category_name,
        p.product_name,
        p.list_price,

        RANK() OVER
        (
            PARTITION BY p.category_id
            ORDER BY p.list_price DESC
        ) AS product_rank

    FROM production.products p

    INNER JOIN production.categories c
    ON p.category_id = c.category_id
)

SELECT *
FROM ProductRanks
WHERE product_rank <= 3
ORDER BY category_name, product_rank;

-- ================================================================================
-- QUESTION 15
-- Customer Spending Report
-- ================================================================================

WITH CustomerSpending AS
(
    SELECT

        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,

        SUM
        (
            oi.quantity *
            oi.list_price *
            (1 - oi.discount)
        ) AS total_spent

    FROM sales.customers c

    INNER JOIN sales.orders o
    ON c.customer_id = o.customer_id

    INNER JOIN sales.order_items oi
    ON o.order_id = oi.order_id

    GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
)

SELECT

    customer_name,
    total_spent,

    RANK() OVER
    (
        ORDER BY total_spent DESC
    ) AS customer_rank,

    CASE
        WHEN total_spent > 5000 THEN 'VIP'
        WHEN total_spent >= 1000 THEN 'Regular'
        ELSE 'New'
    END AS price_tier

FROM CustomerSpending
ORDER BY customer_rank;

-- ================================================================================
-- END OF SOLUTIONS
-- ================================================================================