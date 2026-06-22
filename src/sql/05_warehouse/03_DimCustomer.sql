/*
The source tables for this Dim are the Customer table in the Sales schema, the Store table in the Sales schema, and the Person table in the Person schema.
*/

USE AdventureWorks2022
GO

SELECT *
FROM Sales.Customer
GO
SELECT *
FROM Person.Person
GO
SELECT *
FROM Sales.Store
GO

USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS DimCustomer
GO
CREATE TABLE DimCustomer
(
    CustomerKey  INT PRIMARY KEY IDENTITY(1,1), -- Surrogate Key
    CustomerIDBK INT          NOT NULL,         -- Business Key
    CustomerName NVARCHAR(255) NOT NULL,        -- Person full name OR store name
    CustomerType NVARCHAR(20) NOT NULL,         -- 'Individual' or 'Store'
    DimRowHash   NVARCHAR(64) NOT NULL          -- SHA2_256 hash of all attribute columns; used by SCD Check Lookup to detect changes (SCD Type 1)
)
GO

-- ETL uses this to look up the surrogate key from the source business key
CREATE NONCLUSTERED INDEX IX_DimCustomer_CustomerIDBK ON DimCustomer (CustomerIDBK)
GO

SELECT * FROM DimCustomer
GO




