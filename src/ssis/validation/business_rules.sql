-- ============================================================
-- BUSINESS RULE VALIDATION
-- Verify warehouse data is internally consistent and matches
-- source aggregations. Each check is documented with expected result.
-- ============================================================

USE AdventureWorks_DW
GO

-- ------------------------------------------------------------
-- 1. Total revenue match (OLTP vs Warehouse)
-- Expected: values very close; small variance (<$300) is acceptable
-- due to DECIMAL rounding (source computes LineTotal with 6 d.p.,
-- warehouse stores DECIMAL(18,2) — rounds to 2 d.p. on insert)
-- ------------------------------------------------------------
SELECT 
    'OLTP'      AS DataSource, 
    SUM(LineTotal) AS TotalSales
FROM AdventureWorks2022.Sales.SalesOrderDetail
UNION ALL
SELECT 
    'Warehouse' AS DataSource, 
    SUM(LineTotal) AS TotalSales
FROM AdventureWorks_DW.dbo.FactSales
GO

-- ------------------------------------------------------------
-- 2. Year-by-year revenue comparison (OLTP vs Warehouse)
-- Expected: same 4 years (2011–2014), line counts and revenue match
-- NOTE: DateKey is stored as YYYYMMDD integer; / 10000 extracts the year
-- ------------------------------------------------------------
SELECT 
    'OLTP'      AS DataSource,
    YEAR(h.OrderDate)   AS OrderYear,
    COUNT(*)            AS LineCount,
    SUM(d.LineTotal)    AS Revenue
FROM AdventureWorks2022.Sales.SalesOrderHeader h
JOIN AdventureWorks2022.Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
GROUP BY YEAR(h.OrderDate)
UNION ALL
SELECT 
    'Warehouse' AS DataSource,
    f.DateKey / 10000   AS OrderYear,
    COUNT(*)            AS LineCount,
    SUM(f.LineTotal)    AS Revenue
FROM AdventureWorks_DW.dbo.FactSales f
GROUP BY f.DateKey / 10000
ORDER BY OrderYear, DataSource
GO

-- ------------------------------------------------------------
-- 3. DateKey range check
-- Expected: min = 20110531, max = 20140630 (AdventureWorks 2022 range)
-- ------------------------------------------------------------
SELECT 
    MIN(DateKey) AS StartDate, 
    MAX(DateKey) AS EndDate
FROM AdventureWorks_DW.dbo.FactSales
GO

-- Out-of-range dates — should return 0
SELECT COUNT(*) AS OutOfRangeCount
FROM AdventureWorks_DW.dbo.FactSales
WHERE DateKey < 20110101 OR DateKey > 20141231
GO

-- ------------------------------------------------------------
-- 4. Channel completeness — Online + Reseller must cover 100% of rows
-- Expected: 2 rows, PctOfTotal sums to 100.00
-- ------------------------------------------------------------
SELECT 
    c.ChannelName,
    COUNT(*)    AS LineCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS PctOfTotal
FROM AdventureWorks_DW.dbo.FactSales f
JOIN AdventureWorks_DW.dbo.DimChannel c ON f.ChannelKey = c.ChannelKey
GROUP BY c.ChannelName
GO

-- ------------------------------------------------------------
-- 5. Data quality guards — no negative prices, quantities, or duplicates
-- Expected: 0 rows each
-- ------------------------------------------------------------
SELECT COUNT(*) AS NegativeValueCount
FROM AdventureWorks_DW.dbo.FactSales
WHERE UnitPrice < 0 OR OrderQty < 0
GO

-- No duplicate order lines (same SalesOrderID + SalesOrderDetailID must appear once)
SELECT SalesOrderIDBK, SalesOrderDetailIDBK, COUNT(*) AS DupeCount
FROM AdventureWorks_DW.dbo.FactSales
GROUP BY SalesOrderIDBK, SalesOrderDetailIDBK
HAVING COUNT(*) > 1
GO

