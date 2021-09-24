--16.	List all stock items that are manufactured in China. (Country of Manufacture)
USE WideWorldImporters;
GO

SELECT
	DISTINCT StockItemName
FROM
	Warehouse.StockItems 
WHERE JSON_VALUE(CustomFields,'$.CountryOfManufacture') = 'China'
