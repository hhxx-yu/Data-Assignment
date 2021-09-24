--6.	List of stock items that are not sold to the state of Alabama and Georgia in 2014.

USE WideWorldImporters;
GO

SELECT 
	DISTINCT (S.StockItemName)
FROM Warehouse.StockItems AS S
EXCEPT(
	SELECT 
		DISTINCT(S.StockItemName)
	FROM 
		Warehouse.StockItems AS S
	JOIN Sales.OrderLines AS OL
	ON S.StockItemID = OL.StockItemID
	JOIN Sales.Orders AS O
	ON OL.OrderID = O.OrderID
	JOIN Sales.Customers AS C
	ON C.CustomerID = O.CustomerID
	JOIN Application.Cities AS CT
	ON C.DeliveryCityID = CT.CityID
	JOIN Application.StateProvinces AS SP
	ON CT.StateProvinceID = SP.StateProvinceID
	WHERE SP.StateProvinceName IN ('Alabama' ,'Georgia')
	AND YEAR(O.OrderDate) = 2014)
