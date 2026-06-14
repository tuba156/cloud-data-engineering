-- ================================================================================
-- HOMEWORK: CLASS 5 - CTEs, PIVOT, EXPRESSIONS & WINDOW FUNCTIONS (EASY VERSION)
-- Database: BikeStores Sample Database
-- Instructions: Write SQL statements to solve each problem below.
-- ================================================================================

-- ================================================================================
-- SECTION A: CASE Expressions 
-- ================================================================================

-- Q1: Write a simple CASE that shows order_status as a word instead of number.
--     Show order_id, order_status (number), and status_description (word).
select
order_status
Case
WHEN order_status = 1 THEN 'PLACED' WHEN order_status = 2 THEN 'CONFIRMED' WHEN order_status = 3 THEN 'DISPATCHED' WHEN order_status = 4 THEN 'COMPLETED'
ELSE 'UNKNOWN'
END AS status_description
FROM sales.orders;





-- Q2: Categorize products by price:
--     Under $500 = 'Budget'
--     $500 to $2000 = 'Standard' 
--     Over $2000 = 'Premium'
--     Show product_name, list_price, and price_category.

product_name,
list_price,
CASE 
WHEN list_price < 500 THEN 'Budget' WHEN list_price <= 2000 THEN 'Standard'
ELSE 'Premium'
END AS price_category 
FROM production.products;







-- Q3: Using CASE with COUNT, count how many orders have status = 4 (Completed) 
--     vs non-completed for each store. Show store_id, completed_count, not_completed_count.

select
store_id,
COUNT(CASE WHEN order_status = 4 THEN 1 END) AS completed_count,
COUNT(CASE WHEN order_status <> 4 THEN 1 END) AS not_completed_count
FROM sales.orders 
GROUP BY store_id;





-- Q4: Create a column called "year_label" that shows:
--     If model_year = 2024: 'New'
--     If model_year = 2023: 'Recent'
--     Else: 'Older'
--     Show product_name, model_year, year_label.

-- Q4: Create a column called "year_label"

SELECT
    product_name,
    model_year,
    CASE
        WHEN model_year = 2024 THEN 'New'
        WHEN model_year = 2023 THEN 'Recent'
        ELSE 'Older'
    END AS year_label
FROM production.products;


-- Q5: For customers, show email and a column called "has_email" that says 'Yes' if email is not NULL, 'No' if NULL.

-- Q5: Show email and whether the customer has an email

SELECT
    email,
    CASE
        WHEN email IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS has_email
FROM sales.customers;


-- ================================================================================
-- SECTION B: CTEs (Common Table Expressions)
-- ================================================================================  

-- Q6: Create a CTE called "high_value_products" that selects products with list_price > 3000.
--     Then SELECT from that CTE to show all those products.

-- Q6: Create a CTE called "high_value_products"
-- Select products with list_price > 3000
-- Then display all those products

WITH high_value_products AS
(
    SELECT
        product_id,
        product_name,
        list_price
    FROM production.products
    WHERE list_price > 3000
)

SELECT *
FROM high_value_products;






-- Q7: Write a CTE that calculates the average list_price of all products.
--     Then use it to find products that cost more than average.



WITH average_price AS
(
    SELECT
        AVG(list_price) AS avg_price
    FROM production.products
)

SELECT
    product_name,
    list_price
FROM production.products, average_price
WHERE list_price > avg_price;




-- Q8: Create a CTE called "customer_order_counts" that counts how many orders each customer has.
--     Then use it to find customers with more than 5 orders.


WITH customer_order_counts AS
(
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM sales.orders
    GROUP BY customer_id
)

SELECT *
FROM customer_order_counts
WHERE total_orders > 5;


-- ================================================================================
-- SECTION C: ROW_NUMBER() and RANK() - EASY BEGINNER
-- ================================================================================

-- Q9: Use ROW_NUMBER() to number all products ordered by list_price from highest to lowest.
--      Show product_name, list_price, and row_number.

SELECT
    product_name,
    list_price,
    ROW_NUMBER() OVER(ORDER BY list_price DESC) AS row_number
FROM production.products;



-- Q10: Use ROW_NUMBER() to rank products by price WITHIN each brand (partition by brand_id).
--      Show brand_id, product_name, list_price, and rank_in_brand.

SELECT
    brand_id,
    product_name,
    list_price,
    ROW_NUMBER() OVER(PARTITION BY brand_id ORDER BY list_price DESC) AS rank_in_brand
FROM production.products;
-- Q11: Use RANK() instead of ROW_NUMBER() on products ordered by list_price.
--      See what happens when multiple products have the same price.


-- ================================================================================
-- SECTION D: Window Functions - Running Totals and Averages
-- ================================================================================

-- Q12: Calculate a running total of daily orders (cumulative sum over time).
--      Show order_date, daily_order_count, and running_total.
WITH daily_orders AS
(
    SELECT
        order_date,
        COUNT(order_id) AS daily_order_count
    FROM sales.orders
    GROUP BY order_date
)

SELECT
    order_date,
    daily_order_count,
    SUM(daily_order_count) OVER(ORDER BY order_date) AS running_total
FROM daily_orders;

-- Q13: For each product, show its list_price and the average list_price of its brand.
--      Use AVG() OVER (PARTITION BY brand_id).
SELECT
    product_name,
    list_price,
    AVG(list_price) OVER(PARTITION BY brand_id) AS brand_average_price
FROM production.products;

-- Q14: Calculate a running total of quantity sold for each product over time.
--      Show product_id, order_date, quantity, and cumulative_quantity for that product.
SELECT
    oi.product_id,
    o.order_date,
    oi.quantity,
    SUM(oi.quantity) OVER
    (
        PARTITION BY oi.product_id
        ORDER BY o.order_date
    ) AS cumulative_quantity
FROM sales.order_items oi
JOIN sales.orders o
ON oi.order_id = o.order_id;

-- ================================================================================
-- SECTION E: LAG, LEAD (Previous and Next)
-- ================================================================================

-- Q15: For each customer, show their order date and the date of their previous order.
--      Use LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date).
SELECT
    customer_id,
    order_date,
    LAG(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order_date
FROM sales.orders;

-- Q16: Calculate the number of days between a customer's consecutive orders.
--      (Use LAG and DATEDIFF)

SELECT
    customer_id,
    order_date,
    LAG(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order_date,

    DATEDIFF(
        DAY,
        LAG(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY order_date
        ),
        order_date
    ) AS days_between_orders

FROM sales.orders;

-- ================================================================================
-- SECTION F: PIVOT (Rows to Columns)
-- ================================================================================

-- Q17: Create a simple pivot showing the count of orders for each order_status (1,2,3,4) 
--      as separate columns. Only need store_id and the 4 status columns.
SELECT *
FROM
(
    SELECT
        store_id,
        order_status,
        order_id
    FROM sales.orders
) AS SourceTable

PIVOT
(
    COUNT(order_id)
    FOR order_status IN ([1],[2],[3],[4])
) AS PivotTable;

-- ================================================================================
-- SECTION G: Mixed Practice (Putting It All Together)
-- ================================================================================

-- Q18: Use CASE to categorize customers by total spending:
--      Over $5000 = 'VIP'
--      $1000-$5000 = 'Regular'
--      Under $1000 = 'New'
--      Show customer_name and tier.
WITH customer_spending AS
(
    SELECT
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spending
    FROM sales.customers c
    JOIN sales.orders o
        ON c.customer_id = o.customer_id
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.first_name,
        c.last_name
)

SELECT
    customer_name,
    CASE
        WHEN total_spending > 5000 THEN 'VIP'
        WHEN total_spending BETWEEN 1000 AND 5000 THEN 'Regular'
        ELSE 'New'
    END AS tier
FROM customer_spending;

-- Q19: Use ROW_NUMBER() and CASE together: Find top 3 products per category, 
--      and label them as 'Gold', 'Silver', 'Bronze'.
WITH ranked_products AS
(
    SELECT
        category_id,
        product_name,
        list_price,
        ROW_NUMBER() OVER
        (
            PARTITION BY category_id
            ORDER BY list_price DESC
        ) AS rn
    FROM production.products
)

SELECT
    category_id,
    product_name,
    list_price,
    CASE
        WHEN rn = 1 THEN 'Gold'
        WHEN rn = 2 THEN 'Silver'
        WHEN rn = 3 THEN 'Bronze'
    END AS medal
FROM ranked_products
WHERE rn <= 3;


-- Q20: Create a CTE that calculates monthly revenue, then use LAG to show month-over-month growth.
WITH monthly_revenue AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM sales.orders o
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
)

SELECT
    order_year,
    order_month,
    revenue,
    LAG(revenue) OVER
    (
        ORDER BY order_year, order_month
    ) AS previous_month_revenue
FROM monthly_revenue;


-- Q21: Write a query that shows each product, its price, its rank in its brand, 
--      and a CASE that says 'Top Product' if rank = 1, else 'Other'.
WITH ranked_products AS
(
    SELECT
        product_name,
        brand_id,
        list_price,
        RANK() OVER
        (
            PARTITION BY brand_id
            ORDER BY list_price DESC
        ) AS brand_rank
    FROM production.products
)

SELECT
    product_name,
    list_price,
    brand_rank,
    CASE
        WHEN brand_rank = 1 THEN 'Top Product'
        ELSE 'Other'
    END AS product_label
FROM ranked_products;

-- Q22: Create a pivot showing the count of customers by state and by customer tier 
--      (you'll need to create the tier using CASE first, then pivot).
WITH customer_tier AS
(
    SELECT
        state,
        CASE
            WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 5000 THEN 'VIP'
            WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) BETWEEN 1000 AND 5000 THEN 'Regular'
            ELSE 'New'
        END AS tier
    FROM sales.customers c
    JOIN sales.orders o
        ON c.customer_id = o.customer_id
    JOIN sales.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.state
)

SELECT *
FROM
(
    SELECT
        state,
        tier
    FROM customer_tier
) AS SourceTable

PIVOT
(
    COUNT(tier)
    FOR tier IN ([VIP], [Regular], [New])
) AS PivotTable;

-- ================================================================================
-- END OF HOMEWORK - ALL QUESTIONS ARE BEGINNER-FRIENDLY
-- ================================================================================