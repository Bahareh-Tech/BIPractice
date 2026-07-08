# Source Analysis

## Main Source
The AdventureWorks database contains approximately 71 base tables across schemas like Sales, Production, Person, etc. While the initial focus is on core sales-related tables, for a comprehensive BI solution, explore additional tables based on business needs.

## Initial Focus Tables
- `Sales.SalesOrderHeader`
- `Sales.SalesOrderDetail`
- `Sales.Customer`
- `Sales.SalesTerritory`
- `Production.Product`
- `Production.ProductSubcategory`
- `Production.ProductCategory`
- `Person.Person`


## Expanded Table Exploration
Key additional tables to consider (based on business questions):

- `Sales.SalesPerson` (for sales rep performance)
- `Sales.Store` (for reseller details)
- `Production.ProductModel` (for product model analysis)
- `Person.Address` and `Person.StateProvince` (for location-based insights)
- `Sales.CreditCard` (if payment analysis is needed)
- `Purchasing.PurchaseOrderHeader` and `Purchasing.PurchaseOrderDetail` (for cost analysis, if expanding scope)

## Key Business Questions
- What are total sales by month?
- Which products and categories perform best?
- Which customers drive the most revenue?
- Which territories perform best?
- What is the average order value?

## Notes to Fill In
- important joins
- business meaning of each table
- key filters and date columns
- assumptions and data quality observations

## Join Map
## Table Relationships & Join Map

| From Table | FK Column | → | To Table | PK Column | Relationship Type |
--------------------------------------------------------------------------
| BillOfMaterials | ComponentID | Product | ProductID | Many-to-One |
| BillOfMaterials | ProductAssemblyID | Product | ProductID |
| Customer | PersonID | Person | BusinessEntityID |
| Customer | StoreID | Store | BusinessEntityID |
| Customer | TerritoryID | SalesTerritory | TerritoryID |
| Product | ProductModelID | ProductModel | ProductModelID |
| Product | ProductSubcategoryID | ProductSubcategory | ProductSubcategoryID |
| Product | SizeUnitMeasureCode | UnitMeasure | UnitMeasureCode |
| Product | WeightUnitMeasureCode | UnitMeasure | UnitMeasureCode |
| ProductCostHistory | ProductID | Product | ProductID |
| ProductDocument | ProductID | Product | ProductID | 
| ProductInventory | ProductID | Product | ProductID | 
| ProductListPriceHistory | ProductID | Product | ProductID |
| ProductProductPhoto | ProductID | Product | ProductID |
| ProductReview | ProductID | Product | ProductID |
| ProductSubcategory | ProductCategoryID | ProductCategory | ProductCategoryID |
| ProductVendor | ProductID | Product | ProductID |
| PurchaseOrderDetail | ProductID | Product | ProductID |
| SalesOrderDetail | ProductID | SpecialOfferProduct | ProductID |
| SalesOrderDetail | ProductID | SpecialOfferProduct | SpecialOfferID |
| SalesOrderDetail | SalesOrderID | SalesOrderHeader | SalesOrderID |
| SalesOrderDetail | SpecialOfferID | SpecialOfferProduct | ProductID |
| SalesOrderDetail | SpecialOfferID | SpecialOfferProduct | SpecialOfferID |
| SalesOrderHeader | BillToAddressID | Address | AddressID |
| SalesOrderHeader | CreditCardID | CreditCard | CreditCardID |
| SalesOrderHeader | CurrencyRateID | CurrencyRate,CurrencyRateID |
| SalesOrderHeader | CustomerID | Customer | CustomerID |
| SalesOrderHeader | SalesPersonID | SalesPerson | BusinessEntityID |
| SalesOrderHeader | ShipMethodID | ShipMethod | ShipMethodID |
| SalesOrderHeader | ShipToAddressID | Address | AddressID |
| SalesOrderHeader | TerritoryID | SalesTerritory | TerritoryID |
| SalesOrderHeaderSalesReason | SalesOrderID | SalesOrderHeader | SalesOrderID |
| SalesPerson | TerritoryID | SalesTerritory | TerritoryID |
| SalesTerritory | CountryRegionCode | CountryRegion | CountryRegionCode |
| SalesTerritoryHistory | TerritoryID | SalesTerritory | TerritoryID |
| ShoppingCartItem | ProductID | Product | ProductID |
| SpecialOfferProduct | ProductID | Product | ProductID |
| StateProvince | TerritoryID | SalesTerritory | TerritoryID |
| TransactionHistory | ProductID | Product | ProductID |
| WorkOrder | ProductID | Product | ProductID |



| SalesOrderDetail | ProductID | → | Product | ProductID | Many-to-One |
| SalesOrderDetail | SalesOrderID | → | SalesOrderHeader | SalesOrderID | Many-to-One |
| SalesOrderHeader | CustomerID | → | Customer | CustomerID | Many-to-One |
| SalesOrderHeader | TerritoryID | → | SalesTerritory | TerritoryID | Many-to-One |
| Customer | TerritoryID | → | SalesTerritory | TerritoryID | Many-to-One |


## Business Dictionary

- `Sales.SalesOrderHeader`
Sales.SalesOrderHeader = represent Order transactions (one per order)
Each row is an order. Also, this table has relationships with other tables to show features of an order.
Primary key = [SalesOrderID]
Foreign Key = [CustomerID], [SalesPersonID], [TerritoryID], [BillToAddressID],
[ShipToAddressID], [ShipMethodID], [CreditCardID], [CurrencyRateID]
It is refernced by SalesOrderDetail through foreign key SalesOrderID.
It references Customer table through foreign key CustomerID, SalesTerritory through foreign key TerritoryID,??

- `Sales.SalesOrderDetail`
Sales.SalesOrderDetail = represent order details (one per product in an order)
Each row is a line item for an order.
Primary key = [SalesOrderDetailID]
Foreign Key = [SalesOrderID], [ProductID], [SpecialOfferID]
It is not referenced by any table. 
It references SalesOrderHeader table through SalesOrderID, Product table through foreign key ProductID, ??

- `Sales.Customer`
Sales.Customer = represent Customers information
Each row is a customer.
Primary key = [CustomerID]
Foreign key = [PersonID], [StoreID], [TerritoryID]
It is referenced by SalesOrderHeader through foreign key CustomerID
It references SalesTerritory table through foreign key TerritoryID, ??

- `Sales.SalesTerritory`
Sales.SalesTerritory = represent Sales Territories information
Each row is a sales territory.
Primary key = [TerritoryID]
Foreign key = -
It is referenced by Customer and SalesOrderHeader through foreign key TerritoryID.
It references through none table.

- `Production.Product`
Production.Product = Product information
Each row is a product.
Primary key = [ProductID]
Foreign key = [ProductSubcategoryID], [ProductModelID]
It is referenced by SalesOrderDetail through foreign key ProductID.
It references ProductSubcategory table through foreign key ProductSubcategoryID, ??

- `Production.ProductSubcategory`
Production.ProductSubcategory = Product Subcategories information
Each row is a subcategory of a product.
Primary key = [ProductSubcategoryID]
Foreign key = [ProductCategoryID]
It is referenced by Product table through foreign key ProductSubCategoryID.
It references ProductCategory table through ProductCategoryID.

- `Production.ProductCategory`
Production.ProductCategory = Product Categories information
Each row is a category of a product.
Primary key = [ProductCategoryID]
Foreign key = -
It is referenced by ProductSubcategory table through foreign key ProductCategoryID.
It references through none table.

- `Person.Person`
Person.Person = represent Person information
Each row is a person.
Primary key = [BusinessEntityID]
Foreign key = -
It is not referenced by any table.
It references through none table.