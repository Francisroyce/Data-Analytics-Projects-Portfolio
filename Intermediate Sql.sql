--INTERMEDIATE SQL SERIES

--(JOIN)
--Inner, Joins, Full/Left/Right/ Outer Joins

--(Joins): combinning tables

SELECT * 
FROM [SQL Tutorial].dbo.EmployeeDemographics

SELECT *
FROM [SQL Tutorial].dbo.EmployeeSalary

----(Inner Join: Join by default is inner- showing everything that is common)
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
inner join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


--(Full Outer join: shows everything)
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
Full Outer join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

--(Left Outer join)
--Left table is the first table, while right is the second table
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
Left Outer join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

----(Right Outer Join)
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
Right Outer join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

----Instead of using (SELECT *) We can select from the table's column name
SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitles, Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics
Inner join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitles, Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics
Full Outer join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitles, Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics
Left Outer join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitles, Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics
Right Outer join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID


----(USERCASE STUDY, WHO IS THE HIGHEST PAID SALARY? company onwed by Francis)
SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics
Inner join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE FirstName <> 'Kelvin'
ORDER BY Salary DESC

--here, Angela is the most paid besides Kelvin


--Example 2: Calculate average Salary for Salesman

SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
Inner join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

----Selecting only jobtitles and salary
SELECT JobTitles, Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics
Inner join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE JobTitles = 'Salesman'

----Calculating average
SELECT JobTitles, AVG(Salary)
FROM [SQL Tutorial].dbo.EmployeeDemographics
Inner join [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE JobTitles = 'Salesman'
GROUP BY JobTitles


--Today's Topic: union, union All

--They are similar to join.
--join combines based on common columns, while union combines all the tables

--(UNION)
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
UNION
SELECT *
FROM [SQL Tutorial].dbo.WareHouseEmployeeDemographics

----(UNION ALL: IT REMOVES DUPLICATE)
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
UNION ALL
SELECT *
FROM [SQL Tutorial].dbo.WareHouseEmployeeDemographics
----The two tables above are almost similar

--Let's use entirely two different tables

SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
--UNION 
----(All queries combined using a UNION, INTERSECT or EXCEPT 
----operator must have an equal number of expressions in their target lists.)
----SO THIS WILL NOT WORK
SELECT *
FROM [SQL Tutorial].dbo.EmployeeSalary

------Let's do it this way (HERE, combinning age and salary cos they have
----the same data structure)
SELECT EmployeeID, FirstName, Age
FROM [SQL Tutorial].dbo.EmployeeDemographics
UNION 
SELECT EmployeeID, JobTitles, Salary
FROM [SQL Tutorial].dbo.EmployeeSalary


--CASE STATEMENT: it specifies condition and what will return
--when the contidion is met.

SELECT FirstName, LastName, Age
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age

--BUILDING CASE STATEMENT (THEN, ELSE)

SELECT FirstName, LastName, Age,
CASE
	WHEN Age > 30 THEN 'Old'
	ELSE 'Young' 
	END
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age

--(BETWEN, AND, ELSE)
SELECT FirstName, LastName, Age,
CASE
	WHEN Age > 30  THEN 'Old'
	WHEN Age BETWEEN 27 AND 30 THEN 'Young'
	ELSE 'Baby' 
	END
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age

--NOTE: FIRST CONDITION IS MET BEFORE THE NEXT LINE.
--EXAMPLE, HERE IT STILL SAY OLD
SELECT FirstName, LastName, Age,
CASE
	WHEN Age > 30 THEN 'Old'
	WHEN Age = 31 THEN 'Angela'
	ELSE 'Young' 
	END
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age


SELECT FirstName, LastName, Age,
CASE
	WHEN Age = 31 THEN 'Angela'
	WHEN Age > 30 THEN 'Old'
	ELSE 'Young' 
	END
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE Age IS NOT NULL
ORDER BY Age

--BUIDLING CASE STATMENT
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

----INCREASING THE SALARY OF THOSE DOING WELL.
SELECT FirstName, LastName, JobTitles, Salary,
CASE
	WHEN JobTitles = 'Salesman' THEN Salary + (Salary* .10)
	WHEN JobTitles = 'Accountant' THEN Salary + (Salary* .05)
	WHEN JobTitles = 'Engineer' THEN Salary + (Salary* .20)
	ELSE Salary + (Salary* .03)
END AS SalaryIncrease
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
ORDER BY SalaryIncrease DESC


--TOPIC: (HAVING CLAUSE)

SELECT JobTitles, COUNT(JobTitles)
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitles

----LOOKING AT JOB MORE THAN ONE PERSON IN THE JOB
SELECT JobTitles, COUNT(JobTitles)
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitles
HAVING COUNT(JobTitles) > 1

----NOTHER EXAMPLE
SELECT JobTitles, AVG(Salary)
FROM [SQL Tutorial].dbo.EmployeeDemographics
JOIN [SQL Tutorial].dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitles
HAVING AVG(Salary) > 4000
ORDER BY AVG(Salary)


--TOPIC UPDATING/DELETING DATA
--INSERT: CREATES NEW ROLL WHILE UPDATING: ALTERS THE TABLE
--DELETE: SPECIFIES ROLLS OR COULUMNS TO REMOVE

--(UPDATE, USING SET. SET SPECIFIES WHAT COLUMN AND VALUE YOU WANT TO
--INSERT)

UPDATE [SQL Tutorial].dbo.EmployeeDemographics
SET EmployeeID = 1012
WHERE FirstName = 'Holly' AND LastName = 'Flox'

----LET;S CHECK
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics


UPDATE [SQL Tutorial].dbo.EmployeeDemographics
SET Age = 31, Gender = 'Female'
WHERE FirstName = 'Holly' AND LastName = 'Flox'

SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics


----(DELETE STATEMENT: IT REMOVES)
DELETE FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE EmployeeID = 1002

SELECT*
FROM [SQL Tutorial].dbo.EmployeeDemographics

--NOTE: BEFORE YOU DELETE, RUN A SELECT STATEMENT
--TO SEE WHAT YOU WANT TO DELETE FIRST
--EXAMPLE
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
WHERE EmployeeID = 1007


---TOPIC: ALIASING: temporary changing the column or roll name
--in your scrift

--(ALIASING IN COLUMN NAMES)
SELECT*
FROM [SQL Tutorial].dbo.EmployeeDemographics

--EXAMPLE
SELECT FirstName AS Fname
FROM [SQL Tutorial].dbo.EmployeeDemographics

----OR

SELECT FirstName Fname
FROM [SQL Tutorial].dbo.EmployeeDemographics

--EXAMPLE2
SELECT FirstName + ' ' + LastName AS FullName
FROM [SQL Tutorial].dbo.EmployeeDemographics

--ANOTHER TIME TO USE ALIASING IS HWNE YOU ARE USING
--AGREGATE FUNCTION
SELECT AVG(Age) AS AvgAge
FROM [SQL Tutorial].dbo.EmployeeDemographics


----ALIASING IN TABLE NAMES
SELECT Demo.EmployeeID, Sal.Salary
FROM [SQL Tutorial].dbo.EmployeeDemographics AS Demo
JOIN [SQL Tutorial].dbo.EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID

--JOINING THREE DIFFERENT TABLE USIN ALIASING
SELECT a.EmployeeID, a.FirstName, a.LastName, b.JobTitles, c.Age
FROM [SQL Tutorial].dbo.EmployeeDemographics AS a
LEFT JOIN [SQL Tutorial].dbo.EmployeeSalary AS b
	ON a.EmployeeID = b.EmployeeID
LEFT JOIN [SQL Tutorial].dbo.WareHouseEmployeeDemographics AS c
	ON a.EmployeeID = c.EmployeeID

----the above code is confusing, let's make it neater

----Here is the same code:
SELECT Demo.EmployeeID, Demo.FirstName, Demo.LastName, 
Sal.JobTitles, Ware.Age
FROM [SQL Tutorial].dbo.EmployeeDemographics AS Demo
LEFT JOIN [SQL Tutorial].dbo.EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID
LEFT JOIN [SQL Tutorial].dbo.WareHouseEmployeeDemographics AS Ware
	ON Demo.EmployeeID = Ware.EmployeeID


----Topic: PARTITION BY: it is often compared to GROUP BY STATEMENT

SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics


SELECT*
FROM [SQL Tutorial].dbo.EmployeeSalary

--(partition by)
SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
	ON Dem.EmployeeID = Sal.EmployeeID

----HERE, WE ARE CHECKING HOW MANYMALE AND FEAMLE WE HAVE
SELECT FirstName, LastName, Gender, Salary,
       COUNT(Gender) OVER (PARTITION BY Gender) AS GenderCount
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID;

----USING ORDER
SELECT FirstName, LastName, Gender, Salary,
       COUNT(Gender) OVER (ORDER BY Gender) AS GenderCount
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID;
----HERE: This query now produces a running total rather than a group-based total.

----USING GROUP BY AGAIN
SELECT FirstName, LastName, Gender, Salary, COUNT(Gender)  AS GenderCount
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY FirstName, LastName, Gender, Salary;


SELECT Gender, COUNT(Gender)  AS GenderCount
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
    ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY Gender;


----TOPIC: (CTEs- Common Table Expression; uses WITH query)

WITH CTE_Employee AS
(
    SELECT FirstName, LastName, Gender, Salary, 
           COUNT(Gender) OVER (PARTITION BY Gender) AS GenderCount,
           AVG(Salary) OVER (PARTITION BY Gender) AS AvgSalary
    FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
    JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
        ON Dem.EmployeeID = Sal.EmployeeID
    WHERE Salary > 4000
)
SELECT * FROM CTE_Employee

----this is like writing a function
-- --we can do this to call up other things from it

 WITH CTE_Employee AS
(
    SELECT FirstName, LastName, Gender, Salary, 
           COUNT(Gender) OVER (PARTITION BY Gender) AS GenderCount,
           AVG(Salary) OVER (PARTITION BY Gender) AS AvgSalary
    FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
    JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
        ON Dem.EmployeeID = Sal.EmployeeID
    WHERE Salary > 4000
)
SELECT FirstName, AvgSalary
FROM CTE_Employee;


WITH CTE_TABLE AS
(SELECT *
FROM [SQL Tutorial].dbo.EmployeeDemographics
)
SELECT *
FROM CTE_TABLE


----TOPIC: (TEMP TABLES; uisng (#) Temporary tables)
CREATE TABLE #Tem_Employee
(EmployeeID int,
JobTitle varchar(100),
Salary int)

SELECT *
FROM #Tem_Employee

INSERT INTO #Tem_Employee VALUES
(1001, 'HR', 45000)

--SELECTING PARAMETERS FROM AN EXISTING TABLE AND INSERT INTO
--TEMP TABLE
INSERT INTO #Tem_Employee
SELECT *
FROM [SQL Tutorial].dbo.EmployeeSalary

SELECT *
FROM #Tem_Employee

--CREATING 2ND TEMP TABLE
CREATE TABLE #Tem_Employee2
(JobTitle varchar(100),
EmployeePerJob int,
AvgAge int,
AvgSalary int)

INSERT INTO #Tem_Employee2
SELECT JobTitles, COUNT(JobTitles), Avg(Age), Avg(Salary)
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
 ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY JobTitles

SELECT *
FROM #Tem_Employee2

--IF YOU RUN THE ABOVE TABLE2 CODE, IT SAYS TABLE ALREADY EXISTS
 --THIS WILL RUN INTO ERRORRSS, TO SOLVE THIS.
DROP TABLE IF EXISTS #Tem_Employee2
CREATE TABLE #Tem_Employee2
(JobTitle varchar(100),
EmployeePerJob int,
AvgAge int,
AvgSalary int)

INSERT INTO #Tem_Employee2
SELECT JobTitles, COUNT(JobTitles), Avg(Age), Avg(Salary)
FROM [SQL Tutorial].dbo.EmployeeDemographics Dem
JOIN [SQL Tutorial].dbo.EmployeeSalary Sal
 ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY JobTitles

SELECT *
FROM #Tem_Employee2


--TOPIC: STRING FUNCTIONS- TRIM. LTRIM, RTRIM, REPLACE, SUBSTRING
--UPPER, LOWER

DROP TABLE IF EXISTS EmployeeErrors
CREATE TABLE EmployeeErrors
(
    EmployeeID varchar(10),  -- Adjust the size based on your needs
    FirstName varchar(50),
    LastName varchar(50)
);


INSERT INTO EmployeeErrors (EmployeeID, FirstName, LastName) VALUES
('1001', 'Jimbo', 'Halbert'),
('  1002', 'Pamela', 'Hamsley'),
('1005', 'Toby', 'Fienderson - fired');


SELECT *
FROM EmployeeErrors


----USING: TRIM, LTRIM(LEFT TRIM), RTRIM(RIGHT TRIM)

SELECT EmployeeID, TRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

SELECT EmployeeID, LTRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

SELECT EmployeeID, RTRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors


---- USING REPLACE
SELECT *
FROM EmployeeErrors

SELECT LastName, REPLACE(LastName, '- fired', '') AS LastNameFixed
FROM EmployeeErrors

--USING SUBSTRINGS
SELECT SUBSTRING(FirstName, 3, 3)
FROM EmployeeErrors

----ANOTHER EXAMPLE OF USE CASE
SELECT SUBSTRING(err.FirstName, 1, 3), SUBSTRING(dem.FirstName, 1, 3) 
FROM EmployeeErrors err
JOIN [SQL Tutorial].dbo.EmployeeDemographics dem 
	ON SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(dem.FirstName, 1, 3)

----LOOKING AT THE ORIGINAL NAMES
SELECT err.FirstName, SUBSTRING(err.FirstName, 1, 3), dem.FirstName, SUBSTRING(dem.FirstName, 1, 3) 
FROM EmployeeErrors err
JOIN [SQL Tutorial].dbo.EmployeeDemographics dem 
	ON SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(dem.FirstName, 1, 3)

----UISNG UPPER AND LOWER
SELECT FirstName, LOWER(FirstName) AS 'LOWERCASE'
FROM EmployeeErrors

----UISNG UPPER AND UPPER
SELECT FirstName, UPPER(FirstName) AS 'UPPERCASE'
FROM EmployeeErrors


----TOPIC: STORE PROCEDURES: IT SQL STATEMENT CREATED AND STORED IN DATABASE
---- I SEE IT AS CALLING UP A FUNCTION
CREATE PROCEDURE TEST
AS
SELECT *
FROM EmployeeDemographics

EXEC TEST


---- EXAMPLE2
---CREATING 2ND TEMP TABLE
CREATE PROCEDURE TEMP_EMPLOYEE
AS
SELECT *
FROM #Tem_Employee
CREATE TABLE #Tem_Employee
(JobTitle varchar(100),
EmployeePerJob int,
AvgAge int,
AvgSalary int)

INSERT INTO #Tem_Employee
SELECT JobTitles, COUNT(JobTitles), Avg(Age), Avg(Salary)
FROM EmployeeDemographics Dem
JOIN EmployeeSalary Sal
 ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY JobTitles

SELECT *
FROM #Tem_Employee

EXEC TEMP_EMPLOYEE


--TOPIC: SUBQUERRIES (IN THE SELECT, FROM, AND WHERE STATMENT)
SELECT *
FROM EmployeeSalary

-- SUBQUERY IN SELECT
SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM EmployeeSalary) AS
AllAvgSalary
FROM EmployeeSalary

-- how to it with partition
SELECT EmployeeID, Salary, AVG(Salary) OVER () AS
AllAvgSalary
FROM EmployeeSalary

--Why GROUP BY doesn't work

SELECT EmployeeID, Salary, AVG(Salary) OVER () AS
AllAvgSalary
FROM EmployeeSalary
GROUP BY EmployeeID, Salary
ORDER BY 1, 2

--SUBQUERY IN FROM
SELECT a.EmployeeID, AllAvgSalary
FROM (SELECT EmployeeID, Salary, AVG(Salary) OVER () AS
	AllAvgSalary
	FROM EmployeeSalary) a


--SUBQUERY IN WHERE

SELECT EmployeeID, JobTitles, Salary
FROM EmployeeSalary
WHERE EmployeeID IN (
	SELECT EmployeeID
	FROM EmployeeDemographics
	WHERE Age > 25)





