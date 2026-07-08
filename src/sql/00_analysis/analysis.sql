
-- This query retrieves metadata about the columns in the database, including their names, data types, and other attributes.
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, COLUMN_NAME;

-- This query retrieves metadata about the tables in the database, including their schema and name.
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- This query retrieves metadata about the views in the database, including their schema and name.
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
ORDER BY TABLE_SCHEMA, TABLE_NAME;
-- OR
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'VIEW'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- This query retrieves metadata about the stored procedures in the database, including their schema and name.
SELECT 
    SPECIFIC_SCHEMA, SPECIFIC_NAME  
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY SPECIFIC_SCHEMA, SPECIFIC_NAME;   

-- This query retrieves metadata about the functions in the database, including their schema and name.
SELECT 
    SPECIFIC_SCHEMA, 
    SPECIFIC_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION'
ORDER BY SPECIFIC_SCHEMA, SPECIFIC_NAME;

-- This query retrieves metadata about the constraints in the database, including their name, type, and associated table.
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    CONSTRAINT_NAME, 
    CONSTRAINT_TYPE   
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
ORDER BY TABLE_SCHEMA, TABLE_NAME, CONSTRAINT_NAME; 

-- This query retrieves Schema.TableName for all base tables in the AdventureWorks.
SELECT 
    TABLE_SCHEMA + '.' + TABLE_NAME AS FullTableName
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;



