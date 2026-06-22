# Warehouse Design

## Goal
Design a simple reporting model based on a star schema.

## Proposed Tables
### Dimensions
- `DimDate`
- `DimProduct`
- `DimCustomer`
- `DimTerritory`

### Fact
- `FactSales`

## Design Notes

**Grain of `FactSales`**: one row per sales order line (`SalesOrderID` + `SalesOrderDetailID`). This is the lowest granularity available in the source and supports all required business questions without pre-aggregation.

**Surrogate keys**: all dimension tables use an integer identity surrogate key (`ProductKey`, `CustomerKey`, etc.) as the join column in `FactSales`. Business keys (e.g., `ProductIDBK`, `CustomerIDBK`) are retained in dimensions for traceability.

**DimChannel**: a static two-row lookup table (Online / Reseller) derived from `SalesOrderHeader.OnlineOrderFlag`. Populated manually via INSERT — not loaded by SSIS.

**DimDate**: pre-generated via T-SQL script (`01_DimDate.sql`) covering 2005-01-01 to 2030-12-31. Must be loaded before any ETL packages run.

**DimProduct scope**: only products that appear in `SalesOrderDetail` are loaded (295 of 504 source products). Products with no sales history are excluded by design.

## Hierarchies

| Dimension | Hierarchy | Levels |
|---|---|---|
| DimDate | Calendar | Year → Quarter → Month → Date |
| DimProduct | Product | Category → Subcategory → Product |
| DimTerritory | Geography | Group → Country → Territory |

## Source-to-Target Mapping

### DimProduct

| Source Table | Source Column | Transformation | Target Table | Target Column | Notes |
|---|---|---|---|---|---|
| `Production.Product` | `ProductID` | none | `DimProduct` | `ProductIDBK` | Business key |
| `Production.Product` | `ProductNumber` | none | `DimProduct` | `ProductNumber` | |
| `Production.Product` | `Name` | none | `DimProduct` | `ProductName` | |
| `Production.ProductSubcategory` | `Name` | JOIN via `Product.ProductSubcategoryID` | `DimProduct` | `ProductSubcategory` | NULL if product has no subcategory |
| `Production.ProductCategory` | `Name` | JOIN via `ProductSubcategory.ProductCategoryID` | `DimProduct` | `ProductCategory` | NULL if product has no subcategory |
| `Production.Product` | `Color` | none | `DimProduct` | `Color` | nullable |
| `Production.Product` | `ListPrice` | none | `DimProduct` | `ListPrice` | |

### DimCustomer
| Source Table | Source Column | Transformation | Target Table | Target Column | Notes |
|---|---|---|---|---|---|
| `Sales.Customer` | `CustomerID` | none | `DimCustomer` | `CustomerIDBK` | business key |
| `Person.Person` | `FirstName`, `LastName` | `FirstName + ' ' + LastName`, JOIN via `Customer.PersonID = Person.BusinessEntityID` | `DimCustomer` | `CustomerName` | where `PersonID` is not null |
| `Sales.Store` | `Name` | JOIN via `Customer.StoreID = Store.BusinessEntityID` | `DimCustomer` | `CustomerName` | where `StoreID` is not null |
| `Sales.Customer` | `PersonID`, `StoreID` | `CASE WHEN PersonID IS NOT NULL THEN 'Individual' ELSE 'Store' END` | `DimCustomer` | `CustomerType` |
| `Sales.Customer` | `AccountNumber` | none | `DimCustomer` | `AccountNumber` | nullable |

### DimTerritory
| Source Table | Source Column | Transformation | Target Table | Target Column | Notes |
|---|---|---|---|---|---|
| `Sales.SalesTerritory` | `TerritoryID` | none | `DimTerritory` | `TerritoryIDBK` |
| `Sales.SalesTerritory` | `Name` | none | `DimTerritory` | `TerritoryName` |
| `Person.CountryRegion` | `Name` | JOIN via `CountryRegion.CountryRegionCode` + CountryRegion.Name | `DimTerritory` | `TerritoryCountry` |
| `Sales.SalesTerritory` | `Group` | none | `DimTerritory` | `TerritoryGroup` |

### DimChannel
| Source Table | Source Column | Transformation | Target Table | Target Column | Notes |
|---|---|---|---|---|---|
| `Sales.SalesOrderHeader` | `OnlineOrderFlag` | inserted manually | `DimChannel` | `ChannelName` | it is a static 2-row lookup which is inserted manually and not loaded from source table |

### DimDate
| Source Table | Source Column | Transformation | Target Table | Target Column | Notes |
|---|---|---|---|---|---|
| `-` | `-` | `CONVERT(INT, FORMAT([Date], 'yyyyMMdd'))` | `DimDate` | `DateKey` | YYYYMMDD natural key — derived from `[Date]` column |
| `-` | `-` | T-SQL generated date series (see `src/sql/05_warehouse/01_DimDate.sql`) — covers 2005-01-01 to 2030-12-31 | `DimDate` | `[Date]` | Pre-load with SQL script **before** running any ETL packages |
| `-` | `-` | `YEAR([Date])` | `DimDate` | `DateYear` | |
| `-` | `-` | `MONTH([Date])` | `DimDate` | `MonthOfYear` | |
| `-` | `-` | `DATENAME(MM, [Date])` | `DimDate` | `MonthName` | |
| `-` | `-` | `DAY([Date])` | `DimDate` | `DayOfMonth` | |
| `-` | `-` | `DATENAME(DW, [Date])` | `DimDate` | `DayName` | |
| `-` | `-` | `DATEPART(DW, [Date])` | `DimDate` | `DayOfWeek` | |
| `-` | `-` | `DATEPART(WK, [Date])` | `DimDate` | `WeekOfYear` | |
| `-` | `-` | `DATEPART(QUARTER, [Date])` | `DimDate` | `[Quarter]` | |
| `-` | `-` | `'Q' + CAST(DATEPART(QUARTER, [Date]) AS NVARCHAR(1))` | `DimDate` | `QuarterName` | |
| `-` | `-` | `CASE WHEN DATENAME(DW, [Date]) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END` | `DimDate` | `IsWeekend` | |

### FactSales
| Source Table | Source Column | Transformation | Target Table | Target Column | Notes |
|---|---|---|---|---|---|
| `Sales.SalesOrderHeader` | `SalesOrderID` | none | `FactSales` | `SalesOrderIDBK` | business key |
| `Sales.SalesOrderDetail` | `SalesOrderDetailID` | none | `FactSales` | `SalesOrderDetailIDBK` | business key |
| `Sales.SalesOrderHeader` | `OrderDate` | `CONVERT(INT, FORMAT(OrderDate,'yyyyMMdd'))` - lookup `DimDate.DateKey` | `FactSales` | `DateKey` | FK - DimDate |
| `Sales.SalesOrderDetail` | `ProductID` | lookup `DimProduct.ProductKey` via `ProductIDBK` | `FactSales` | `ProductKey` | FK - DimProduct |
| `Sales.SalesOrderHeader` | `CustomerID` | lookup `DimCustomer.CustomerKey` via `CustomerIDBK` | `FactSales` | `CustomerKey` | FK - DimCustomer |
| `Sales.SalesOrderHeader` | `TerritoryID` | lookup `DimTerritory.TerritoryKey` via `TerritoryIDBK` | `FactSales` | `TerritoryKey` | FK - DimTerritory |
| `Sales.SalesOrderHeader` | `OnlineOrderFlag` | `CASE WHEN OnlineOrderFlag = 1 THEN 1 ELSE 2 END` → lookup `DimChannel.ChannelKey` | `FactSales` | `ChannelKey` | FK - DimChannel |
| `Sales.SalesOrderDetail` | `OrderQty` | none | `FactSales` | `OrderQty` | measure |
| `Sales.SalesOrderDetail` | `UnitPrice` | none | `FactSales` | `UnitPrice` | measure |
| `Sales.SalesOrderDetail` | `UnitPriceDiscount` | none | `FactSales` | `UnitPriceDiscount` | measure |
| `Sales.SalesOrderDetail` | `LineTotal` | none | `FactSales` | `LineTotal` | measure |


