USE AdventureWorks2012;
GO

/*
DECLARE @begin_time AS DATETIME = DATEADD(DAY, -10, GETDATE());
DECLARE @end_time AS DATETIME = GETDATE();
EXEC dbo.CDC_GetHREmployee @begin_time, @end_time;
*/

ALTER PROCEDURE dbo.CDC_GetHREmployee
(
	@begin_time DATETIME,
	@end_time	DATETIME
)
AS
BEGIN

	-- Map the time intervals to a CDC query range, using LSNs
	DECLARE @from_lsn AS BINARY(10) = sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', @begin_time);
	DECLARE @to_lsn AS BINARY(10) = sys.fn_cdc_map_time_to_lsn('largest less than or equal', @end_time);
	DECLARE @min_lsn AS BINARY(10) = sys.fn_cdc_get_min_lsn('HumanResources_Employee');

	IF (@from_lsn < @min_lsn)
	BEGIN
		SET @from_lsn = @min_lsn;
	END

	-- Get the ordinal positions of the columns you want to track
	DECLARE @hiredate_ord INT = sys.fn_cdc_get_column_ordinal(N'HumanResources_Employee', N'HireDate');
	DECLARE @vac_hr_ord INT = sys.fn_cdc_get_column_ordinal(N'HumanResources_Employee', N'VacationHours');

	-- Return all changes and flags to tell us if HireDate & VacationHours changed
	SELECT
		BusinessEntityID,
		BirthDate,
		HireDate,
		VacationHours,
		[HireDateChng] = sys.fn_cdc_is_bit_set(@hiredate_ord, [__$update_mask]),
		[VacHrsChng] = sys.fn_cdc_is_bit_set(@vac_hr_ord, [__$update_mask]),
		[_Operation] = [__$operation]
	FROM
		cdc.fn_cdc_get_net_changes_HumanResources_Employee(@from_lsn, @to_lsn, N'all with mask');

	SET NOCOUNT OFF;

END
