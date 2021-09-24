
--11.	List all the cities that were updated after 2015-01-01.

--SELECT
--   CityName
--FROM Application.Cities
--WHERE ValidFrom> '2015-01-01'

USE WideWorldImporters;
GO

SELECT 
	CityName
FROM Application.Cities
FOR SYSTEM_TIME CONTAINED IN ('2015-01-01', '9999-12-31 23:59:59.9999999')