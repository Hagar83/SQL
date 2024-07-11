--Analyze sales persons in territory no.1
--Exploring what is the name of territory no.1
SELECT 
	TerritoryID,Name
FROM 
	Sales.SalesTerritory
WHERE 
	TerritoryID =1

--Exploring Sales persons assigned to this territory
/*
Columns Refernce:
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)

QueryResult:
we have 6 sales person in this territory
*/
SELECT DISTINCT
	ST.TerritoryID,ST.Name 
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP'

--Exploring Employee Demographics
/*Columns Refernce:
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
Gender & MaritalStatus -->HumanResources.Employee
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)-->HumanResources.Employee

QueryResult:
We have 2 females and 4 males
3 of males were married 
1 of females was married
*/
SELECT DISTINCT
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,Gender,MaritalStatus

FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID =EMP.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP'

--Demographics Analysis
--Does gender diffrences and MaritalStatus Affecting their performance?
--The fact that we have two Females and 4 males Make the Female results is better than men
SELECT 
	ST.TerritoryID,ST.Name
	,Gender
	,SUM(TotalDue) Total_sales
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID =EMP.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' 
GROUP BY 
	ST.TerritoryID,ST.Name,Gender

--Then MaritalStatus
SELECT 
	ST.TerritoryID,ST.Name
	,MaritalStatus
	,SUM(TotalDue) Total_sales
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID =EMP.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' 
GROUP BY 
	ST.TerritoryID,ST.Name,MaritalStatus

--Does Age affect their Performance?
/*NOTE: i used OrderDate in Datedif function to calculate the age of each sales Person When Delivering each order 
in my opinion Current Date will not be a good choice */
SELECT DISTINCT
	ST.TerritoryID,ST.Name
	,DATEDIFF(YEAR,BirthDate,OrderDate) Age
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SUM(TotalDue) Total_sales
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID =EMP.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' 
GROUP BY 
	ST.TerritoryID,ST.Name,CONCAT(FirstName,' ',MiddleName,' ',LastName) ,DATEDIFF(YEAR,BirthDate,OrderDate)
ORDER BY
	CONCAT(FirstName,' ',MiddleName,' ',LastName)

--Who achived The Best Sales LastYear In this territory
/*
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)
*/
SELECT TOP(1)
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,MAX(SPR.SalesLastYear) AS Sales_Last_Year
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP'
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)
ORDER BY
	MAX(SPR.SalesLastYear) DESC

--For Each Sales Person What is the projected yearly sales
/*
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesQuota-->SalesPerson
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)
*/
SELECT
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SalesQuota
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP'
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)
	,SalesQuota

--Discovering why Projected yearly Sales for Stephen Y Jiang is NULL
--How many Sales He achieved last Year?
SELECT
	CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SalesLastYear AS Sales_Last_Year
FROM 
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	 PER.PersonType='SP' AND CONCAT(FirstName,' ',MiddleName,' ',LastName)='Stephen Y Jiang'
--I think there will be a mistake while entering the data into sales person 
--Let's take a look on his orders 
/*
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
SalesOrderID & OrderDate & ShipDate &TotalDu-->SalesOrderHeader
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)
*/
SELECT 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SalesOrderID,OrderDate
	,ShipDate
	,TotalDue
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' AND CONCAT(FirstName,' ',MiddleName,' ',LastName)='Stephen Y Jiang'
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)
	,OrderDate,ShipDate,SalesOrderID,TotalDue


--Maybe he is hired recently so,what is his hire date 
/*
Column Refernce:
SalesPersonName-->Person.Person
HireDate-->HumanReasources.Employee
Steps:
SalesPerson(SPR)-->Person.Person(PER)-->Humanreasourses(EMP)
*/
SELECT 
    CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,HireDate
FROM  
	Sales.SalesPerson AS SPR
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN 
	HumanResources.Employee AS EMP
ON 
	PER.BusinessEntityID=EMP.BusinessEntityID
WHERE 
    PER.PersonType='SP' AND CONCAT(FirstName,' ',MiddleName,' ',LastName)='Stephen Y Jiang'
--OK He Worked with us since 2005 and deliverd orders assigned to him
--So there is must be a wrong in entering data in SalesPerson data

--Calculating How Many Sales Stephen Y Jiang Achieved
/*
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
TotalDue-->SalesOrderHeader
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)

QueryResult:
we should modify SalesLastYear Column in SalesPerson to 230173.8472
*/
SELECT 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SUM(TotalDue) LastYearSales
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' AND CONCAT(FirstName,' ',MiddleName,' ',LastName)='Stephen Y Jiang' AND Year(OrderDate)=2007
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)

--What is the performance of our Sales Persons in this territory during years?
/*
Column Refernce:
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
TotalDue,OrderDate-->SalesOrderHeader
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)

Query Result:
For 2005 Pamela Was the Best Sales Person
For 2006 and 2007 David was the Best Sales Person 
For 2008 Tete was the Best
*/

SELECT 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,DATEPART(YEAR,OrderDate) AS YEARS
	,SUM(TotalDue) Total_sales
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' 
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)
	,DATEPART(YEAR,OrderDate)
ORDER BY 
	DATEPART(YEAR,OrderDate) ASC
	,SUM(TotalDue) DESC

/*Who has the large number of shipped orders?
Column Refernce:
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
Status-->SalesOrderHeader
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)

QueryResult:
David have large number of shippped orders
*/
SELECT TOP(1)
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,COUNT(SOD.Status) AS Shipped_Orders
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' AND SOD.Status=5
GROUP BY 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName)
ORDER BY
	COUNT(SOD.Status) DESC

--What is the Ship method each Sales Person use?
/*
Column Refernces:
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
ShipMethodName-->PurchasingShipMethod
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)
Salesterritory(ST)-->SalesOrderHeader(SOD)-->Purchasing.PurshasingShipMethod(SM)

QueryResult:
They All have the Same Shipping Method
*/

SELECT DISTINCT
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SM.Name AS ShipMethod_Name
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN Purchasing.ShipMethod AS SM
ON SOD.ShipMethodID=SM.ShipMethodID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' 

--What is the Ship Rate for Each SalesPerson?
/*
Column Refernces:
TerritoryName & ID -->SalesTerritory
SalesPerson name-->Person.Person
SalesLastYear-->SalesPerson
ShipRate-->PurchasingShipMethod
Steps:
Salesterritory(ST)-->SalesOrderHeader(SOD)-->SalesPerson(SPR)-->Person.Person(PER)
Salesterritory(ST)-->SalesOrderHeader(SOD)-->Purchasing.PurshasingShipMethod(SM)

Query Result:
They All have the same ShipRate
*/

SELECT DISTINCT 
	ST.TerritoryID,ST.Name
	,CONCAT(FirstName,' ',MiddleName,' ',LastName) AS Sales_Person_Name
	,SM.ShipRate 
FROM 
	Sales.SalesTerritory AS ST
JOIN 
	Sales.SalesOrderHeader AS SOD 
ON 
	ST.TerritoryID=SOD.TerritoryID
JOIN 
	Sales.SalesPerson AS SPR
ON 
	SOD.SalesPersonID =SPR.BusinessEntityID
JOIN 
	Person.Person PER
ON 
	SPR.BusinessEntityID=PER.BusinessEntityID
JOIN Purchasing.ShipMethod AS SM
ON SOD.ShipMethodID=SM.ShipMethodID
WHERE 
	ST.TerritoryID =1 AND PER.PersonType='SP' 
