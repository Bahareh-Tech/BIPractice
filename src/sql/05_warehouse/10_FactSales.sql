
SELECT *
FROM Sales.SalesOrderHeader
GO
SELECT *
FROM Sales.SalesOrderDetail
GO

CREATE TABLE FactSales
(
    OrderID INT PRIMARY KEY,
    DateKey INT,
    ProductKey INT,
    CustomerKey INT,
    TerritoryKey INT,
    ChannelKey INT,
    OrderQty INT,
    UnitPrice DECIMAL(18, 2),
    LineTotal DECIMAL(18, 2),
    OrderAmount DECIMAL(18, 2),
    )