--27.	Create a new table called ods.ConfirmedDeviveryJson with 3 columns (id, date, value) . 
--Create a stored procedure, input is a date. 
--The logic would load invoice information (all columns) 
--as well as invoice line information (all columns) and forge them 
--into a JSON string and then insert into the new table just created. 
--Then write a query to run the stored procedure for each DATE 
--that customer id 1 got something delivered to him.

-------------------------------CREATE TABLE ----------------------------
USE WideWorldImporters;
--DROP TABLE ods.ConfirmedDeviveryJson;
CREATE TABLE ods.ConfirmedDeviveryJson(
	id INT IDENTITY,
	date DATE,
	value nvarchar(MAX)
)
-----------------------------------CREATE PROCEDURE -------------------------------

--DROP PROCEDURE dbo.GetInvoiceInfo;

CREATE PROCEDURE dbo.GetInvoiceInfo
	@OrderDate date
AS
	DECLARE @json nvarchar(MAX);
	SET @json = (
	SELECT 
       O.InvoiceID
      ,O.CustomerID
      ,O.BillToCustomerID
      ,O.OrderID
      ,O.DeliveryMethodID
      ,O.ContactPersonID
      ,O.AccountsPersonID
      ,O.SalespersonPersonID
      ,O.PackedByPersonID
      ,O.InvoiceDate
      ,O.CustomerPurchaseOrderNumber
      ,O.IsCreditNote
      ,O.CreditNoteReason
      ,O.Comments
      ,O.DeliveryInstructions
      ,O.InternalComments
      ,O.TotalDryItems
      ,O.TotalChillerItems
      ,O.DeliveryRun
      ,O.RunPosition
      ,O.ReturnedDeliveryData
      ,O.ConfirmedDeliveryTime
      ,O.ConfirmedReceivedBy
      ,O.LastEditedBy AS OrderLastEdit
      ,O.LastEditedWhen AS OrderLastEditWhen
	  ,OL.InvoiceLineID
      ,OL.StockItemID
      ,OL.Description
      ,OL.PackageTypeID
      ,OL.Quantity
      ,OL.UnitPrice
      ,OL.TaxRate
      ,OL.TaxAmount
      ,OL.LineProfit
      ,OL.ExtendedPrice
      ,OL.LastEditedBy AS OrderLineLastEdit
      ,OL.LastEditedWhen AS OrderLineLastEditWhen
	FROM Sales.Invoices AS O 
	JOIN Sales.InvoiceLines AS OL
	ON O.InvoiceID = OL.InvoiceID AND O.InvoiceDate = @OrderDate
	FOR JSON PATH);

	INSERT INTO ods.ConfirmedDeviveryJson(date,value) VALUES(@OrderDate,@json)
GO

-----------------------------INSERT INTO TABLE ----------------------------
DECLARE @param DATE

DECLARE curs CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT CONVERT(DATE,ConfirmedDeliveryTime) AS OrderDate
	FROM 
	Sales.Invoices WHERE CustomerID = 1

OPEN curs

FETCH NEXT FROM curs INTO @param

WHILE @@FETCH_STATUS = 0 BEGIN
    EXEC dbo.GetInvoiceInfo  @param
    FETCH NEXT FROM curs INTO @param
END

CLOSE curs
DEALLOCATE curs

--SELECT * FROM ods.ConfirmedDeviveryJson