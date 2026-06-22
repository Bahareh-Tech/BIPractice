# Build ETL scripts to load dimensions

## Goal
Load cleaned data from staging into dimension tables.

## Description
Create SSIS packages in `src/ssis/etl/` to populate dimensions from staging.

## Deliverables
- Load scripts for `DimDate`, `DimProduct`, `DimCustomer`, and `DimTerritory`
- Insert or merge logic as appropriate
- Comments explaining transformations

## Done when
- [ ] Dimension load scripts are created
- [ ] Dimension data loads successfully
- [ ] Transformation logic is understandable
- [ ] Changes are committed

## Suggested label
`etl`
