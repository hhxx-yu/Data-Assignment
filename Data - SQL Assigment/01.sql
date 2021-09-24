--1.	List of Persons’ full name, all their fax and phone numbers, 
--as well as the phone number and fax of the company they are working for (if any). 
USE WideWorldImporters;
GO
SELECT 
      People.FullName,
      People.FaxNumber,
      People.PhoneNumber,
      Customers.PhoneNumber AS CompanyPhoneNumber,
      Customers.FaxNumber AS CompanyFaxNumber
From 
	Application.People AS People
LEFT JOIN
	Sales.Customers AS Customers
ON 
	People.PersonID = Customers.PrimaryContactPersonID OR
	People.PersonID = Customers.AlternateContactPersonID