
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Api].[ContaminationReportNoActions]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [Api].[ContaminationReportNoActions]
GO

-- =============================================
-- Author:      Simon Foster
-- Create date: 15/05/2013
-- Description:  All contaminations for particular client
--               where no pas involvement
--               
--              

-- =============================================
CREATE PROCEDURE [Api].[ContaminationReportNoActions]

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
		c.pasPN as [PAS PN]
		
	FROM api.Properties p
	JOIN dbo.Contaminations c on c.PropertyId = p.Id
	--LEFT JOIN dbo.ContaminationComment cc on cc.ContaminationId = c.Id
	WHERE p.CustomerId = @CustomerId
	AND c.paspn is null
	AND c.status = 1
	AND p.disposed =0
	AND c.datecleaned is null
	AND c.superseded = 0
END



GO
