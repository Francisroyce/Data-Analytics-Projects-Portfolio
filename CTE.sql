-- 1. Daily Loan Disbursement Trend
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    CAST(disburse_date AS DATE) AS disbursement_date,
    DATENAME(WEEKDAY, disburse_date) AS day_of_week,
    COUNT(*) AS total_loans_disbursed,
    SUM(loan_amount) AS total_amount_disbursed
FROM loan_data
GROUP BY CAST(disburse_date AS DATE), DATENAME(WEEKDAY, disburse_date)
ORDER BY disbursement_date;

-- 2. Monthly Loan Disbursement Trend
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    FORMAT(CAST(disburse_date AS DATE), 'yyyy-MM') AS disbursement_month,
    DATENAME(MONTH, CAST(disburse_date AS DATE)) AS month_name,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_disbursed
FROM loan_data
GROUP BY 
    FORMAT(CAST(disburse_date AS DATE), 'yyyy-MM'),
    DATENAME(MONTH, CAST(disburse_date AS DATE))
ORDER BY disbursement_month;

-- 3. Collection Trend
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    CAST(collection_date AS DATE) AS collection_date,
    DATENAME(WEEKDAY, CAST(collection_date AS DATE)) AS day_name,
    DATENAME(MONTH, CAST(collection_date AS DATE)) AS month_name,
    SUM(actual_collection) AS total_collected,
    SUM(actual_capital_collected) AS capital_collected,
    SUM(actual_profit_collected) AS profit_collected
FROM loan_data
GROUP BY 
    CAST(collection_date AS DATE),
    DATENAME(WEEKDAY, CAST(collection_date AS DATE)),
    DATENAME(MONTH, CAST(collection_date AS DATE))
ORDER BY collection_date;

-- 4. Default Risk by Branch and Staff
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    branch,
    staff_full_name,
    COUNT(*) AS total_loans,
    ROUND(SUM(default_amount), 2) AS total_default,
    ROUND(AVG(default_amount), 2) AS avg_default
FROM loan_data
WHERE default_amount > 0
GROUP BY branch, staff_full_name
ORDER BY total_default DESC;

-- 5. Negative Loan Amounts
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT TOP 20 loan_amount
FROM loan_data
WHERE loan_amount < 0;

-- 5b. Profitability by Branch and Staff
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    branch,
    staff_full_name,
    SUM(actual_collection - loan_amount) AS actual_profit,
    SUM(loan_amount) AS total_loan_amount,
    CASE 
        WHEN SUM(loan_amount) = 0 THEN 0
        ELSE ROUND(SUM(actual_collection - loan_amount) * 1.0 / SUM(loan_amount), 2)
    END AS profit_margin
FROM loan_data
GROUP BY branch, staff_full_name
ORDER BY actual_profit DESC;

-- 6. Loan Status Breakdown
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(SUM(actual_collection), 2) AS total_collected
FROM loan_data
GROUP BY status
ORDER BY total_loans DESC;

-- 7. Frequency and Loan Term Analysis
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    frequency,
    COUNT(*) AS total_loans,
    AVG(loan_term) AS avg_loan_term,
    SUM(loan_amount) AS total_loan_amount
FROM loan_data
GROUP BY frequency
ORDER BY total_loan_amount DESC;

-- 7b. Frequency and Loan Term Analysis (Yearly)
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    YEAR(disburse_date) AS disbursement_year,
    frequency,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_term), 2) AS avg_loan_term,
    SUM(loan_amount) AS total_loan_amount
FROM loan_data
GROUP BY 
    YEAR(disburse_date),
    frequency
ORDER BY 
    disbursement_year,
    total_loan_amount DESC;

-- 8. Customer Loan Count
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    customer_id,
    customer_full_name,
    MAX(loan_count) AS max_loan_count
FROM loan_data
GROUP BY customer_id, customer_full_name
ORDER BY max_loan_count DESC;

-- 9. Gender-Based Loan Analysis
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    customer_gender,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(SUM(actual_collection), 2) AS total_collected,
    ROUND(SUM(default_amount), 2) AS total_defaulted
FROM loan_data
GROUP BY customer_gender;

-- 10. Age Group Analysis
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) < 25 THEN 'Under 25'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(SUM(default_amount), 2) AS total_defaulted
FROM loan_data
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) < 25 THEN 'Under 25'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END;

-- 11. Top Defaulting Customers
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    customer_id,
    customer_full_name,
    ROUND(SUM(default_amount), 2) AS total_defaulted,
    SUM(loan_count) AS total_loans
FROM loan_data
GROUP BY customer_id, customer_full_name
HAVING SUM(default_amount) > 0
ORDER BY total_defaulted DESC;

-- 12. Maturity Date Performance
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    customer_id,
    customer_full_name,
    CAST(maturity_date AS DATE) AS maturity_date,
    COUNT(*) AS matured_loans,
    SUM(amount_to_be_paid) AS total_due,
    ROUND(SUM(actual_collection), 2) AS total_collected
FROM loan_data
GROUP BY 
    CAST(maturity_date AS DATE), 
    customer_id,
    customer_full_name
ORDER BY maturity_date;

-- 12b. Inconsistency Based on Date
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    customer_full_name,
    SUM(amount_to_be_paid) AS total_due,
    CAST(last_payment AS DATE) AS last_payment
FROM loan_data
GROUP BY 
    customer_full_name,
    CAST(last_payment AS DATE)
ORDER BY last_payment;

-- 13. Loan Status Summary: Active vs Completed
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT 
    status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_value,
    SUM(actual_collection) AS total_collected,
    SUM(default_amount) AS total_default
FROM loan_data
WHERE status IN ('Active', 'Completed', 'Closed')
GROUP BY status;

-- 13b. Checking with Active Loan
WITH loan_data AS (
    SELECT * FROM cleaned_loans_dataset
)
SELECT active_loan,
    COUNT(active_loan) AS number_of_active_loans
FROM loan_data
GROUP BY active_loan;
