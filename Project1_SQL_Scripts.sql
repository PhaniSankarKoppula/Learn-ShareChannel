CREATE TABLE [dbo].[Raw_Sales](
	[Transaction Date] [date] NULL,
	[Shipment Date] [date] NULL,
	[Product] [nvarchar](255) NULL,
	[Product Line] [nvarchar](255) NULL,
	[Model Name] [nvarchar](255) NULL,
	[Subcategory] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Seller Country] [nvarchar](255) NULL,
	[Seller Customer] [nvarchar](255) NULL,
	[Buyer Country] [nvarchar](255) NULL,
	[Sales] [money] NULL,
	[Sales Quantity] [float] NULL,
	[Buyer Customer] [varchar](250) NULL,
	[Seller Customer Code] [varchar](50) NULL,
	[Buyer Customer Code] [varchar](50) NULL,
	[Seller Country Code] [varchar](10) NULL,
	[Buyer Country Code] [varchar](10) NULL,
	[Sales In Net USD] [decimal](32, 2) NULL,
	[Sales In NDP USD] [decimal](32, 2) NULL,
	[Sales In ASP USD] [decimal](32, 2) NULL,
	[Sales Base Qty] [float] NULL,
	[Sales Prod Qty] [float] NULL
) ON [PRIMARY]
GO

GO
-- Fact Table
	-- Sales
		--[Transaction Date](FK)
		--Seller Customer Code(FK)
		--Buyer Customer Code(FK)
		--Seller Geo Code(FK)
		--Buyer Geo Code(FK)
		--Product (FK)
		--Sales In Net USD
		--Sales In NDP USD
		--Sales In ASP USD
		--Sales Base Qty
		--Sales Prod Qty
		--DataLoad_TimeStamp

--Dimension Tables.

	--Time
		--[Transaction Date](PK)
		--CY_Month
		--CY_Quarter
		--CY_HalfYear
		--CY_Year
		--FY_Month
		--FY_Quarter
		--FY_HalfYear
		--FY_Year
		--DataLoad_TimeStamp

	--Seller Customer
		--Seller Customer Code(PK)
		--Seller Customer Name
		--DataLoad_TimeStamp
	--Buyer Customer
		--Buyer Customer Code(PK)
		--Buyer Customer Name
		--DataLoad_TimeStamp
	--Seller Geo
		--Seller Geo Code(PK)
		--Seller Geo Country
		--Seller Sub Region
		--Seller Region
		--DataLoad_TimeStamp
	--Buyer Geo
		--Buyer Geo Code(PK)
		--Buyer Country
		--Buyer Sub Region
		--Buyer Region
		--DataLoad_TimeStamp
	--Product
		--Product (PK)
		--Product Line
		--Model Name
		--SubCategory
		--Category
		--DataLoad_TimeStamp

--Fact Tables
drop table if exists Fact_Sales
go
Create Table Fact_Sales([Transaction Date] date,SellerCustomerCode Varchar(75),BuyerCustomerCode Varchar(75),SellerGeoCode varchar(10)
,BuyerGeoCode varchar(10),Product varchar(75),SalesInNetUSD decimal(32,2),SalesInNDPUSD decimal(32,2),SalesInASPUSD decimal(32,2)
,SalesBaseQty float,SalesProdQty float,DataLoad_TimeStamp datetime)
go
insert into Fact_Sales
SELECT [Transaction Date]
,[Seller Customer Code]
,[Buyer Customer Code]
,[Seller Country Code]
,[Buyer Country Code]
,[Product]      
,[Sales In Net USD]
,[Sales In NDP USD]
,[Sales In ASP USD]
,[Sales Base Qty]
,[Sales Prod Qty]
,getdate()
  FROM [POC].[dbo].[Raw_Sales]

--Dimension Tables
drop table if exists DimTime
GO
Create table DimTime (
 [Transaction Date] date
,CY_Month varchar(25)
,CY_Quarter varchar(25)
,CY_HalfYear varchar(25)
,CY_Year varchar(25)
,FY_Month varchar(25)
,FY_Quarter varchar(25)
,FY_HalfYear varchar(25)
,FY_Year varchar(25)
,DataLoad_TimeStamp datetime)
GO
insert into DimTime
select Cast(PK_Date as Date) as Date,
[Month_Name] as CY_Month,
[Quarter_Name] as CY_Quarter,
[Half_Year_Name] as CY_HalfYear,
[Year_Name] as CY_Year,
[Fiscal_Month_Name] as FY_Month,
[Fiscal_Quarter_Name] as FY_Quarter,
[Fiscal_Half_Year_Name] as FY_HalfYear,
[Fiscal_Year_Name] as FY_Year
,getdate()
from time


drop table if exists DimSellerCustomer
GO
Create table DimSellerCustomer (
		 [SellerCustomerCode] Varchar(75)
		,[SellerCustomerName] varchar(250)
		,[DataLoad_TimeStamp] datetime)
GO
insert into DimSellerCustomer
select distinct [Seller Customer Code],[Seller Customer], getdate() FROM [POC].[dbo].[Raw_Sales]


drop table if exists DimBuyerCustomer
GO
Create table DimBuyerCustomer (
		 [BuyerCustomerCode] Varchar(75)
		,[BuyerCustomerName] varchar(250)
		,[DataLoad_TimeStamp] datetime)
GO
insert into DimBuyerCustomer
select distinct [Buyer Customer Code],[Buyer Customer], getdate() FROM [POC].[dbo].[Raw_Sales]

drop table if exists DimSellerGeo
GO
Create table DimSellerGeo(
		 [Seller Geo Code] varchar(10)
		,[Seller Geo Country] varchar(75)
		,[Seller Sub Region] varchar(75)
		,[Seller Region] varchar(75)
		,[DataLoad_TimeStamp] datetime)
GO
Insert into DimSellerGeo
SELECT distinct 
		[Seller Country Code],
       [Seller Country],
	   Case 
	   when [Seller Country Code]='AU' then 'Australia'
	   when [Seller Country Code]='BE' then 'Central Europe'
	   when [Seller Country Code]='CA' then 'North America'
	   when [Seller Country Code]='FR' then 'North Europe'
	   when [Seller Country Code]='UK' then 'United Kingdom'
	   when [Seller Country Code]='US' then 'North America' end ,
	   	   Case 
	   when [Seller Country Code]='AU' then 'Asiapacific'
	   when [Seller Country Code]='BE' then 'Europe'
	   when [Seller Country Code]='CA' then 'Americas'
	   when [Seller Country Code]='FR' then 'Europe'
	   when [Seller Country Code]='UK' then 'Europe'
	   when [Seller Country Code]='US' then 'Americas' end ,
	   Getdate()
  FROM [POC].[dbo].[Raw_Sales]

drop table if exists DimBuyerGeo
GO
Create table DimBuyerGeo(
		 [Buyer Geo Code] varchar(10)
		,[Buyer Geo Country] varchar(75)
		,[Buyer Sub Region] varchar(75)
		,[Buyer Region] varchar(75)
		,[DataLoad_TimeStamp] datetime)
GO
Insert into DimBuyerGeo	
SELECT distinct 
		[Buyer Country Code],
       [Buyer Country],
	   Case 
	   when [Buyer Country Code]='AU' then 'Australia'
	   when [Buyer Country Code]='BE' then 'Central Europe'
	   when [Buyer Country Code]='CA' then 'North America'
	   when [Buyer Country Code]='FR' then 'North Europe'
	   when [Buyer Country Code]='UK' then 'United Kingdom'
	   when [Buyer Country Code]='US' then 'North America' end ,
	   	   Case 
	   when [Buyer Country Code]='AU' then 'Asiapacific'
	   when [Buyer Country Code]='BE' then 'Europe'
	   when [Buyer Country Code]='CA' then 'Americas'
	   when [Buyer Country Code]='FR' then 'Europe'
	   when [Buyer Country Code]='UK' then 'Europe'
	   when [Buyer Country Code]='US' then 'Americas' end ,
	   Getdate()
  FROM [POC].[dbo].[Raw_Sales]


drop table if exists DimProduct
GO
Create table DimProduct(
		 [Product] varchar(75)
		,[Product Line] varchar(75)
		,[Model Name] varchar(75)
		,[SubCategory] varchar(75)
		,[Category] varchar(75)
		,[DataLoad_TimeStamp] datetime)
GO
insert into DimProduct  
SELECT distinct 
       [Product]
      ,[Product Line]
      ,[Model Name]
      ,[Subcategory]
      ,[Category]
	  ,getdate()
  FROM [POC].[dbo].[Raw_Sales]


select * from [dbo].[Fact_Sales]
select * from [dbo].[DimBuyerCustomer]
select * from [dbo].[DimBuyerGeo]
select * from [dbo].[DimProduct]
select * from [dbo].[DimSellerCustomer]
select * from [dbo].[DimSellerGeo]
select * from [dbo].[DimTime]


