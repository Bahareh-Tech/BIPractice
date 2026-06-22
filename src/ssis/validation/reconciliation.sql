-- ============================================================
-- RECONCILIATION REPORT
-- Side-by-side comparisons across OLTP source and warehouse.
-- All variances should be documented and explainable.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Total revenue (overall)
-- Expected variance: <$300 due to DECIMAL rounding
-- ------------------------------------------------------------
SELECT 'OLTP'      AS Layer, SUM(LineTotal) AS TotalRevenue 
FROM AdventureWorks2022.Sales.SalesOrderDetail
UNION ALL
SELECT 'Warehouse' AS Layer, SUM(LineTotal) AS TotalRevenue 
FROM AdventureWorks_DW.dbo.FactSales
GO

-- ------------------------------------------------------------
-- 2. Year-by-year revenue variance (source of truth: OLTP)
-- Expected: small rounding variance per year, no full-year gaps
-- ------------------------------------------------------------
SELECT 
    src.OrderYear,
    src.SourceRevenue,
    wh.WarehouseRevenue,
    CAST(src.SourceRevenue - wh.WarehouseRevenue AS DECIMAL(18,2)) AS Variance,
    CAST((src.SourceRevenue - wh.WarehouseRevenue) / src.SourceRevenue * 100 AS DECIMAL(10,6)) AS VariancePct
FROM (
    SELECT YEAR(h.OrderDate) AS OrderYear, SUM(d.LineTotal) AS SourceRevenue
    FROM AdventureWorks2022.Sales.SalesOrderHeader h
    JOIN AdventureWorks2022.Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    GROUP BY YEAR(h.OrderDate)
) src
JOIN (
    SELECT f.DateKey / 10000 AS OrderYear, SUM(f.LineTotal) AS WarehouseRevenue
    FROM AdventureWorks_DW.dbo.FactSales f
    GROUP BY f.DateKey / 10000
) wh ON src.OrderYear = wh.OrderYear
ORDER BY src.OrderYear
GO

-- ------------------------------------------------------------
-- 3. Territory revenue comparison
-- Expected: same 10 territories, revenue totals match
-- ------------------------------------------------------------
SELECT DISTINCT 'OLTP'      AS Layer, Name AS TerritoryName
FROM AdventureWorks2022.Sales.SalesTerritory
UNION ALL
SELECT DISTINCT 'Warehouse' AS Layer, TerritoryName
FROM AdventureWorks_DW.dbo.DimTerritory
ORDER BY TerritoryName
GO

-- Revenue by territory (warehouse)
SELECT 
    t.TerritoryName,
    SUM(f.LineTotal) AS WarehouseRevenue
FROM AdventureWorks_DW.dbo.FactSales f
JOIN AdventureWorks_DW.dbo.DimTerritory t ON f.TerritoryKey = t.TerritoryKey
GROUP BY t.TerritoryName
ORDER BY WarehouseRevenue DESC
GO

-- ------------------------------------------------------------
-- 4. Product category comparison
-- Expected: same 4 categories (Bikes, Components, Clothing, Accessories)
-- ------------------------------------------------------------
SELECT DISTINCT 'OLTP'      AS Layer, Name AS ProductCategoryName
FROM AdventureWorks2022.Production.ProductCategory
UNION ALL
SELECT DISTINCT 'Warehouse' AS Layer, ProductCategory AS ProductCategoryName
FROM AdventureWorks_DW.dbo.DimProduct
ORDER BY ProductCategoryName
GO

