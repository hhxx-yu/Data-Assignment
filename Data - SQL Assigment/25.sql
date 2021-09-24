--25.	Revisit your answer in (19). 
--Convert the result in JSON string and save it to the server using TSQL FOR JSON PATH.

 
USE WideWorldImporters;
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

DROP VIEW ods.VIEW2;

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

DECLARE @json NVARCHAR(MAX);

SET @json = (
SELECT * FROM ods.VIEW2
FOR JSON PATH)

--DROP TABLE ods.json;
CREATE TABLE ods.json(
    _id bigint primary key identity,
    json nvarchar(max)
);


INSERT INTO ods.json
SELECT @json

SELECT * FROM ods.json