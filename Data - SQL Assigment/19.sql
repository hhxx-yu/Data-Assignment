--19.	Create a view that shows the total quantity of stock items of each stock group sold (in orders) 
--by year 2013-2017. [Year, Stock Group Name1, Stock Group Name2, Stock Group Name3, … , Stock Group Name10] 
USE WideWorldImporters;
GO


DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';

-- select the category names
SELECT 
    @columns+=QUOTENAME(StockGroupName) + ','
FROM 
    Warehouse.StockGroups
ORDER BY 
    StockGroupName;

-- remove the last comma
SET @columns = LEFT(@columns, LEN(@columns) - 1);

--DROP VIEW ods.VIEW2;

SET @sql =
'
CREATE VIEW ods.VIEW2 AS
(
SELECT 
*
FROM
(
SELECT
SG.StockGroupName,
OL.PickedQuantity AS Q,
YEAR(O.OrderDate) AS Year
FROM
Sales.OrderLines AS OL
JOIN Sales.Orders AS O
ON O.OrderID = OL.OrderID
JOIN Warehouse.StockItems AS SI
ON OL.StockItemID = SI.StockItemID
JOIN Warehouse.StockItemStockGroups AS SISG
ON SI.StockItemID = SISG.StockItemID
JOIN Warehouse.StockGroups AS SG
ON SISG.StockGroupID = SG.StockGroupID
) AS t
PIVOT 
(
  SUM(Q)
  FOR StockGroupName IN( ' + @columns + ' )' +
' ) AS p ) ';

EXECUTE sp_executesql @sql;

--SELECT * FROM ods.VIEW2