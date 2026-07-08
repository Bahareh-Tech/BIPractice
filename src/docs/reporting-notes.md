# Reporting Notes

## Power BI Goal
Build a clean and simple reporting solution on top of the warehouse.

## Suggested Report Pages
### 1. Executive Sales Overview
- total sales
- total orders
- average order value
- monthly sales trend
- sales by territory

### 2. Product Performance
- sales by category
- sales by subcategory
- top products
- product trend over time

### 3. Customer and Territory Insights
- top customers
- repeat customers
- sales by territory
- customer contribution

## Final Report Pages

### Page 1 — Sales Performance
- **Cards**: Total Sales, Total Orders, Average Order Value, Customer Count
- **Line chart**: Total Sales by month (DimDate[MonthName] + DateYear slicer)
- **Matrix**: Total Sales + Sales Growth % by year
- **Bar chart**: Total Sales by territory

### Page 2 — Product & Category Analysis
- **Bar chart**: Total Sales by ProductCategory
- **Bar chart**: Total Sales by ProductSubcategory (filtered by category slicer)
- **Table**: Top products by Total Sales and Total Quantity side by side
- **Line chart**: Total Sales by product category over time

### Page 3 — Customer & Territory Insights
- **Cards**: Customer Count, Top 10 Customer Revenue, Top 20% Customer Revenue
- **Bar chart**: Top 10 customers by Total Sales (TOPN visual-level filter)
- **Map / bar chart**: Total Sales by territory and group
- **Donut chart**: Channel split (Online vs Reseller)

### Page 4 — Seasonal & YoY Analysis
- **Line chart**: Monthly Average Order Value trend across years
- **Matrix**: Total Sales by Year × Month (seasonal heatmap pattern)
- **Bar chart**: Sales Growth % by year
- **Slicer**: Year



## DAX Measures

All measures stored in `FactSales`. Full definitions with business meaning in [measures.md](../powerbi/measures.md).

| Measure | Business Question |
|---|---|
| Total Sales | BQ1, BQ2, BQ4 |
| Total Orders | BQ1 |
| Average Order Value | BQ5 |
| Total Quantity | BQ6 |
| Customer Count | BQ3 |
| Sales Growth % | BQ7 |
| Top 10 Customer Revenue | BQ3 |
| Top 20% Customer Revenue | BQ8 |
| Reseller Revenue | BQ10 |
| Online Revenue | BQ10 |



## Report Design Notes

- `DimDate` is marked as the **Date Table** in Power BI using the `[Date]` column — required for time intelligence measures (`SAMEPERIODLASTYEAR`)
- All relationships use **surrogate keys** (integer), not business keys
- Relationship direction is single (dimension → fact) to avoid ambiguous filter propagation
- `DimChannel` uses a simple two-row table; the channel slicer filters the entire report page
- Report theme: default Power BI theme with no custom colours — keeps focus on data during portfolio review
- Screenshots stored in `src/powerbi/screenshots/`
