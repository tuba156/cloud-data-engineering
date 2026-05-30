-- ============================================
-- SQL Server — Class 3 Homework
-- BikeStores Sample Database
-- Topics: GROUP BY · HAVING · Subqueries · EXISTS
-- ============================================

-- Q1: Count how many products each brand has in the catalog.

select
    b.brand_name,
    count(*) as product_count
from [production].[products] p
inner join [production].[brands] b
    on p.brand_id = b.brand_id
group by b.brand_name
order by product_count desc;

-- Q2: For each category, show:
-- category name,
-- total number of products,
-- cheapest price,
-- most expensive price,
-- average price (rounded to 2 decimals).
-- Sort by average price descending.

select
    c.category_name,
    count(*) as total_products,
    min(p.list_price) as cheapest_price,
    max(p.list_price) as most_expensive_price,
    round(avg(p.list_price),2) as avg_price
from [production].[categories] c
inner join [production].[products] p
    on c.category_id = p.category_id
group by c.category_name
order by avg_price desc;

-- Q3: Show the number of orders placed per order status.
-- Display the status value and order count.
-- Sort by order_status ascending.
select
    order_status,
    count(*) as order_count
from [sales].[orders]
group by order_status
order by order_status;

-- Q4: For each store, calculate total revenue:
-- (quantity × list_price × (1 – discount)) from order_items.
-- Show store name and total revenue.
-- Sort by revenue descending.

select
    s.store_name,
    sum((oi.quantity * oi.list_price) * (1 - oi.discount)) as total_revenue
from [sales].[order_items] oi
inner join [sales].[orders] o
    on oi.order_id = o.order_id
inner join [sales].[stores] s
    on o.store_id = s.store_id
group by s.store_name
order by total_revenue desc;

-- Q5: Show total number of products per brand per model year.
-- Display brand name, model year, and product count.
-- Sort by brand name then model year.
select
    b.brand_name,
    p.model_year,
    count(*) as product_count
from [production].[products] p
inner join [production].[brands] b
    on p.brand_id = b.brand_id
group by b.brand_name, p.model_year
order by b.brand_name, p.model_year;

-- Q6: Find all brands that have more than 25 products in the catalog.
-- Show brand name and product count.

select
    b.brand_name,
    count(*) as product_count
from [production].[products] p
inner join [production].[brands] b
    on p.brand_id = b.brand_id
group by b.brand_name
having count(*) > 25
order by product_count desc;

-- Q7: Among products from year 2018 only,
-- find categories whose average price is above $1500.
-- Show category name, product count, and average price.
select
    c.category_name,
    count(*) as product_count,
    round(avg(p.list_price),2) as avg_price
from [production].[products] p
inner join [production].[categories] c
    on p.category_id = c.category_id
where p.model_year = 2018
group by c.category_name
having avg(p.list_price) > 1500
order by avg_price desc;

-- Q8: Find customers who have placed 3 or more orders.
-- Show customer full name and order count.
-- Sort by order count descending.

select
    c.first_name + ' ' + c.last_name as customer_full_name,
    count(*) as order_count
from [sales].[customers] c
inner join [sales].[orders] o
    on c.customer_id = o.customer_id
group by c.first_name, c.last_name
having count(*) >= 3
order by order_count desc;

-- Q9: Find all products whose list price is higher than
-- the average list price of all products.
-- Show product name and price.
-- Sort by price descending.
select
    product_name,
    list_price
from [production].[products]
where list_price >
(
    select avg(list_price)
    from [production].[products]
)
order by list_price desc;


-- Q10: Find all orders placed by customers from state 'TX'.
-- Use a subquery (NOT a JOIN).
-- Show order ID, customer ID, and order date.
select
    order_id,
    customer_id,
    order_date
from [sales].[orders]
where customer_id in
(
    select customer_id
    from [sales].[customers]
    where state = 'TX'
);

-- Q11: For each brand, show its average price,
-- but only for brands whose average price exceeds overall product average.
-- Use a subquery in FROM (derived table).
-- Show brand name and average price.

select *
from
(
    select
        b.brand_name,
        avg(p.list_price) as avg_price
    from [production].[products] p
    inner join [production].[brands] b
        on p.brand_id = b.brand_id
    group by b.brand_name
) brand_avg
where avg_price >
(
    select avg(list_price)
    from [production].[products]
)
order by avg_price desc;

-- Q12: Using EXISTS:
-- Find all customers who have placed at least one order.
-- Show customer full name and email.
select
    c.first_name + ' ' + c.last_name as customer_full_name,
    c.email
from [sales].[customers] c
where exists
(
    select 1
    from [sales].[orders] o
    where o.customer_id = c.customer_id
);

-- Q13: Using NOT EXISTS:
-- Find all products that have never appeared in any order (order_items).
-- Show product name and list price.
select
    p.product_name,
    p.list_price
from [production].[products] p
where not exists
(
    select 1
    from [sales].[order_items] oi
    where oi.product_id = p.product_id
);