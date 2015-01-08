
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[api].[GenerateBulkInvoice]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [api].[GenerateBulkInvoice]
GO

-- =============================================
-- Author:      Simon Foster
-- Create date: 21/06/2013
-- Description: SP that creates an Bulk Invoices
-- =============================================
CREATE Procedure [Api].[GenerateBulkInvoice]
(
		@OrderNos nvarchar(max), 
		@StartInvoiceNumber int,
		@InvoiceName nvarchar(255),
		@InvoiceAddress nvarchar(255),
		@InvoiceCity nvarchar(255),
		@InvoiceCounty nvarchar(255),
		@InvoicePostCode nvarchar(255),
		@CustomerRefs nvarchar(max)
)
AS
BEGIN
	SET NOCOUNT ON
	
    DECLARE @T TABLE (Id int IDENTITY,OrderNo nvarchar(255),CustomerRef nvarchar(255))
    INSERT INTO @T (CustomerRef) SELECT string FROM dbo.splitstring(@CustomerRefs, ',')
    
	DECLARE @NumOfInvoices INT 
	SELECT @NumOfInvoices = count(*) FROM @T
	
	DECLARE @Counter int
	SET @Counter = @StartInvoiceNumber
	
	DECLARE @Results TABLE (CustomerId int,
							CustomerName nvarchar(255),
							InvoiceName nvarchar(255),
							CustomerAddress nvarchar(255),
							CustomerCity nvarchar(255),
							CustomerPostCode nvarchar(255),
							MiscInfo nvarchar(max),
							PropertyId int,
							SurveyId int,
							PN int,
							PropertyName nvarchar(255),	
							LBOName nvarchar(255),
							PropertyAddress nvarchar(255),
							PropertyCity nvarchar(255),
							PropertyPostCode nvarchar(255),
							CustomerRef nvarchar(255),
							PManager nvarchar(255),
							Undertaken datetime,
							Surveyor nvarchar(255),
							NextDue datetime,
							OrderNo nvarchar(255),
							AdditionalSamples int,
							Amount money,
							InvoiceNumber int,
							InvoiceAddress nvarchar(255),
							InvoiceCity nvarchar(255),
							InvoiceCounty nvarchar(255),
							InvoicePostCode nvarchar(255))

	WHILE @Counter < @StartInvoiceNumber + @NumOfInvoices

	BEGIN

		DECLARE @OrderNo nvarchar(255)
		--SELECT @OrderNo = OrderNo FROM @T WHERE Id = @Counter - @StartInvoiceNumber + 1
		
		DECLARE @CustomerRef nvarchar(255)
		SELECT @CustomerRef = CustomerRef FROM @T WHERE Id = @Counter - @StartInvoiceNumber + 1

		SELECT TOP 1 @OrderNo = OrderNo from api.ManagementReinspectionOrders where CustomerRef = @CustomerRef order by undertaken desc
		
		DECLARE @CustomerId int
		SELECT TOP 1 @CustomerId = CustomerId from api.ManagementReinspectionOrders where CustomerRef = @CustomerRef order by undertaken desc
		
		DECLARE @NumOfOrders int
		SELECT @NumOfOrders = count(*) from api.ManagementReinspectionOrders where CustomerRef = @CustomerRef

		--DECLARE @NumOfOrders2 int
		--SELECT @NumOfOrders2 = count(*) from api.ManagementReinspectionOrders where OrderNo = @OrderNo
--print @CustomerRef
		IF(@CustomerId = 251 and @NumOfOrders = 1) 
		BEGIN
			INSERT INTO @Results
			SELECT	c.Id as CustomerId,
					c.CustomerName as CustomerName,
					@InvoiceName as InvoiceName,
					c.Address as CustomerAddress,
					c.City as CustomerCity,
					c.PostCode as CustomerPostCode,
					c.MiscInfo,
					m.PropertyId,
					m.SurveyId,
					m.PN,
					m.Name as PropertyName,
					substring	
						(substring
							(m.Name, 
							charindex('(', m.Name), 
							charindex(')', m.Name) - charindex('(', m.Name) +1),
						2,
						len
							(substring
								(m.Name, 
								charindex('(', m.Name), 
								charindex(')', m.Name) - charindex('(', m.Name) +1)
							) -2) 
					AS LBOName, -- this bit I have stack overflow to thank and a bit of tweaking by me. It gets the property name and just displays the LBO Name.
					m.Address as PropertyAddress,
					m.City as PropertyCity,
					m.PostCode as PropertyPostCode,
					m.CustomerRef,
					m.PManager,
					m.Undertaken,
					m.Surveyor,
					m.NextDue,
					m.OrderNo,
					m.AdditionalSamples,
					m.Amount,
					@Counter AS InvoiceNumber,
					@InvoiceAddress AS InvoiceAddress,
					@InvoiceCity AS InvoiceCity,
					@InvoiceCounty AS InvoiceCounty,
					@InvoicePostCode AS InvoicePostCode
			FROM	api.AllCustomerAddress c
			JOIN	api.ManagementReinspectionOrders m on c.Id = m.CustomerId
			WHERE	CustomerRef = @CustomerRef
		END
		If(@CustomerId != 251 and @NumOfOrders = 1)
		BEGIN
			INSERT INTO @Results
			SELECT	c.Id as CustomerId,
					c.CustomerName as CustomerName,
					@InvoiceName as InvoiceName,
					c.Address as CustomerAddress,
					c.City as CustomerCity,
					c.PostCode as CustomerPostCode,
					c.MiscInfo,
					m.PropertyId,
					m.SurveyId,
					m.PN,
					m.Name as PropertyName,
					m.Name AS LBOName, 
					m.Address as PropertyAddress,
					m.City as PropertyCity,
					m.PostCode as PropertyPostCode,
					m.CustomerRef,
					m.PManager,
					m.Undertaken,
					m.Surveyor,
					m.NextDue,
					m.OrderNo,
					m.AdditionalSamples,
					m.Amount,
					@Counter AS InvoiceNumber,
					@InvoiceAddress AS InvoiceAddress,
					@InvoiceCity AS InvoiceCity,
					@InvoiceCounty AS InvoiceCounty,
					@InvoicePostCode AS InvoicePostCode
			FROM	api.AllCustomerAddress c
			JOIN	api.ManagementReinspectionOrders m on c.Id = m.CustomerId
			WHERE	CustomerRef = @CustomerRef
		END
		If(@CustomerId != 251 and @NumOfOrders > 1)
		BEGIN
			INSERT INTO @Results
			SELECT	c.Id as CustomerId,
					c.CustomerName as CustomerName,
					@InvoiceName as InvoiceName,
					c.Address as CustomerAddress,
					c.City as CustomerCity,
					c.PostCode as CustomerPostCode,
					c.MiscInfo,
					m.PropertyId,
					m.SurveyId,
					m.PN,
					m.Name as PropertyName,
					m.Name AS LBOName, 
					m.Address as PropertyAddress,
					m.City as PropertyCity,
					m.PostCode as PropertyPostCode,
					m.CustomerRef,
					m.PManager,
					m.Undertaken,
					m.Surveyor,
					m.NextDue,
					m.OrderNo,
					m.AdditionalSamples,
					m.Amount,
					@Counter AS InvoiceNumber,
					@InvoiceAddress AS InvoiceAddress,
					@InvoiceCity AS InvoiceCity,
					@InvoiceCounty AS InvoiceCounty,
					@InvoicePostCode AS InvoicePostCode
			FROM	api.AllCustomerAddress c
			JOIN	api.ManagementReinspectionOrders m on c.Id = m.CustomerId
			WHERE	m.CustomerRef = @CustomerRef 
			AND 	m.OrderNo = @OrderNo
		END
		IF(@CustomerId = 251 and @NumOfOrders > 1) 
		BEGIN
			INSERT INTO @Results
			SELECT	c.Id as CustomerId,
					c.CustomerName as CustomerName,
					@InvoiceName as InvoiceName,
					c.Address as CustomerAddress,
					c.City as CustomerCity,
					c.PostCode as CustomerPostCode,
					c.MiscInfo,
					m.PropertyId,
					m.SurveyId,
					m.PN,
					m.Name as PropertyName,
					substring	
						(substring
							(m.Name, 
							charindex('(', m.Name), 
							charindex(')', m.Name) - charindex('(', m.Name) +1),
						2,
						len
							(substring
								(m.Name, 
								charindex('(', m.Name), 
								charindex(')', m.Name) - charindex('(', m.Name) +1)
							) -2) 
					AS LBOName, -- this bit I have stack overflow to thank and a bit of tweaking by me. It gets the property name and just displays the LBO Name.
					m.Address as PropertyAddress,
					m.City as PropertyCity,
					m.PostCode as PropertyPostCode,
					m.CustomerRef,
					m.PManager,
					m.Undertaken,
					m.Surveyor,
					m.NextDue,
					m.OrderNo,
					m.AdditionalSamples,
					m.Amount,
					@Counter AS InvoiceNumber,
					@InvoiceAddress AS InvoiceAddress,
					@InvoiceCity AS InvoiceCity,
					@InvoiceCounty AS InvoiceCounty,
					@InvoicePostCode AS InvoicePostCode
			FROM	api.AllCustomerAddress c
			JOIN	api.ManagementReinspectionOrders m on c.Id = m.CustomerId
			WHERE	m.CustomerRef = @CustomerRef 
			AND 	m.OrderNo = @OrderNo
		END

		SET @Counter = @Counter + 1
	END
	SELECT * FROM @Results
END



GO
