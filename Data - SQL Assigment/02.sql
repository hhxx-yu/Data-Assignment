--2.	If the customer's primary contact person has the same phone number as the customer’s phone number, 
--list the customer companies. 
USE WideWorldImporters;
GO

SELECT 
      Customers.CustomerName
FROM
	Application.People AS People
INNER JOIN
	Sales.Customers AS Customers
ON 
	People.PersonID = Customers.PrimaryContactPersonID
WHERE 
	People.PhoneNumber = Customers.PhoneNumber