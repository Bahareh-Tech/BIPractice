-- ============================================================
-- PERFORMANCE TESTS
-- Run typical dashboard queries against the warehouse and verify
-- they execute in acceptable time. Use SET STATISTICS TIME ON
-- to capture elapsed milliseconds in the Messages tab.
-- All queries on a 121K-row FactSales should complete in < 1 sec.
-- ============================================================

USE AdventureWorks_DW
GO

SET STATISTICS TIME ON
GO

-- ------------------------------------------------------------
-- Test 1: Monthly revenue trend (Sales Performance page)
-- Simulates the most common time-series dashboard query.
-- Expected: 48 rows (12 months × 4 years), < 500 ms
-- ------------------------------------------------------------
SELECT 
    d.[Year],
    d.MonthOfYear,
    d.MonthName,
    SUM(f.LineTotal)                        AS MonthlyRevenue,
    COUNT(DISTINCT f.SalesOrderIDBK)        AS OrderCount
FROM FactSales f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.[Year], d.MonthOfYear, d.MonthName
ORDER BY d.[Year], d.MonthOfYear
GO

-- ------------------------------------------------------------
-- Test 2: Top 10 products by revenue (Product Analysis page)
-- Expected: 10 rows, < 500 ms
-- ------------------------------------------------------------
SELECT TOP 10
    p.ProductName,
    p.ProductCategory,
    SUM(f.LineTotal)    AS TotalRevenue,
    SUM(f.OrderQty)     AS TotalQty
FROM FactSales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName, p.ProductCategory
ORDER BY TotalRevenue DESC
GO

-- ------------------------------------------------------------
-- Test 3: Revenue by territory (Territory Insights page)
-- Expected: 10 rows, < 500 ms
-- ------------------------------------------------------------
SELECT 
    t.TerritoryName,
    t.TerritoryGroup,
    SUM(f.LineTotal)                    AS TotalRevenue,
    COUNT(DISTINCT f.SalesOrderIDBK)    AS OrderCount
FROM FactSales f
JOIN DimTerritory t ON f.TerritoryKey = t.TerritoryKey
GROUP BY t.TerritoryName, t.TerritoryGroup
ORDER BY TotalRevenue DESC
GO

-- ------------------------------------------------------------
-- Test 4: Year-over-year revenue comparison (YoY Analysis page)
-- Self-join on DimDate to align current vs prior year.
-- Expected: 4 rows, < 1 sec
-- ------------------------------------------------------------
SELECT 
    cy.[Year]                           AS CurrentYear,
    SUM(f.LineTotal)                    AS CurrentRevenue,
    LAG(SUM(f.LineTotal)) OVER (ORDER BY cy.[Year]) AS PriorYearRevenue,
    SUM(f.LineTotal) - LAG(SUM(f.LineTotal)) OVER (ORDER BY cy.[Year]) AS YoYGrowth
FROM FactSales f
JOIN DimDate cy ON f.DateKey = cy.DateKey
GROUP BY cy.[Year]
ORDER BY cy.[Year]
GO

-- ------------------------------------------------------------
-- Test 5: Channel revenue split (Channel Performance page)
-- Expected: 2 rows, < 200 ms
-- ------------------------------------------------------------
SELECT 
    c.ChannelName,
    SUM(f.LineTotal)                                            AS TotalRevenue,
    CAST(SUM(f.LineTotal) * 100.0 / SUM(SUM(f.LineTotal)) OVER()
         AS DECIMAL(5,2))                                      AS RevenuePct,
    COUNT(DISTINCT f.SalesOrderIDBK)                           AS OrderCount
FROM FactSales f
JOIN DimChannel c ON f.ChannelKey = c.ChannelKey
GROUP BY c.ChannelName
GO

SET STATISTICS TIME OFF
GO

-- ------------------------------------------------------------
-- Index review — run if any query above exceeds 1 sec
-- Existing indexes on FactSales: DateKey, ProductKey,
-- CustomerKey, TerritoryKey, ChannelKey (all nonclustered)
-- ------------------------------------------------------------
SELECT 
    i.name          AS IndexName,
    i.type_desc     AS IndexType,
    SUM(s.used_page_count) * 8 AS IndexSizeKB
FROM sys.indexes i
JOIN sys.dm_db_partition_stats s 
    ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE OBJECT_NAME(i.object_id) = 'FactSales'
GROUP BY i.name, i.type_desc
ORDER BY IndexSizeKB DESC
GO
