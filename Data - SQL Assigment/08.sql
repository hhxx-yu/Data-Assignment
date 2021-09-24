--8.	List of States and Avg dates for processing (confirmed delivery date – order date) by month.

USE WideWorldImporters;
GO

SELECT
	MONTH(O.OrderDate) AS Month,
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
GROUP BY SP.StateProvinceName,MONTH(O.OrderDate)
ORDER BY MONTH(O.OrderDate),SP.StateProvinceName