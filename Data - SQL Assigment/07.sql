--7.	List of States and Avg dates for processing (confirmed delivery date – order date).

USE WideWorldImporters;
GO

SELECT
	SP.StateProvinceName,
	AVG(DATEDIFF(day, O.OrderDate, CONVERT(DATE,I.ConfirmedDeliveryTime))) AS AVGProcessDates 
FROM Sales.Invoices AS I
JOIN Sales.Orders AS O
ON I.OrderID = O.OrderID
JOIN Sales.Customers AS C
ON C.CustomerID = O.CustomerID
JOIN Application.Cities AS CT
ON CT.CityID = C.DeliveryCityID
JOIN Application.StateProvinces AS SP
ON CT.StateProvinceID = SP.StateProvinceID
GROUP BY SP.StateProvinceName
ORDER BY SP.StateProvinceName