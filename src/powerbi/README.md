# Power BI

## Contents

| File / Folder | Description |
|---|---|
| `measures.md` | All DAX measures with definitions, business meaning, and page references |
| `screenshots/` | PNG exports of all 5 report pages |

## Report Pages

| Page | Focus |
|---|---|
| Page 1 — Sales Performance | Monthly trend, KPI cards (Total Sales, Total Orders, AOV), territory bar chart |
| Page 2 — Product & Category Analysis | Revenue by category and subcategory, top products by sales vs volume |
| Page 3 — Customer & Territory Insights | Top 10 customers, Top 20% revenue share, territory map, channel donut |
| Page 4 — Seasonal & YoY Analysis | Sales growth %, YoY matrix, monthly AOV trend |
| Page 5 — Channel Performance | Online vs Reseller revenue cards and split visuals |

## Notes
- All measures are stored in the `FactSales` table in the Power BI model
- `DimDate` is marked as the Date Table using the `[Date]` column
- All relationships use surrogate integer keys — single-direction filters (dimension → fact)
