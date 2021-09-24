
--12.	List all the Order Detail (Stock Item name, delivery address, delivery state, 
--city, country, customer name, customer contact person name, customer phone, quantity) 
--for the date of 2014-07-01. Info should be relevant to that date.

USE WideWorldImporters;
GO

SELECT
	S.StockItemName,
	CONCAT(C.DeliveryAddressLine1,', ',C.DeliveryAddressLine2,', ',C.DeliveryPostalCode) AS DeliverAddress,
	SP.StateProvinceName,
	City.CityName,
	Country.CountryName,
	C.CustomerName,
	P.FullName AS ContactPersonName,
	C.PhoneNumber AS CustomerPhone,
	OL.PickedQuantity
FROM
Sales.Orders AS O
JOIN Sales.OrderLines AS OL
ON O.OrderID = OL.OrderID AND O.OrderDate = '2014-07-01'
JOIN Sales.Customers AS C
ON O.CustomerID = C.CustomerID
JOIN Warehouse.StockItems AS S
ON S.StockItemID = OL.StockItemID
JOIN Application.Cities AS City
ON City.CityID = C.DeliveryCityID
JOIN Application.StateProvinces AS SP
ON City.StateProvinceID = SP.StateProvinceID
JOIN Application.Countries AS Country
ON Country.CountryID = SP.CountryID
JOIN Application.People AS P
ON C.PrimaryContactPersonID = P.PersonID
