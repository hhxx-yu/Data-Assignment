--24.	Consider the JSON file:
--Looks like that it is our missed purchase orders. 
--Migrate these data into Stock Item, Purchase Order and Purchase Order Lines tables.
--Of course, save the script.
DECLARE @json NVARCHAR(MAX),@json2 NVARCHAR(MAX),@json3 NVARCHAR(MAX);
declare @test NVARCHAR(MAX);

-----------------------------------------SET JSON AND GET INFO---------------------------------------

SELECT @json = '{
   "PurchaseOrders":[
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"7",
         "UnitPackageId":"1",
         "OuterPackageId":[
            6,	
            7
         ],
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-01",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"WWI2308"
      },
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"5",
         "UnitPackageId":"1",
         "OuterPackageId":"7",
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-025",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"269622390"
      }
   ]
}';

SET @json2 = (
	SELECT
		*
	FROM OPENJSON(@json)
	WITH(
	[PurchaseOrders] nvarchar(max) as json
	) 
);

SET @json3 =(
SELECT 
StockItemName,Supplier,UnitPackageId,ISNULL(OuterPackageId,OuterPackageId2) AS OuterPackageId,Brand,
LeadTimeDays,QuantityPerOuter,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,[CustomFields.CountryOfManufacture],
[CustomFields.Range],OrderDate,DeliveryMethod,ExpectedDeliveryDate,SupplierReference
FROM OPENJSON (@json2)
WITH(
StockItemName NVARCHAR(50) '$.StockItemName',
Supplier INT '$.Supplier',
UnitPackageId INT '$.UnitPackageId',
Brand NVARCHAR(50) '$.Brand',
LeadTimeDays INT '$.LeadTimeDays',
QuantityPerOuter INT '$.QuantityPerOuter',
TaxRate  DECIMAL(18,3) '$.TaxRate',
UnitPrice DECIMAL(18,2) '$.UnitPrice',
RecommendedRetailPrice DECIMAL(18,2) '$.RecommendedRetailPrice',
TypicalWeightPerUnit  DECIMAL(18,3) '$.TypicalWeightPerUnit',
[CustomFields.CountryOfManufacture] NVARCHAR(50)  '$.CountryOfManufacture',
[CustomFields.Range] NVARCHAR(50) '$.Range',
OrderDate NVARCHAR(50) '$.OrderDate',
DeliveryMethod NVARCHAR(50) '$.DeliveryMethod',
ExpectedDeliveryDate NVARCHAR(50) '$.ExpectedDeliveryDate',
SupplierReference NVARCHAR(MAX) '$.SupplierReference',
OuterPackage NVARCHAR(MAX) '$.OuterPackageId'  AS JSON,
OuterPackageId2 NVARCHAR(MAX) '$.OuterPackageId'
)
OUTER APPLY OPENJSON(OuterPackage) WITH (
OuterPackageId INT '$')
FOR JSON PATH);


------------------------------------GET FINAL JSON INFO------------------------

WITH TEMP2 AS(
SELECT *
FROM OPENJSON(@json3)
WITH(
StockItemName NVARCHAR(50) '$.StockItemName',
SupplierID INT '$.Supplier',
UnitPackageID INT '$.UnitPackageId',
OuterPackageID INT '$.OuterPackageId',
Brand NVARCHAR(50) '$.Brand',
LeadTimeDays INT '$.LeadTimeDays',
QuantityPerOuter INT '$.QuantityPerOuter',
TaxRate  DECIMAL(18,3) '$.TaxRate',
UnitPrice DECIMAL(18,2) '$.UnitPrice',
RecommendedRetailPrice DECIMAL(18,2) '$.RecommendedRetailPrice',
TypicalWeightPerUnit  DECIMAL(18,3) '$.TypicalWeightPerUnit',
[CustomFields] NVARCHAR(MAX)  '$.CustomFields' AS JSON,
OrderDate NVARCHAR(50) '$.OrderDate',
DeliveryMethod NVARCHAR(50) '$.DeliveryMethod',
ExpectedDeliveryDate NVARCHAR(50) '$.ExpectedDeliveryDate',
SupplierReference NVARCHAR(MAX) '$.SupplierReference'))

--SELECT * FROM TEMP2
----------------------------------------INSERT PART----------------------------------------------

--------INSERT INTO STOCKITEMS

INSERT INTO WideWorldImporters.Warehouse.StockItems(
StockItemName,
SupplierID,
UnitPackageID,
OuterPackageID,
Brand,
LeadTimeDays,
QuantityPerOuter,
IsChillerStock,
TaxRate,
UnitPrice,
RecommendedRetailPrice,
TypicalWeightPerUnit,
CustomFields,
LastEditedBy)
SELECT 
		CONCAT(StockItemName,' version 1'),
		SupplierID,
		UnitPackageID,
		OuterPackageID,
		Brand,
		LeadTimeDays,
		QuantityPerOuter,
		0,
		TaxRate,
		UnitPrice,
		RecommendedRetailPrice,
		TypicalWeightPerUnit,
		CustomFields,
		1
FROM TEMP2
ORDER BY SupplierID, OuterPackageID
OFFSET 0 ROWS   -- Skip this number of rows
FETCH NEXT 1 ROWS ONLY; 

INSERT INTO WideWorldImporters.Warehouse.StockItems(
StockItemName,
SupplierID,
UnitPackageID,
OuterPackageID,
Brand,
LeadTimeDays,
QuantityPerOuter,
IsChillerStock,
TaxRate,
UnitPrice,
RecommendedRetailPrice,
TypicalWeightPerUnit,
CustomFields,
LastEditedBy)
SELECT  
		CONCAT(StockItemName,' version 2'),
		SupplierID,
		UnitPackageID,
		OuterPackageID,
		Brand,
		LeadTimeDays,
		QuantityPerOuter,
		0,
		TaxRate,
		UnitPrice,
		RecommendedRetailPrice,
		TypicalWeightPerUnit,
		CustomFields,
		1
FROM TEMP2
ORDER BY SupplierID, OuterPackageID
OFFSET 1 ROWS   -- Skip this number of rows
FETCH NEXT 1 ROWS ONLY; 

INSERT INTO WideWorldImporters.Warehouse.StockItems(
StockItemName,
SupplierID,
UnitPackageID,
OuterPackageID,
Brand,
LeadTimeDays,
QuantityPerOuter,
IsChillerStock,
TaxRate,
UnitPrice,
RecommendedRetailPrice,
TypicalWeightPerUnit,
CustomFields,
LastEditedBy)
SELECT  
		CONCAT(StockItemName,' version 3'),
		SupplierID,
		UnitPackageID,
		OuterPackageID,
		Brand,
		LeadTimeDays,
		QuantityPerOuter,
		0,
		TaxRate,
		UnitPrice,
		RecommendedRetailPrice,
		TypicalWeightPerUnit,
		CustomFields,
		1
FROM TEMP2
ORDER BY SupplierID, OuterPackageID
OFFSET 2 ROWS   -- Skip this number of rows
FETCH NEXT 1 ROWS ONLY; 

DELETE FROM WideWorldImporters.Warehouse.StockItems WHERE StockItemName LIKE '%Panzer Video Game version%'
SELECT * FROM WideWorldImporters.Warehouse.StockItems


----------INSERT INTO PURCHASE ORDERS------------

--INSERT INTO WideWorldImporters.Purchasing.PurchaseOrders(
--SupplierID,
--OrderDate,
--DeliveryMethodID,
--ContactPersonID,
--SupplierReference,
--IsOrderFinalized,
--LastEditedBy
--)
--SELECT 
--A.SupplierID,
--CONVERT(DATE,CONVERT(datetime,A.OrderDate)),
--M.DeliveryMethodID,
--2,
--A.SupplierReference,
--1,
--999
--FROM TEMP2 AS A
--JOIN WideWorldImporters.Application.DeliveryMethods AS M 
--ON A.DeliveryMethod = M.DeliveryMethodName

