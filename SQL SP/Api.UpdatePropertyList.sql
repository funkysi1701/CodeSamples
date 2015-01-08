
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Api].[UpdatePropertyList]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [Api].[UpdatePropertyList]
GO

-- =============================================
-- Author:		Simon Foster
-- Create date: 30/10/2014
-- Description:	Update part of the contents of PropertyImport into Property
--				
-- =============================================
CREATE Procedure [Api].[UpdatePropertyList]
(
    @Id int,
	@Type int, -- 1 to 10 selecting which part to update
	--@Update nvarchar(100) --value we want to update to
	@JoinType int -- see compare type for explanation 0 compare by postcode, 1 by propertyref, 2 by postcode and propertyref
    
)
AS
BEGIN
	DECLARE @Result int
	If(@JoinType=1)
	BEGIN
		IF(@Type=1)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.CustomerRef = dbo.PropertyImport.CustomerRef
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=2)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Name = dbo.PropertyImport.Name
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=3)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Description = dbo.PropertyImport.Description
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=4)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Address = dbo.PropertyImport.Address
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=5)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.City = dbo.PropertyImport.City
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=6)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.County = dbo.PropertyImport.City
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=7)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.PostCode = dbo.PropertyImport.PostCode
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=8)
		BEGIN
			SELECT	@Result = COUNT(*)
			FROM	dbo.PropertyContact
			JOIN	dbo.Property
			ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'PROPERTY'
			WHERE	dbo.Property.Id = @Id
			If(@Result=1)
			BEGIN
				UPDATE	dbo.PropertyContact
				SET		dbo.PropertyContact.Tel = dbo.PropertyImport.Tel
				FROM	dbo.PropertyContact
				JOIN	dbo.Property
				ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'PROPERTY'
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				WHERE	dbo.Property.Id = @Id
			END
			If(@Result=0)
			BEGIN
				INSERT INTO	dbo.PropertyContact (PropertyId,RoleId,Tel) 
				SELECT	@Id,'PROPERTY',dbo.PropertyImport.Tel
				FROM	dbo.Property
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				WHERE	dbo.Property.Id = @Id
			END
			--WHERE	PropertyId = @Id and RoleID = 'PROPERTY'
		END
		IF(@Type=9)
		BEGIN
			SELECT	@Result = COUNT(*)
			FROM	dbo.PropertyContact
			JOIN	dbo.Property
			ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'MAIN'
			WHERE	dbo.Property.Id = @Id
			If(@Result=1)
			BEGIN
				UPDATE	dbo.PropertyContact
				SET		dbo.PropertyContact.Name = dbo.PropertyImport.ContactName
				FROM	dbo.PropertyContact
				JOIN	dbo.Property
				ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'MAIN'
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				WHERE	dbo.Property.Id = @Id
			END
			If(@Result=0)
			BEGIN
				INSERT INTO	dbo.PropertyContact (PropertyId,RoleId,Name) 
				SELECT	@Id,'MAIN',dbo.PropertyImport.ContactName
				FROM	dbo.Property
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				WHERE	dbo.Property.Id = @Id
			END
		END
		IF(@Type=10)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.CustomerRegion = dbo.PropertyImport.RegionName
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			WHERE	dbo.Property.Id = @Id
		END
	END
	If(@JoinType=0)
	BEGIN
		IF(@Type=1)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.CustomerRef = dbo.PropertyImport.CustomerRef
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=2)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Name = dbo.PropertyImport.Name
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=3)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Description = dbo.PropertyImport.Description
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=4)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Address = dbo.PropertyImport.Address
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=5)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.City = dbo.PropertyImport.City
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=6)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.County = dbo.PropertyImport.City
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=7)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.PostCode = dbo.PropertyImport.PostCode
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=8)
		BEGIN
			SELECT	@Result = COUNT(*)
			FROM	dbo.PropertyContact
			JOIN	dbo.Property
			ON		dbo.PropertyContact.PropertyId = dbo.Property.Id and RoleID = 'PROPERTY'
			WHERE	dbo.Property.Id = @Id
			If(@Result=1)
			BEGIN
				UPDATE	dbo.PropertyContact
				SET		dbo.PropertyContact.Tel = dbo.PropertyImport.Tel
				FROM	dbo.PropertyContact
				JOIN	dbo.Property
				ON		dbo.PropertyContact.PropertyId = dbo.Property.Id and RoleID = 'PROPERTY'
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.PostCode = dbo.Property.PostCode
				WHERE	dbo.Property.Id = @Id
			END
			If(@Result=0)
			BEGIN
				INSERT INTO	dbo.PropertyContact (PropertyId,RoleId,Tel) 
				SELECT	@Id,'PROPERTY',dbo.PropertyImport.Tel
				FROM	dbo.Property
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
				WHERE	dbo.Property.Id = @Id
			END
		END
		IF(@Type=9)
		BEGIN
			SELECT	@Result = COUNT(*)
			FROM	dbo.PropertyContact
			JOIN	dbo.Property
			ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'MAIN'
			WHERE	dbo.Property.Id = @Id
			If(@Result=1)
			BEGIN
				UPDATE	dbo.PropertyContact
				SET		dbo.PropertyContact.Name = dbo.PropertyImport.ContactName
				FROM	dbo.PropertyContact
				JOIN	dbo.Property
				ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'MAIN'
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
				WHERE	dbo.Property.Id = @Id
			END
			If(@Result=0)
			BEGIN
				INSERT INTO	dbo.PropertyContact (PropertyId,RoleId,Name) 
				SELECT	@Id,'MAIN',dbo.PropertyImport.ContactName
				FROM	dbo.Property
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
				WHERE	dbo.Property.Id = @Id
			END
		END
		IF(@Type=10)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.CustomerRegion = dbo.PropertyImport.RegionName
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
	END
	If(@JoinType=2)
	BEGIN
		IF(@Type=1)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.CustomerRef = dbo.PropertyImport.CustomerRef
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=2)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Name = dbo.PropertyImport.Name
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=3)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Description = dbo.PropertyImport.Description
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=4)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.Address = dbo.PropertyImport.Address
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=5)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.City = dbo.PropertyImport.City
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=6)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.County = dbo.PropertyImport.City
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=7)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.PostCode = dbo.PropertyImport.PostCode
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
		IF(@Type=8)
		BEGIN
			SELECT	@Result = COUNT(*)
			FROM	dbo.PropertyContact
			JOIN	dbo.Property
			ON		dbo.PropertyContact.PropertyId = dbo.Property.Id and RoleID = 'PROPERTY'
			WHERE	dbo.Property.Id = @Id
			If(@Result=1)
			BEGIN
				UPDATE	dbo.PropertyContact
				SET		dbo.PropertyContact.Tel = dbo.PropertyImport.Tel
				FROM	dbo.PropertyContact
				JOIN	dbo.Property
				ON		dbo.PropertyContact.PropertyId = dbo.Property.Id and RoleID = 'PROPERTY'
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.PostCode = dbo.Property.PostCode
				AND		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				WHERE	dbo.Property.Id = @Id
			END
			If(@Result=0)
			BEGIN
				INSERT INTO	dbo.PropertyContact (PropertyId,RoleId,Tel) 
				SELECT	@Id,'PROPERTY',dbo.PropertyImport.Tel
				FROM	dbo.Property
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
				AND		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				WHERE	dbo.Property.Id = @Id
			END
		END
		IF(@Type=9)
		BEGIN
			SELECT	@Result = COUNT(*)
			FROM	dbo.PropertyContact
			JOIN	dbo.Property
			ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'MAIN'
			WHERE	dbo.Property.Id = @Id
			If(@Result=1)
			BEGIN
				UPDATE	dbo.PropertyContact
				SET		dbo.PropertyContact.Name = dbo.PropertyImport.ContactName
				FROM	dbo.PropertyContact
				JOIN	dbo.Property
				ON		dbo.PropertyContact.PropertyId =  dbo.Property.Id and RoleID = 'MAIN'
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
				WHERE	dbo.Property.Id = @Id
			END
			If(@Result=0)
			BEGIN
				INSERT INTO	dbo.PropertyContact (PropertyId,RoleId,Name) 
				SELECT	@Id,'MAIN',dbo.PropertyImport.ContactName
				FROM	dbo.Property
				JOIN	dbo.PropertyImport
				ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
				AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
				WHERE	dbo.Property.Id = @Id
			END
		END
		IF(@Type=10)
		BEGIN
			UPDATE	dbo.Property
			SET		dbo.Property.CustomerRegion = dbo.PropertyImport.RegionName
			FROM	dbo.Property
			JOIN	dbo.PropertyImport
			ON		dbo.PropertyImport.CustomerRef =  dbo.Property.CustomerRef
			AND		dbo.PropertyImport.PostCode =  dbo.Property.PostCode
			WHERE	dbo.Property.Id = @Id
		END
	END
END
GO
