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
- define the grain of `FactSales`
- choose measures carefully
- keep dimension names business-friendly
- use surrogate keys where appropriate

## To Add Later
- source-to-target mapping
- column definitions
- hierarchy ideas
- model diagram
