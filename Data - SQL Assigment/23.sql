----23.	Rewrite your stored procedure in (21). 
--Now with a given date, it should wipe out all the order data prior to the input date 
--and load the order data that was placed in the next 7 days following the input date.

USE WideWorldImporters;

DROP TABLE ods.Orders;

CREATE TABLE ods.Orders(
	OrderID INT NOT NULL,
	OrderDate DATE NOT NULL,
	OrderTotal INT NOT NULL,
	CustomerID INT NOT NULL);
	
---------------------------------PROCEDURE GET ORDER INFO-----------------------------------------

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
---------------------------------PROCEDURE REMOVE PREVIOUS ORDER-----------------------------


DROP PROCEDURE dbo.RemoveOrderInfo;

CREATE PROCEDURE dbo.RemoveOrderInfo
	@OrderDate date
AS
	BEGIN TRY
		BEGIN TRANSACTION 
		IF NOT EXISTS (SELECT * FROM ods.Orders WHERE OrderDate < @OrderDate)
		    RAISERROR ('Error raised in TRY block.This OrderDate does not exist', -- Message text.  
               16, -- Severity.  
               1 -- State.  
               )

		ELSE
			BEGIN
			DELETE FROM ods.Orders WHERE OrderDate < @OrderDate
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

---------------------------------PROCEDURE WIPE OUT & LOAD------------------------



DROP PROCEDURE dbo.WipeOutLoad;
CREATE PROCEDURE dbo.WipeOutLoad
	@OrderDate DATE
AS
	DECLARE @OrderDateF DATE

	EXEC dbo.RemoveOrderInfo @OrderDate

	EXEC dbo.GetOrderInfo @OrderDate
	
	SELECT @OrderDateF = CONVERT(DATE,DATEADD(DAY,1,@OrderDate))
	EXEC dbo.GetOrderInfo @OrderDateF

	SELECT @OrderDateF = CONVERT(DATE,DATEADD(DAY,2,@OrderDate))
	EXEC dbo.GetOrderInfo @OrderDateF

	SELECT @OrderDateF = CONVERT(DATE,DATEADD(DAY,3,@OrderDate))
	EXEC dbo.GetOrderInfo @OrderDateF

	SELECT @OrderDateF = CONVERT(DATE,DATEADD(DAY,4,@OrderDate))
	EXEC dbo.GetOrderInfo @OrderDateF

	SELECT @OrderDateF = CONVERT(DATE,DATEADD(DAY,5,@OrderDate))
	EXEC dbo.GetOrderInfo @OrderDateF

	SELECT @OrderDateF = CONVERT(DATE,DATEADD(DAY,6,@OrderDate))
	EXEC dbo.GetOrderInfo @OrderDateF
GO

EXEC dbo.WipeOutLoad @OrderDate = '2015-01-18'
SELECT  DISTINCT OrderDate FROM ods.Orders

--EXEC dbo.GetOrderInfo @OrderDate = '2015-01-01';
--EXEC dbo.GetOrderInfo @OrderDate = '2015-01-02';
--EXEC dbo.GetOrderInfo @OrderDate = '2015-01-03';
--EXEC dbo.GetOrderInfo @OrderDate = '2015-01-04';
--EXEC dbo.GetOrderInfo @OrderDate = '2015-01-05';

