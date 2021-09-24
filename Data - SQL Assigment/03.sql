--3.	List of customers to whom we made a sale prior to 2016 but no sale since 2016-01-01.

USE WideWorldImporters;
GO

SELECT 
	Customers.CustomerName
FROM
	Sales.Customers AS Customers
INNER JOIN
	(
	SELECT
		A.CUSTOMERID
	FROM Sales.CustomerTransactions AS A
	GROUP BY A.CustomerID
	HAVING (MAX(A.TRANSACTIONDATE)<'2016-01-01') AND (MIN(A.TRANSACTIONDATE)<'2016-01-01')
	) AS T
ON Customers.CustomerID = T.CustomerID