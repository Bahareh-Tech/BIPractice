-- ============================================================
-- FOREIGN KEY INTEGRITY CHECKS
-- Verify no orphaned rows exist in FactSales (i.e., every
-- surrogate key in FactSales must exist in its dimension table).
-- Every query below should return 0 rows to pass.
-- ============================================================

USE AdventureWorks_DW
GO

-- Check for referential integrity between FactSales and DimProduct
SELECT DISTINCT 
    FactSales.ProductKey 
FROM FactSales
LEFT JOIN DimProduct 
    ON FactSales.ProductKey = DimProduct.ProductKey
WHERE DimProduct.ProductKey IS NULL
GO

-- Check for referential integrity between FactSales and DimCustomer
SELECT DISTINCT 
    FactSales.CustomerKey
FROM FactSales
LEFT JOIN DimCustomer
    ON FactSales.CustomerKey = DimCustomer.CustomerKey
WHERE DimCustomer.CustomerKey IS NULL
GO

-- Check for referential integrity between FactSales and DimTerritory
SELECT DISTINCT 
    FactSales.TerritoryKey
FROM FactSales
LEFT JOIN DimTerritory
    ON FactSales.TerritoryKey = DimTerritory.TerritoryKey
WHERE DimTerritory.TerritoryKey IS NULL
GO

-- Check for referential integrity between FactSales and DimChannel
SELECT DISTINCT 
    FactSales.ChannelKey
FROM FactSales
LEFT JOIN DimChannel
    ON FactSales.ChannelKey = DimChannel.ChannelKey
WHERE DimChannel.ChannelKey IS NULL
GO

-- Check for referential integrity between FactSales and DimDate
SELECT DISTINCT 
    FactSales.DateKey
FROM FactSales
LEFT JOIN DimDate
    ON FactSales.DateKey = DimDate.DateKey
WHERE DimDate.DateKey IS NULL
GO

-- ============================================================
-- NULL SURROGATE KEY CHECKS
-- Surrogate keys in FactSales must never be NULL.
-- Every query below should return 0 rows to pass.
-- ============================================================

SELECT COUNT(*) AS NullProductKey   FROM FactSales WHERE ProductKey  IS NULL
GO
SELECT COUNT(*) AS NullCustomerKey  FROM FactSales WHERE CustomerKey IS NULL
GO
SELECT COUNT(*) AS NullTerritoryKey FROM FactSales WHERE TerritoryKey IS NULL
GO
SELECT COUNT(*) AS NullChannelKey   FROM FactSales WHERE ChannelKey  IS NULL
GO
SELECT COUNT(*) AS NullDateKey      FROM FactSales WHERE DateKey     IS NULL
GO