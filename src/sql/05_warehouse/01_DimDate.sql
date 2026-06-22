/*
DateKey is stored as YYYYMMDD integer — no IDENTITY needed because the ETL generates
the key deterministically from the date value.
*/
USE AdventureWorks_DW
GO

DROP TABLE IF EXISTS DimDate
GO

/*
Create DimDate table with a surrogate key (DateKey) and various date attributes for 
easy querying and filtering in the data warehouse.
*/
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

-- Populate DimDate with a range of dates (2005-01-01 to 2030-12-31)

DECLARE @StartDate DATE = '2005-01-01';
DECLARE @EndDate   DATE = '2030-12-31';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DimDate (DateKey, [Date], [Year], MonthOfYear, MonthName,
        DayOfMonth, DayName, DayOfWeek, WeekOfYear,
        IsWeekend, [Quarter], QuarterName)
    VALUES (
        CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')),
        @CurrentDate,
        YEAR(@CurrentDate),
        MONTH(@CurrentDate),
        DATENAME(MONTH, @CurrentDate),
        DAY(@CurrentDate),
        DATENAME(WEEKDAY, @CurrentDate),
        DATEPART(WEEKDAY, @CurrentDate),
        DATEPART(WEEK, @CurrentDate),
        CASE WHEN DATENAME(WEEKDAY, @CurrentDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
        DATEPART(QUARTER, @CurrentDate),
        'Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS NVARCHAR(1))
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END
GO

-- Verifying the data was inserted correctly
SELECT 
    COUNT(*) AS TotalRows, 
    MIN([Date]) AS MinDate, 
    MAX([Date]) AS MaxDate 
FROM DimDate;
GO

SELECT * FROM DimDate
GO 
