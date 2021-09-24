--17.	Total quantity of stock items sold in 2015, group by country of manufacturing.

USE WideWorldImporters;
GO
SELECT
	Country,
	SUM(Q) AS TotalQuantity
FROM
(
SELECT
	OL.PickedQuantity AS Q,
	JSON_VALUE(CustomFields,'$.CountryOfManufacture') AS Country
FROM 
	Sales.OrderLines AS OL
JOIN 
	Warehouse.StockItems AS S
ON OL.StockItemID = S.StockItemID
JOIN Sales.Orders AS O
ON O.OrderID = OL.OrderID AND YEAR(O.OrderDate) = 2015
)TEMP 
GROUP BY Country


--SELECT
--	Country,
--	SUM(Q) AS TotalQuantity
--FROM
--(
--SELECT
--	OL.Quantity AS Q,
--	JSON_VALUE(CustomFields,'$.CountryOfManufacture') AS Country
--FROM 
--	Sales.OrderLines AS OL
--JOIN 
--	Warehouse.StockItems AS S
--ON OL.StockItemID = S.StockItemID
--JOIN Sales.Orders AS O
--ON O.OrderID = OL.OrderID AND YEAR(O.OrderDate) = 2015
--)TEMP 
--GROUP BY Country