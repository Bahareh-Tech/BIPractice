
/*
The source tables for this Dim are the Product, ProductCategory and ProductSubcategory tables in the Production schema.
*/

USE AdventureWorks2022
GO

SELECT *
FROM Production.Product
GO
SELECT *
FROM Production.ProductCategory
GO 
SELECT *
FROM Production.ProductSubcategory
GO

USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS DimProduct
GO
CREATE TABLE DimProduct
(
    ProductKey         INT PRIMARY KEY IDENTITY(1,1), -- Surrogate Key
    ProductIDBK        INT NOT NULL,                  -- Business Key
    ProductNumber      NVARCHAR(25)    NOT NULL,
    ProductName        NVARCHAR(50)    NOT NULL,
    ProductSubcategory NVARCHAR(50)    NULL,           -- NULL for uncategorized products
    ProductCategory    NVARCHAR(50)    NULL,           -- NULL for uncategorized products
    Color              NVARCHAR(15)    NULL,
    ListPrice          DECIMAL(18, 2)  NOT NULL,
    DimRowHash         NVARCHAR(64)    NOT NULL        -- SHA2_256 hash of all attribute columns; used by SCD Check Lookup to detect changes (SCD Type 1)
)
GO

-- ETL uses this to look up the surrogate key from the source business key
CREATE NONCLUSTERED INDEX IX_DimProduct_ProductIDBK ON DimProduct (ProductIDBK)
GO

SELECT * FROM DimProduct



