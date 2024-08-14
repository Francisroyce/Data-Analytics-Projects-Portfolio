
------SQL BASICS FOR BEGINNERS



--CREATING OF TABLE

CREATE TABLE EmployeeSalary
(EmployeeID int,
JobTitles varchar(50),
Salary int)

CREATING OF TABLE

CREATE TABLE EmployeeDemographics
(EmployeeID int,
FirstName varchar(50),
LastName varchar(50),
Age int,
Gender varchar(50)
)


--INSERT FUNCTION
INSERT INTO EmployeeDemographics VALUES
--(1001, 'Francis', 'Royce', 30, 'Male'), this has been inserted before
(1002, 'Harmony', 'Maduka', 30, 'Female'),
(1003, 'Chioma', 'Noni', 29, 'Female'),
(1004, 'Toby', 'Angela', 27, 'Male'),
(1005, 'Angela', 'Martin', 31, 'Female'),
(1006, 'Cole', 'Palmer', 23, 'Male'),
(1007, 'Nkunku', 'Gusto', 25, 'Male'),
(1008, 'Jackson', 'Nicolas', 25, 'Male'),
(1009, 'Kelvin', 'Scott', 30, 'Female')


INSERT INTO EmployeeSalary VALUES
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 3000),
(1003, 'Salesman', 5000),
(1004, 'Accountant', 50000),
(1005, 'Engineer', 70000),
(1006, 'Animal Scientist', 4000),
(1007, 'Technician', 1000),
(1008, 'Artist', 900),
(1009, 'Senior Engineer', 100000)

--QUERYING DATABASE
--SELECT FUNCTION
--use of TOP. DISTINCT, COUNT, AS, MAX, MIN, AVG FUNCTION
--Under SELECT FUNTION

SELECT EmployeeID, FirstName, LastName 
FROM EmployeeDemographics

--USE * TO RETURN (TOP) 5 ETC
SELECT TOP 5*
FROM EmployeeDemographics

--USE OF DISTINCT FUNTION 
--here employeeID is unqiue and it will return everything
SELECT DISTINCT(EmployeeID) 
FROM EmployeeDemographics

--here two gender is returned cos it is just two gender
--even tho. it is more two or more female and male
SELECT DISTINCT(Gender) 
FROM EmployeeDemographics

SELECT DISTINCT(Age) 
FROM EmployeeDemographics

--Use of (COUNT) function (here no column name)
SELECT COUNT (LastName)
FROM EmployeeDemographics

--use of (AS) FUNCTION to asign name to the column when you used (COUNT)
SELECT COUNT (LastName) AS LastNameCount
FROM EmployeeDemographics


--Using Salary table
--Using (MAX) FUNCTION
SELECT Max(Salary)
FROM EmployeeSalary

--(MIN)
SELECT MIN(Salary)
FROM EmployeeSalary

----Average (AVG)
SELECT AVG(Salary) As SalaryAverage
FROM EmployeeSalary


--Changing Database from the left corner.
--this code below will give error cos it has left from
--SQL Tutorial to Master

SELECT *
FROM EmployeeSalary

--To make the above work again we use this (dbo statement)
--here you specify the database first
SELECT *
FROM [SQL Tutorial].dbo.EmployeeSalary


--WHERE STATEMENT(help li mit amount of data and specify the amount of
--data to return)
--  =, <>, <, >, And, or, Like, Null, Not NUll, In
--  */

--(=)
SELECT *
FROM EmployeeDemographics
WHERE FirstName = 'Harmony'

--(<> is not equl to)
SELECT *
FROM EmployeeDemographics
WHERE FirstName <> 'Harmony'

----(>)
--SELECT *
FROM EmployeeDemographics
WHERE Age > 30

--(<)
--SELECT *
FROM EmployeeDemographics
WHERE Age < 30

--(>=)
SELECT *
FROM EmployeeDemographics
WHERE Age >= 30

--(<=)
SELECT *
FROM EmployeeDemographics
WHERE Age <= 30

----(AND)
SELECT *
FROM EmployeeDemographics
WHERE Age <= 30 AND Gender = 'male'

--SELECT *
FROM EmployeeDemographics
WHERE Age <= 30 AND Gender = 'female'

--(OR)
SELECT *
FROM EmployeeDemographics
WHERE Age >= 30 OR Gender = 'Female'

--(Like)
--(Like)( with wildcard after alphabet %
--, this only select the first name with A)
SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE 'A%'


--(Like)( with wildcard after and before alphabet %
--, this select the names with A)
SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE '%A%'

SELECT *
FROM EmployeeDemographics
WHERE FirstName LIKE 'c%l%'


----(NULL (IS))
SELECT *
FROM EmployeeDemographics
WHERE FirstName IS NULL 

----(IS NOT NULL)
SELECT *
FROM EmployeeDemographics
WHERE FirstName IS NOT NULL 

--(IN)
SELECT *
FROM EmployeeDemographics
WHERE FirstName IN ('Harmony', 'Francis')


--GROUP BY, ORDER BY STATEMENT
SELECT *
FROM EmployeeDemographics

SELECT DISTINCT (Gender)
FROM EmployeeDemographics

--GROUP BY )
--(Using GROUP BY, you group all the female in female
--and male by male)

SELECT (Gender)
FROM EmployeeDemographics
GROUP BY Gender

--Let comfirm the above

SELECT (Gender), COUNT(Gender) as Groupby
FROM EmployeeDemographics
GROUP BY Gender

--To confirm the above

SELECT *
FROM EmployeeDemographics


SELECT (Gender), Age, COUNT(Gender) as Groupby
FROM EmployeeDemographics
GROUP BY Gender, Age


SELECT (Gender), COUNT(Gender) as CountGender
FROM EmployeeDemographics
WHERE Age > 29
GROUP BY Gender

--ORDER BY (ascending order by default)
SELECT (Gender), COUNT(Gender) as CountGender
FROM EmployeeDemographics
WHERE Age > 29
GROUP BY Gender
ORDER BY CountGender


----we can chnage the ascending order by default (FROM 3 - 1)
SELECT (Gender), COUNT(Gender) as CountGender
FROM EmployeeDemographics
WHERE Age > 29
GROUP BY Gender
ORDER BY CountGender DESC

SELECT *
FROM EmployeeDemographics
ORDER BY Age


--Descending
SELECT *
FROM EmployeeDemographics
ORDER BY Age DESC

SELECT *
FROM EmployeeDemographics
ORDER BY Age, Gender DESC

SELECT *
FROM EmployeeDemographics
ORDER BY Age, Gender DESC

SELECT *
FROM EmployeeDemographics
ORDER BY Age DESC, Gender DESC

SELECT *
FROM EmployeeDemographics
ORDER BY Age DESC, Gender

--NUMBER CAN ALSO BE USED IN PLACE OF COLUMN NAMES COUNTING FROM LEFT TO RIGHT
SELECT *
FROM EmployeeDemographics
ORDER BY 4 DESC, 5 DESC