# ETL Design

## Goal
Load the warehouse from AdventureWorks using SSIS-based ETL.

## Suggested Layers
- source: AdventureWorks
- staging: `stg`
- warehouse: `dw`

## ETL Flow
1. extract source data
2. load staging tables
3. clean and transform
4. load dimensions
5. load fact table
6. validate row counts and totals

## Validation Ideas
- compare source and target totals
- compare row counts
- verify foreign key coverage
- check null handling

## Load Order

The load sequence must follow this order to satisfy foreign key dependencies:

1. **Pre-load** — run `01_DimDate.sql` manually once to populate `DimDate` for the full date range (2005–2030). This is a script-based load, not an SSIS package.
2. **S1 — Load Staging** — all `S1_LoadStaging_*.dtsx` packages extract raw data from AdventureWorks into the staging database. These are independent of each other and can run in parallel.
3. **S2 — Clean Staging** — `S2_CleanStaging_*.dtsx` packages apply data quality rules and fix known issues in staging before warehouse load.
4. **S3 — Load Dimensions** — dimensions must be loaded before the fact table:
   - `s3_LoadDimProduct.dtsx`
   - `s3_LoadDimCustomer.dtsx`
   - `s3_LoadDimTerritory.dtsx`
   - `DimChannel` is populated manually (2 static rows — no SSIS package needed)
5. **S4 — Load Fact** — `s3_LoadFactSales.dtsx` runs last; performs surrogate key lookups against all four dimensions.

The `Master.dtsx` package orchestrates steps 2–5 in the correct sequence with precedence constraints.

---

## Rerun Strategy

All warehouse loads use a **truncate-and-reload** approach:
- Each load package truncates the target table before inserting
- This keeps the logic simple and avoids duplicate key issues
- Suitable for this dataset size (121K fact rows loads in seconds)
- For larger datasets, a delta/incremental load using `OrderDate` watermarking would be the next step

**To rerun the full ETL**: execute `Master.dtsx`. It handles the full sequence from staging through fact load.



## Error Handling

### S2 — Clean Staging
- Each S2 cleaning package routes invalid rows to a **dedicated error table** per entity (`stg_Product_Error`, `stg_Person_Error`, `stg_SalesOrderHeader_Error`, `stg_SalesOrderDetail_Error`)
- After cleaning, each package logs a summary row to the shared `stg_ETL_log` table (`PackageName`, `StageTableName`, `ValidRows`, `ErrorRows`, `LoadDate`) so the outcome of every run is visible in one place

### S3 — Load Dimensions & Fact
- The warehouse load packages use SSIS **Lookup** components in redirect-on-no-match mode
- Rows where a surrogate key lookup fails (e.g., a `ProductID` not found in `DimProduct`) are routed to the shared `stg_errors_Lookup` table (`PackageName`, `LookupStep`, `FailedKeyName`, `FailedKeyValue`) rather than failing the package
- A single `stg_errors_Lookup` table covers all S3 packages — no separate table per dimension

After each full run, row counts in the validation scripts (`src/ssis/validation/row_counts.sql`) confirm expected volumes.
