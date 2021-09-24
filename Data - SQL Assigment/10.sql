
--10.	List of Customers and their phone number, together with the primary contact person’s name, 
--      to whom we did not sell more than 10  mugs (search by name) in the year 2016.

USE WideWorldImporters;
GO
WITH TEMP AS
(
SELECT
	A.CustomerID
	--,SUM(A.Q) AS Q
FROM
(
SELECT 
	O.CustomerID,
	O.OrderID,
	--OL.PickedQuantity
	SUM(OL.PickedQuantity) as Q
FROM Sales.Orders AS O
JOIN Sales.OrderLines AS OL
ON O.OrderID = OL.OrderID AND YEAR(O.OrderDate) = 2016
JOIN Warehouse.StockItems AS S
ON OL.StockItemID = S.StockItemID AND S.StockItemName LIKE '%mug%'
GROUP BY O.CustomerID, O.OrderID
) A
GROUP BY A.CustomerID
HAVING SUM(A.Q)<=10
)

SELECT 
	C.CustomerName,
	C.PhoneNumber,
	P.FullName
FROM TEMP
JOIN Sales.Customers AS C
ON TEMP.CustomerID = C.CustomerID
JOIN Application.People AS P
ON P.PersonID = C.PrimaryContactPersonID
