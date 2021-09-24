--9.	List of StockItems that the company purchased more than sold in the year of 2015.

USE WideWorldImporters;
GO

SELECT 
	StockItemName = 
	CASE 
		WHEN PP.Q-SS.Q>0 THEN StockItemName 
	END
FROM
(
SELECT
	PL.StockItemID,
	SUM(PL.ReceivedOuters) AS Q
FROM 
	Purchasing.PurchaseOrderLines AS PL
JOIN Purchasing.PurchaseOrders AS P
ON PL.PurchaseOrderID = P.PurchaseOrderID
WHERE YEAR(P.OrderDate) = 2015
GROUP BY PL.StockItemID
) AS PP
LEFT JOIN
(
SELECT
	SL.StockItemID,
	SUM(SL.PickedQuantity) AS Q
FROM 
	Sales.OrderLines AS SL
JOIN Sales.Orders AS S
ON SL.OrderID = S.OrderID
WHERE YEAR(S.OrderDate) = 2015
GROUP BY SL.StockItemID
) AS SS
ON PP.StockItemID = SS.StockItemID
JOIN Warehouse.StockItems AS Stock
ON PP.StockItemID = Stock.StockItemID