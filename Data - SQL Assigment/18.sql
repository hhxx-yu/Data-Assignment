--18.	Create a view that shows the total quantity of stock items of each stock group sold (in orders) 
--by year 2013-2017. 
--[Stock Group Name, 2013, 2014, 2015, 2016, 2017]

USE WideWorldImporters;
GO

CREATE VIEW ods.VIEW1 AS
(
SELECT
	StockGroupName,
	[2013],[2014],[2015],[2016],[2017]
FROM
(
SELECT
	SG.StockGroupName,
	OL.PickedQuantity AS Q,
	YEAR(O.OrderDate) AS Year
FROM
	Sales.OrderLines AS OL
JOIN 
	Sales.Orders AS O
ON O.OrderID = OL.OrderID
JOIN 
	Warehouse.StockItems AS SI
ON OL.StockItemID = SI.StockItemID
JOIN 
	Warehouse.StockItemStockGroups AS SISG
ON SI.StockItemID = SISG.StockItemID
JOIN 
	Warehouse.StockGroups AS SG
ON SISG.StockGroupID = SG.StockGroupID) S
PIVOT(
	SUM(Q) FOR 
	YEAR IN ([2013],[2014],[2015],[2016],[2017])) P)