/*
Create staging tables to hold raw data from the source system before transformation
 and loading into the data warehouse.
*/

USE AdventureWorks_Staging
GO

DROP TABLE IF EXISTS stg_Product
GO
CREATE TABLE stg_Product
(
    ProductID INT,
    Name NVARCHAR(255),
    ProductNumber NVARCHAR(255),
    Color NVARCHAR(30),
    ListPrice money,              
    ProductSubCategoryID INT,
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_ProductSubCategory
GO
CREATE TABLE stg_ProductSubCategory
(
    ProductSubcategoryID INT,
    Name NVARCHAR(255),
    ProductCategoryID INT,
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_ProductCategory
GO
CREATE TABLE stg_ProductCategory
(
    ProductCategoryID INT,
    Name NVARCHAR(255),
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_Customer
GO
CREATE TABLE stg_Customer
(
    CustomerID INT,
    PersonID INT,
    StoreID INT,
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_Person
GO
CREATE TABLE stg_Person
(
    BusinessEntityID INT,
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_Store
GO
CREATE TABLE stg_Store
(
    BusinessEntityID INT,
    Name NVARCHAR(255),
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_SalesTerritory
GO
CREATE TABLE stg_SalesTerritory
(
    TerritoryID INT,
    Name NVARCHAR(255),
    CountryRegionCode NVARCHAR(10),
    TerritoryGroup NVARCHAR(255), -- source column is [Group], renamed to avoid reserved word
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_CountryRegion
GO
CREATE TABLE stg_CountryRegion
(
    CountryRegionCode NVARCHAR(10),
    Name NVARCHAR(255),
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_SalesOrderHeader
GO
CREATE TABLE stg_SalesOrderHeader
(
    SalesOrderID INT,
    OrderDate DATETIME,
    DueDate DATETIME,
    ShipDate DATETIME,
    OnlineOrderFlag BIT,
    CustomerID INT,
    TerritoryID INT,
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

DROP TABLE IF EXISTS stg_SalesOrderDetail
GO
CREATE TABLE stg_SalesOrderDetail
(
    SalesOrderDetailID INT,
    SalesOrderID INT,
    ProductID INT,
    OrderQty SMALLINT,                 
    UnitPrice money,                   
    UnitPriceDiscount money,           
    LineTotal DECIMAL(18, 6),          
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO


SELECT * FROM stg_Product
GO
SELECT * FROM stg_ProductSubCategory
GO
SELECT * FROM stg_ProductCategory
GO
SELECT * FROM stg_Customer
GO
SELECT * FROM stg_Person
GO
SELECT * FROM stg_Store
GO
SELECT * FROM stg_SalesTerritory
GO
SELECT * FROM stg_CountryRegion
GO
SELECT * FROM stg_SalesOrderHeader
GO
SELECT * FROM stg_SalesOrderDetail
GO

-- Verify row counts in staging tables
DROP TABLE IF EXISTS etl_log
GO
CREATE TABLE etl_log
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    PackageName NVARCHAR(255),
    TableName NVARCHAR(255),
    RowsLoaded INT,
    LoadDate DATETIME DEFAULT GETDATE()
)
GO

USE AdventureWorks_Staging
SELECT * FROM etl_log
GO

-- S2 logging table: captures valid vs error row counts after each cleaning package
DROP TABLE IF EXISTS stg_ETL_log
GO
CREATE TABLE stg_ETL_log
(
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    PackageName NVARCHAR(255),
    StageTableName NVARCHAR(255),
    ValidRows   INT,
    ErrorRows   INT,
    LoadDate    DATETIME DEFAULT GETDATE()
)
GO

SELECT
    SH.SalesOrderID AS SalesOrderIDBK,
    SD.SalesOrderDetailID AS SalesOrderDetailIDBK,
    SD.ProductID,
    SH.CustomerID,
    SH.TerritoryID,
    SH.OrderDate,
    SH.OnlineOrderFlag,
    SD.OrderQty,
    SD.UnitPrice,
    SD.UnitPriceDiscount,
    SD.LineTotal
FROM stg_SalesOrderHeader AS SH
LEFT JOIN stg_SalesOrderDetail AS SD
    ON SH.SalesOrderID = SD.SalesOrderID
GO

--- Create a staging table to log lookup failures during ETL
DROP TABLE IF EXISTS stg_errors_Lookup
GO
CREATE TABLE stg_errors_Lookup
(
    ErrorID        INT IDENTITY(1,1) PRIMARY KEY,
    PackageName    NVARCHAR(255),
    LookupStep     NVARCHAR(100),
    FailedKeyName  NVARCHAR(100),
    FailedKeyValue NVARCHAR(50),   -- NVARCHAR covers both INT keys and string keys
    LoadDate       DATETIME DEFAULT GETDATE()
)
GO

USE AdventureWorks_Staging
SELECT COUNT(*) FROM stg_errors_Lookup
GO


