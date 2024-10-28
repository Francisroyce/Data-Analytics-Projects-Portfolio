use [Bank Loan Project]
go
----DASHBOARD 1: SUMMARY
select* from financial_loan_data

--1. Total Loan Applications: 
SELECT COUNT(id) 
	AS Total_Loan_Applications 
	FROM financial_loan_data

-- MTD_Loan_Applications 
SELECT COUNT(id) 
	AS MTD_Loan_Applications 
	FROM financial_loan_data
WHERE MONTH(issue_date) = 12 AND
YEAR(issue_date) = 2021

--- PMTD_Loan_Applications 
SELECT COUNT(id) 
	AS PMTD_Loan_Applications 
	FROM financial_loan_data
WHERE MONTH(issue_date) = 11 AND
YEAR(issue_date) = 2021

-- CTE (This common table expression )
WITH Loan_Applications AS (
    SELECT
        FORMAT(issue_date, 'yyyy-MM') AS loan_month,
        COUNT(id) AS MTD_Loan_Applications
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(issue_date, 'yyyy-MM')
),
Previous_Loan_Applications AS (
    SELECT
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM') AS prev_loan_month,
        COUNT(id) AS PMTD_Loan_Applications
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM')
)
SELECT
    L.loan_month,
    L.MTD_Loan_Applications,
    COALESCE(P.PMTD_Loan_Applications, 0) AS PMTD_Loan_Applications,
    (L.MTD_Loan_Applications - COALESCE(P.PMTD_Loan_Applications, 0)) AS MoM_Change
FROM
    Loan_Applications L
LEFT JOIN
    Previous_Loan_Applications P
ON
    L.loan_month = P.prev_loan_month
ORDER BY
    L.loan_month 


--2. Total Funded Amount: 
SELECT SUM(loan_amount)
	AS Total_Funded_Amount 
FROM financial_loan_data

-- CTE
WITH Funded_Amounts AS (
    SELECT
        FORMAT(issue_date, 'yyyy-MM') AS loan_month,
        SUM(loan_amount) AS MTD_Funded_Amount
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(issue_date, 'yyyy-MM')
),
Previous_Funded_Amounts AS (
    SELECT
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM') AS prev_loan_month,
        SUM(loan_amount) AS PMTD_Funded_Amount
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM')
)
SELECT
    F.loan_month,
    F.MTD_Funded_Amount,
    COALESCE(P.PMTD_Funded_Amount, 0) AS PMTD_Funded_Amount,
    (F.MTD_Funded_Amount - COALESCE(P.PMTD_Funded_Amount, 0)) AS MoM_Funded_Change
FROM
    Funded_Amounts F
LEFT JOIN
    Previous_Funded_Amounts P
ON
    F.loan_month = P.prev_loan_month
ORDER BY
    F.loan_month;

-- 3.	Total Amount Received: 
SELECT
	SUM(total_payment) 
	AS Total_Amount_Received
FROM financial_loan_data

--- INTEREST
WITH LoanData AS (
    SELECT
        SUM(loan_amount) AS Total_Funded_Amount,
        SUM(total_payment) AS Total_Amount_Received
    FROM
        financial_loan_data
)
SELECT
    Total_Funded_Amount,
    Total_Amount_Received,
    (Total_Amount_Received - Total_Funded_Amount) AS Interest
FROM
    LoanData;
-- CTE
WITH Monthly_Amounts AS (
    -- Calculate MTD Total Amount Received for each month
    SELECT
        FORMAT(issue_date, 'yyyy-MM') AS loan_month,
        SUM(total_payment) AS MTD_Total_Amount_Received
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(issue_date, 'yyyy-MM')
),
Previous_Monthly_Amounts AS (
    -- Calculate PMTD (Previous Month) Total Amount Received
    SELECT
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM') AS prev_loan_month,
        SUM(total_payment) AS PMTD_Total_Amount_Received
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM')
)
-- Join both MTD and PMTD data to calculate MoM change
SELECT
    M.loan_month,
    M.MTD_Total_Amount_Received,
    COALESCE(P.PMTD_Total_Amount_Received, 0) AS PMTD_Total_Amount_Received,
    (M.MTD_Total_Amount_Received - COALESCE(P.PMTD_Total_Amount_Received, 0)) AS MoM_Change
FROM
    Monthly_Amounts M
LEFT JOIN
    Previous_Monthly_Amounts P
ON
    M.loan_month = P.prev_loan_month
ORDER BY
    M.loan_month;


-- 4.	Average Interest Rate: 
SELECT AVG(int_rate) * 100
	AS Average_Interest_Rate 
FROM financial_loan_data

-- CTE
WITH Monthly_Interest AS (
    -- Calculate MTD Average Interest Rate for each month and round to 2 decimal places
    SELECT
        FORMAT(issue_date, 'yyyy-MM') AS loan_month,
        ROUND(AVG(int_rate) * 100, 2) AS MTD_Average_Interest_Rate
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(issue_date, 'yyyy-MM')
),
Previous_Monthly_Interest AS (
    -- Calculate PMTD (Previous Month) Average Interest Rate and round to 2 decimal places
    SELECT
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM') AS prev_loan_month,
        ROUND(AVG(int_rate) * 100, 2) AS PMTD_Average_Interest_Rate
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM')
)
-- Join both MTD and PMTD data to calculate MoM change in interest rates and round to 2 decimal places
SELECT
    M.loan_month,
    M.MTD_Average_Interest_Rate,
    COALESCE(P.PMTD_Average_Interest_Rate, 0) AS PMTD_Average_Interest_Rate,
    ROUND(M.MTD_Average_Interest_Rate - COALESCE(P.PMTD_Average_Interest_Rate, 0), 2) AS MoM_Interest_Change
FROM
    Monthly_Interest M
LEFT JOIN
    Previous_Monthly_Interest P
ON
    M.loan_month = P.prev_loan_month
ORDER BY
    M.loan_month

-- 5.	Average Debt-to-Income Ratio (DTI): 
SELECT ROUND (AVG(dti), 4) * 100
 AS Average_Debt_to_Income_Ratio
FROM financial_loan_data


--- CTE
WITH Monthly_DTI AS (
    -- Calculate MTD Average Debt-to-Income Ratio for each month
    SELECT
        FORMAT(issue_date, 'yyyy-MM') AS loan_month,
        ROUND(AVG(dti) * 100, 4) AS MTD_Average_DTI
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(issue_date, 'yyyy-MM')
),
Previous_Monthly_DTI AS (
    -- Calculate PMTD (Previous Month) Average Debt-to-Income Ratio
    SELECT
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM') AS prev_loan_month,
        ROUND(AVG(dti) * 100, 4) AS PMTD_Average_DTI
    FROM
        financial_loan_data
    GROUP BY
        FORMAT(DATEADD(MONTH, -1, issue_date), 'yyyy-MM')
)
-- Join both MTD and PMTD data to calculate MoM change in Debt-to-Income Ratio
SELECT
    M.loan_month,
    M.MTD_Average_DTI,
    COALESCE(P.PMTD_Average_DTI, 0) AS PMTD_Average_DTI,
    ROUND(M.MTD_Average_DTI - COALESCE(P.PMTD_Average_DTI, 0), 4) AS MoM_DTI_Change
FROM
    Monthly_DTI M
LEFT JOIN
    Previous_Monthly_DTI P
ON
    M.loan_month = P.prev_loan_month
ORDER BY
    M.loan_month DESC;  -- Order by loan_month in descending order



--Good Loan v Bad Loan KPI’s

--1. Good Loan Application Percentage: 
SELECT 
	(COUNT(CASE WHEN loan_status = 'Fully Paid'
	OR loan_status = 'Current' THEN id
	END)* 100)
	/
	COUNT(id) Good_loan_percentage
FROM financial_loan_data



--2. Good Loan Applications: 
SELECT COUNT(id) AS Good_Loan_Applications
FROM financial_loan_data
WHERE loan_status = 'Fully Paid' 
	OR loan_status = 'Current'

-- 3. Good Loan Funded Amount: 
SELECT SUM(loan_amount) Good_Loan_Funded_Amount
FROM financial_loan_data
WHERE loan_status = 'Fully Paid' 
	OR loan_status = 'Current'

-- 4. Good Loan Total Received Amount: 
SELECT SUM(total_payment) Good_Loan_Total_Received_Amount
FROM financial_loan_data
WHERE loan_status = 'Fully Paid' 
	OR loan_status = 'Current'


---- Bad Loan KPIs:
SELECT loan_status
FROM financial_loan_data
WHERE loan_status = 'Charged off'
or loan_status = 'Null'


-- 1. Bad Loan Application Percentage:
SELECT 
    FORMAT(
        (COUNT(CASE WHEN loan_status = 'Charged off' THEN id END) * 100.0) 
        / COUNT(id), 
        'N2'
    ) AS Bad_Loan_Application_Percentage
FROM financial_loan_data;



--2. Bad Loan Applications: 
SELECT COUNT(id) AS Bad_Loan_Applications
FROM financial_loan_data
WHERE loan_status = 'Charged off' 
	
-- 3. Bad Loan Funded Amount:
SELECT SUM(loan_amount) AS Bad_Loan_Funded_Amount
FROM financial_loan_data
WHERE loan_status = 'Charged off' 


--4.Bad Loan Total Received Amount: 
SELECT SUM(total_payment) Bad_Loan_Total_Received_Amount
FROM financial_loan_data
WHERE loan_status = 'Charged off'


-- ADDITIONAL CALCULATIONS
--  Average Interest Rate by Loan Grade
SELECT 
    grade, 
    AVG(int_rate) AS avg_interest_rate 
FROM financial_loan_data
GROUP BY grade;




SELECT 
    FORMAT(issue_date, 'yyyy-MM') AS Month,
    COUNT(*) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM 
    financial_loan_data
GROUP BY 
    FORMAT(issue_date, 'yyyy-MM')
ORDER BY 
    Month;




--  Bad Loan Rate by State
SELECT 
    address_state,
    ROUND((COUNT(CASE WHEN loan_status = 'Charged off' THEN id END) * 100.0) 
	/ COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan_data
GROUP BY address_state;

--. Average Loan Amount by Employment Length
SELECT 
    emp_length, address_state,
    AVG(loan_amount) AS avg_loan_amount 
FROM financial_loan_data
GROUP BY emp_length, address_state
ORDER BY avg_loan_amount DESC

--Debt-to-Income (DTI) Ratio Analysis
SELECT 
   grade, 
    AVG(dti) * 100 AS avg_dti_ratio 
FROM financial_loan_data
GROUP BY grade;

-- Monthly Installments Summary
SELECT 
    term, 
    SUM(installment) AS Sum_installment 
FROM financial_loan_data
GROUP BY term;


-- Loan Status Grid View
SELECT 
    loan_status,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    ROUND(AVG(int_rate * 100), 2) AS Average_Interest_Rate,
    ROUND(AVG(dti * 100), 2) AS Average_DTI
FROM financial_loan_data
GROUP BY loan_status;

-- TOTAL MTD(MONTH TO DATE)
SELECT 
    loan_status,
    SUM(loan_amount) AS MTD_Total_Funded_Amount,
    SUM(total_payment) AS MTD_Total_Amount_Received

FROM financial_loan_data
WHERE MONTH(issue_date) = 12
GROUP BY loan_status;

---- DASHBOARD 2: OVERVIEW
SELECT issue_date FROM financial_loan_data

-- Monthly Trends by Issue Date (Line Chart):
SELECT	
		MONTH(issue_date)AS Month_number,
		DATENAME(MONTH, issue_date) AS Month_Names,
		COUNT(id) AS Total_Loan_Application,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Received_Amount
FROM financial_loan_data
GROUP BY DATENAME(MONTH, issue_date),
		MONTH(issue_date)
ORDER BY MONTH(issue_date) 

--Regional Analysis by State (Filled Map):
SELECT	
		address_state AS State_address,
		COUNT(id) AS Total_Loan_Application,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Received_Amount
FROM financial_loan_data
GROUP BY address_state
ORDER BY address_state


--Loan Term Analysis (Donut Chart):
SELECT term
FROM financial_loan_data
SELECT	
		term AS Loan_Term,
		COUNT(id) AS Total_Loan_Application,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Received_Amount
FROM financial_loan_data
GROUP BY term
ORDER BY term


-- Employee Length Analysis (Bar Chart):
SELECT emp_length
FROM financial_loan_data

SELECT	
		emp_length AS Employee_Length,
		COUNT(id) AS Total_Loan_Application,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Received_Amount
FROM financial_loan_data
GROUP BY emp_length
ORDER BY emp_length


--Loan Purpose Breakdown (Bar Chart):
SELECT purpose
FROM financial_loan_data
SELECT	
		purpose AS Loan_Purpose,
		COUNT(id) AS Total_Loan_Application,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Received_Amount
FROM financial_loan_data
GROUP BY purpose
ORDER BY purpose


-- Home Ownership Analysis (Tree Map):
SELECT home_ownership
FROM financial_loan_data
SELECT	
		home_ownership AS Home_Ownership,
		COUNT(id) AS Total_Loan_Application,
		SUM(loan_amount) AS Total_Funded_Amount,
		SUM(total_payment) AS Total_Received_Amount
FROM financial_loan_data
GROUP BY home_ownership
ORDER BY home_ownership 