--21.	Create a new table called ods.Orders. Create a stored procedure, 
--with proper error handling and transactions, that input is a date; 
--when executed, it would find orders of that day, calculate order total, 
--and save the information (order id, order date, order total, customer id) into the new table. 
--If a given date is already existing in the new table, throw an error and roll back. 
--Execute the stored procedure 5 times using different dates. 


USE WideWorldImporters;

DROP TABLE ods.Orders;

CREATE TABLE ods.Orders(
	OrderID INT NOT NULL,
	OrderDate DATE NOT NULL,
	OrderTotal INT NOT NULL,
	CustomerID INT NOT NULL);
	

DROP PROCEDURE dbo.GetOrderInfo; 

CREATE PROCEDURE dbo.GetOrderInfo
	@OrderDate date
AS
	BEGIN TRY
		BEGIN TRANSACTION 
		IF EXISTS (SELECT * FROM ods.Orders WHERE OrderDate = @OrderDate)
		    RAISERROR ('Error raised in TRY block.This OrderDate already exists', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               )

		ELSE
			BEGIN
			INSERT INTO ods.Orders(OrderID, OrderDate, OrderTotal, CustomerID)
			SELECT OrderID, @OrderDate AS OrderDate, OrderTotal, CustomerID
			FROM
			(SELECT o.OrderID, o.CustomerID, SUM(ol.PickedQuantity) AS OrderTotal
			FROM Sales.Orders o 
			JOIN Sales.OrderLines ol
			ON o.OrderID = ol.OrderID
			WHERE o.OrderDate = @OrderDate
			GROUP BY o.OrderID, o.CustomerID) AS Temp
			COMMIT TRANSACTION 
			END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		    DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  
  
			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE();  
    
			RAISERROR (
			   @ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
		ROLLBACK TRANSACTION 
	END CATCH
GO



EXEC dbo.GetOrderInfo @OrderDate = '2015-01-01';
EXEC dbo.GetOrderInfo @OrderDate = '2015-01-02';
EXEC dbo.GetOrderInfo @OrderDate = '2015-01-03';
EXEC dbo.GetOrderInfo @OrderDate = '2015-01-04';
EXEC dbo.GetOrderInfo @OrderDate = '2015-01-05';


EXEC dbo.GetOrderInfo @OrderDate = '2015-01-01';



