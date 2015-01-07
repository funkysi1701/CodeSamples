
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Api].[ContaminationReportAffectsTrade]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [Api].[ContaminationReportAffectsTrade]
GO

-- =============================================
-- Author:      Simon Foster
-- Create date: 15/05/2013
-- Description:  All contaminations for particular client
--               where no pas involvement
--               
--              

-- =============================================
CREATE PROCEDURE [Api].[ContaminationReportAffectsTrade]

(
      @CustomerId		INT
	, @fromy INT
	, @fromm INT
	, @fromd INT
	, @toy INT
	, @tom INT
	, @tod INT


)
AS
BEGIN

	-- data validation; ensure we can build a date from these values
	IF @fromm  NOT BETWEEN 1 AND 12 OR
       @tom NOT BETWEEN 1 AND 12
		RAISERROR('@fromm and @tom must be between 1 and 12 inclusive', 16, 1)
    
    IF @fromy  < 1753 OR
       @toy < 1753
        RAISERROR('@fromy and @toy must be later than 1753; SQL Server can''t handle dates earlier than 1753', 16, 1)

    -- now we compute the dates from the parameters
	DECLARE @from DATETIME, @to DATETIME

	SELECT @from = DATEADD(YEAR, @fromy - 1753, '1753-01-01')
	SELECT @from = DATEADD(MONTH, @fromm - 1, @from)
	SELECT @from = DATEADD(DAY, @fromd - 1, @from)

	SELECT @to = DATEADD(YEAR, @toy - 1753, '1753-01-01')
	SELECT @to = DATEADD(MONTH, @tom - 1, @to)
	SELECT @to = DATEADD(DAY, @tod - 1, @to)	-- last day of previous month
    
    -- final validation of dates
    IF @from > @to
        RAISERROR('From must be before To', 16, 1)

select	p.customerref,
		p.customer,
		p.name,
		p.address,
		p.city,
		p.county,
		p.postcode,
		p.telephone,
		p.propertymanager,
		c.id as [Contamination Number],
		(SELECT top 1 Comment FROM dbo.ContaminationComment cc WHERE cc.ContaminationId = c.Id) as comment,
		c.datereported,
		c.status,
		c.datecleaned,
		p.projectnos as [Asbestos PN],
		c.pasPN as [PAS PN],
		* 
	FROM api.Properties p
	JOIN dbo.Contaminations c on c.PropertyId = p.Id
	--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
	WHERE p.CustomerId = @CustomerId
	AND c.datereported between @from and @to
	AND c.status = 1
	AND p.disposed =0
	AND c.superseded = 0
	AND c.affecttrade = 1
END



GO
