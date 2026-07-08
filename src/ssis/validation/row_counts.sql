
-- ============================================================
-- ROW COUNT VALIDATION
-- Compare record counts between source (OLTP) and warehouse.
-- All counts should match except DimProduct (see note below).
-- ============================================================

-- Fact table: must match exactly (121,317 rows expected)
SELECT 'OLTP - SalesOrderDetail' AS Layer, COUNT(*) AS RecordCount
FROM AdventureWorks2022.Sales.SalesOrderDetail
UNION ALL
SELECT 'DW   - FactSales',        COUNT(*)
FROM AdventureWorks_DW.dbo.FactSales
GO

-- Dimension: Customer (must match exactly — all customers loaded)
SELECT 'OLTP - Customer'  AS Layer, COUNT(*) AS RecordCount
FROM AdventureWorks2022.Sales.Customer
UNION ALL
SELECT 'DW   - DimCustomer',      COUNT(*)
FROM AdventureWorks_DW.dbo.DimCustomer
GO

-- Dimension: Territory (must match exactly — all 10 territories loaded)
SELECT 'OLTP - SalesTerritory' AS Layer, COUNT(*) AS RecordCount
FROM AdventureWorks2022.Sales.SalesTerritory
UNION ALL
SELECT 'DW   - DimTerritory',     COUNT(*)
FROM AdventureWorks_DW.dbo.DimTerritory
GO

-- Dimension: Product (expected difference — DimProduct loads only products
-- that appear in sales orders, not the full 504-row product catalog.
-- 295 DW rows vs 504 OLTP rows is acceptable and by design.)
SELECT 'OLTP - Product'   AS Layer, COUNT(*) AS RecordCount
FROM AdventureWorks2022.Production.Product
UNION ALL
SELECT 'DW   - DimProduct',       COUNT(*)
FROM AdventureWorks_DW.dbo.DimProduct
GO