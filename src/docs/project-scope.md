# Project Scope

## Project Title
AdventureWorks Sales BI Project

## Scenario
AdventureWorks management wants a better sales reporting solution. The source database is transactional and not suited for analytics. This project builds an end-to-end BI pipeline — from source exploration through to an interactive Power BI dashboard — simulating the work of a junior BI developer.

## Objectives
- Explore and profile the AdventureWorks source database
- Design and build a star schema data warehouse
- Implement a full ETL pipeline using SSIS
- Develop a Power BI dashboard to answer business questions

## Scope

### Included
- source system exploration and data profiling
- reusable reporting SQL (views, stored procedures, ad-hoc queries)
- star schema design (5 dimensions + 1 fact table)
- SSIS-based ETL (staging → cleaning → warehouse load)
- Power BI dashboard (5 report pages, 10 DAX measures)

### Out of Scope
- advanced OLAP cube development
- enterprise orchestration or scheduling infrastructure
- SCD Type 2 (full history tracking)
- advanced performance tuning

## Stakeholders

| Stakeholder | Reporting Need |
|---|---|
| Sales Manager | Monthly and territory sales performance |
| Product Manager | Category and product revenue analysis |
| Finance | Revenue totals, trends, and year-over-year comparisons |

## Business Questions
1. What are total sales by month and year?
2. Which product categories generate the most revenue?
3. Who are the top 10 customers by total sales?
4. Which sales territories perform best?
5. What is the average order value and how does it trend over time?
6. Which products have the highest revenue vs highest order volume?
7. How does sales performance compare year-over-year?
8. What share of revenue comes from the top 20% of customers?
9. Which months show seasonal peaks in sales?
10. What is the revenue split between online and reseller channels?

## Architecture

Three-layer data architecture:

```
AdventureWorks (OLTP)  →  AdventureWorks_Staging  →  AdventureWorksDW (Star Schema)  →  Power BI
```

| Layer | Database | Purpose |
|---|---|---|
| Source | `AdventureWorks` | Production OLTP — read only |
| Staging | `AdventureWorks_Staging` | Raw copy of source; data quality checks and cleaning |
| Warehouse | `AdventureWorksDW` | Star schema optimised for analytics |

See [architecture-flow.drawio](../diagrams/architecture-flow.drawio) for the full diagram.

---

## Phases

### Phase 1 — Source Analysis & Data Quality Assessment

Explored the AdventureWorks database to understand structure, relationships, and data quality before any design work began.

**Key activities**
- Inventoried all 71 base tables across Sales, Production, and Person schemas
- Profiled core tables for row counts, NULLs, date ranges, and duplicate checks
- Mapped foreign key relationships between sales, customer, product, and territory tables
- Documented business meaning of each key table and its role in answering the business questions

**Outputs**: `src/sql/00_analysis/` — profiling and quality check scripts; `src/docs/source-analysis.md`

---

### Phase 2 — Warehouse Design

Designed a star schema to organise cleaned data for analytics reporting.

**Key decisions**
- Grain of `FactSales`: one row per sales order line (`SalesOrderID` + `SalesOrderDetailID`)
- Surrogate integer keys used for all dimension joins; business keys retained for traceability
- `DimDate` pre-generated via T-SQL script (2005–2030); not sourced from OLTP tables
- `DimChannel` is a static two-row lookup (Online / Reseller) — no ETL package needed
- SCD Type 1 used throughout (overwrite on update); Type 2 out of scope for this project

**Schema**: 5 dimensions (`DimDate`, `DimProduct`, `DimCustomer`, `DimTerritory`, `DimChannel`) + `FactSales`

**Outputs**: `src/sql/05_warehouse/` — DDL scripts; `src/docs/warehouse-design.md`; `src/diagrams/star-schema.drawio`

---

### Phase 3 — ETL Implementation (SSIS)

Built a three-stage ETL pipeline to load data from AdventureWorks into the warehouse.

**Load sequence**
1. **S1 — Extract to Staging**: 10 SSIS packages extract raw source tables into `AdventureWorks_Staging`
2. **S2 — Clean Staging**: 3 packages apply data quality rules; invalid rows redirected to error tables
3. **S3 — Load Warehouse**: Dimension packages load `DimProduct`, `DimCustomer`, `DimTerritory`; fact package resolves all surrogate key lookups and loads `FactSales`
4. **Master.dtsx** orchestrates the full sequence with precedence constraints

All packages use truncate-and-reload; `Master.dtsx` handles full re-runs safely.

**Outputs**: `src/ssis/etl/AdventureWorks_ETL/`; `src/docs/etl-design.md`

---

### Phase 4 — Validation & Testing

Verified that warehouse data matched the source and met all business rules.

**Checks performed**

| Check | Result |
|---|---|
| FactSales row count vs source | PASS — 121,317 exact match |
| DimCustomer row count | PASS — 19,820 exact match |
| FK integrity (all 5 keys) | PASS — 0 orphaned rows |
| Total revenue variance | PASS — $267.50 (0.0002%) rounding only |
| Negative prices / quantities | PASS — 0 rows |
| Duplicate fact rows | PASS — 0 duplicates |
| All reporting queries | PASS — < 500 ms each |

**Outputs**: `src/ssis/validation/`; `src/docs/validation-report.md`

---

### Phase 5 — Power BI Dashboard

Built an interactive dashboard on top of the warehouse to answer all 10 business questions.

**Report pages**

| Page | Key Visuals |
|---|---|
| Sales Performance | Monthly trend, KPI cards (Total Sales, Orders, AOV), territory bar chart |
| Product & Category Analysis | Revenue by category/subcategory, top products by revenue vs volume |
| Customer & Territory Insights | Top 10 customers, Top 20% revenue share, channel donut |
| Seasonal & YoY Analysis | Sales growth %, YoY matrix, monthly AOV trend |
| Channel Performance | Online vs Reseller revenue split |

10 DAX measures cover all business questions. `DimDate` is marked as the Date Table for time intelligence.

**Outputs**: `src/powerbi/measures.md`; `src/powerbi/screenshots/`

---

### Phase 6 — Documentation & Portfolio Polish

Finalised all documentation and prepared the repository for portfolio presentation.

**Activities**
- Polished root `README.md` with architecture overview, validation summary, and embedded screenshots
- Completed all `src/docs/` files — filled in ETL load order, rerun strategy, error handling, report design decisions, and warehouse hierarchy definitions
- Created `src/diagrams/architecture-flow.drawio` — end-to-end data flow diagram
- Confirmed star schema diagram reflects the final built model
- Added all 5 Power BI report page screenshots

**Outputs**: `README.md`; `src/docs/`; `src/diagrams/`; `src/powerbi/screenshots/`

---

## Getting Started Checklist

**Pre-Setup**:
- [ ] Install VS Code and recommended extensions (SQL Server mssql, Git Graph, Markdown Preview Enhanced)
- [ ] Install Visual Studio with SQL Server Data Tools (for SSIS)
- [ ] Install Power BI Desktop
- [ ] Ensure SQL Server and AdventureWorks are installed and accessible

**Phase 1**:
- [ ] Connect VS Code to AdventureWorks
- [ ] Run table discovery query
- [ ] Profile key tables for quality
- [ ] Document findings in `src/docs/source-analysis.md`

**Phase 2**:
- [ ] Design dimension and fact tables
- [ ] Create DDL scripts in `src/sql/05_warehouse/`
- [ ] Create warehouse database
- [ ] Document schema

**Phase 3**:
- [ ] Create staging database (AdventureWorks_Staging)
- [ ] Build Stage 1 SSIS packages (extract raw to staging)
- [ ] Build Stage 2 SSIS packages (clean and validate in staging)
- [ ] Build Stage 3 SSIS packages (load dimensions and facts to warehouse)
- [ ] Test packages with sample data
- [ ] Schedule execution

**Phase 4**:
- [ ] Run validation queries
- [ ] Compare row counts and sums
- [ ] Document reconciliation

**Phase 5**:
- [ ] Connect Power BI to warehouse
- [ ] Build dashboards for each reporting goal
- [ ] Add measures and interactivity
- [ ] Export .pbix and screenshots
- [ ] Document KPIs discovered

**Phase 6**:
- [ ] Document all phases
- [ ] Commit to Git
- [ ] Create final README with KPI catalog

