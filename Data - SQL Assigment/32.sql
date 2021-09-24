--32 Write script(s) and stored procedure(s) for the entire ETL from WWI db to DW.

--b
ALTER TABLE WideWorldImportersDW.Dimension.[Stock Item]
ADD [Country of Manufacture] NVARCHAR(20)


--ALTER TABLE WideWorldImportersDW.Dimension.[Stock Item]
--DROP COLUMN [Country of Manufacture]

UPDATE WideWorldImportersDW.Dimension.[Stock Item]
SET [Country of Manufacture] = JSON_VALUE(SI.CustomFields,'$.CountryOfManufacture')
FROM WideWorldImporters.Warehouse.StockItems AS SI
WHERE [Stock Item Key] = SI.StockItemID

SELECT [Country of Manufacture] FROM WideWorldImportersDW.Dimension.[Stock Item]

--c.
-----------------------------------------Extract-----------------------------------------------
--USE WideWorldImportersDW;

--DROP PROCEDURE dbo.ExtractOrder;
--GO

CREATE PROCEDURE dbo.ExtractOrder
AS
	SELECT 
	C.DeliveryCityID,
	O.CustomerID,
	OL.StockItemID ,
	O.OrderDate,
	CONVERT(DATE,O.PickingCompletedWhen) AS [Picked Date Key],
	O.SalespersonPersonID,
	O.PickedByPersonID,
	O.OrderID ,
	O.BackorderOrderID ,
	SI.StockItemName,
	PT.PackageTypeName,
	OL.Quantity,
	OL.UnitPrice,
	OL.TaxRate,
	IL.TaxAmount
	FROM WideWorldImporters.Sales.Orders AS O
	JOIN WideWorldImporters.Sales.OrderLines AS OL
	ON O.OrderID = OL.OrderID
	JOIN WideWorldImporters.Sales.Invoices AS I
	ON I.OrderID = O.OrderID
	JOIN WideWorldImporters.Sales.InvoiceLines AS IL
	ON IL.InvoiceID = I.InvoiceID AND IL.StockItemID = OL.StockItemID
	JOIN WideWorldImporters.Warehouse.StockItems AS SI
	ON SI.StockItemID = OL.StockItemID
	JOIN WideWorldImporters.Warehouse.PackageTypes AS PT
	ON PT.PackageTypeID = OL.PackageTypeID
	JOIN WideWorldImporters.Sales.Customers AS C
	ON C.CustomerID = O.CustomerID 

GO

--DROP TABLE WideWorldImportersDW.Integration.ExtractOrder_Staging;
--GO

CREATE TABLE WideWorldImportersDW.Integration.ExtractOrder_Staging(
	DeliveryCityID INT,
	CustomerID INT,
	StockItemID INT ,
	OrderDate DATE ,
	[Picked Date Key] DATE ,
	SalespersonPersonID INT ,
	PickedByPersonID INT ,
	OrderID INT,
	BackorderOrderID INT ,
	StockItemName NVARCHAR(MAX),
	PackageTypeName NVARCHAR(50),
	Quantity INT,
	UnitPrice DECIMAL(18,2),
	TaxRate DECIMAL(18,3),
	TaxAmount DECIMAL(18,2)
);  

INSERT INTO WideWorldImportersDW.Integration.ExtractOrder_Staging      
    EXEC dbo.ExtractOrder ;


--------------------------------------------TRANSFORM--------------------------------------


--DROP PROCEDURE dbo.TrasformOrder;
--GO

CREATE PROCEDURE dbo.TrasformOrder
AS
	 SELECT 
	 DeliveryCityID,
	 CustomerID,
	 StockItemID,
	 OrderDate,
	 [Picked Date Key],
	 SalespersonPersonID,
	 PickedByPersonID,
	 OrderID,
	 BackorderOrderID,
	 StockItemName,
	 PackageTypeName,
	 Quantity,
	 UnitPrice,
	 TaxRate,
	 Quantity*UnitPrice  AS [Total Excluding Tax],
	 TaxAmount,
	 Quantity*UnitPrice + TaxAmount AS [Total Including Tax]
	 FROM WideWorldImportersDW.Integration.ExtractOrder_Staging  

GO

--DROP TABLE WideWorldImportersDW.Integration.TransformOrder_Staging;

CREATE TABLE WideWorldImportersDW.Integration.TransformOrder_Staging(
	DeliveryCityID INT,
	CustomerID INT,
	StockItemID INT ,
	OrderDate DATE ,
	[Picked Date Key] DATE ,
	SalespersonPersonID INT ,
	PickedByPersonID INT ,
	OrderID INT,
	BackorderOrderID INT ,
	StockItemName NVARCHAR(MAX),
	PackageTypeName NVARCHAR(50),
	Quantity INT,
	UnitPrice DECIMAL(18,2),
	TaxRate DECIMAL(18,3),
	[Total Excluding Tax] DECIMAL(18,3),
	TaxAmount DECIMAL(18,2),
	[Total Including Tax] DECIMAL(18,3)
);  

INSERT INTO  WideWorldImportersDW.Integration.TransformOrder_Staging   
	EXEC dbo.TrasformOrder;

DROP TABLE WideWorldImportersDW.Integration.ExtractOrder_Staging;
--------------------------------------------LOAD--------------------------------------------------


--DROP PROCEDURE dbo.LoadOrder;

CREATE PROCEDURE dbo.LoadOrder
AS
	INSERT INTO WideWorldImportersDW.Fact.[Order](
	 [City Key],
	 [Customer Key],
	 [Stock Item Key],
	 [Order Date Key],
	 [Picked Date Key],
	 [Salesperson Key],
	 [Picker Key],
	 [WWI Order ID],
	 [WWI Backorder ID],
	 [Description],
	 [Package],
	 Quantity,
	 [Unit Price],
	 [Tax Rate],
	 [Total Excluding Tax],
	 [Tax Amount],
	 [Total Including Tax],
	 [Lineage Key])

	SELECT
	 City.[City Key],
	 ISNULL(C.[Customer Key],0) AS [Customer Key],
	 SI.[Stock Item Key],
	 OrderDate AS [Order Date Key],
	 [Picked Date Key],
	 E.[Employee Key] AS [Salesperson Key],
	 EE.[Employee Key] AS [Picker Key],
	 OrderID AS [WWI Order ID],
	 BackorderOrderID AS [WWI Backorder ID],
	 StockItemName AS [Description],
	 PackageTypeName AS [Package],
	 Quantity,
	 UnitPrice AS [Unit Price],
	 TaxRate AS [Tax Rate],
	 [Total Excluding Tax],
	 TaxAmount AS [Tax Amount],
	 [Total Including Tax],
	 9
	FROM WideWorldImportersDW.Integration.TransformOrder_Staging    AS A
	LEFT JOIN WideWorldImportersDW.Dimension.Customer AS C
	ON A.CustomerID = C.[WWI Customer ID] AND C.[Valid To]='9999-12-31 23:59:59.9999999'
	LEFT JOIN WideWorldImportersDW.Dimension.[Stock Item] AS SI
	ON SI.[WWI Stock Item ID] = A.StockItemID AND SI.[Valid To] = '9999-12-31 23:59:59.9999999'
	LEFT JOIN WideWorldImportersDW.Dimension.Employee AS E
	ON E.[WWI Employee ID] = A.SalespersonPersonID AND E.[Valid To] = '9999-12-31 23:59:59.9999999'
	LEFT JOIN WideWorldImportersDW.Dimension.Employee AS EE
	ON EE.[WWI Employee ID] = A.PickedByPersonID AND EE.[Valid To] = '9999-12-31 23:59:59.9999999'
	LEFT JOIN WideWorldImportersDW.Dimension.City AS City
	ON City.[WWI City ID] = A.DeliveryCityID AND City.[Valid To] = '9999-12-31 23:59:59.9999999'


EXEC dbo.LoadOrder
DROP TABLE WideWorldImportersDW.Integration.TransformOrder_Staging;