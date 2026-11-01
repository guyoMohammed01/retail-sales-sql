-- Q1: Retrieve all customer records

SELECT * FROM customers;

-- Q2: Display customer names, cities, and segments

SELECT customer_name, city, customer_segment
FROM customers;

-- Q3: Find customers living in Nairobi
SELECT *
FROM customers
WHERE city = 'Nairobi';

-- Q4: Find customers registered after January 1, 2025
SELECT *
FROM customers
WHERE registration_date > '2025-01-01';

-- Q5: Display all unique customer cities
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- Q6: Retrieve the 10 most recent orders
SELECT *
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 10;

-- Q7: Find orders with unit prices above KSh 10,000
SELECT *
FROM orders
WHERE unit_price > 10000;

-- Q8: Find customers whose names start with A
SELECT *
FROM customers
WHERE customer_name LIKE 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5;

-- Q10: Find orders paid through M-Pesa
SELECT *
FROM orders
WHERE payment_method = 'M-Pesa'; 


-- Q11: Count all customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q12: Count all orders (every status counts)
SELECT COUNT(*) AS total_orders
FROM orders;


-- Q13: Calculate completed-order revenue
SELECT SUM(quantity * unit_price * (1 - discount / 100.0))
FROM orders
WHERE order_status = 'Completed';

-- Q14: Calculate the average completed-order value

SELECT AVG(quantity * unit_price * (1 - discount / 100.0))
FROM orders
WHERE order_status = 'Completed';

-- Q15: Find the highest and lowest product prices
SELECT MAX(unit_price) AS highest_price,
       MIN(unit_price) AS lowest_price
FROM orders; 


-- Q16: Calculate revenue by product category
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;

-- Q17: Count customers by city
SELECT city, COUNT(*) AS customers
FROM customers
GROUP BY city
ORDER BY customers DESC;

-- Q18: Calculate quantity sold by product
SELECT product_name, SUM(quantity) AS units_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY units_sold DESC;

-- Q19: Find categories generating more than KSh 100,000 in revenue
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100.0)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100.0)) > 100000
ORDER BY revenue DESC;

-- Q20: Calculate the percentage of cancelled orders

SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE order_status = 'Cancelled') / COUNT(*), 2) AS pct_cancelled
FROM orders; 

--SECTION C

-- Q21: Display orders with customer names and cities
SELECT o.order_id, o.order_date, c.customer_name, c.city,
       o.product_name, o.quantity, o.order_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;



-- Q22: Calculate total spending by customer

SELECT c.customer_id, c.customer_name,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_spent
FROM customers c
LEFT JOIN orders o
       ON o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC ;

-- Q23: Identify customers who have never ordered
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Q24: Find the 10 highest-spending customers
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;



-- Q25: Calculate revenue by customer city
SELECT c.city, SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY revenue DESC;

-- Q26: Identify customers with more than five orders

SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;

-- Q27: Calculate average customer spending by segment

-- (first total per customer, then average those totals per segment)
SELECT customer_segment, AVG(total_spent) AS avg_spending
FROM (
    SELECT c.customer_id, c.customer_segment,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_segment
) AS t
GROUP BY customer_segment;

-- Q28: Identify the most popular category among VIP customers (by number of orders)

SELECT o.product_category, COUNT(*) AS orders_placed
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'VIP'
GROUP BY o.product_category
ORDER BY orders_placed DESC;



-- Q25: Calculate revenue by customer city
SELECT c.city, SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY revenue DESC;

-- Q26: Identify customers with more than five orders
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;

-- Q27: Calculate average customer spending by segment
-- (first total per customer, then average those totals per segment)
SELECT customer_segment, AVG(total_spent) AS avg_spending
FROM (
    SELECT c.customer_id, c.customer_segment,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spent
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_segment
) AS t
GROUP BY customer_segment;

-- Q28: Identify the most popular category among VIP customers (by number of orders)
SELECT o.product_category, COUNT(*) AS orders_placed
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'VIP'
GROUP BY o.product_category
ORDER BY orders_placed DESC;




-- Q29: Find customers spending above the average total spending per purchasing customer
-- Step 1: total spent by each customer (completed orders). 
--Step 2: keep those above the average of the totals.

WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT customer_id, total_spent
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY total_spent DESC;

-- Q30: Find products priced above the overall average unit price
SELECT DISTINCT product_name, unit_price
FROM orders
WHERE unit_price > (SELECT AVG(unit_price) FROM orders)
ORDER BY unit_price DESC;

-- Q31: Use a CTE to identify the three highest-revenue months
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue
FROM monthly
ORDER BY revenue DESC
LIMIT 3;

-- Q32: Find customers purchasing from at least three categories
SELECT customer_id, COUNT(DISTINCT product_category) AS categories_bought
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(DISTINCT product_category) >= 3
ORDER BY categories_bought DESC;

-- Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin
WITH category_totals AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
           SUM(quantity * cost_price) AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category, revenue, cost,
       revenue - cost AS profit,
       (revenue - cost) / NULLIF(revenue, 0) * 100 AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC;

-- Q34: Find customers whose latest completed order is more than 90 days before the latest order date in the dataset
SELECT customer_id,
       MAX(order_date) AS last_completed_order,
       (SELECT MAX(order_date) FROM orders) - MAX(order_date) AS days_since
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING (SELECT MAX(order_date) FROM orders) - MAX(order_date) > 90
ORDER BY days_since DESC;



--Window Function 


--- -- Q35: Rank customers by spending using RANK()
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT customer_id, total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_totals
ORDER BY spending_rank;

-- Q36: Number each customer's orders by recency using ROW_NUMBER()
SELECT customer_id, order_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) AS order_recency
FROM orders
ORDER BY customer_id, order_recency;

-- Q37: Rank products within categories using DENSE_RANK()
-- (ranked by completed-order revenue)

SELECT product_category, product_name,
       SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
       DENSE_RANK() OVER (PARTITION BY product_category
                          ORDER BY SUM(quantity * unit_price * (1 - discount / 100.0)) DESC) AS rank_in_category
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category, product_name
ORDER BY product_category, rank_in_category;

-- Q38: Calculate cumulative monthly revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM monthly
ORDER BY month;



-- Q39: Compare monthly revenue using LAG()
WITH monthly AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
       revenue - LAG(revenue) OVER (ORDER BY month) AS change
FROM monthly
ORDER BY month;

-- Q40: Calculate month-over-month revenue growth (%)
WITH monthly AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT month, revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS growth_pct
FROM monthly
ORDER BY month;

-- Q41: Divide customers into four spending groups using NTILE(4)
-- Group 1 = highest spenders, group 4 = lowest (customers with completed orders only)

WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT customer_id, total_spent,
       NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_group
FROM customer_totals
ORDER BY spending_group, total_spent DESC;

-- Q42: Calculate each category's share of total revenue using window functions
SELECT product_category,
       SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
       ROUND(100.0 * SUM(quantity * unit_price * (1 - discount / 100.0))
             / SUM(SUM(quantity * unit_price * (1 - discount / 100.0))) OVER (), 2) AS pct_of_total
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;


-- Q43: Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it
-- orders counts every order in the month; revenue, cost and profit count Completed orders only.
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
       COUNT(*) AS orders,
       SUM(CASE WHEN order_status = 'Completed'
                THEN quantity * unit_price * (1 - discount / 100.0) ELSE 0 END) AS revenue,
       SUM(CASE WHEN order_status = 'Completed'
                THEN quantity * cost_price ELSE 0 END) AS cost,
       SUM(CASE WHEN order_status = 'Completed'
                THEN quantity * unit_price * (1 - discount / 100.0) - quantity * cost_price
                ELSE 0 END) AS profit
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM');

SELECT * FROM monthly_sales_summary ORDER BY month;


-- Q44: Function returning completed-order revenue for a customer ID
CREATE OR REPLACE FUNCTION customer_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_result NUMERIC;
BEGIN
    SELECT SUM(quantity * unit_price * (1 - discount / 100.0))
    INTO v_result
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';

    IF v_result IS NULL THEN
        RETURN 0;
    END IF;

    RETURN v_result;
END;
$$;

SELECT customer_revenue(33);     -- a customer who exists
SELECT customer_revenue(9999);   -- an ID that does not exist: returns 0


-- Q45: Segment customers into High, Medium and Low Value
-- High = KSh 250,000 or more, Medium = 50,000 to 249,999, Low = under 50,000.
-- 250,000 is close to the top-quarter cut-off from Q41, so High is roughly the top 25% of buyers.
-- 50,000 is a round number separating occasional buyers from the smallest spenders.
-- Only customers with at least one completed order are included.

SELECT c.customer_id, c.customer_name,
       SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS total_spent,
       CASE WHEN SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) >= 250000 THEN 'High Value'
            WHEN SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) >= 50000 THEN 'Medium Value'
            ELSE 'Low Value' END AS value_segment
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;


-- Q46: Management report
-- (a) Top 5 customers
SELECT c.customer_id, c.customer_name,
       SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 5;

-- (b) Top 5 products by revenue
SELECT product_name,
       SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 5;

-- (c) Most profitable category
SELECT product_category,
       SUM(quantity * unit_price * (1 - discount / 100.0)) - SUM(quantity * cost_price) AS profit
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY profit DESC
LIMIT 1;

-- (d) Lowest-revenue month
SELECT month, revenue
FROM monthly_sales_summary
ORDER BY revenue ASC
LIMIT 1;















