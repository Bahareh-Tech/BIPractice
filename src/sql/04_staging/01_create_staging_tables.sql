USE AdventureWorks_Staging
GO

DROP TABLE IF EXISTS stg_Product
GO
CREATE TABLE stg_Product
(
    ProductID INT,
    Name NVARCHAR(255),
    ProductNumber NVARCHAR(255),
    Color NVARCHAR(50),
    ListPrice DECIMAL(18, 2),
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
    AccountNumber NVARCHAR(50),
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
    TerritoryGroup NVARCHAR(50), -- source column is [Group], renamed to avoid reserved word
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
    OrderQty INT,
    UnitPrice DECIMAL(18, 2),
    UnitPriceDiscount DECIMAL(18, 2),
    LineTotal DECIMAL(18, 2),
    RowHash   NVARCHAR(64),
    LoadDate  DATETIME DEFAULT GETDATE()
)
GO

