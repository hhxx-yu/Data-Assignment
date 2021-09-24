--22.	Create a new table called ods.StockItem. It has following columns: 
--[StockItemID], [StockItemName] ,[SupplierID] ,[ColorID] ,[UnitPackageID] 
--,[OuterPackageID] ,[Brand] ,[Size] ,[LeadTimeDays] ,[QuantityPerOuter] ,[IsChillerStock] ,
--[Barcode] ,[TaxRate]  ,[UnitPrice],[RecommendedRetailPrice] ,[TypicalWeightPerUnit] ,[MarketingComments]  ,
--[InternalComments], [CountryOfManufacture], [Range], [Shelflife]. 
--Migrate all the data in the original stock item table.
USE WideWorldImporters;

CREATE SCHEMA ods;

CREATE TABLE ods.StockItem(
[StockItemID] INT,
[StockItemName] NVARCHAR(100),
[SupplierID] INT, 
[ColorID] INT,
[UnitPackageID] INT,
[OuterPackageID] INT,
[Brand] NVARCHAR(50),
[Size] NVARCHAR(20),
[LeadTimeDays] INT ,
[QuantityPerOuter] INT ,
[IsChillerStock] BIT ,
[Barcode]NVARCHAR(50) ,
[TaxRate]  DECIMAL(18,3) ,
[UnitPrice]DECIMAL(18,2),
[RecommendedRetailPrice] DECIMAL(18,2),
[TypicalWeightPerUnit]  DECIMAL(18,3),
[MarketingComments] NVARCHAR(MAX)  ,
[InternalComments] NVARCHAR(MAX), 
[CountryOfManufacture] NVARCHAR(20), 
[Range] NVARCHAR(20), 
[Shelflife] NVARCHAR(20)
)

INSERT INTO ods.StockItem
SELECT
StockItemID,
StockItemName,
SupplierID,
ColorID,
UnitPackageID,
OuterPackageID,
Brand,
Size,
LeadTimeDays,
QuantityPerOuter,
IsChillerStock,
Barcode,
TaxRate,
UnitPrice,
RecommendedRetailPrice,
TypicalWeightPerUnit,
MarketingComments,
InternalComments,
JSON_VALUE(CustomFields,'$.CountryOfManufacture') AS CountryOfManufacture,
JSON_VALUE(CustomFields,'$.Range') AS [Range],
JSON_VALUE(CustomFields,'$.ShelfLife') AS Shelflife
FROM WideWorldImporters.Warehouse.StockItems