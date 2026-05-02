# ETL Design

## Goal
Load the warehouse from AdventureWorks using simple SQL-based ETL.

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

## To Add Later
- rerun strategy
- load order
- error handling approach
