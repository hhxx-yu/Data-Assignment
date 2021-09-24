--5.	List of stock items that have at least 10 characters in description.

USE WideWorldImporters;
GO
SELECT 
	S.StockItemName
FROM 
	Warehouse.StockItems AS S
WHERE Len(S.MarketingComments)>10