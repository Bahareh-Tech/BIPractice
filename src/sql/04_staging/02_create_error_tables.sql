/*
Creating error tables to hold rejected rows from the staging tables after validation checks. 
This allows us to keep a record of what was rejected and why, which can be helpful 
for troubleshooting and improving data quality over time.
*/

USE AdventureWorks_Staging
GO

DROP TABLE IF EXISTS stg_Product_Error
GO
CREATE TABLE stg_Product_Error
(
    ProductID INT,
    Name NVARCHAR(255),
    ProductNumber NVARCHAR(255),
    Color NVARCHAR(50),
    ListPrice DECIMAL(18, 2),
    ProductSubCategoryID INT,
    ErrorReason NVARCHAR(255),
    LoadDate DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_Person_Error
GO
CREATE TABLE stg_Person_Error
(
    BusinessEntityID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    ErrorReason NVARCHAR(255),
    LoadDate DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_SalesOrderHeader_Error
GO
CREATE TABLE stg_SalesOrderHeader_Error
(
    SalesOrderID INT,
    OrderDate DATETIME,
    DueDate DATETIME,
    ShipDate DATETIME,
    OnlineOrderFlag BIT,
    CustomerID INT,
    TerritoryID INT,
    ErrorReason NVARCHAR(255),
    LoadDate DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_SalesOrderDetail_Error
GO
CREATE TABLE stg_SalesOrderDetail_Error
(
    SalesOrderID INT,
    SalesOrderDetailID INT,
    ProductID INT,
    OrderQty SMALLINT,
    UnitPrice DECIMAL(18, 2),
    LineTotal DECIMAL(18, 2),
    ErrorReason NVARCHAR(255),
    LoadDate DATETIME DEFAULT GETDATE()
)
GO


/*
Logging table to track ETL runs and row counts for valid vs. rejected rows. 
This can be helpful for monitoring data quality over time and identifying trends or recurring issues.
*/
DROP TABLE IF EXISTS stg_ETL_log
GO
CREATE TABLE stg_ETL_log
(
    LogID INT IDENTITY PRIMARY KEY,
    PackageName NVARCHAR(100),
    StageTableName NVARCHAR(100),
    ValidRows INT,
    ErrorRows INT,
    LoadDate DATETIME DEFAULT GETDATE()
)
GO


/*
0. Development steps:
Defining the validation rules for the tables
Checking if any invalid rows actually exist, How many invalid rows do we have? 
*/

-- stg_Product --

SP_HELP 'stg_Product'
GO

-- Checking the data types, lengths, possibility of NULL values of the fields to make sure they align with the source system and business rules
SELECT 
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM AdventureWorks2022.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Product'
    AND TABLE_SCHEMA = 'Production';
GO

-- Checking for fields that are not allowed to NULL and also checking for negative prices which don't make sense in this context (according to source, warehouse and business rules)
SELECT 
    COUNT(*) 
FROM stg_Product
WHERE ProductID IS NULL 
    OR TRIM(ISNULL(Name, '')) = '' 
    OR ListPrice < 0;
GO

-- stg_Person --

SP_HELP 'stg_Person'
GO

-- Checking the data types, lengths, possibility of NULL values of the fields to make sure they align with the source system and business rules
SELECT 
    C.COLUMN_NAME,
    C.IS_NULLABLE,
    C.DATA_TYPE,
    C.CHARACTER_MAXIMUM_LENGTH
FROM AdventureWorks2022.INFORMATION_SCHEMA.COLUMNS AS C
WHERE C.TABLE_NAME = 'Person'
    AND C.TABLE_SCHEMA = 'Person';
GO

-- Checking for fields that are not allowed to NULL and also checking for empty strings (according to source, warehouse and business rules)
SELECT 
    COUNT(*)
FROM stg_Person
WHERE BusinessEntityID IS NULL
    OR TRIM(ISNULL(FirstName, '')) = ''
    OR TRIM(ISNULL(LastName, '')) = '';
GO

-- stg_SalesOrderHeader --

SP_HELP 'stg_SalesOrderHeader'
GO

-- Checking the data types, lengths, possibility of NULL values of the fields to make sure they align with the source system and business rules
SELECT 
    C.COLUMN_NAME,
    C.IS_NULLABLE,
    C.DATA_TYPE,
    C.CHARACTER_MAXIMUM_LENGTH
FROM AdventureWorks2022.INFORMATION_SCHEMA.COLUMNS AS C
WHERE C.TABLE_NAME = 'SalesOrderHeader'
    AND C.TABLE_SCHEMA = 'Sales';  
GO

-- Checking for fields that are not allowed to NULL and also checking for date logic issues (according to source, warehouse and business rules)
SELECT COUNT(*)
FROM stg_SalesOrderHeader
WHERE SalesOrderID IS NULL
    OR OrderDate IS NULL
    OR CustomerID IS NULL
    OR TerritoryID IS NULL
    OR OnlineOrderFlag IS NULL;
GO

-- Checking for date logic issues separately so we know exactly which problem exists
SELECT COUNT(*)
FROM stg_SalesOrderHeader
WHERE ShipDate < OrderDate;         -- ship before order: logical error
GO

SELECT COUNT(*)
FROM stg_SalesOrderHeader
WHERE OrderDate < '2000-01-01'
    OR OrderDate > GETDATE();       -- clearly out-of-range dates
GO

-- stg_SalesOrderDetail --

SP_HELP 'stg_SalesOrderDetail'
GO

-- Checking the data types, lengths, possibility of NULL values of the fields to make sure they align with the source system and business rules
SELECT
    C.COLUMN_NAME,
    C.IS_NULLABLE,
    C.DATA_TYPE,
    C.CHARACTER_MAXIMUM_LENGTH
FROM AdventureWorks2022.INFORMATION_SCHEMA.COLUMNS AS C
WHERE C.TABLE_NAME = 'SalesOrderDetail'
    AND C.TABLE_SCHEMA = 'Sales';
GO

-- Checking for fields that are not allowed to NULL and invalid numeric values (according to source, warehouse and business rules)
SELECT COUNT(*)
FROM stg_SalesOrderDetail
WHERE SalesOrderDetailID IS NULL
    OR SalesOrderID IS NULL
    OR ProductID IS NULL
    OR OrderQty IS NULL OR OrderQty <= 0
    OR UnitPrice IS NULL OR UnitPrice < 0
    OR UnitPriceDiscount IS NULL
    OR LineTotal IS NULL OR LineTotal < 0;
GO


/*
Next steps after identifying the invalid rows (These steps are done through SSIS packages):
1. Copying invalid rows to the error table so there is a record of what will be removed and why
2. Removing the invalid rows from staging so they don't cause issues downstream
3. Fixing formatting issues on the rows that passed validation, mainly trimming whitespace so string joins work correctly later
4. Checking row counts after cleaning, the two numbers should add up to the original row count
*/


SELECT * FROM stg_Product_Error
GO
SELECT * FROM stg_Person_Error
GO
SELECT * FROM stg_SalesOrderHeader_Error
GO
SELECT * FROM stg_SalesOrderDetail_Error
GO
SELECT * FROM stg_ETL_log
GO