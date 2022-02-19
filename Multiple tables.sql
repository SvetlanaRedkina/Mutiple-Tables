/* First, we create 4 tables: Info, Records, Suspension, and Emp_Salary.
   Second, we insert values into them. 
   A note: these tables simplified samples of the original tables, and do not have primary keys assigned.
   Simplification helps to illustrate queries. */

CREATE TABLE Info (
	Dept_Manager_Id INT NOT NULL,
	Emp_Id INT NOT NULL,
	Emp_Name VARCHAR(100),
	Job_Title VARCHAR(100),
	Employment_Type ENUM('PT', 'FT')
	);

INSERT INTO Info (
	Dept_Manager_Id,
	Emp_Id,
	Emp_Name,
	Job_Title,
	Employment_Type
	)
VALUES 
	(10, 101, 'Maria Bienev', 'Shopping_Cart_Attendant', 'PT'),
        (10, 102, 'John Sullivan', 'Bagger','FT'),
        (10, 103, 'Samantha Cruz', 'Cashier', 'FT'),
	(10, 104, 'Peter Vernik', 'Custodian', 'FT'),
	(10, 105, 'Diego Rodriguez', 'Cashier', 'FT'),
	(10, 106, 'Emmanuel Jones', 'Shopping_Cart_Attendant', 'FT'),
	(10, 107, 'Penelope High', 'Cashier', 'FT'),
	(10, 108, 'Martha Hilton', 'Custodian', 'FT'),
	(10, 109, 'Patrick Cabrero', 'Floral_Assistant', 'FT'),
	(20, 201, 'Leah Belle', 'Assistant_Store_Manager', 'FT'),
	(20, 202, 'Holly Smith', 'Customer_Service_Representative', 'FT'),
	(20, 203, 'Russel Goodyear', 'Stock_Clerk', 'FT'),
	(20, 204,'Miranda Holmes', 'Stock_Clerk', 'PT'),
	(20, 205, 'Sasha Pozdnaya', 'Customer_Service_Representative', 'FT'),
	(20, 206, 'Matthew Abrams', 'Overnight_Stock_Clerk', 'FT'),
	(20, 207, 'Ann Taylor', 'Assistant_Store_Manager', 'FT'),
	(20, 208, 'Katherine Middino', 'Inventory_Control_Specialist', 'FT'),
	(20, 209, 'Lisa Brown', 'Customer_Service_Representative', 'FT');

SELECT *
FROM Info;

CREATE TABLE Records (
	Manager_Id INT NOT NULL,
	Employee_Id INT NOT NULL,
	No_Show ENUM('Yes', 'No'),
	Date_Recorded DATE
	);

INSERT INTO Records (
	Manager_Id,
	Employee_Id,
	No_Show,
	Date_Recorded
	)
VALUES 
        (10, 101, 'No', '21-09-12'),
	(10, 102, 'No', '21-09-12'),
	(10, 103, 'No', '21-09-12'),
	(10, 104, 'No', '21-09-12'),
	(10, 105, 'No', '21-09-12'),
	(10, 106, 'No', '21-09-12'),
	(10, 107, 'No', '21-09-12'),
	(10, 108, 'No', '21-09-12'),
	(10, 109, 'No', '21-09-12'),
	(20, 201, 'No', '21-09-12'),
	(20, 202, 'No', '21-09-12'),
	(20, 203, 'No', '21-09-12'),
	(20, 204, 'Yes', '21-09-12'),
	(20, 205, 'No', '21-09-12'),
	(20, 206, 'No', '21-09-12'),
	(20, 207, 'No', '21-09-12'),
	(20, 209, 'Yes', '21-09-12'),
	(20, 208, 'No', '21-09-12');

SELECT *
FROM Records;

CREATE TABLE Suspension (
	Id INT NOT NULL,
	Suspended_Prior ENUM('Yes', 'No')
	);

INSERT INTO Suspension (
	Id,
	Suspended_Prior
	)
VALUES 
        (101, 'Yes'),
	(102, 'No'),
	(103, 'No'),
	(104, 'No'),
	(105, 'No'),
	(106, 'No'),
	(107, 'No'),
	(108, 'No'),
	(109, 'No'),
	(201, 'No'),
	(202, 'No'),
	(203, 'No'),
	(204, 'Yes'),
	(205, 'No'),
	(206,'No'),
	(207, 'No'),
	(208, 'No'),
	(209, 'No');

SELECT *
FROM Suspension;

CREATE TABLE Emp_Salary (
	Emp_Id INT NOT NULL,
	Salary INT NOT NULL
    );

INSERT INTO Emp_Salary (
	Emp_Id,
	Salary
	)
VALUES 
        (201, 41400),
	(202, 33600),
	(203, 45700),
	(204, 29500),
	(205, 33900),
	(206, 29900),
	(207, 44800),
	(208, 61000),
	(209, 33200);

SELECT *
FROM Emp_Salary;

/* Task 1. 
The HR team is interested in calculating 'No Show' rate within the company.
They would like Analytics team to help them calculate 'No Show' rate for the employees who have had no prior history of no-shows.
Write a query to determine the employees' 'No Show' rate.

In order to calculate the rate, we, first, need to join Records and Suspension tables.
Then we count all records with 'Yes' value in No_Show column from the Records table for the employees who have no history of prior suspension.
After that, we divide the result by the count of employees who have not been suspended before;
these records can be taken from Suspension table.
 */
 
WITH cte
AS (
	SELECT Employee_Id,
		 No_Show,
		 Date_Recorded,
		 Suspended_Prior,
		 CASE 
			WHEN No_Show = 'Yes'
				AND Suspended_Prior = 'No'
				THEN 1
			ELSE 0
			END AS New_No_Show,
		 CASE 
			WHEN Suspended_Prior = 'No'
				THEN 1
			ELSE 0
			END AS Not_Suspended_Prior_Count
	FROM (
		SELECT R.Employee_Id,
			 R.No_Show,
			 R.Date_Recorded,
			 S.Suspended_Prior
		FROM Records R
		JOIN Suspension S ON R.Employee_Id = S.Id
		) TEMP
	)
SELECT Date_Recorded AS 'Date Reported',
	 SUM(New_No_Show) / SUM(Not_Suspended_Prior_Count) AS 'New No Show Rate'
FROM cte
GROUP BY Date_Recorded;

/* Output:
Date Reported			New No Show Rate
2021-09-12				0.0625
*/

/* Task 2. 
The HR department would like all employess whose Department Manager Id is 10 to be sorted by the positions they hold.
In other words, we need to pivot Info table in MySQl.

We start by calculating the distinct positions.
We set the variables that will help us to assign a number to each position (the logic here is similar to using row_number()).
We use CASE in order to query the names of the employees.
CASE helps us to create a column for each position. The labels are:
Shopping_Cart_Attendant,
Bagger,
Cashier, 
Floral_Assistant,
Custodian.
We order the pivoted table by employee name, so it'll be convenient to navigate through the table, especially, if it grows bigger.
*/

SELECT COUNT(DISTINCT Job_Title) AS Counted
FROM Info
WHERE Dept_Manager_Id = 10;

SET @y1 = 0,
    @y2 = 0,
    @y3 = 0,
    @y4 = 0,
    @y5 = 0;

SELECT MIN(Shopping_Cart_Attendant) AS Shopping_Cart_Attendant,
       MIN(Bagger) AS Bagger,
       MIN(Cashier) AS Cashier,
       MIN(Floral_Assistant) AS Floral_Assistant,
       MIN(Custodian) AS Custodian
FROM (
	SELECT CASE 
			WHEN Job_title = 'Shopping_Cart_Attendant'
				THEN (@y1:=@y1 + 1)
			WHEN Job_title = 'Bagger'
				THEN (@y2:=@y2 + 1)
			WHEN Job_title = 'Cashier'
				THEN (@y3:=@y3 + 1)
			WHEN Job_title = 'Floral_Assistant'
				THEN (@y4:=@y4 + 1)
			WHEN Job_title = 'Custodian'
				THEN (@y5:=@y5 + 1)
			END AS NumberAssigned,
		 CASE 
			WHEN Job_title = 'Shopping_Cart_Attendant'
				THEN Emp_name
			END AS Shopping_Cart_Attendant,
		 CASE 
			WHEN Job_title = 'Bagger'
				THEN Emp_name
			END AS Bagger,
		 CASE 
			WHEN Job_title = 'Cashier'
				THEN Emp_name
			END AS Cashier,
		 CASE 
			WHEN Job_title = 'Floral_Assistant'
				THEN Emp_name
			END AS Floral_Assistant,
		 CASE 
			WHEN Job_title = 'Custodian'
				THEN Emp_name
			END AS Custodian
	FROM Info
	ORDER BY Emp_Name
	) TEMP
GROUP BY NumberAssigned;

/* Output:
Shopping_Cart_Attendant			Bagger				Cashier				Floral_Assistant		Custodian
Emmanuel Jones				John Sullivan			Diego Rodriguez			Patrick Cabrero			Martha Hilton
Maria Bienev								Penelope High							Peter Vernik
									Samantha Cruz
*/

/* Task3. 
The HR team continues conducting their research.
This time they are interested in finding median salary within a certain manager's department.
They specify that they would like to query the median salary data for the department where the Manager's Id is 20.
They also know that the number of employees is odd in that team, 
and prefer to have the information about the person who is paid the median salary.
After Analytics team helps them to find out the median salary value, the HR would like to collect the following information:
Deptartment Manager Id, 
Employee Id, 
Job Title,
and Employment Type.

The query listed below achieves the HR's goal.
It is built based on the logic that we can have either even or odd number of employees.
We assign two variables: 
@Total_Count to the count the employees, and @t variable to rank the employees based on their Salary value.
CASE helps to get the median salary depending on whether we have even or odd number of employees in the department. 
*/

SET @t:= 0;

SELECT COUNT(*)
FROM Emp_Salary
INTO @Total_Count;

SELECT AVG(TEMP.Salary) AS Median_Salary
FROM (
	SELECT @t:= @t + 1 AS Var_Id,
		 Salary
	FROM Emp_Salary
	ORDER BY Salary
	) TEMP
WHERE CASE 
		WHEN MOD(@Total_Count, 2) = 0
			THEN TEMP.Var_Id IN (
					@Total_Count / 2,
					(@Total_Count / 2 + 1)
					)
		ELSE TEMP.Var_Id = (@Total_count + 1) / 2
		END;
        
/* Output:
Median_Salary
33900.0000
*/

/* The median salary is equal to 33,900. 
   Let's find out the information the HR needs. 
*/

SELECT *
FROM Emp_Salary
WHERE Salary = 33900;

/* Output:
Emp_Id			Salary
205			33900
*/

/* Emp_Id = 205. 
   We create a view to get the data. 
*/
   
CREATE
	OR replace VIEW Median_Data AS

SELECT Dept_Manager_Id,
	 Emp_Id,
	 Job_Title,
	 Employment_Type
FROM Info
WHERE Emp_Id = 205;

SELECT *
FROM Median_Data;

/* Output:
Dept_Manager_Id			Emp_Id			Job_Title					Employment_Type
20				205			Customer_Service_Representative			FT
*/
