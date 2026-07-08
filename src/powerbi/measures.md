# DAX Measures

All measures are stored in the `FactSales` table in the Power BI data model.

---

## Core Sales Measures

### Total Sales
```dax
Total Sales = SUM(FactSales[LineTotal])
```
**Business meaning**: Total revenue from all sales order lines.  
**Used on**: All pages (cards, charts, slicers).

---

### Total Orders
```dax
Total Orders = DISTINCTCOUNT(FactSales[OrderID])
```
**Business meaning**: Number of unique sales orders placed.  
**Used on**: Page 1 — Sales Performance (card).

---

### Average Order Value
```dax
Average Order Value = DIVIDE(SUM(FactSales[LineTotal]), DISTINCTCOUNT(FactSales[OrderID]))
```
**Business meaning**: Average revenue per order. Answers BQ5.  
**Used on**: Page 1 — Sales Performance (card), Page 4 — Seasonal & YoY (line chart).

---

### Total Quantity
```dax
Total Quantity = SUM(FactSales[OrderQty])
```
**Business meaning**: Total units sold across all order lines.  
**Used on**: Page 2 — Product & Category Analysis (bar chart for volume comparison).

---

### Customer Count
```dax
Customer Count = DISTINCTCOUNT(FactSales[CustomerKey])
```
**Business meaning**: Number of unique customers who placed at least one order.  
**Used on**: Page 3 — Customer & Territory Insights (card).

---

## Year-over-Year Measures

### Sales Growth %
```dax
Sales Growth % = 
VAR CurrentYearSale = SUM(FactSales[LineTotal])
VAR PriorYearSale = CALCULATE(SUM(FactSales[LineTotal]), SAMEPERIODLASTYEAR(DimDate[Date]))
RETURN DIVIDE(CurrentYearSale - PriorYearSale, PriorYearSale)
```
**Business meaning**: Percentage change in revenue compared to the same period in the prior year. Answers BQ7.  
**Note**: Requires `DimDate` to be marked as a date table. Use in a matrix with year context — a card shows 0 with no year selected.  
**Used on**: Page 1 — Sales Performance (matrix), Page 4 — Seasonal & YoY (matrix).

---

## Customer Measures

### Top 10 Customer Revenue
```dax
Top 10 Customer Revenue = 
CALCULATE(
    [Total Sales],
    TOPN(10, ALL(DimCustomer[CustomerName]), [Total Sales])
)
```
**Business meaning**: Combined revenue from the top 10 customers by total sales.  
**Used on**: Page 3 — Customer & Territory Insights (card).

### Top 20% Customer Revenue
```dax
Top 20% Customer Revenue = 
VAR CustomerCount = DISTINCTCOUNT(FactSales[CustomerKey])
VAR Top20Count = ROUNDUP(CustomerCount * 0.2, 0)
RETURN
    CALCULATE(
        [Total Sales],
        TOPN(Top20Count, ALL(DimCustomer[CustomerName]), [Total Sales])
    )
```
**Business meaning**: Revenue contributed by the top 20% of customers by spend. Answers BQ8.  
**Used on**: Page 3 — Customer & Territory Insights (card, paired with Total Sales card to show proportion).

---

## Channel Measures

### Reseller Revenue
```dax
Reseller Revenue = 
CALCULATE(
    SUM(FactSales[LineTotal]),
    DimChannel[ChannelName] = "Reseller"
)
```
**Business meaning**: Total revenue from reseller channel orders. Answers BQ10 (partial).  
**Used on**: Page 5 — Channel Performance (card).

### Online Revenue
```dax
Online Revenue = 
CALCULATE(
    SUM(FactSales[LineTotal]),
    DimChannel[ChannelName] = "Online"
)
```
**Business meaning**: Total revenue from online channel orders. Answers BQ10 (partial).  
**Used on**: Page 5 — Channel Performance (card).

---

## Notes

209 products have no `ProductSubcategory` in the source (raw materials/components). These appear as blank in category charts — this is expected per source data design.
