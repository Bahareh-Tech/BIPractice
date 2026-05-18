/*
The source tables for this Dim are:
Sales.SalesTerritory : TerritoryID, Name, CountryRegionCode, Group
Person.CountryRegion : full country name from the 2-letter CountryRegionCode
*/

USE AdventureWorks2022
GO

SELECT *
FROM Sales.SalesTerritory
GO
SELECT *
FROM Person.CountryRegion
GO

USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS DimTerritory
GO
CREATE TABLE DimTerritory
(
    TerritoryKey    INT PRIMARY KEY IDENTITY(1,1), -- Surrogate Key
    TerritoryIDBK   INT NOT NULL,   -- Business Key
    TerritoryName   NVARCHAR(50) NOT NULL,  -- region name via Name
    TerritoryCountry    NVARCHAR(50) NOT NULL,  -- via CountryRegion.CountryRegionCode + CountryRegion.Name
    TerritoryGroup  NVARCHAR(50) NOT NULL -- via Group
)
GO

-- ETL uses this to look up the surrogate key from the source business key
CREATE NONCLUSTERED INDEX IX_DimTerritory_TerritoryIDBK ON DimTerritory (TerritoryIDBK)
GO

SELECT * FROM DimTerritory
GO