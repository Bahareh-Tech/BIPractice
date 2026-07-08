----------- Phase 1: Data Profiling -----------

-- profiling the SalesOrderHeader table

SELECT 
    COUNT(*)
FROM SALES.SalesOrderHeader;
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesOrderHeader';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, TC.CONSTRAINT_TYPE, CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
ON TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'SalesOrderHeader';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Sales';
DECLARE @table SYSNAME = 'SalesOrderHeader';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema
    AND TABLE_NAME = @table
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

-- profiling the SalesOrderDetail table

SELECT 
    COUNT(*)
FROM SALES.SalesOrderDetail;
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesOrderDetail';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
ON TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'SalesOrderDetail';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Sales';
DECLARE @tableName SYSNAME = 'SalesOrderDetail';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema
    AND TABLE_NAME = @tableName
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

-- profiling the Customer table

SELECT 
    COUNT(*)
FROM Sales.Customer;
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
ON CCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'Customer';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Sales'; 
DECLARE @tableName SYSNAME = 'Customer';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema
    AND TABLE_NAME = @tableName;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

SELECT 
    COUNT(*)
FROM Sales.SalesTerritory;
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesTerritory';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON CCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'SalesTerritory';    
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Sales';
DECLARE @tableName SYSNAME = 'SalesTerritory';
DECLARE @sql NVARCHAR(MAX) = N'';   

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema
    AND TABLE_NAME = @tableName
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

-- profiling the Product table
SELECT 
    COUNT(*)
FROM Production.Product;   
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Product';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON CCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'Product';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Production';
DECLARE @tableName SYSNAME = 'Product';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema    
    AND TABLE_NAME = @tableName    
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

-- profiling the ProductCategory table
SELECT 
    COUNT(*)
FROM Production.ProductCategory;
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ProductCategory';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON CCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'ProductCategory';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Production';
DECLARE @tableName SYSNAME = 'ProductCategory';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema    
    AND TABLE_NAME = @tableName    
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

--- profiling the ProductSubcategory table
SELECT 
    COUNT(*)
FROM Production.ProductSubcategory;
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ProductSubcategory';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON CCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'ProductSubcategory';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Production';
DECLARE @tableName SYSNAME = 'ProductSubcategory';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema    
    AND TABLE_NAME = @tableName    
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO

--- profiling the Person table
SELECT 
    COUNT(*)
FROM Person.Person; 
GO

-- columns and data types
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Person';
GO

-- primary key and foreign key constraints
SELECT 
    CCU.COLUMN_NAME, 
    TC.CONSTRAINT_TYPE, 
    CCU.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON CCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
WHERE TC.TABLE_NAME = 'Person';
GO

-- count of null values in each column
DECLARE @schema SYSNAME = 'Person';
DECLARE @tableName SYSNAME = 'Person';
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql +=
    'SELECT ' + QUOTENAME(COLUMN_NAME, '''') + ' AS ColumnName, '
    + 'COUNT(*) AS NullCount FROM '
    + QUOTENAME(@schema) + '.' + QUOTENAME(@tableName) + ' '
    + 'WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @schema    
    AND TABLE_NAME = @tableName    
ORDER BY ORDINAL_POSITION;

SET @sql = LEFT(@sql, LEN(@sql) - LEN(' UNION ALL ')); -- The final string ends with an extra 'UNION ALL', this removes the trailing ' UNION ALL '

EXEC sp_executesql @sql;
GO


