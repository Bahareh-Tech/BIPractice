/*
The source table for this Dim is the SalesOrderHeader table in the Sales schema, and the OnlineOrderFlag attribute is used to determine the channel.
DimChannel itself is not loaded from that table. It is a static 2-row lookup which is inserted manually:
INSERT INTO DimChannel (ChannelName) VALUES ('Online')
INSERT INTO DimChannel (ChannelName) VALUES ('Reseller')
*/

USE AdventureWorks2022
GO

SELECT *
FROM Sales.SalesOrderHeader
GO

USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS DimChannel
GO

CREATE TABLE DimChannel
(
    ChannelKey  INT PRIMARY KEY IDENTITY(1,1), -- Surrogate Key
    ChannelName NVARCHAR(20) NOT NULL    -- 'Online' or 'Reseller'
)
GO

-- Insert static data for DimChannel
INSERT INTO DimChannel (ChannelName) VALUES ('Reseller');
INSERT INTO DimChannel (ChannelName) VALUES ('Online');
GO

-- Verify: ChannelKey 1 = Reseller, 2 = Online
SELECT * FROM DimChannel
GO
