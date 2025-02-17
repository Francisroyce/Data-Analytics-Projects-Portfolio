-- checking the data
SELECT *
FROM cleaned_data
-- KPI
-- TOTAL REVENUE
SELECT
	SUM(amount_paid) AS total_revenue
FROM cleaned_data;

--Total Transactions
SELECT COUNT(receipt_number) AS total_transactions 
FROM cleaned_data;

-- Average Transaction Value
SELECT AVG(amount_paid) AS avg_transaction_value 
FROM cleaned_data;

-- Distribution of Payments Across MDAs and Revenue Heads
SELECT 
    mdas, 
    revenue_head, 
    SUM(amount_paid) AS total_revenue,
    COUNT(*) AS transaction_count
FROM cleaned_data
GROUP BY mdas, revenue_head
ORDER BY total_revenue DESC;

-- Patterns in Payment Methods (Frequency & Correlations with Payment Amounts)
SELECT 
    payment_method, 
    COUNT(*) AS transaction_count,
    SUM(amount_paid) AS total_amount,
    AVG(amount_paid) AS avg_transaction_value
FROM cleaned_data
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Average Time Lag Between Bill Generation and Payment (MISSING VALUE)
SELECT 
    mdas, 
    revenue_head, 
    AVG(DATEDIFF(day, bill_date, payment_date)) AS avg_days_to_pay
FROM cleaned_data
GROUP BY mdas, revenue_head
ORDER BY avg_days_to_pay DESC;


-- Seasonal or Periodic Trends in Payments
SELECT 
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    SUM(amount_paid) AS total_revenue
FROM cleaned_data
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY year, month;



