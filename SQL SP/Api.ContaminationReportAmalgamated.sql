
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Api].[ContaminationReportAmalgamated]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [Api].[ContaminationReportAmalgamated]
GO

CREATE PROCEDURE [Api].[ContaminationReportAmalgamated]
(
      @CustomerId INT
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
		
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				' ' as clientinformed,
				' ' as requestdate,
				' ' as contractoranalystinformedtostart,
				' ' as contractorstartdateconfirmed,
				' ' as contractorcompletiondateconfirmed,
				' ' as areaclosed,
				'New Contamination' as status
				
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		WHERE p.CustomerId = @CustomerId
		AND c.datereported BETWEEN @from AND @to
		AND c.status = 1
		AND p.disposed =0
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				' ' as clientinformed,
				' ' as requestdate,
				' ' as contractoranalystinformedtostart,
				' ' as contractorstartdateconfirmed,
				' ' as contractorcompletiondateconfirmed,
				' ' as areaclosed,
				'Contamination Cleaned' as status
				
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		WHERE p.CustomerId = @CustomerId
		AND c.datecleaned BETWEEN @from AND @to
		AND c.status = 1
		AND p.disposed =0
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				' ' as clientinformed,
				' ' as requestdate,
				' ' as contractoranalystinformedtostart,
				' ' as contractorstartdateconfirmed,
				' ' as contractorcompletiondateconfirmed,
				' ' as areaclosed,
				'No Action' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		WHERE p.CustomerId = @CustomerId
		AND c.paspn is null
		AND c.status = 1
		AND p.disposed =0
		AND c.datecleaned is null
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				ppre.clientinformed,
				pest.requestdate,
				ppre.contractoranalystinformedtostart,
				pcomp.contractorstartdateconfirmed,
				pcomp.contractorcompletiondateconfirmed,
				c.areaclosed,
				'Costs requested' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		JOIN projectdiary.dbo.PAS_Estimate PEst on PEst.projectnumber = c.pasPN
		JOIN projectdiary.dbo.PAS_PreStartView PPre on PEst.projectnumber = ppre.projectnumber
		JOIN projectdiary.dbo.PAS_Core PCore	on pest.projectnumber = pcore.projectnumber 	
		JOIN projectdiary.dbo.PAS_Completion PComp on pcomp.projectnumber = pest.projectnumber
		WHERE p.CustomerId = @CustomerId
		AND	pest.requestdate is not null
		AND pcomp.contractorstartdateconfirmed is null
		AND ppre.contractoranalystinformedtostart is null
		AND ppre.clientinformed is null
		AND pest.EstimateNumber = 1
		AND c.status = 1
		AND p.disposed =0
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				ppre.clientinformed,
				pest.requestdate,
				ppre.contractoranalystinformedtostart,
				pcomp.contractorstartdateconfirmed,
				pcomp.contractorcompletiondateconfirmed,
				c.areaclosed,
				'Costs with Client' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		JOIN projectdiary.dbo.PAS_Estimate PEst on PEst.projectnumber = c.pasPN
		JOIN projectdiary.dbo.PAS_PreStartView PPre on PEst.projectnumber = ppre.projectnumber
		JOIN projectdiary.dbo.PAS_Core PCore	on pest.projectnumber = pcore.projectnumber 	
		JOIN projectdiary.dbo.PAS_Completion PComp on pcomp.projectnumber = pest.projectnumber
		WHERE p.CustomerId = @CustomerId
		AND	pest.requestdate is not null
		AND pcomp.contractorstartdateconfirmed is null
		AND ppre.contractoranalystinformedtostart is null
		AND ppre.clientinformed is not null
		AND pest.EstimateNumber = 1
		AND c.status = 1
		AND p.disposed = 0
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				ppre.clientinformed,
				pest.requestdate,
				ppre.contractoranalystinformedtostart,
				pcomp.contractorstartdateconfirmed,
				pcomp.contractorcompletiondateconfirmed,
				c.areaclosed,
				'Awaiting Start Date' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		JOIN projectdiary.dbo.PAS_Estimate PEst on PEst.projectnumber = c.pasPN
		JOIN projectdiary.dbo.PAS_PreStartView PPre on PEst.projectnumber = ppre.projectnumber
		JOIN projectdiary.dbo.PAS_Core PCore	on pest.projectnumber = pcore.projectnumber 	
		JOIN projectdiary.dbo.PAS_Completion PComp on pcomp.projectnumber = pest.projectnumber
		WHERE p.CustomerId = @CustomerId
		AND	pest.requestdate is not null
		AND pcomp.contractorstartdateconfirmed is null
		AND ppre.contractoranalystinformedtostart is not null
		AND ppre.clientinformed is not null
		AND pest.EstimateNumber = 1
		AND c.status = 1
		AND p.disposed =0
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				ppre.clientinformed,
				pest.requestdate,
				ppre.contractoranalystinformedtostart,
				pcomp.contractorstartdateconfirmed,
				pcomp.contractorcompletiondateconfirmed,
				c.areaclosed,
				'Contractor Start Date' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		JOIN projectdiary.dbo.PAS_Estimate PEst on PEst.projectnumber = c.pasPN
		JOIN projectdiary.dbo.PAS_PreStartView PPre on PEst.projectnumber = ppre.projectnumber
		JOIN projectdiary.dbo.PAS_Core PCore	on pest.projectnumber = pcore.projectnumber 	
		JOIN projectdiary.dbo.PAS_Completion PComp on pcomp.projectnumber = pest.projectnumber
		WHERE p.CustomerId = @CustomerId
		AND	pest.requestdate is not null
		AND pcomp.contractorstartdateconfirmed is not null
		AND ppre.contractoranalystinformedtostart is not null
		AND ppre.clientinformed is not null
		AND pest.EstimateNumber = 1
		AND c.status = 1
		AND p.disposed =0
		AND	pcomp.contractorcompletiondateconfirmed > getdate()
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				ppre.clientinformed,
				pest.requestdate,
				ppre.contractoranalystinformedtostart,
				pcomp.contractorstartdateconfirmed,
				pcomp.contractorcompletiondateconfirmed,
				c.areaclosed,
				'Awaiting Paperwork' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		JOIN projectdiary.dbo.PAS_Estimate PEst on PEst.projectnumber = c.pasPN
		JOIN projectdiary.dbo.PAS_PreStartView PPre on PEst.projectnumber = ppre.projectnumber
		JOIN projectdiary.dbo.PAS_Core PCore	on pest.projectnumber = pcore.projectnumber 	
		JOIN projectdiary.dbo.PAS_Completion PComp on pcomp.projectnumber = pest.projectnumber
		WHERE p.CustomerId = @CustomerId
		AND	pcomp.contractorcompletiondateconfirmed is not null
		AND pest.EstimateNumber = 1
		AND	(c.areaclosed = 0 Or c.areaclosed is null)
		AND PCore.Status != 'Completed'
		AND PComp.ContractorCompletionDateConfirmed < getdate()
		AND c.status = 1
		AND c.datecleaned is null
		AND p.disposed =0
		AND c.superseded = 0
	UNION ALL
		SELECT	p.customerref,
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
				--c.status,
				c.datecleaned,
				p.projectnos as [Asbestos PN],
				c.pasPN as [PAS PN],
				ppre.clientinformed,
				pest.requestdate,
				ppre.contractoranalystinformedtostart,
				pcomp.contractorstartdateconfirmed,
				pcomp.contractorcompletiondateconfirmed,
				c.areaclosed,
				'In Sealed Area' as status
		
		FROM api.Properties p
		JOIN dbo.Contaminations c on c.PropertyId = p.Id
		--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
		JOIN projectdiary.dbo.PAS_Estimate PEst on PEst.projectnumber = c.pasPN
		JOIN projectdiary.dbo.PAS_PreStartView PPre on PEst.projectnumber = ppre.projectnumber
		JOIN projectdiary.dbo.PAS_Core PCore	on pest.projectnumber = pcore.projectnumber 	
		JOIN projectdiary.dbo.PAS_Completion PComp on pcomp.projectnumber = pest.projectnumber
		WHERE p.CustomerId = @CustomerId
		AND	c.areaclosed = 1
		AND pest.EstimateNumber = 1
		AND c.status = 1
		AND p.disposed =0
		AND c.superseded = 0
END



GO


