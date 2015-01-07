
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Api].[ContaminationReportAction5]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [Api].[ContaminationReportAction5]
GO

-- =============================================
-- Author:      Simon Foster
-- Create date: 15/05/2013
-- Description:  All contaminations for particular client
--               PAS 5 
--               
--              

-- =============================================
CREATE PROCEDURE [Api].[ContaminationReportAction5]

(
      @CustomerId		INT



)
AS
BEGIN



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
		ppre.clientinformed,
		pest.requestdate,
		ppre.contractoranalystinformedtostart,
		pcomp.contractorstartdateconfirmed,
		pcomp.contractorcompletiondateconfirmed,
		c.areaclosed
		
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
END



GO
