/*
This Dim is created from Sales.SalesOrderHeader table and OnlineOrderFlag attribute in the Sales schema.
*/

SELECT *
FROM Sales.SalesOrderHeader
GO

CREATE TABLE DimChannel
(
    ChannelKey INT PRIMARY KEY
)
GO