# Project Scope

## Project Title
AdventureWorks Sales BI Project

## Scenario
AdventureWorks management wants a better sales reporting solution. The source database is transactional and not ideal for analytics. The goal is to build a small BI solution from source tables to dashboard.

## Main Objective
Create a portfolio-ready BI project that demonstrates:
- SQL reporting and analysis
- warehouse design basics
- ETL implementation in SQL Server
- Power BI reporting

## Scope
### Included
- source system exploration
- reporting queries
- reusable SQL objects
- star schema design
- SQL-based ETL
- Power BI dashboard pages

### Not included for now
- advanced OLAP cube development
- enterprise orchestration
- advanced performance tuning
- complex SCD implementations

## Stakeholders
- **Sales Manager** - wants monthly and territory sales performance
- **Product Manager** - wants category and product revenue analysis
- **Finance** - wants revenue totals, trends, and year-over-year comparisons

## Reporting Goals
- track monthly and annual sales performance over time
- identify top-performing products and categories
- understand which customers and territories drive the most revenue
- analyze seasonal patterns and year-over-year trends
- compare online vs reseller channel performance

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

## Target Role
Junior / Associate BI Developer

## Implementation Workflow

### Architecture Overview
This project uses a three-layer data architecture:
1. **Source Database (AdventureWorks)**: Production transactional database (read-only access)
2. **Staging Database (AdventureWorks_Staging)**: Raw copy of source data with minimal transformations; used for data quality checks and cleaning
3. **Warehouse Database (AdventureWorksDW)**: Clean, organized star schema for analytics and reporting

**Data Flow**: Source → Staging (extract raw) → Warehouse (extract, transform, load clean data / source column → transformation → warehouse column)

---

Detailed tools, steps, and information for each phase:

### Phase 1: Source Analysis & Data Quality Assessment

**Objective**: Understand source database structure, table relationships, data quality issues, and plan cleaning strategies. (This phase identifies issues; cleaning is implemented in Phase 3.)

**Tools Required**:
- VS Code with `SQL Server (mssql)` extension
- SQL Server Management Studio (SSMS) or Azure Data Studio (optional, for visual schema exploration)
- Markdown editor in VS Code

**Step-by-Step Process**:
1. **Connect to Source Database**
   - Configure mssql extension in VS Code to connect to AdventureWorks
   - Test connection and verify access

2. **Identify All Tables**
   - Run query to list all 71+ base tables
   - Save results to `src/sql/00_analysis/table_list.sql`
   - Update `src/docs/source-analysis.md` with complete table inventory

3. **Profile Core Tables for Business Questions**
   - For each table relevant to business questions, execute profiling queries:
     - Row count
     - Column list with types
     - Primary and foreign keys
     - NULL values per column count
   - Save profiling queries in `src/sql/00_analysis/profile_*.sql`

4. **Assess Data Quality**
   - Check for duplicates
   - Identify NULL percentages: Calculate (NullCount / TotalRows) * 100
   - Check date ranges: `SELECT MIN(DateColumn), MAX(DateColumn) FROM TableName`
   - Detect negative or unusual values in numeric fields
   - Save quality checks in `src/sql/00_analysis/quality_checks.sql`

5. **Map Table Relationships**
   - Document foreign keys linking tables (e.g., SalesOrderDetail.ProductID → Product.ProductID)
   - Identify many-to-many relationships requiring bridge tables
   - Create a join map in `src/docs/source-analysis.md`

6. **Understand Business Meaning**
   - For each key table, document:
     - What it represents (e.g., Sales.SalesOrderHeader = order transactions)
     - Key columns and their meanings
     - How it relates to other tables
     - Any special filters or conditions (e.g., OnlineOrderFlag)
   - Update `src/docs/source-analysis.md` with business dictionary

**Extra Information**:
- Assume AdventureWorks follows standard schema naming (Sales, Production, Person, etc.)
- Be aware of historical data (e.g., archived orders) vs. current data
- Check if soft deletes (IsActive flags) are used instead of physical deletes
- Note any data entry standards (e.g., territory abbreviations)

**Deliverables**:
- Complete table list and schema documentation
- Data quality report (row counts, NULLs, date ranges)
- Join map and table relationship diagram
- Updated `src/docs/source-analysis.md` with findings
- All profiling and quality check queries saved in `src/sql/00_analysis/`

---

### Phase 2: Data Warehouse Design

**Objective**: Design a star schema that organizes cleaned data for analytics. (Note: This is warehouse design only; staging uses source structure.)

**Tools Required**:
- VS Code with `SQL Server (mssql)` extension
- Draw.io or similar for schema diagram (optional but recommended)
- SSMS for visual inspection (optional)

**Step-by-Step Process**:
1. **Design Dimension Tables**
   - Based on business questions, identify dimensions needed:
     - **DimDate**: Contains all dates for time-series analysis
     - **DimProduct**: Product attributes 
     - **DimCustomer**: Customer attributes
     - **DimTerritory**: Territory information
     - **DimChannel**: Online/Reseller channel
     - Additional: DimSalesPerson, DimStore (if analyzing sales rep/reseller performance)

2. **Design Fact Table**
   - **FactSales**: Core fact table with measures and dimension keys:
     - Foreign keys: DateKey, ProductKey, CustomerKey, TerritoryKey, ChannelKey
     - Measures: OrderQty, UnitPrice, LineTotal, OrderTotal, TaxAmount, ShippingAmount
     - Attributes: OrderID, LineNumber, DueDate, ShipDate
     - Flags: IsOnlineOrder, IsCanceled

3. **Create DDL Scripts**
   - Write SQL CREATE TABLE statements for each dimension and fact table
   - Save in `src/sql/05_warehouse/`:
     - `01_DimDate.sql`
     - `02_DimProduct.sql`
     - `03_DimCustomer.sql`
     - `04_DimTerritory.sql`
     - `05_DimChannel.sql`
     - `10_FactSales.sql` (load last after dimensions)
   - Include primary keys, data types, constraints, and indexes

4. **Define Data Types and Constraints**
   - Use INT for keys (or BIGINT if high cardinality)
   - Use appropriate sizes for strings (VARCHAR vs. NVARCHAR)
   - Add NOT NULL constraints for critical columns
   - Define primary and foreign keys
   - Consider indexes on frequently filtered or joined columns

5. **Document Schema**
   - Create an ER diagram (visual or text-based in Markdown)
   - Document table purposes, columns, and relationships
   - Save in `src/docs/warehouse-design.md`

**Extra Information**:
- Use surrogate keys (DimProductKey) instead of natural keys (ProductID) for flexibility
- DimDate should be generated separately and pre-loaded (not sourced from tables)
- Consider Slowly Changing Dimension (SCD) Type 2 for dimensions that change over time (e.g., customer address)
- Plan for data types: Ensure source and warehouse types align (or handle conversion in ETL)
- Think about grain: FactSales should be at the order line level (one row per line item)

**Deliverables**:
- DDL scripts for all dimension and fact tables in `src/sql/05_warehouse/`
- Warehouse schema documentation and ER diagram
- Data type and key mapping document
- Constraint and index design specifications

---

### Phase 3: ETL Implementation (SSIS)

**Objective**: Build automated data flows to extract, transform, and load data from source through staging to warehouse.

**Tools Required**:
- Visual Studio (with SQL Server Data Tools (SSDT) extension)
- SQL Server Integration Services (SSIS)
- VS Code for documentation and SQL scripts

**Architecture**:
- **Stage 1**: Extract raw data from AdventureWorks to Staging database (minimal transformations)
- **Stage 2**: Apply data quality and cleaning transformations in Staging
- **Stage 3**: Load cleaned data from Staging to Warehouse (star schema)

**Step-by-Step Process**:
1. **Create Staging Database**
   - Create new database: `AdventureWorks_Staging`
   - Create raw tables matching source structure (or subset needed for project)
   - Add audit columns: LoadDate, RowHash (for change detection)

2. **Build Stage 1 SSIS Packages (Extract to Staging)**
   - Create packages to load raw source data to staging tables:
     - **Package**: LoadStagingProduct.dtsx
       - OLE DB Source: Select all columns from Production.Product
       - OLE DB Destination: Load into Staging.Product (raw copy)
       - Log row counts for reconciliation
     - Repeat for other key tables: SalesOrderHeader, SalesOrderDetail, Customer, SalesTerritory, etc.
     - Store packages in `src/sql/06_etl/stage1_extract/`

3. **Build Stage 2 SSIS Packages (Transform & Clean in Staging)**
   - Create cleaning transformation packages:
     - **Package**: CleanStagingProduct.dtsx
       - Source: Read from Staging.Product
       - Transformations:
         - Derived Column: Standardize strings (TRIM, UPPER for consistency)
         - Lookup: Validate against reference data
         - Conditional Split: Identify invalid records (NULLs in key columns, negative prices)
         - Redirect invalid rows to error tables (StagingErrors.Product)
       - Destination: Update cleaned Staging.Product
     - Handle common issues:
       - NULL values: Impute, default, or mark for exclusion
       - Duplicates: Use Fuzzy Match or SQL deduplication
       - Data type mismatches: Convert or flag
       - Date formatting: Standardize to YYYY-MM-DD
     - Store packages in `src/sql/06_etl/stage2_clean/`

4. **Build Stage 3 SSIS Packages (Dimension Load from Staging)**
   - Create packages to load dimensions from cleaned staging data:
     - **Package**: LoadDimProduct.dtsx
       - Source: Read from cleaned Staging.Product
       - Transformations:
         - Lookup: Get surrogate keys, handle slowly changing dimensions
         - Derived Column: Create DimKey, effective dates
       - Destination: Load into DimProduct in Warehouse
     - Repeat for DimCustomer, DimTerritory, DimChannel, etc.
     - Store packages in `src/sql/06_etl/stage3_load_dimensions/`

5. **Build Stage 3 SSIS Package (Fact Load from Staging)**
   - Create LoadFactSales.dtsx:
     - Sources: Read from cleaned Staging.SalesOrderHeader and Staging.SalesOrderDetail
     - Transformations:
       - Merge Join: Combine headers and details
       - Multiple Lookup Tasks: Map Staging IDs to warehouse surrogate keys (ProductKey, CustomerKey, etc.)
       - Derived Columns: Calculate extended amounts, apply business logic
       - Conditional Split: Flag cancelled/invalid orders
     - Destination: Load into FactSales in Warehouse
     - Store in `src/sql/06_etl/stage3_load_facts/`

6. **Control Flow & Dependencies**
   - Create master SSIS package with precedence constraints:
     - Stage 1 packages run first (extract to staging)
     - Stage 2 packages run after Stage 1 (cleaning)
     - Stage 3 dimension packages run after Stage 2
     - Stage 3 fact package runs last (after all dimensions)
   - Add error handling and logging at each stage

7. **Data Quality Checks (Optional but Recommended)**
   - After each stage, insert validation queries:
     - Stage 1 → 2: Compare row counts before/after cleaning
     - Stage 2 → 3: Verify no orphaned keys before loading warehouse
   - Log results to audit table

8. **Schedule Package Execution**
   - Create SQL Server Agent jobs:
     - Daily job: Run master ETL package (all stages)
     - Set up notifications for failures
   - Document schedule in `src/docs/etl-design.md`

**Extra Information**:
- Staging layer acts as a buffer: Isolates source from warehouse; easier to debug and reprocess
- Keep staging tables simple (close to source structure) to simplify Stage 1
- Add data profiling in Stage 2 to log cleaning metrics (e.g., "2000 NULLs found, 1800 imputed")
- Consider incremental loads: Use ModifiedDate to load only changed records
- Error rows in staging can be analyzed later to improve source data entry

**Deliverables**:
- Staging database (AdventureWorks_Staging) created
- SSIS project organized into three subdirectories:
  - `stage1_extract/` - packages to load raw data to staging
  - `stage2_clean/` - packages to clean and validate staging data
  - `stage3_load_dimensions/` - packages to load dimensions to warehouse
  - `stage3_load_facts/` - package to load facts to warehouse
- Master SSIS package with orchestration and error handling
- Data cleaning documentation in `src/docs/etl-design.md` (which transformations fix which issues)
- SQL Server Agent job definitions
- Audit/logging tables for tracking ETL execution

---

### Phase 4: Validation and Testing

**Objective**: Verify that warehouse data matches source data and meets business rules.

**Tools Required**:
- VS Code with mssql extension
- SQL Server for query execution

**Step-by-Step Process**:
1. **Row Count Validation**
   - Compare row counts: Source vs. Warehouse
   - Query: `SELECT 'Source', COUNT(*) FROM AdventureWorks.Sales.SalesOrderDetail UNION ALL SELECT 'Warehouse', COUNT(*) FROM AdventureWorksDW.dbo.FactSales`
   - Save in `src/sql/07_validation/row_counts.sql`
   - Acceptable variance: Document expected differences (e.g., cancelled orders excluded)

2. **Data Integrity Validation**
   - Check foreign key referential integrity:
     - All ProductKeys in FactSales exist in DimProduct
     - All CustomerKeys in FactSales exist in DimCustomer
   - Check for NULLs in non-nullable columns
   - Save queries in `src/sql/07_validation/fk_integrity.sql`

3. **Business Rule Validation**
   - Validate calculations (sums, averages match between source and warehouse)
   - Check date ranges (all orders in valid date range)
   - Verify aggregations (e.g., total sales by category should match source)
   - Check segment splits (e.g., online vs. reseller %, should total 100%)
   - Save queries in `src/sql/07_validation/business_rules.sql`

4. **Reconciliation Report**
   - Create reconciliation queries that show:
     - Source total sales vs. warehouse total sales
     - Source order count vs. warehouse line count
     - Missing or mismatched records
   - Generate reports and save in `src/sql/07_validation/reconciliation.sql`

5. **Performance Testing**
   - Run sample reporting queries on warehouse
   - Measure execution time
   - Identify slow queries; add indexes if needed
   - Save query performance logs

6. **Document Findings**
   - Create validation report: `src/docs/validation-report.md`
   - Document any data discrepancies and resolutions
   - List assumptions and known limitations

**Extra Information**:
- Expect small variances due to rounding or data cleaning
- Consider time zone differences when comparing timestamps
- Document the source of truth (if source ≠ warehouse, which is correct?)
- Plan for re-runs: If issues found, re-load affected tables and re-validate

**Deliverables**:
- Validation query library in `src/sql/07_validation/`
- Reconciliation report comparing source and warehouse
- Performance test results
- Validation summary in `src/docs/validation-report.md`

---

### Phase 5: Dashboard Development

**Objective**: Create Power BI dashboards to answer business questions and visualize KPIs.

**Tools Required**:
- Power BI Desktop
- Warehouse database (AdventureWorksDW)

**Step-by-Step Process**:
1. **Connect Power BI to Warehouse**
   - Open Power BI Desktop
   - Get Data → SQL Server → Connect to AdventureWorksDW
   - Load fact and dimension tables

2. **Build Data Model**
   - Create relationships: FactSales to all dimensions
   - Set relationship cardinality (1-to-many)
   - Verify relationships are correct

3. **Create Measures (DAX Formulas)**
   - Total Sales: `SUM(FactSales[LineTotal])`
   - Average Order Value: `DIVIDE(SUM(FactSales[LineTotal]), DISTINCTCOUNT(FactSales[OrderID]))`
   - Sales Growth %: YoY comparison
   - Customer Count: `DISTINCTCOUNT(FactSales[CustomerKey])`
   - Top 20% Revenue: Cumulative distribution

4. **Build Dashboard Pages**
   - Page 1: **Sales Performance** (line chart trends, monthly/yearly)
   - Page 2: **Product & Category Analysis** (bar charts, top performers)
   - Page 3: **Customer & Territory Insights** (top customers, territory performance)
   - Page 4: **Seasonal & YoY Analysis** (seasonal patterns, YoY comparison)
   - Page 5: **Channel Performance** (online vs. reseller split, pie/donut charts)

5. **Add Interactivity**
   - Slicers: Date range, territory, product category, channel
   - Filters: Apply to pages or specific visuals
   - Drill-through: Navigate from summary to detail

6. **Format and Polish**
   - Use consistent colors and fonts
   - Add titles and descriptions
   - Format numbers (currency, percentages)
   - Remove unnecessary gridlines; clean up visuals

7. **Test and Export**
   - Verify all visuals work with sample data
   - Test slicers and filters
   - Publish to Power BI Service (if needed) or export as .pbix
   - Save file in `src/powerbi/`
   - Create screenshots in `src/powerbi/screenshots/`

**Extra Information**:
- KPIs will emerge during dashboard building (e.g., "Total Sales trend" is a KPI)—document them as you discover them
- Use conditional formatting for alerts (e.g., highlight declining sales in red)
- Consider different dashboard views for different stakeholders (Sales Manager vs. Finance)
- Ensure date filters work correctly for YoY comparisons

**Deliverables**:
- Power BI .pbix file with interactive dashboards
- Screenshot gallery of dashboard pages
- Documentation of measures and calculations
- KPI discoveries documented in `src/docs/kpi-catalog.md` (created during this phase)
- Published link (if using Power BI Service)

---

### Phase 6: Documentation and Polish

**Objective**: Complete and organize the project for portfolio presentation.

**Tools Required**:
- VS Code with Markdown editor
- Git for version control

**Step-by-Step Process**:
1. **Update All Documentation**
   - Complete `src/docs/project-scope.md` (overview)
   - Complete `src/docs/source-analysis.md` (table list, quality findings)
   - Complete `src/docs/warehouse-design.md` (star schema, dimensions, facts)
   - Create `src/docs/etl-design.md` (SSIS packages, transformations, schedule)
   - Create `src/docs/validation-report.md` (test results, reconciliation)
   - Create `src/docs/kpi-catalog.md` (KPI definitions and calculations discovered in phases)
   - Create main `README.md` (project summary, setup instructions)

2. **Organize SQL Scripts**
   - Ensure all scripts in `src/sql/` are:
     - Well-commented (explain purpose, logic, expected output)
     - Organized by phase (00_analysis, 05_warehouse, 06_etl, 07_validation)
     - Tested and runnable
     - Consistent naming (e.g., `profile_*.sql`, `validate_*.sql`)

3. **Document SSIS Packages**
   - Create SSIS package guide: `src/docs/ssis-packages.md`
   - For each package, document:
     - Source tables and columns extracted
     - Transformations applied
     - Destination table and data mapping
     - Error handling logic
     - Schedule and dependencies

4. **Capture KPI Insights**
   - Document KPIs discovered during dashboard building in `src/docs/kpi-catalog.md`
   - For each KPI, record:
     - Definition and business meaning
     - Calculation method (DAX or SQL)
     - Associated visuals/charts
     - Stakeholder relevance

5. **Add Screenshots and Diagrams**
   - Power BI dashboard screenshots in `src/powerbi/screenshots/`
   - ER diagram of warehouse schema
   - SSIS package flow diagrams (screenshots from Visual Studio)
   - Data quality findings charts

6. **Version Control**
   - Commit all files to Git with meaningful messages:
     - `git add .`
     - `git commit -m "Phase 1: Source analysis complete"`
     - etc. for each phase
   - Create tags for each phase milestone: `git tag v1.0-phase-1`

7. **Create Setup Instructions**
   - Document how to:
     - Connect to AdventureWorks
     - Create warehouse database
     - Run SSIS packages
     - Open Power BI dashboard
     - Verify validation
   - Include these in main `README.md` or new `SETUP.md`

**Extra Information**:
- Use consistent terminology throughout documentation
- Include lessons learned and challenges overcome
- Document assumptions and known limitations
- Add references to business questions answered by each component
- Consider creating a project video walkthrough (optional)

**Deliverables**:
- Complete documentation suite in `src/docs/`
- Well-organized and commented SQL/SSIS code
- Setup and usage instructions
- Screenshots and diagrams
- Git history with clear commit messages
- Final `README.md` with project overview
- KPI catalog documenting discoveries from all phases

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

