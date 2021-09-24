
--26.	Revisit your answer in (19).
--Convert the result into an XML string and save it to the server using TSQL FOR XML PATH.

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

DECLARE @xml XML;

SET @xml = (
SELECT YEAR AS [Year],
       [Airline Novelties] AS [Airline_Novelties],
       Clothing       AS Clothing,
       [USB Novelties]    AS [USB_Novelties],
       [Furry Footwear] AS [Furry_Footwear],
	   Mugs AS Mugs,
	   [Novelty Items] AS [Novelty_Items],
	   [Packaging Materials] AS [Packaging_Materials],
	   Toys AS Toys,
	   [T-Shirts] AS [T-Shirts],
	   [USB Novelties] AS [USB_Novelties]
FROM   ods.VIEW2
FOR XML PATH('') )



--drop table ods.xml;
CREATE TABLE ods.xml(
    _id bigint primary key identity,
    xml XML
);


INSERT INTO ods.xml
SELECT @xml

SELECT * FROM ods.xml


