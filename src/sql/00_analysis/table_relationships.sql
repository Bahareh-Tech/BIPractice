
-- 1. Identify foreign key relationships 

SELECT
    FK.TABLE_SCHEMA AS FK_Schema,
    FK.TABLE_NAME AS FK_Table,
    CU.COLUMN_NAME AS FK_Column,
    PK.TABLE_SCHEMA AS PK_Schema,
    PK.TABLE_NAME AS PK_Table,
    PT.COLUMN_NAME AS PK_Column
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS RC
JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS FK
  ON RC.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS PK
  ON RC.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS CU
  ON RC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS PT
  ON PT.CONSTRAINT_NAME = PK.CONSTRAINT_NAME
WHERE FK.TABLE_NAME IN ('SalesOrderHeader', 'SalesOrderDetail',
    'Customer', 'SalesTerritory','Product', 'PProductCategory',
    'ProductSubcategory') OR PK.TABLE_NAME IN ('SalesOrderHeader', 
    'SalesOrderDetail', 'Customer', 'SalesTerritory','Product', 
    'PProductCategory', 'ProductSubcategory')
ORDER BY FK.TABLE_SCHEMA, FK.TABLE_NAME, CU.COLUMN_NAME;



/*
Customer Table (the referenced table):
CustomerID (Primary Key)  CustomerName
1                        Alice
2                        Bob

Order Table (the referencing table):
OrderID    CustomerID (Foreign Key)    OrderAmount
101        1                           $100
103        2                           $50

Order references Customer: The Order table has a foreign key that points to Customer table
Referencing table (Order) references referenced table (Customer)
Order is the referencing table (it has the FK)
Customer is the referenced table (it has the PK)
Order has a reference to Customer (through the CustomerID foreign key)
Customer is referenced by Order (through the CustomerID primary key)
Order table references Customer table (via FK CustomerID → PK CustomerID)
Customer table is referenced by Order table
*/

-- 2. Identify many-to-many relationships 

-- Identify tables with multiple foreign keys (potential junction tables)
-- Tables with 2+ FKs may be many-to-many bridges
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COUNT(*) AS FK_Count
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'FOREIGN KEY' AND 
    TABLE_NAME IN ('SalesOrderHeader', 'SalesOrderDetail',
    'Customer', 'SalesTerritory','Product', 'ProductCategory',
    'ProductSubcategory') 
GROUP BY TABLE_SCHEMA, TABLE_NAME
HAVING COUNT(*) > 1
ORDER BY FK_Count DESC;

-- OR

SELECT
    t.name AS TableName,
    COUNT(DISTINCT c.column_id) AS TotalColumns,
    COUNT(DISTINCT fkc.parent_column_id) AS FKColumns
FROM sys.tables t
JOIN sys.columns c
    ON t.object_id = c.object_id
LEFT JOIN sys.foreign_key_columns fkc
    ON t.object_id = fkc.parent_object_id
GROUP BY t.name
HAVING COUNT(DISTINCT fkc.parent_column_id) >= 2
ORDER BY FKColumns DESC;

/*

A one-to-many (1:M) relationship means:
One row in parent table & Many related rows in child table.
Usually this is directly visible from a foreign key.

A many-to-many (M:N) relationship means:  
Many rows in parent table & Many related rows in child table
This is not directly visible from foreign keys.
Many-to-many relationships are implemented via a junction table that has two or more foreign keys.
For example, if you have a junction table that has two foreign keys, each referencing a different parent table,
then you can infer that there is a many-to-many relationship between those two parent tables.
For example, if you have a junction table called OrderProduct that has two foreign keys, one
referencing the Order table and another referencing the Product table, then you can infer that
there is a many-to-many relationship between Order and Product.
This means that one order can have many products, and one product can be in many orders.  

The real sign of a many-to-many table:
1. It connects two parents via foreign keys (Shows that it references multiple parent tables and is likely a junction table)
2. Its foreign keys are also its primary keys (It has a composite primary key made from those foreign keys)
3. It has few or no descriptive attributes (it’s mostly relationship columns, in the fraction of columns that are FKs, and little/no descriptive attributes)
4. It has a name that suggests it’s a bridge (e.g. OrderProduct, StudentCourse, etc.)
5. It has a large number of rows (because it’s connecting many-to-many relationships)
6. It has no natural business key (because it’s just a bridge)
7. It has no surrogate key (because the composite key is sufficient to uniquely identify rows)

When inspecting a table with multiple FKs, ask:
Does this table mainly STORE an entity/event? one-to-many
Or
Does this table mainly CONNECT entities? many-to-many

Transaction/entity table usually contains:
dates
amounts
statuses
descriptions
measures

Bridge/junction table usually contains:
mostly foreign keys
composite PK
little/no business attributes

*/
-- 3. Document relationships in markdown format

/*
This creates your join map for Phase 2 warehouse design
The query in step 1 returns the complete join map: which foreign key columns
in which tables reference which primary key columns in which tables. 
This is exactly what is needed for Phase 1 to document table relationships and
later for Phase 2 to design star schema joins.
*/

SELECT * FROM Production.BillOfMaterials
