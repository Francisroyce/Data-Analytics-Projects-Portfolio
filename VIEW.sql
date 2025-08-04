-- 1. Daily Loan Disbursement Trend
DROP VIEW IF EXISTS vw_DailyLoanDisbursementTrend;
GO
CREATE VIEW vw_DailyLoanDisbursementTrend AS
SELECT 
    CAST(disburse_date AS DATE) AS disbursement_date,
    DATENAME(WEEKDAY, disburse_date) AS day_of_week,
    COUNT(*) AS total_loans_disbursed,
    SUM(loan_amount) AS total_amount_disbursed
FROM cleaned_loans_dataset
GROUP BY CAST(disburse_date AS DATE), DATENAME(WEEKDAY, disburse_date);
GO

-- 2. Monthly Loan Disbursement Trend
DROP VIEW IF EXISTS vw_MonthlyLoanDisbursementTrend;
GO
CREATE VIEW vw_MonthlyLoanDisbursementTrend AS
SELECT 
    FORMAT(CAST(disburse_date AS DATE), 'yyyy-MM') AS disbursement_month,
    DATENAME(MONTH, CAST(disburse_date AS DATE)) AS month_name,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_disbursed
FROM cleaned_loans_dataset
GROUP BY FORMAT(CAST(disburse_date AS DATE), 'yyyy-MM'), DATENAME(MONTH, CAST(disburse_date AS DATE));
GO

-- 3. Collection Trend
DROP VIEW IF EXISTS vw_CollectionTrend;
GO
CREATE VIEW vw_CollectionTrend AS
SELECT 
    CAST(collection_date AS DATE) AS collection_date,
    DATENAME(WEEKDAY, CAST(collection_date AS DATE)) AS day_name,
    DATENAME(MONTH, CAST(collection_date AS DATE)) AS month_name,
    SUM(actual_collection) AS total_collected,
    SUM(actual_capital_collected) AS capital_collected,
    SUM(actual_profit_collected) AS profit_collected
FROM cleaned_loans_dataset
GROUP BY CAST(collection_date AS DATE), DATENAME(WEEKDAY, CAST(collection_date AS DATE)), DATENAME(MONTH, CAST(collection_date AS DATE));
GO

-- 4. Default Risk by Branch and Staff
DROP VIEW IF EXISTS vw_DefaultRiskByBranchStaff;
GO
CREATE VIEW vw_DefaultRiskByBranchStaff AS
SELECT 
    branch,
    staff_full_name,
    COUNT(*) AS total_loans,
    ROUND(SUM(default_amount), 2) AS total_default,
    ROUND(AVG(default_amount), 2) AS avg_default
FROM cleaned_loans_dataset
WHERE default_amount > 0
GROUP BY branch, staff_full_name;
GO

-- 5. Profitability by Branch and Staff
DROP VIEW IF EXISTS vw_ProfitabilityByBranchStaff;
GO
CREATE VIEW vw_ProfitabilityByBranchStaff AS
SELECT 
    branch,
    staff_full_name,
    SUM(actual_collection - loan_amount) AS actual_profit,
    SUM(loan_amount) AS total_loan_amount,
    CASE 
        WHEN SUM(loan_amount) = 0 THEN 0
        ELSE ROUND(SUM(actual_collection - loan_amount) * 1.0 / SUM(loan_amount), 2)
    END AS profit_margin
FROM cleaned_loans_dataset
GROUP BY branch, staff_full_name;
GO

-- 6. Loan Status Breakdown
DROP VIEW IF EXISTS vw_LoanStatusBreakdown;
GO
CREATE VIEW vw_LoanStatusBreakdown AS
SELECT 
    status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(SUM(actual_collection), 2) AS total_collected
FROM cleaned_loans_dataset
GROUP BY status;
GO

-- 7. Frequency and Loan Term Analysis
DROP VIEW IF EXISTS vw_FrequencyLoanTermAnalysis;
GO
CREATE VIEW vw_FrequencyLoanTermAnalysis AS
SELECT 
    frequency,
    COUNT(*) AS total_loans,
    AVG(loan_term) AS avg_loan_term,
    SUM(loan_amount) AS total_loan_amount
FROM cleaned_loans_dataset
GROUP BY frequency;
GO

-- 8. Frequency and Loan Term Yearly
DROP VIEW IF EXISTS vw_FrequencyLoanTermYearly;
GO
CREATE VIEW vw_FrequencyLoanTermYearly AS
SELECT 
    YEAR(disburse_date) AS disbursement_year,
    frequency,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_term), 2) AS avg_loan_term,
    SUM(loan_amount) AS total_loan_amount
FROM cleaned_loans_dataset
GROUP BY YEAR(disburse_date), frequency;
GO

-- 9. Customer Loan Count
DROP VIEW IF EXISTS vw_CustomerLoanCount;
GO
CREATE VIEW vw_CustomerLoanCount AS
SELECT 
    customer_id,
    customer_full_name,
    MAX(loan_count) AS max_loan_count
FROM cleaned_loans_dataset
GROUP BY customer_id, customer_full_name;
GO

-- 10. Gender-Based Loan Analysis
DROP VIEW IF EXISTS vw_GenderLoanAnalysis;
GO
CREATE VIEW vw_GenderLoanAnalysis AS
SELECT 
    customer_gender,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(SUM(actual_collection), 2) AS total_collected,
    ROUND(SUM(default_amount), 2) AS total_defaulted
FROM cleaned_loans_dataset
GROUP BY customer_gender;
GO

-- 11. Age Group Analysis
DROP VIEW IF EXISTS vw_AgeGroupLoanAnalysis;
GO
CREATE VIEW vw_AgeGroupLoanAnalysis AS
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
FROM cleaned_loans_dataset
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) < 25 THEN 'Under 25'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, date_of_birth, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END;
GO

-- 12. Top Defaulting Customers
DROP VIEW IF EXISTS vw_TopDefaultingCustomers;
GO
CREATE VIEW vw_TopDefaultingCustomers AS
SELECT 
    customer_id,
    customer_full_name,
    ROUND(SUM(default_amount), 2) AS total_defaulted,
    SUM(loan_count) AS total_loans
FROM cleaned_loans_dataset
GROUP BY customer_id, customer_full_name
HAVING SUM(default_amount) > 0;
GO

-- 13. Maturity Date Performance
DROP VIEW IF EXISTS vw_MaturityDatePerformance;
GO
CREATE VIEW vw_MaturityDatePerformance AS
SELECT 
    customer_id,
    customer_full_name,
    CAST(maturity_date AS DATE) AS maturity_date,
    COUNT(*) AS matured_loans,
    SUM(amount_to_be_paid) AS total_due,
    ROUND(SUM(actual_collection), 2) AS total_collected
FROM cleaned_loans_dataset
GROUP BY CAST(maturity_date AS DATE), customer_id, customer_full_name;
GO

-- 14. Loan Status Summary
DROP VIEW IF EXISTS vw_LoanStatusSummary;
GO
CREATE VIEW vw_LoanStatusSummary AS
SELECT 
    status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_value,
    SUM(actual_collection) AS total_collected,
    SUM(default_amount) AS total_default
FROM cleaned_loans_dataset
WHERE status IN ('Active', 'Completed', 'Closed')
GROUP BY status;
GO

DROP VIEW IF EXISTS vw_customersdetails;
GO

CREATE VIEW vw_customersdetails AS
SELECT 
    branch,
    staff_full_name,
    phone_number,
    customer_address,
    COUNT(*) AS total_loans,
    ROUND(SUM(default_amount), 2) AS total_default,
    ROUND(AVG(default_amount), 2) AS avg_default
FROM cleaned_loans_dataset
WHERE default_amount > 0
GROUP BY branch, staff_full_name, phone_number, customer_address;
GO



--- Collection Summary by Month and Year CollectionSummarybyMonthandYear
DROP VIEW IF EXISTS vw_CollectionSummarybyMonthandYear;
GO

CREATE VIEW vw_CollectionSummarybyMonthandYear AS
SELECT 
    DATEPART(YEAR, collection_date) AS collection_year,
    DATENAME(MONTH, collection_date) AS collection_month_name,
    SUM(actual_collection) AS total_collected,
    SUM(actual_capital_collected) AS capital_collected,
    SUM(actual_profit_collected) AS profit_collected
FROM cleaned_loans_dataset
GROUP BY 
    DATEPART(YEAR, collection_date),
    DATENAME(MONTH, collection_date)
GO