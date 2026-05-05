CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;

CREATE TABLE customers (
    customer_id               VARCHAR(50) PRIMARY KEY,
    customer_unique_id        VARCHAR(50),
    customer_zip_code_prefix  VARCHAR(10),
    customer_city             VARCHAR(50),
    customer_state            VARCHAR(5)
);

CREATE TABLE sellers (
    seller_id                VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix   VARCHAR(10),
    seller_city              VARCHAR(50),
    seller_state             VARCHAR(5)
);

CREATE TABLE products (
    product_id                    VARCHAR(50) PRIMARY KEY,
    product_category_name         VARCHAR(100),
    product_name_length           INT,
    product_description_length    INT,
    product_photos_qty            INT,
    product_weight_g              INT,
    product_length_cm             INT,
    product_height_cm             INT,
    product_width_cm              INT
);

CREATE TABLE category_translation (
    product_category_name            VARCHAR(100) PRIMARY KEY,
    product_category_name_english    VARCHAR(100)
);

CREATE TABLE orders (
    order_id                      VARCHAR(50) PRIMARY KEY,
    customer_id                   VARCHAR(50),
    order_status                  VARCHAR(20),
    order_purchase_timestamp      DATETIME,
    order_approved_at             DATETIME,
    order_delivered_carrier_date  DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

CREATE TABLE order_items (
    order_id             VARCHAR(50),
    order_item_id        INT,
    product_id           VARCHAR(50),
    seller_id            VARCHAR(50),
    shipping_limit_date  DATETIME,
    price                DECIMAL(10,2),
    freight_value        DECIMAL(10,2)
);

CREATE TABLE order_payments (
    order_id               VARCHAR(50),
    payment_sequential     INT,
    payment_type           VARCHAR(20),
    payment_installments   INT,
    payment_value          DECIMAL(10,2)
);

CREATE TABLE order_reviews (
    review_id                 VARCHAR(50),
    order_id                  VARCHAR(50),
    review_score              INT,
    review_comment_title      VARCHAR(100),
    review_comment_message    TEXT,
    review_creation_date      DATETIME,
    review_answer_timestamp   DATETIME
);


SELECT COUNT(*) 
FROM category_translation;

-- Date range of the business
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;

-- Order status breakdown
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Top 10 product categories (in English)
SELECT
    ct.product_category_name_english,
    COUNT(oi.order_id) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY total_orders DESC
LIMIT 10;

-- Payment methods breakdown
SELECT
    payment_type,
    COUNT(*) AS usage_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments), 2) AS pct
FROM order_payments
GROUP BY payment_type
ORDER BY usage_count DESC;

-- Check NULLs in orders table
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date
FROM orders;

-- Check NULLs in order_items
SELECT
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight
FROM order_items;

-- Check NULLs in products
SELECT
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category
FROM products;

-- Check for zero or negative prices (bad data)
SELECT COUNT(*) AS bad_price_rows
FROM order_items
WHERE price <= 0;

-- Check duplicate order_items
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS occurrences
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
    order_status,
    COUNT(*) AS cnt
FROM orders
WHERE order_status NOT IN ('delivered', 'shipped')
GROUP BY order_status;

ALTER TABLE order_items
ADD COLUMN revenue DECIMAL(10,2),
ADD COLUMN profit DECIMAL(10,2),
ADD COLUMN margin_pct DECIMAL(5,2);

SET SQL_SAFE_UPDATES= 0;
UPDATE order_items
SET
    revenue = price,
    profit = ROUND(price - freight_value, 2),
    margin_pct = ROUND(((price - freight_value) / price) * 100, 2);

-- Verify
SELECT
    price,
    freight_value,
    revenue,
    profit,
    margin_pct
FROM order_items
LIMIT 10;

CREATE VIEW vw_master AS
SELECT
    -- Order info
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    o.order_delivered_customer_date,

    -- Item info
    oi.order_item_id,
    oi.price,
    oi.freight_value,
    oi.revenue,
    oi.profit,
    oi.margin_pct,

    -- Product info
    p.product_id,
    p.product_category_name,
    COALESCE(ct.product_category_name_english, 'unknown') AS category_english,

    -- Seller info
    s.seller_id,
    s.seller_city,
    s.seller_state,

    -- Customer info
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- Payment info
    py.payment_type,
    py.payment_value,
    py.payment_installments,

    -- Review info
    rv.review_score

FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
LEFT JOIN order_payments py ON o.order_id = py.order_id
LEFT JOIN order_reviews  rv ON o.order_id = rv.order_id
WHERE o.order_status = 'delivered';

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct,
    ROUND(SUM(revenue) /
          COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM vw_master;

-- Revenue and profit by year
SELECT
    order_year,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM vw_master
GROUP BY order_year
ORDER BY order_year;

-- Revenue and profit by month
SELECT
    order_year,
    order_month,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit
FROM vw_master
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Revenue and profit by category
SELECT
    category_english,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM vw_master
GROUP BY category_english
ORDER BY total_revenue DESC
LIMIT 15;

-- High revenue but low profit categories
SELECT
    category_english,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM vw_master
GROUP BY category_english
HAVING
    SUM(revenue) > 50000
    AND AVG(margin_pct) < 60
ORDER BY total_revenue DESC;

-- Most profitable categories by margin
SELECT
    category_english,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM vw_master
GROUP BY category_english
ORDER BY avg_margin_pct DESC
LIMIT 10;

-- Loss making or lowest margin categories
SELECT
    category_english,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM vw_master
GROUP BY category_english
ORDER BY avg_margin_pct ASC
LIMIT 10;

-- Category revenue rank vs profit rank
SELECT
    category_english,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM vw_master
GROUP BY category_english
ORDER BY revenue_rank
LIMIT 15;

-- Repeat vs one-time customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 /
          COUNT(DISTINCT customer_unique_id), 2) AS repeat_rate_pct
FROM (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM vw_master
    GROUP BY customer_unique_id
) AS customer_orders;

-- AOV by customer state
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) /
          COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM vw_master
GROUP BY customer_state
ORDER BY avg_order_value DESC
LIMIT 10;

-- Top 10 highest value customers
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin
FROM vw_master
GROUP BY customer_unique_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer segmentation by spend
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(SUM(total_revenue), 2) AS segment_total_revenue
FROM (
    SELECT
        customer_unique_id,
        ROUND(SUM(revenue), 2) AS total_revenue,
        CASE
            WHEN SUM(revenue) >= 1000 THEN 'High Value'
            WHEN SUM(revenue) >= 300  THEN 'Mid Value'
            ELSE                           'Low Value'
        END AS customer_segment
    FROM vw_master
    GROUP BY customer_unique_id
) AS segments
GROUP BY customer_segment
ORDER BY avg_revenue_per_customer DESC;

-- Month over month revenue growth using LAG
SELECT
    order_year,
    order_month,
    ROUND(SUM(revenue), 2) AS monthly_revenue,
    ROUND(LAG(SUM(revenue))
          OVER (ORDER BY order_year, order_month), 2) AS prev_month_revenue,
    ROUND(SUM(revenue) - LAG(SUM(revenue))
          OVER (ORDER BY order_year, order_month), 2) AS revenue_change,
    ROUND((SUM(revenue) - LAG(SUM(revenue))
          OVER (ORDER BY order_year, order_month)) /
          LAG(SUM(revenue))
          OVER (ORDER BY order_year, order_month) * 100, 2) AS growth_pct
FROM vw_master
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Top 3 categories per year using PARTITION BY
SELECT
    order_year,
    category_english,
    total_revenue,
    revenue_rank
FROM (
    SELECT
        order_year,
        category_english,
        ROUND(SUM(revenue), 2) AS total_revenue,
        RANK() OVER (PARTITION BY order_year
                     ORDER BY SUM(revenue) DESC) AS revenue_rank
    FROM vw_master
    GROUP BY order_year, category_english
) AS ranked
WHERE revenue_rank <= 3
ORDER BY order_year, revenue_rank;

-- CTE profit tier classification
WITH category_profit AS (
    SELECT
        category_english,
        ROUND(SUM(revenue), 2) AS total_revenue,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(AVG(margin_pct), 2) AS avg_margin
    FROM vw_master
    GROUP BY category_english
),
category_tier AS (
    SELECT
        category_english,
        total_revenue,
        total_profit,
        avg_margin,
        CASE
            WHEN avg_margin >= 70 THEN 'High Margin'
            WHEN avg_margin >= 50 THEN 'Medium Margin'
            WHEN avg_margin >= 0  THEN 'Low Margin'
            ELSE 'Loss Making'
        END AS profit_tier
    FROM category_profit
)
SELECT *
FROM category_tier
ORDER BY avg_margin DESC;

-- Customer lifetime value using CTE
WITH customer_stats AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(revenue), 2) AS total_revenue,
        ROUND(SUM(profit), 2) AS total_profit,
        MIN(order_purchase_timestamp) AS first_order,
        MAX(order_purchase_timestamp) AS last_order
    FROM vw_master
    GROUP BY customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    total_revenue,
    total_profit,
    DATEDIFF(last_order, first_order) AS customer_lifespan_days,
    ROUND(total_revenue /
          NULLIF(DATEDIFF(last_order, first_order), 0), 2) AS revenue_per_day
FROM customer_stats
ORDER BY total_revenue DESC
LIMIT 20;

-- Payment method analysis
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,
    ROUND(AVG(payment_installments), 2) AS avg_installments,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(revenue) * 100.0 /
          (SELECT SUM(revenue) FROM vw_master), 2) AS revenue_pct
FROM vw_master
WHERE payment_type IS NOT NULL
GROUP BY payment_type
ORDER BY total_orders DESC;

SELECT
    order_year,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(margin_pct), 2) AS avg_margin_pct
FROM vw_master
GROUP BY order_year
ORDER BY order_year;

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM order_items;

SELECT 
    ROUND(SUM(price), 2) AS revenue_from_price,
    ROUND(SUM(revenue), 2) AS revenue_from_column
FROM order_items;

UPDATE order_items
SET
    revenue    = price,
    profit     = ROUND(price - freight_value, 2),
    margin_pct = ROUND(
        ((price - freight_value) / price) * 100, 2
    )
WHERE revenue IS NULL 
   OR profit IS NULL;
   
SELECT 
    payment_type,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY avg_payment_value DESC;