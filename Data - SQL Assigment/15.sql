--15.	List any orders that had more than one delivery attempt (located in invoice table).
USE WideWorldImporters;
GO

SELECT
	OrderID--,
--COUNT(JSON_VALUE(ReturnedDeliveryData,'$.Events[1].Event')) AS Attempt
FROM Sales.Invoices
GROUP BY OrderID
HAVING COUNT(JSON_VALUE(ReturnedDeliveryData,'$.Events[1].Event'))>1