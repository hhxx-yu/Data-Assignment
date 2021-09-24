--20. ??	Create a function, input: order id; return: total of that order. 
--List invoices and use that function to attach the order total to the other fields of invoices. 
USE WideWorldImporters;
GO

DROP FUNCTION OrderTotal;

CREATE FUNCTION OrderTotal(@OrderID int)
RETURNS int AS BEGIN
RETURN(
		SELECT SUM(IL.Quantity)
		FROM Sales.Invoices AS I
		JOIN Sales.InvoiceLines AS IL
		ON I.InvoiceID = IL.InvoiceID AND I.OrderID = @OrderID)
END;

SELECT InvoiceID, OrderID, dbo.OrderTotal(OrderID) AS OrderTotal
FROM Sales.Invoices


