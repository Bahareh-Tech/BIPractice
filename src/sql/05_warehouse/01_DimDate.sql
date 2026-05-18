/*
DateKey is stored as YYYYMMDD integer — no IDENTITY needed because the ETL generates
the key deterministically from the date value.
*/
USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS DimDate
GO

CREATE TABLE DimDate
(
    DateKey INT PRIMARY KEY,   -- YYYYMMDD natural key
    [Date]  DATE NOT NULL,
    [Year]  SMALLINT NOT NULL,
    MonthOfYear TINYINT NOT NULL,
    MonthName   NVARCHAR(10) NOT NULL,    -- January, February ...
    DayOfMonth TINYINT NOT NULL,
    DayName NVARCHAR(10) NOT NULL,      -- Monday, Tuesday ...
    DayOfWeek   TINYINT      NOT NULL,      -- 1 = Monday, 7 = Sunday
    WeekOfYear  TINYINT      NOT NULL,
    IsWeekend   BIT          NOT NULL,       -- 1 = Saturday or Sunday
    [Quarter]   TINYINT      NOT NULL,      -- 1–4
    QuarterName NVARCHAR(6)  NOT NULL      -- Q1, Q2, Q3, Q4
)
GO

SELECT * FROM DimDate
GO 

/*
SELECT 
    CONVERT(INT, FORMAT([Date], 'yyyyMMdd')) AS DateKey, 
    YEAR(OrderDate) AS [Year], 
    MONTH(OrderDate) AS MonthOfYear, -- or DATEPART(MM, OrderDate) AS MonthOfYear
    DATENAME(MM, OrderDate) AS MonthName,
    DAY(OrderDate) AS DayOfMonth, -- or DATEPART(DD, OrderDate) AS DayOfMonth
    DATENAME(DW, OrderDate) AS DayName,
    DATEPART(DW, OrderDate) AS DayOfWeek,
    DATEPART(WK, OrderDate) AS WeekOfYear,
    CASE WHEN DATENAME(DW, OrderDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS IsWeekend,
    DATEPART(QUARTER, OrderDate) AS [Quarter],
    'Q' + CAST(DATEPART(QUARTER, OrderDate) AS NVARCHAR(1)) AS QuarterName
FROM Sales.SalesOrderHeader
GO
*/