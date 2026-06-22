# ETL — SSIS

ETL load scripts for dimensions and facts are implemented using SSIS (SQL Server Integration Services).

## Project

The SSIS solution lives in `etl/`.

## Contents
- `etl/` — SSIS project with packages for loading staging, dimensions, and fact tables

## Load Order
1. Staging tables (from AdventureWorks source)
2. Dimensions (DimDate, DimProduct, DimCustomer, DimTerritory, DimChannel)
3. Fact table (FactSales)

## Notes
- Source connection: `AdventureWorks_DB.conmgr`
- Staging connection: `AdventureWorks_Staging.conmgr`
- Warehouse connection: `AdventureWorks_DW.conmgr`
- Record any assumptions or known issues per package in the relevant `.dtsx` package
