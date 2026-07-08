
/*
The source tables for this Fact are the SalesOrderHeader and SalesOrderDetail tables in the Sales schema. 
Each row in the Fact corresponds to one line item in an order, so the grain of the Fact 
is one row per order line item (one product per order).
Sales.SalesOrderDetail (grain table) : OrderQty, UnitPrice, UnitPriceDiscount, LineTotal
Sales.SalesOrderHeader : OrderDate (DateKey), CustomerID (CustomerKey),
TerritoryID (TerritoryKey), OnlineOrderFlag (ChannelKey)
*/

USE AdventureWorks2022
GO

SELECT *
FROM Sales.SalesOrderHeader
GO
SELECT *
FROM Sales.SalesOrderDetail
GO

USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS FactSales
GO

CREATE TABLE FactSales
(
    SalesKey    INT PRIMARY KEY IDENTITY(1,1),
    SalesOrderIDBK  INT NOT NULL,   -- Business Key - SalesOrderHeader
    SalesOrderDetailIDBK INT NOT NULL,  -- Business Key - SalesOrderDetail
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    TerritoryKey INT NOT NULL,
    ChannelKey INT NOT NULL,
    OrderQty    INT            NOT NULL,
    UnitPrice   DECIMAL(18, 2) NOT NULL,
    UnitPriceDiscount   DECIMAL(18, 2) NOT NULL,  -- discount rate applied to UnitPrice
    LineTotal   DECIMAL(18, 2) NOT NULL   -- = OrderQty * UnitPrice * (1 - UnitPriceDiscount)
)
GO

-- DateKey: most queries filter by a date range — most critical index on the fact table
CREATE NONCLUSTERED INDEX IX_FactSales_DateKey      ON FactSales (DateKey)
GO

-- Remaining FK columns: needed for JOIN performance when reports slice by dimension
CREATE NONCLUSTERED INDEX IX_FactSales_ProductKey   ON FactSales (ProductKey)
GO
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerKey  ON FactSales (CustomerKey)
GO
CREATE NONCLUSTERED INDEX IX_FactSales_TerritoryKey ON FactSales (TerritoryKey)
GO
CREATE NONCLUSTERED INDEX IX_FactSales_ChannelKey   ON FactSales (ChannelKey)
GO

SELECT * FROM FactSales
GO
