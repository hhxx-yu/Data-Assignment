--14.	List of Cities in the US and the stock item that the city got the most deliveries in 2016. 
--      If the city did not purchase any stock items in 2016, print “No Sales”.

USE WideWorldImporters;
GO

WITH TEMP AS
(
SELECT 
	City.CityID
	,OL.StockItemID
	,SUM(OL.PickedQuantity) AS Q
FROM
	Application.Cities AS City
LEFT JOIN 
	Sales.Customers AS C
ON City.CityID = C.DeliveryCityID
LEFT JOIN 
	Sales.Orders AS O
ON C.CustomerID = O.CustomerID AND YEAR(O.OrderDate) = 2016
LEFT JOIN 
	Application.StateProvinces AS SP
ON SP.StateProvinceID = City.StateProvinceID
JOIN 
	Application.Countries AS Country
ON Country.CountryID = SP.CountryID AND Country.CountryName = 'United States'
LEFT JOIN 
	Sales.OrderLines AS OL
ON OL.OrderID = O.OrderID 
GROUP BY City.CityID,OL.StockItemID
)

SELECT 
	--A.CityID,
	C.CityName,
	--ISNULL(A.StockItemID,0),
	CASE WHEN ISNULL(A.StockItemID,0)=0 THEN 'No Sales' ELSE S.StockItemName END AS ItemName
FROM (
SELECT
	CityID,
	ROW_NUMBER() OVER (PARTITION BY CityID ORDER BY Q DESC) AS RANKING,
	StockItemID,
	Q
FROM TEMP) A 
JOIN Application.Cities AS C
ON A.CityID = C.CityID AND A.RANKING=1
LEFT JOIN Warehouse.StockItems AS S
ON S.StockItemID = A.StockItemID