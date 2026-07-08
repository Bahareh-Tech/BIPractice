# Validation Report

**Project**: AdventureWorks Sales BI  
**Database**: AdventureWorks_DW  
**Validation Date**: 2026-05-28  
**Status**: PASSED (with documented variance)



## Summary

| Check | Result | Notes |
|---|---|---|
| FactSales row count | PASS | 121,317 rows — exact match |
| DimCustomer row count | PASS | 19,820 rows — exact match |
| DimTerritory row count | PASS | 10 rows — exact match |
| DimProduct row count | EXPECTED DIFF | 295 DW vs 504 OLTP — by design (see §2) |
| FK integrity — all dimensions | PASS | 0 orphaned rows across all 5 keys |
| NULL surrogate keys | PASS | 0 NULLs in any key column |
| Total revenue variance | PASS | $267.50 variance (0.0002%) — rounding (see §3) |
| Year distribution (2011–2014) | PASS | All 4 years present, line counts match |
| DateKey range | PASS | 20110531 – 20140630, 0 out-of-range rows |
| Channel completeness | PASS | Online 49.79% + Reseller 50.21% = 100% |
| Negative prices / quantities | PASS | 0 rows |
| Duplicate fact rows | PASS | 0 duplicate (OrderID, DetailID) pairs |
| Performance — all 5 queries | PASS | All completed in < 500 ms |



## 1. Row Count Validation

| Layer | Table | Count |
|---|---|---|
| OLTP | Sales.SalesOrderDetail | 121,317 |
| Warehouse | FactSales | 121,317 |
| OLTP | Sales.Customer | 19,820 |
| Warehouse | DimCustomer | 19,820 |
| OLTP | Sales.SalesTerritory | 10 |
| Warehouse | DimTerritory | 10 |
| OLTP | Production.Product | 504 |
| Warehouse | DimProduct | 295 |

**DimProduct difference (504 → 295)**: By design. The ETL loads only products that appear in `SalesOrderDetail` (products with actual sales history). The remaining 209 products exist in the catalog but have never been ordered, making them irrelevant for sales analytics. No data loss has occurred.



## 2. Foreign Key Integrity

All surrogate key checks returned **0 orphaned rows**:

| Check | Orphan Count |
|---|---|
| ProductKey not in DimProduct | 0 |
| CustomerKey not in DimCustomer | 0 |
| TerritoryKey not in DimTerritory | 0 |
| ChannelKey not in DimChannel | 0 |
| DateKey not in DimDate | 0 |

NULL key checks also returned **0 rows** for all 5 keys.



## 3. Business Rule Validation

### Revenue totals

| Layer | Total Revenue |
|---|---|
| OLTP (SalesOrderDetail) | $109,846,381.40 |
| Warehouse (FactSales) | $109,846,113.90 |
| **Variance** | **$267.50 (0.0002%)** |

**Root cause**: The OLTP `LineTotal` is a computed column stored with 6 decimal places. The warehouse `LineTotal` is `DECIMAL(18,2)` — values are rounded on insert. The $267.50 total variance is the sum of per-row rounding differences across 121,317 rows. This is **acceptable and expected**.

### Year-by-year breakdown

| Year | OLTP Revenue | Warehouse Revenue | Variance |
|---|---|---|---|
| 2011 | $12,641,672.21 | $12,641,648.05 | $24.16 |
| 2012 | $33,524,301.32 | $33,524,206.35 | $94.97 |
| 2013 | $43,622,479.05 | $43,622,365.13 | $113.92 |
| 2014 | $20,057,928.81 | $20,057,894.37 | $34.44 |

All variances are consistent with the DECIMAL rounding explanation above.

### Date range

- Minimum DateKey: **20110531** (May 31, 2011)
- Maximum DateKey: **20140630** (June 30, 2014)
- Out-of-range rows: **0**

### Channel split

| Channel | Lines | % of Total |
|---|---|---|
| Reseller | 60,919 | 50.21% |
| Online | 60,398 | 49.79% |
| **Total** | **121,317** | **100.00%** |

### Data quality

- Negative UnitPrice or OrderQty: **0 rows**
- Duplicate (SalesOrderID, SalesOrderDetailID) pairs: **0 rows**



## 4. Reconciliation

### Territory revenue (warehouse)

| Territory | Group | Revenue |
|---|---|---|
| Southwest | North America | $24,184,550.88 |
| Canada | North America | $16,355,721.43 |
| Northwest | North America | $16,084,908.27 |
| Australia | Pacific | $10,655,324.98 |
| Central | North America | $7,908,984.36 |
| Southeast | North America | $7,879,629.62 |
| United Kingdom | Europe | $7,670,705.26 |
| France | Europe | $7,251,540.56 |
| Northeast | North America | $6,939,349.32 |
| Germany | Europe | $4,915,399.22 |

All 10 OLTP territories are present in DimTerritory. No territory missing from warehouse.



## 5. Performance Test Results

All 5 reporting queries were run against `AdventureWorks_DW` using `SET STATISTICS TIME ON`. Execution times on a local SQL Server 2022 instance:

| Query | Description | Result Rows | Elapsed |
|---|---|---|---|
| Test 1 | Monthly revenue trend | 48 | < 50 ms |
| Test 2 | Top 10 products by revenue | 10 | < 50 ms |
| Test 3 | Territory revenue breakdown | 10 | < 50 ms |
| Test 4 | Year-over-year comparison | 4 | < 50 ms |
| Test 5 | Channel revenue split | 2 | < 50 ms |

All queries completed well under the 1-second threshold. Existing nonclustered indexes on `DateKey`, `ProductKey`, `CustomerKey`, `TerritoryKey`, and `ChannelKey` are sufficient for this data volume. No additional indexes required.



## 6. Known Limitations and Assumptions

| Item | Detail |
|---|---|
| Source of truth | OLTP is the source of truth. Any difference between OLTP and DW must be explained. |
| Revenue variance | $267.50 total variance is caused by DECIMAL rounding (OLTP: 6 d.p. → DW: 2 d.p.) and is accepted. |
| DimProduct scope | Only products with sales history are loaded. The 209 un-sold products are intentionally excluded. |
| DimDate coverage | Populated 2005-01-01 to 2030-12-31. All FactSales DateKeys fall within this range. |
| SCD strategy | SCD Type 1 (overwrite) is used for all dimensions. Historical attribute changes are not tracked. |
| ETL bug (resolved) | `s3_LoadFactSales.dtsx` initially used `YEAR × 1000` instead of `YEAR × 10000` for DateKey. Fixed and reloaded. |
| Manual load | DimDate and DimChannel were manually seeded via SQL scripts, not SSIS packages. |
