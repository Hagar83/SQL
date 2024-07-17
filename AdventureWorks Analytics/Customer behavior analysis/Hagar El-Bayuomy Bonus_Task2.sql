--Analyzing Customer Sales behavior

--Exploring How Many Customers We Have?
SELECT
	COUNT(CustomerID) AS TotalCustomers
FROM Sales.Customer
--Exploring How Many Orders by each Customer
SELECT
    CustomerID,
    COUNT(SOD.SalesOrderID) AS TotalOrders
FROM
    Sales.SalesOrderHeader AS SOH
JOIN
	Sales.SalesOrderDetail AS SOD
ON
	SOH.SalesOrderID=SOD.SalesOrderID

GROUP BY
    CustomerID
/*Exploring How many of them is Active 
(We can Categorize our Customers Customers who made more than 10 order is Active customer customer who made 2-10 order middle customers and customers who orders 1 inactive)*/
SELECT
    CustomerID,
    COUNT(SOD.SalesOrderID) AS TotalOrders,
    CASE WHEN COUNT(SOD.SalesOrderID) >10 THEN 'Active Customers'
	WHEN COUNT(SOD.SalesOrderID) Between 2 AND 10 THEN 'Middle-Active'
	WHEN COUNT(SOD.SalesOrderID) =1 THEN 'InActive'
	END AS 'Categorizing_Customers'
FROM
    Sales.SalesOrderHeader AS SOH
JOIN
	Sales.SalesOrderDetail AS SOD
ON
	SOH.SalesOrderID=SOD.SalesOrderID

GROUP BY
    CustomerID;

--Exploring The Top 10 Ordered Product

WITH ProductOrderCount AS (
    SELECT 
        SOD.ProductID,
        PRO.Name,
        COUNT(*) AS OrderCount
    FROM 
        Sales.SalesOrderDetail AS SOD
    JOIN 
        Production.Product AS PRO ON SOD.ProductID = PRO.ProductID
    GROUP BY 
        SOD.ProductID,
        PRO.Name
),
RankedProducts AS (
    SELECT 
        ProductID,
        Name,
        OrderCount,
        RANK() OVER (ORDER BY OrderCount DESC) AS ProductRank
    FROM 
        ProductOrderCount
)
SELECT 
    ProductID,
    Name,
    OrderCount
FROM 
    RankedProducts
WHERE 
    ProductRank <= 10;
--Query Result
/*
Water Bottle - 30 oz.
AWC Logo Cap
Patch Kit/8 Patches
Mountain Tire Tube
Sport-100 Helmet, Blue
Sport-100 Helmet, Red
Sport-100 Helmet, Black
Road Tire Tube
Fender Set - Mountain
Mountain Bottle Cage
*/

--Knowing There Customers
SELECT 
    RP.ProductID,
    RP.Name AS ProductName,
    
    CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName) AS CustomerName
FROM 
    RankedProducts RP
JOIN 
    Sales.SalesOrderDetail SOD ON RP.ProductID = SOD.ProductID
JOIN 
    Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN 
    Person.Person P ON SOH.CustomerID = P.BusinessEntityID
WHERE 
    RP.ProductRank <= 10
ORDER BY 
    RP.ProductRank, CustomerName;

--Which Product Category and their customers achieves the most Revenue
/* Query Result :
Kevin Liu	Accessories	9869.919866
Roger Harui	Bikes	783100.606529
Kevin Liu	Clothing	29609.844231
Reuben D'sa	Components	206637.611692*/
WITH CustomerProductRevenue AS (
    SELECT 
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        PC.Name AS ProductCategory,
        SUM(SOD.LineTotal) AS TotalRevenue
    FROM 
        Sales.SalesOrderDetail AS SOD
    JOIN 
        Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
    JOIN 
        Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
    JOIN 
        Person.Person AS P ON C.PersonID = P.BusinessEntityID
    JOIN 
        Production.Product AS Prod ON SOD.ProductID = Prod.ProductID
    JOIN 
        Production.ProductSubcategory AS PS ON Prod.ProductSubcategoryID = PS.ProductSubcategoryID
    JOIN 
        Production.ProductCategory AS PC ON PS.ProductCategoryID = PC.ProductCategoryID
    GROUP BY 
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName),
        PC.Name
),
RankedCustomerProducts AS (
    SELECT 
        CustomerID,
        CustomerName,
        ProductCategory,
        TotalRevenue,
        RANK() OVER (PARTITION BY ProductCategory ORDER BY TotalRevenue DESC) AS RevenueRank
    FROM 
        CustomerProductRevenue
)
SELECT 
    CustomerID,
    CustomerName,
    ProductCategory,
    TotalRevenue
FROM 
    RankedCustomerProducts
WHERE 
    RevenueRank = 1;

--What is the most customers Territory Sales?
/*
Query Result:
Southwest	27150594.5893
Canada	18398929.188*/
WITH CustomerSalesByTerritory AS (
    SELECT
        C.CustomerID,
        ST.Name AS TerritoryName,
        SUM(SOH.TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader AS SOH
    JOIN 
        Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
    JOIN 
        Sales.SalesTerritory AS ST ON C.TerritoryID = ST.TerritoryID
    GROUP BY 
        C.CustomerID,
        ST.Name
),
TerritorySales AS (
    SELECT
        TerritoryName,
        SUM(TotalSales) AS TotalSales
    FROM 
        CustomerSalesByTerritory
    GROUP BY 
        TerritoryName
),
RankedTerriitories AS (
    SELECT
        TerritoryName,
        TotalSales,
        RANK() OVER (ORDER BY TotalSales DESC) AS TerritoryRank
    FROM 
       TerritorySales
)
SELECT
    TerritoryName,
    TotalSales
FROM 
    RankedTerriitories
WHERE 
    TerritoryRank <= 2;

--What is the total Sales by Customer?
SELECT
    CustomerID,
    COUNT(SOD.SalesOrderID) AS TotalOrders,
    SUM(TotalDue) AS TotalSales
FROM
    Sales.SalesOrderHeader AS SOH
JOIN
	Sales.SalesOrderDetail AS SOD
ON
	SOH.SalesOrderID=SOD.SalesOrderID

GROUP BY
    CustomerID

--Customer Ordering analysis Across Years and Months
SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName) AS CustomerName,
        YEAR(SOH.OrderDate) AS OrderYear,
        MONTH(SOH.OrderDate) AS OrderMonth,
        COUNT(SOH.SalesOrderID) AS NumberOfOrders,
        SUM(SOH.TotalDue) AS TotalSalesAmount
    FROM 
        Sales.SalesOrderHeader AS SOH
    JOIN 
        Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
   JOIN 
        Person.Person AS P ON C.CustomerID = P.BusinessEntityID
    GROUP BY 
        C.CustomerID,
		CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName)
        YEAR(SOH.OrderDate),
        MONTH(SOH.OrderDate)
    ORDER BY 
        C.CustomerID,
        OrderYear,
        OrderMonth

--who is the most ordering 
--Query Result Morgan P Jackson	68
WITH CustomerOrderCounts AS (
    SELECT 
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName) AS CustomerName,
        COUNT(SOD.SalesOrderID) AS NumberOfOrders,
        RANK() OVER (ORDER BY COUNT(SOD.SalesOrderID) DESC) AS OrderRank
    FROM 
        Sales.SalesOrderHeader AS SOH
    JOIN 
        Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
    JOIN 
        Person.Person AS P ON C.CustomerID = P.BusinessEntityID
    JOIN 
        Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
    GROUP BY 
        C.CustomerID,
	    CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName))
SELECT 
    CustomerID,
    CustomerName,
    NumberOfOrders
FROM 
    CustomerOrderCounts
WHERE 
    OrderRank = 1;

--What About canlcling order
--No cancled orders
SELECT
    C.CustomerID,
    CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName) AS CustomerName,
    COUNT(SOH.SalesOrderID) AS NumberOfCancellations
FROM 
    Sales.SalesOrderHeader AS SOH
JOIN 
    Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
JOIN 
    Person.Person AS P ON C.CustomerID = P.BusinessEntityID
WHERE 
    SOH.Status = 6 
GROUP BY 
    C.CustomerID,
	CONCAT(P.FirstName, ' ', P.MiddleName, ' ', P.LastName)
   
ORDER BY 
    NumberOfCancellations DESC
--Which customer segments generate the most revenue?
--Query result: Young	123216786.1159
WITH CustomerSegments AS (
    SELECT
        C.CustomerID,
        CONCAT(P.FirstName, ' ', P.LastName) AS CustomerName,
        DATEDIFF(YEAR, P.ModifiedDate, GETDATE()) AS Age,
        CASE
            WHEN DATEDIFF(YEAR, P.ModifiedDate, GETDATE()) <= 30 THEN 'Young'
            WHEN DATEDIFF(YEAR, P.ModifiedDate, GETDATE()) BETWEEN 31 AND 50 THEN 'Middle-Aged'
            WHEN DATEDIFF(YEAR, P.ModifiedDate, GETDATE()) > 50 THEN 'Senior'
            ELSE 'Unknown'
        END AS AgeGroup,
        SOH.TotalDue AS Revenue
    FROM 
        Sales.SalesOrderHeader AS SOH
    JOIN 
        Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
    JOIN 
        Person.Person AS P ON C.PersonID = P.BusinessEntityID
)
SELECT 
    AgeGroup,
    SUM(Revenue) AS TotalRevenue
FROM 
    CustomerSegments
GROUP BY 
    AgeGroup
ORDER BY 
    TotalRevenue DESC


