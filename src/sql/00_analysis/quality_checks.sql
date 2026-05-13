
---------- discovering duplicate data in a table ----------
/*
1. Primary key columns should never duplicate.
2. Any candidate unique keys or business-key combinations that is supposed to be unique in business logic should never duplicate.
3. Keys used for joins in ETL or staging should also be checked for duplicates to avoid bad joins.
We can check for duplicates by grouping by the column(s) and counting the number of occurrences. If any count is greater than 1, then we have duplicates.
*/

-- 1. checking primary keys
-- SalesOrderDetail
SELECT 
    COLUMN_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'SalesOrderDetail'
AND TC.CONSTRAINT_TYPE = 'PRIMARY KEY' ;
GO

SELECT 
    SalesOrderID, 
    SalesOrderDetailID, 
    COUNT(*) AS DuplicateCount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID, SalesOrderDetailID
HAVING COUNT(*) > 1
GO

-- SalesOrderHeader
SELECT 
    COLUMN_NAME, 
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'SalesOrderHeader'
AND TC.CONSTRAINT_TYPE = 'PRIMARY KEY' ;
GO

SELECT 
    SalesOrderID, 
    COUNT(*) AS DuplicateCount
FROM Sales.SalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(*) > 1
GO

-- 2. checking business keys / candidate unique keys
-- SalesOrderDetail
SELECT *
FROM Sales.SalesOrderDetail
GO

SELECT 
    SalesOrderID, 
    ProductID, 
    COUNT(*) AS DuplicateCount 
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID, ProductID   
HAVING COUNT(*) > 1
GO

-- Customer
SELECT *
FROM Sales.Customer
GO

SELECT 
    CustomerID, 
    COUNT(*) AS DuplicateCount
FROM Sales.Customer
GROUP BY CustomerID
HAVING COUNT(*) > 1
GO

-- 3. checking keys used for joins in ETL or staging
-- SalesOrderDetail 
SELECT *
FROM Sales.SalesOrderDetail
GO

SELECT 
    SalesOrderID, 
    COUNT(*) AS DuplicateCount
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(*) > 1
GO

-- SalesTerritory
SELECT *
FROM Sales.SalesTerritory  
GO

SELECT 
    TerritoryID, 
    COUNT(*) AS DuplicateCount
FROM Sales.SalesTerritory   
GROUP BY TerritoryID
HAVING COUNT(*) > 1
GO

---------- Identify NULL percentages ----------

-- NULL percentage for a single column
SELECT 
    OrderQty,
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN OrderQty IS NULL THEN 1 ELSE 0 END) AS NullCount,
    ROUND(100 * SUM(CASE WHEN OrderQty IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS NullPercentage
FROM Sales.SalesOrderDetail
GROUP BY OrderQty
GO

/*
When you are using a column with aggregate functions (COUNT, SUM) in the same SELECT, 
SQL requires every other selected column to be either:

a. inside an aggregate function, or
b. listed in GROUP BY
*/

-- NULL percentage for multiple columns

DECLARE @schema SYSNAME = 'sales';
DECLARE @table SYSNAME = 'SalesOrderHeader';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS TotalRows, '
    + 'SUM(CASE WHEN ' + QUOTENAME(COLUMN_NAME) + ' IS NULL THEN 1 ELSE 0 END) AS NullCount, '
    + 'ROUND(100.0 * SUM(CASE WHEN ' + QUOTENAME(COLUMN_NAME) + ' IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS NullPercentage '
    + 'FROM ' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + ' UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema
    AND TABLE_NAME = @table;

-- Remove the last 'UNION ALL' from the generated SQL
SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL '));

-- Execute the generated SQL
EXEC sp_executesql @sql;
GO

---------- Check date ranges ----------

/*
Knowing data ranges gives you a quick sanity check before you build
the star schema, measures, or time-based visuals.
*/
-- Find tables with date-like columns
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%Date%'
    AND TABLE_NAME IN ('SalesOrderHeader', 'SalesOrderDetail',
    'Customer', 'SalesTerritory','Product', 'ProductCategory',
    'ProductSubcategory')
ORDER BY TABLE_SCHEMA,TABLE_NAME
GO

SELECT 
    MIN(SellStartDate) AS MinOrderDate,
    MAX(SellStartDate) AS MaxOrderDate
FROM Production.Product
GO

SELECT 
    MIN(SellEndDate) AS MinOrderDate,
    MAX(SellEndDate) AS MaxOrderDate
FROM Production.Product
GO

SELECT 
    MIN(DiscontinuedDate) AS MinOrderDate,
    MAX(DiscontinuedDate) AS MaxOrderDate
FROM Production.Product
GO

SELECT 
    MIN(ModifiedDate) AS MinOrderDate,
    MAX(ModifiedDate) AS MaxOrderDate
FROM Production.Product
GO

SELECT 
    MIN(ModifiedDate) AS MinOrderDate,
    MAX(ModifiedDate) AS MaxOrderDate
FROM Production.ProductSubcategory
GO

SELECT 
    MIN(ModifiedDate) AS MinOrderDate,
    MAX(ModifiedDate) AS MaxOrderDate
FROM Sales.Customer
GO

SELECT 
    MIN(ModifiedDate) AS MinOrderDate,
    MAX(ModifiedDate) AS MaxOrderDate
FROM Sales.SalesOrderDetail
GO

SELECT 
    MIN(OrderDate) AS MinOrderDate,
    MAX(OrderDate) AS MaxOrderDate
FROM Sales.SalesOrderHeader
GO

SELECT 
    MIN(DueDate) AS MinOrderDate,
    MAX(DueDate) AS MaxOrderDate
FROM Sales.SalesOrderHeader
GO

SELECT 
    MIN(ShipDate) AS MinOrderDate,
    MAX(ShipDate) AS MaxOrderDate
FROM Sales.SalesOrderHeader
GO

SELECT 
    MIN(ModifiedDate) AS MinOrderDate,
    MAX(ModifiedDate) AS MaxOrderDate
FROM Sales.SalesOrderHeader
GO

SELECT 
    MIN(ModifiedDate) AS MinOrderDate,
    MAX(ModifiedDate) AS MaxOrderDate
FROM Sales.SalesTerritory
GO

---------- Detect negative or unusual values in numeric fields ----------
/*
1. Check for negative values, zero values, or values that are outside of 
expected ranges

2. Use min/max for numeric range profiling, and use count with conditions
to check for negative or zero values.

3. Detect unusual values using statistical checks like mean, median, 
standard deviation, or interquartile range (IQR).

4. Use distribution / outlier checks to identify values that are significantly
different from the rest of the data, then flag values far outside the mean or median, or use IQR to find outliers.
*/

-- Find columns with numeric types automatically
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('tinyint','smallint','int','bigint',
    'decimal','numeric','float','real', 'money','smallmoney')
    AND TABLE_NAME IN ('SalesOrderHeader', 'SalesOrderDetail',
    'Customer', 'SalesTerritory','Product', 'ProductCategory',
    'ProductSubcategory')
GO

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%price%'
    OR COLUMN_NAME LIKE '%freight%'
    OR COLUMN_NAME LIKE '%amount%'
    OR COLUMN_NAME LIKE '%amt%'
    OR COLUMN_NAME LIKE '%cost%' 
    OR COLUMN_NAME LIKE '%total%'
    OR COLUMN_NAME LIKE '%qty%'
    OR COLUMN_NAME LIKE '%discount%'
    AND TABLE_NAME IN ('SalesOrderHeader', 'SalesOrderDetail',
    'Customer', 'SalesTerritory','Product', 'ProductCategory',
    'ProductSubcategory')
GO

