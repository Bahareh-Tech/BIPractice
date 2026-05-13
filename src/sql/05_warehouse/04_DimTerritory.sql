/*
This Dim is created from SalesTerritory table in the Sales schema.
*/

SELECT *
FROM Sales.SalesTerritory
GO

SELECT *
FROM Sales.SalesTerritoryHistory
GO

CREATE TABLE DimTerritory
(
    TerritoryKey INT PRIMARY KEY, -- Surrogate Key
    TerritoryIDBK INT, -- Business Key
    TerritoryName NVARCHAR(255)
)
GO