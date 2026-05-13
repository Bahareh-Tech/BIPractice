
/*
This Dim is created from Product, ProductCategory and ProductSubcategory tables in the Production schema.
*/

SELECT *
FROM Production.Product
GO
SELECT *
FROM Production.ProductCategory
GO 
SELECT *
FROM Production.ProductSubcategory
GO

CREATE TABLE DimProduct
(
    ProductKey INT PRIMARY KEY, -- Surrogate Key
    ProductIDBK INT, -- Business Key
    ProductName NVARCHAR(255),
    ProductCategory NVARCHAR(255),
    ProductSubcategory NVARCHAR(255),
    ProductListPrice DECIMAL(18, 2)
)

