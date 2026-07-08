# ETL — SSIS

ETL load scripts for dimensions and facts are implemented using SSIS (SQL Server Integration Services).

## Project

The SSIS solution lives in `etl/`.

## Contents
- `etl/` — single SSIS project containing all packages
- `validation/` — validation SQL scripts and checks

## Package Naming Convention
All packages live in the one `etl/` project, prefixed by stage:
| Prefix | Stage | Example |
|---|---|---|
| `s1_` | Extract source → staging | `s1_LoadStaging_Product.dtsx` |
| `s2_` | Clean & validate staging | `s2_CleanStaging_Product.dtsx` |
| `s3_` | Load warehouse | `s3_LoadDimProduct.dtsx`, `s3_LoadFactSales.dtsx` |
| *(none)* | Orchestration | `Master.dtsx` |

## Load Order
1. All `s1_` packages (staging extract)
2. All `s2_` packages (staging clean)
3. `s3_LoadDim*.dtsx` packages (dimensions)
4. `s3_LoadFactSales.dtsx` (fact table — must run last)

## Notes
- Source connection: `AdventureWorks_DB.conmgr`
- Staging connection: `AdventureWorks_Staging.conmgr`
- Warehouse connection: `AdventureWorks_DW.conmgr`
- Record any assumptions or known issues per package in the relevant `.dtsx` package
