--EXEC sp_changedbowner 'sa'

--EXEC sys.sp_cdc_enable_db;

--SELECT database_id, name, is_cdc_enabled FROM sys.databases ORDER BY name;

--EXECUTE sys.sp_cdc_enable_table @source_schema = 'HumanResources',         -- sysname
--                                @source_name = 'Employee',           -- sysname
--                                @capture_instance = 'HumanResources_Employee',      -- sysname
--                                @supports_net_changes = 1,  -- bit
--                                @role_name = 'cdc_Admin'             -- sysname
 
 --SELECT name, is_tracked_by_cdc FROM sys.tables;

 --EXEC sys.sp_cdc_help_change_data_capture @source_schema = 'HumanResources', -- sysname
 --                                         @source_name = 'Employee'    -- sysname
 
 SELECT * FROM cdc.HumanResources_Employee_CT

 --UPDATE HumanResources.Employee
 --SET HireDate = DATEADD(DAY, 1, HireDate)
 --WHERE BusinessEntityID IN (1, 2, 3);

 -------------------------------------------------------------------------------------------------------------

 BEGIN

	DECLARE @beginTime AS DATETIME = GETDATE() - 7;
	DECLARE @endTime AS DATETIME = GETDATE();
	DECLARE @fromLSN AS BINARY(10) = sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', @beginTime);
	DECLARE @toLSN AS BINARY(10) = sys.fn_cdc_map_time_to_lsn('largest less than or equal', @endTime);

	SELECT @fromLSN;

	SELECT * FROM cdc.fn_cdc_get_net_changes_HumanResources_Employee(@fromLSN, @toLSN, N'all with mask');

 END

 -------------------------------------------------------------------------------------------------------------

 BEGIN

	--UPDATE HumanResources.Employee
	--SET VacationHours = VacationHours + 1
	--WHERE BusinessEntityID IN (3, 4, 5);

	--WAITFOR DELAY '00:00:10';

	DECLARE @beginTime AS DATETIME = GETDATE() - 10;
	DECLARE @endTime AS DATETIME = GETDATE();
	DECLARE @fromLSN AS BINARY(10) = sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', @beginTime);
	DECLARE @toLSN AS BINARY(10) = sys.fn_cdc_map_time_to_lsn('largest less than or equal', @endTime);

	DECLARE @hiredate_ord INT = sys.fn_cdc_get_column_ordinal(N'HumanResources_Employee', N'HireDate');
	DECLARE @vacHr_ord INT = sys.fn_cdc_get_column_ordinal(N'HumanResources_Employee', N'VacationHours');

	SELECT
		BusinessEntityID,
		sys.fn_cdc_is_bit_set(@hiredate_ord, __$update_mask) AS [HireDateChange],
		sys.fn_cdc_is_bit_set(@vacHr_ord, __$update_mask) AS [VacHoursChange],
		*
	FROM cdc.fn_cdc_get_all_changes_HumanResources_Employee(@fromLSN, @toLSN, N'all');

 END

 -------------------------------------------------------------------------------------------------------------

SELECT * FROM HumanResources.Employee WHERE BusinessEntityID = 291;

--INSERT INTO HumanResources.Employee
--(
--	BusinessEntityID,
--    NationalIDNumber,
--    LoginID,
--    OrganizationNode,
--    JobTitle,
--    BirthDate,
--    MaritalStatus,
--    Gender,
--    HireDate,
--    SalariedFlag,
--    VacationHours,
--    SickLeaveHours,
--    CurrentFlag,
--    rowguid,
--    ModifiedDate
--)
--VALUES
--(   291,
--	N'123456789',       -- NationalIDNumber - nvarchar(15)
--    N'adventure-works\jim01',       -- LoginID - nvarchar(256)
--    NULL,      -- OrganizationNode - hierarchyid
--    N'3',       -- JobTitle - nvarchar(50)
--    '1980-01-10', -- BirthDate - date
--    N'S',       -- MaritalStatus - nchar(1)
--    N'M',       -- Gender - nchar(1)
--    '2018-09-01', -- HireDate - date
--    1,      -- SalariedFlag - Flag
--    120,         -- VacationHours - smallint
--    40,         -- SickLeaveHours - smallint
--    1,      -- CurrentFlag - Flag
--    NEWID(),      -- rowguid - uniqueidentifier
--    GETDATE()  -- ModifiedDate - datetime
--   )


UPDATE HumanResources.Employee 
SET JobTitle = 'Design Engineer'
WHERE BusinessEntityID = 291;

SELECT * FROM HumanResources.Employee WHERE BusinessEntityID = 291;

--DELETE FROM HumanResources.Employee WHERE BusinessEntityID = 291;

--------------------------------------------------------------------------------------------------------------

