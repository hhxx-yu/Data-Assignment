
--13.	List of stock item groups and total quantity purchased, total quantity sold, 
--and the remaining stock quantity (quantity purchased – quantity sold)
USE WideWorldImporters;
GO

WITH TEMP1 AS(
SELECT 
	SG.StockGroupName,
	SUM(PL.ReceivedOuters) AS TotalQuantityPurchased
FROM 
Purchasing.PurchaseOrderLines AS PL
JOIN Warehouse.StockItemStockGroups AS SISG
ON PL.StockItemID = SISG.StockItemID
JOIN Warehouse.StockGroups AS SG
ON SISG.StockGroupID = SG.StockGroupID
GROUP BY SG.StockGroupName
),
TEMP2 AS(
SELECT 
	SG.StockGroupName,
	SUM(OL.PickedQuantity) AS TotalQuantityOrdered
FROM 
Sales.OrderLines AS OL
JOIN Warehouse.StockItemStockGroups AS SISG
ON OL.StockItemID = SISG.StockItemID
JOIN Warehouse.StockGroups AS SG
ON SISG.StockGroupID = SG.StockGroupID
GROUP BY SG.StockGroupName)

SELECT 
	TEMP1.StockGroupName,
	TEMP1.TotalQuantityPurchased,
	TEMP2.TotalQuantityOrdered,
	TEMP1.TotalQuantityPurchased-TEMP2.TotalQuantityOrdered AS RemainingStockQuantity
FROM TEMP1 JOIN TEMP2
ON TEMP1.StockGroupName = TEMP2.StockGroupName