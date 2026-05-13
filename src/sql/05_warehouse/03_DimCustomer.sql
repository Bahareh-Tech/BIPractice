/*
This Dim is created from Customer table in the Sales schema. 
*/

SELECT *
FROM Sales.Customer
GO
SELECT *
FROM Sales.SalesOrderHeader
GO

CREATE TABLE DimCustomer
(
    CustomerKey INT PRIMARY KEY,
    CustomerIDBK INT, -- Business Key
    CustomerName NVARCHAR(255)
)
GO