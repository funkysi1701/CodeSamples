
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TR_UpdateOrderNo]'))
	DROP TRIGGER [dbo].[TR_UpdateOrderNo]
GO

-- =============================================
-- Author:		Simon Foster
-- Create date: 04/06/2013
-- Description:	Copies altered OrderNos to 
--				property table
-- =============================================
CREATE TRIGGER [dbo].[TR_UpdateOrderNo]
ON [dbo].[FutureManagements]
AFTER Update
AS
BEGIN 
	IF UPDATE (OrderNo)
	BEGIN
		UPDATE dbo.Property 
		SET dbo.Property.OrderNo = i.OrderNo
		FROM dbo.Property p JOIN Inserted i
		ON i.Id = p.Id
	END
END

GO
