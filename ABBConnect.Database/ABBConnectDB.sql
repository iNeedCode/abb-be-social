USE [master]
GO
/****** Object:  Database [ABBConnect]    Script Date: 2014-01-13 20:52:10 ******/
CREATE DATABASE [ABBConnect] ON  PRIMARY 
( NAME = N'ABBConnect', FILENAME = N'E:\MSSQL\DATA\ABBConnect.mdf' , SIZE = 34816KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ABBConnect_log', FILENAME = N'E:\MSSQL\DATA\ABBConnect_log.ldf' , SIZE = 20096KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [ABBConnect] SET COMPATIBILITY_LEVEL = 90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ABBConnect].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ABBConnect] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ABBConnect] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ABBConnect] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ABBConnect] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ABBConnect] SET ARITHABORT OFF 
GO
ALTER DATABASE [ABBConnect] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ABBConnect] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [ABBConnect] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ABBConnect] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ABBConnect] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ABBConnect] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ABBConnect] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ABBConnect] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ABBConnect] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ABBConnect] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ABBConnect] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ABBConnect] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ABBConnect] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ABBConnect] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ABBConnect] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ABBConnect] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ABBConnect] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ABBConnect] SET RECOVERY FULL 
GO
ALTER DATABASE [ABBConnect] SET  MULTI_USER 
GO
ALTER DATABASE [ABBConnect] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ABBConnect] SET DB_CHAINING OFF 
GO
USE [ABBConnect]
GO
/****** Object:  StoredProcedure [dbo].[AddCommentToFeed]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Adds a comment to an already existing feed>
-- =============================================
CREATE PROCEDURE [dbo].[AddCommentToFeed]
	@feedId int,
	@username nvarchar(50),
	@text nvarchar(MAX)
AS
BEGIN
	Declare @UserID int
	Set @UserID = (select Id from [User] where name = @username)

	INSERT INTO FeedComments (FeedId, UserId, CreationTimeStamp, CommentText, isVisible, isRead)
	VALUES (@feedId, @UserID, GETDATE(), @text, 1, 0)

	DECLARE @orginUser nvarchar(50)
	SET @orginUser = (select (FirstName + ' ' + Lastname) as Name from Human join Feed on Feed.FeedPublisherId = Human.UserId where Feed.Id = @feedId)

	INSERT INTO Activity
	VALUES (@UserID, @feedID, 'Comment', 'Added a comment to a feed by ' + @orginUser, GETDATE())


END

GO
/****** Object:  StoredProcedure [dbo].[AddFeed]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Adds a new feed to the system>
-- =============================================
CREATE PROCEDURE [dbo].[AddFeed]
	@UserId int,
	@text nvarchar(MAX),
	@filePath nvarchar(MAX),
	@feedPriorityId int,
	@retFeedId int output
AS
BEGIN

	Declare @timestamp datetime
	Set @timestamp = GETDATE()

	INSERT INTO Feed (FeedPublisherId ,CreationTimeStamp ,isVisible ,Text, FilePath, FeedPriorityId, FeedType)
	VALUES (@UserID, @timestamp, 1, @text, @filePath, @feedPriorityId, 'Human');

	SET @retFeedId = (select Id from Feed where FeedPublisherId = @UserId and CreationTimeStamp = @timestamp);

	
	INSERT INTO Activity
	VALUES (@UserId, @retFeedId, 'Feed', 'Posted a feed', GETDATE())

END

GO
/****** Object:  StoredProcedure [dbo].[AddFollowSensor]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Connects a human with a sensor, to enable following>
-- =============================================
CREATE PROCEDURE [dbo].[AddFollowSensor]
@HumanUserId int,
@SensorUserId int
AS
BEGIN
	
	declare @humanId int
	declare @sensorId int

	SET @humanId = (Select Id FROM Human where UserId = @HumanUserId)
	SET @sensorId = (Select Id FROM Sensor where UserId = @SensorUserId)

	INSERT INTO FollowedSensor
	VALUES (@humanId, @sensorId)

END

GO
/****** Object:  StoredProcedure [dbo].[AddImageToFeed]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Adds a base64 string representing an image to a feed>
-- =============================================
CREATE PROCEDURE [dbo].[AddImageToFeed] 
	@feedID int,
	@image nvarchar(MAX)
AS
BEGIN
	UPDATE Feed
	SET FilePath=@image
	WHERE Id = @feedID
END

GO
/****** Object:  StoredProcedure [dbo].[AddSensorValues]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Add the sensor raw value to the database and if the rawvalue is outside of the boudery, a feed is created>
-- =============================================
CREATE PROCEDURE [dbo].[AddSensorValues] 

	@sensorID int,
	@data int
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @timestamp datetime
	SET @timestamp = GetDate();
	
	INSERT INTO SensorData (SensorId ,CreationTimeStamp ,RawValue)
	VALUES (@sensorID, @timestamp, @data);

	DECLARE @MAX Decimal, @MIN Decimal

	SET @MAX = (select MAX_Critical from Sensor where Id = @sensorID);
	SET @MIN = (select MIN_Critical from Sensor where Id = @sensorID);

	if (@data > @MAX OR @data < @MIN) --check if sensor value is outside of the bounderies
	BEGIN
		DECLARE @Uid int
		SET @Uid = (select UserId from Sensor where Id = @sensorId)

		INSERT INTO Feed (FeedPublisherId ,CreationTimeStamp ,isVisible ,Text, FilePath, FeedPriorityId, FeedType)
		VALUES (@Uid, @timestamp, 1, 'An alarm has occured, with the value: ' + convert(nvarchar(6), @data), '', 1, 'Sensor');


	END 

END

GO
/****** Object:  StoredProcedure [dbo].[AddTagToFeed]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Add a human or sensor tag to a feed>
-- =============================================
CREATE PROCEDURE [dbo].[AddTagToFeed]
	@feedId int,
	@username nvarchar(50)

AS
BEGIN
	Declare @UserID int
	Set @UserID = (select Id from [User] where name = @username)

	INSERT INTO Tags (FeedId, UserId)
	VALUES (@feedId, @UserId)

	DECLARE @orginUser nvarchar(50)
	SET @orginUser = (select (FirstName + ' ' + Lastname) as Name from Human join Feed on Feed.FeedPublisherId = Human.UserId where Feed.Id = @feedId)

	INSERT INTO Activity
	VALUES (@UserID, @feedID, 'Tag', 'Got tagged in a feed by ' + @orginUser, GETDATE())

END

GO
/****** Object:  StoredProcedure [dbo].[AddUserAvatar]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Adds the profile picture to a user by adding a base64 string>
-- =============================================
CREATE PROCEDURE [dbo].[AddUserAvatar]
 @userID int,
 @image nvarchar(MAX)
AS
BEGIN
	UPDATE dbo.[User]
	SET [Image] = @image
	WHERE Id = @userID
END

GO
/****** Object:  StoredProcedure [dbo].[AddUserSavedFilter]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Adds a filter to a user>
-- =============================================
CREATE PROCEDURE [dbo].[AddUserSavedFilter]
@UserId int,
@FilterName nvarchar(50),
@StartDate datetime  = NULL,
@EndDate datetime = NULL,
@Location nvarchar(50) = NULL,
@Type nvarchar(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO SavedFilter
	VALUES (@UserId, @FilterName, @StartDate, @EndDate, @Location, @Type)


	select Id from SavedFilter where FilterName = @FilterName

END

GO
/****** Object:  StoredProcedure [dbo].[AddUserToSavedFilter]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Adds another user that the an user want to retrevie feeds from in his filter>
-- =============================================
CREATE PROCEDURE [dbo].[AddUserToSavedFilter]
@UserId int,
@FilterId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	INSERT INTO UserFilter 
	VALUES (@FilterId, @UserId)
END

GO
/****** Object:  StoredProcedure [dbo].[GetAllSensors]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Returns all the sensors that are stored in the database>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllSensors]
AS
BEGIN
	Select S.Id, Name, MIN_Critical, MAX_Critical From Sensor S join [User] U on S.UserId = U.Id

	SET NOCOUNT ON;

END

GO
/****** Object:  StoredProcedure [dbo].[GetFeedByFeedId]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Returns feed information from a specifc feed ID>
-- =============================================
CREATE PROCEDURE [dbo].[GetFeedByFeedId] 
	@feedId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT * from FeedView where FeedId = @feedId
END

GO
/****** Object:  StoredProcedure [dbo].[GetFeedComments]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Get all the comments that are connected to a specific feed ID>
-- =============================================

CREATE PROCEDURE [dbo].[GetFeedComments]
	@feedId int
AS
BEGIN
	select H.FirstName, H.LastName, U.Name as UserName, C.CommentText, C.CreationTimeStamp from 
				[User] U join Human H on H.UserId = U.id join FeedComments C on C.UserId = U.Id join Feed F on F.Id = C.FeedId 
				where F.Id = @feedId and C.IsVisible = 1
				ORDER BY C.CreationTimeStamp DESC

END
GO
/****** Object:  StoredProcedure [dbo].[GetFeedsFromLastShift]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetFeedsFromLastShift] 
@numOfFeeds int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.


	SET NOCOUNT ON;
	
	DECLARE @start_date DATETIME
	DECLARE @end_date DATETIME
	DECLARE @nowTime int
	-- GEt THE CURreNT HOur
	SET @nowTime = (SELECT CONVERT(int, CONVERT(VARCHAR(2), GETDATE() ,108)))
	
	-- SHIFT A 07 - 16
	-- SHIFT B 17 - 00
	-- SHIFT C 01 - 07

	IF (@nowTime >= 1 and @nowTime < 7)
	BEGIN
		SET @start_date = DATEADD(hour, 17, DATEDIFF(DAY, 1, GETDATE()))
		SET @end_date = DATEADD(hour, 01, DATEDIFF(DAY, 0, GETDATE()))
	END
	ELSE IF (@nowTime >= 7 and @nowTime <= 16)
	BEGIN
		SET @start_date = DATEADD(hour, 01, DATEDIFF(DAY, 0, GETDATE()))
		SET @end_date = DATEADD(hour, 07, DATEDIFF(DAY, 0, GETDATE()))
	END
	ELSE IF (@nowTime >= 16 or @nowTime <= 0)
	BEGIN
		SET @start_date = DATEADD(hour, 07, DATEDIFF(DAY, 0, GETDATE()))
		SET @end_date = DATEADD(hour, 16, DATEDIFF(DAY, 0, GETDATE()))
	END

	select Top (CASE WHEN (@numOfFeeds is not null) then @numOfFeeds else 2147483647 end) * from FeedView 
									Where
									CreationTimeStamp <= @end_date and 
									CreationTimeStamp >= @start_date 
	ORDER BY PrioValue DESC, CreationTimeStamp DESC
	

END

GO
/****** Object:  StoredProcedure [dbo].[GetFeedTags]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Returns all users that have been taged in a specifc feed ID>
-- =============================================
CREATE PROCEDURE [dbo].[GetFeedTags]
@feedId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select UserName, FirstName, LastName, UserId from FeedTags where Id = @feedId
END

                        
GO
/****** Object:  StoredProcedure [dbo].[GetFollowedSensors]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Get all the sensors that a specific user is following>
-- =============================================
CREATE PROCEDURE [dbo].[GetFollowedSensors]
@HumanUserId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @humanId int
	SET @humanId = (Select Id FROM Human where UserId = @HumanUserId)
	Select s.UserId from FollowedSensor f join Sensor s on f.SensorId = s.Id where HumanId = @humanId
END

GO
/****** Object:  StoredProcedure [dbo].[GetHistoricalDataFromSensor]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Gets all data from a specific sensor in a specific time-range>
-- =============================================
CREATE PROCEDURE [dbo].[GetHistoricalDataFromSensor]
	@sensorID int,
	@from datetime,
	@to datetime
AS
BEGIN
	SET NOCOUNT ON;

	select RawValue, CreationTimeStamp  from SensorData SD join Sensor S on SD.SensorId = S.Id join [User] U on S.UserId = U.Id where U.Id = @sensorID and CreationTimestamp >= @from and CreationTimestamp <= @to  ORDER BY CreationTimeStamp DESC

END

GO
/****** Object:  StoredProcedure [dbo].[GetHumanInformation]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	Get all human information from a specific user ID>
-- =============================================
CREATE PROCEDURE [dbo].[GetHumanInformation]
	@UserId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Name, FirstName, LastName, PhoneNumber, Email, Location,U.[Image] from Human H join [User] U on H.UserId = U.Id  Where U.Id = @UserId
END

GO
/****** Object:  StoredProcedure [dbo].[GetHumanInformationByUsername]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	Get all human information from a specific username>
-- =============================================
CREATE PROCEDURE [dbo].[GetHumanInformationByUsername]
	@UserName nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT U.Id, Name, FirstName, LastName, PhoneNumber, Email, Location, U.[Image] from Human H join [User] U on H.UserId = U.Id  Where U.Name = @UserName
END

GO
/****** Object:  StoredProcedure [dbo].[GetLatestSensorValue]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Gets the latest value published by a specific sensor ID>
-- =============================================
CREATE PROCEDURE [dbo].[GetLatestSensorValue]
	@sensorID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP 1 RawValue from SensorData SD join Sensor S on SD.SensorId = S.Id join [User] U on S.UserId = U.Id where U.Id = @sensorID ORDER BY CreationTimeStamp DESC
END

GO
/****** Object:  StoredProcedure [dbo].[GetLocations]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetLocations]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Place from Location
END

GO
/****** Object:  StoredProcedure [dbo].[GetPriorityCategories]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Get all the categories that a human can post as>
-- =============================================

CREATE PROCEDURE [dbo].[GetPriorityCategories]
AS
BEGIN
	select Id, Name from FeedPriority Where Name  not like 'Sensor%'
END

GO
/****** Object:  StoredProcedure [dbo].[GetSensorInformation]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Get information about a specific sensor ID>
-- =============================================
CREATE PROCEDURE [dbo].[GetSensorInformation] 
	@sensorID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select U.Id, Metric as Unit, Name, MIN_Critical, MAX_Critical, Location, U.[Image] from Sensor S join [User] U on S.UserId = U.Id  Where U.Id = @sensorID
END


GO
/****** Object:  StoredProcedure [dbo].[GetUserActivity]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description  <Get all the user activites, except the ones that a post has been published>
-- =============================================
CREATE PROCEDURE [dbo].[GetUserActivity]
@userId int
AS
BEGIN
	select *  from Activity where UserId = @userID and ([Type] = 'Comment' or [Type] = 'Tag') ORDER BY [Timestamp] DESC
							
END

GO
/****** Object:  StoredProcedure [dbo].[GetUserSavedFilters]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Gets all the filters that an user has saved>
-- =============================================
CREATE PROCEDURE [dbo].[GetUserSavedFilters]
@UserId int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select * from SavedFilter where UserId = @UserId
END

GO
/****** Object:  StoredProcedure [dbo].[GetUserSavedFiltersTagedUsers]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Get the userd that are added in a specific filter>
-- =============================================

CREATE PROCEDURE [dbo].[GetUserSavedFiltersTagedUsers]
@FilterId int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select us.Id, us.Name, h.FirstName, h.LastName from UserFilter u join SavedFilter s on u.FilterId = s.ID join [User] us on u.UserId = us.Id left join Human h on us.Id = h.UserId  where u.FilterId = @FilterId
END
GO
/****** Object:  StoredProcedure [dbo].[GetUsersByName]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Searches on all users in the system based on there username, firstname and lastname>
-- =============================================
CREATE PROCEDURE [dbo].[GetUsersByName] 
@query nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select U.Id, Name, H.FirstName, H.LastName, U.isHuman from [User] U left join Human H on U.Id = H.UserId where
																							 U.Name like '%' + @query + '%' or
																							 h.FirstName like '%' + @query + '%' or
																							 h.LastName like '%' + @query + '%'

END

GO
/****** Object:  StoredProcedure [dbo].[GetXFeedsByFilter]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Get feeds with a specific filter and any combination of those
--					- from a specific user	
--					- from a specific location
--					- from a specific time range
--					- from a specific type of feed
--					- from a specific type of posting category
--					- from a specific starting ID
--					- a certain amount of feeds
--				this method is the core method the retreive feeds from the system
--				>
-- =============================================
CREATE PROCEDURE [dbo].[GetXFeedsByFilter]
@UserId int  = NULL,
@location nvarchar(50)  = NULL,
@startTime datetime = NULL, 
@endTime datetime = NULL,
@feedType nvarchar(50) = NULL,
@feedCategoryName nvarchar(50) = NULL,
@startingFeedId int = NULL,
@numOfFeeds int = NULL
AS
BEGIN
	IF @startingfeedId is NULL
	BEGIN
		SET @startingFeedId = 2147483647 /*int max*/
	END


	select Top (CASE WHEN (@numOfFeeds is not null) then @numOfFeeds else 2147483647 end) * from FeedView 
										where Location = CASE WHEN (@location is not NULL) then @location else Location end and
										CreationTimeStamp <= CASE WHEN (@endTime is not NULL) then  @endTime else CreationTimeStamp end and 
										CreationTimeStamp >= CASE WHEN (@startTime is not NULL) then @startTime else CreationTimeStamp end and
										UserId = CASE WHEN (@UserId is not NULL) then @UserId else UserId end and
										[Type] = CASE WHEN (@feedType is not NULL) then @feedType else [Type] end and
										FeedId < CASE WHEN (@startingFeedId is not NULL) then @startingFeedId else FeedId end and
										PrioCategory = CASE WHEN (@feedCategoryName is not NULL) then @feedCategoryName else PrioCategory end
	ORDER BY CreationTimeStamp DESC, PrioValue DESC

END

GO
/****** Object:  StoredProcedure [dbo].[GetXUserActivities]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetXUserActivities]
@userId int,
@numOfActivites int = NULL,
@startingId int = NULL
AS
BEGIN
	select Top (CASE WHEN (@numOfActivites is not null) then @numOfActivites else 2147483647 end) *  from Activity 
					where UserId = @userID and
					Id < CASE WHEN (@startingId is not NULL) then @startingId else FeedId end
					ORDER BY [Timestamp] DESC						
END

GO
/****** Object:  StoredProcedure [dbo].[Login]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<check the credentials inserted by a user, if correct return 1, otherwise 0>
-- =============================================
CREATE PROCEDURE [dbo].[Login]
	-- Add the parameters for the stored procedure here
	@username nvarchar(50),
	@password nvarchar(50),
	@ret int output
AS
BEGIN

    SELECT U.Name, FirstName, LastName, PhoneNumber, Email from Human H join [User] U on H.UserId = U.Id Where U.Name = @username and H.[Password] = @password
    if(@@rowcount >0)
        begin
            set @ret=1
        end
    else
        begin
            set @ret=0
        end
END

GO
/****** Object:  StoredProcedure [dbo].[RemoveFollowSensor]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Unfollow a specific sensor>
-- =============================================
CREATE PROCEDURE [dbo].[RemoveFollowSensor]
@HumanUserId int,
@SensorUserId int
AS
BEGIN
	
	declare @humanId int
	declare @sensorId int

	SET @humanId = (Select Id FROM Human where UserId = @HumanUserId)
	SET @sensorId = (Select Id FROM Sensor where UserId = @SensorUserId)

	DELETE FROM FollowedSensor
	WHERE HumanId=@humanId AND SensorId=@sensorId;

END

GO
/****** Object:  StoredProcedure [dbo].[SetBounderyValue]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Robert Gustavsson>
-- Create date: <2014-01-13>
-- Description:	<Updates the boundery of an sensor and creates a feed with the new changes>
-- =============================================
CREATE PROCEDURE [dbo].[SetBounderyValue]
	-- Add the parameters for the stored procedure here
	@sensorID int,
	@lBoundery decimal,
	@uBoundery decimal
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE Sensor
	SET MIN_Critical=@lBoundery, MAX_Critical=@uBoundery
	WHERE Id = @sensorID;

	DECLARE @Uid int
	SET @Uid = (select UserId from Sensor where Id = @sensorId)

	INSERT INTO Feed (FeedPublisherId ,CreationTimeStamp ,isVisible ,Text, FilePath, FeedPriorityId, FeedType)
	VALUES (@Uid, GETDATE(), 1, 'The sensor boundery has changed. lower boundery: ' + convert(nvarchar(6), @lBoundery) + ' upper boundery: '  + convert(nvarchar(6), @uBoundery), '', 5, 'Sensor');
END

GO
/****** Object:  Table [dbo].[Activity]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activity](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[FeedId] [int] NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_Activity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ActivityType]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityType](
	[Type] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ActivityType] PRIMARY KEY CLUSTERED 
(
	[Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Feed]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feed](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FeedPublisherId] [int] NOT NULL,
	[CreationTimeStamp] [datetime] NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[Text] [nvarchar](max) NULL,
	[FilePath] [nvarchar](max) NULL,
	[FeedType] [nvarchar](50) NULL,
	[FeedPriorityId] [int] NOT NULL,
 CONSTRAINT [PK_Feed] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedComments]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedComments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FeedId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[CommentText] [nvarchar](1000) NOT NULL,
	[CreationTimeStamp] [datetime] NOT NULL,
	[isRead] [int] NULL,
	[IsVisible] [bit] NOT NULL,
 CONSTRAINT [PK_FeedComments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedContainedGroups]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedContainedGroups](
	[Id] [int] NOT NULL,
	[FeedId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
 CONSTRAINT [PK_FeedContainedGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedDataType]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedDataType](
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_FeedDataType_1] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedGroup]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedGroup](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_FeedGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeedPriority]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeedPriority](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Value] [int] NOT NULL,
 CONSTRAINT [PK_FeedPriority] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FollowedSensor]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FollowedSensor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[HumanId] [int] NOT NULL,
	[SensorId] [int] NOT NULL,
 CONSTRAINT [PK_FollowedSensor] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Human]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Human](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[BirthDate] [datetime] NOT NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Location]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location](
	[Place] [nvarchar](50) NOT NULL,
	[Coordinates] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[Place] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SavedFilter]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SavedFilter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[FilterName] [nvarchar](50) NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Location] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
 CONSTRAINT [PK_SavedFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sensor]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor](
	[Id] [int] NOT NULL,
	[Metric] [nvarchar](5) NOT NULL,
	[MIN_Critical] [decimal](18, 2) NULL,
	[MAX_Critical] [decimal](18, 2) NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_Sensor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SensorData]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SensorData](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SensorId] [int] NOT NULL,
	[CreationTimeStamp] [datetime] NULL,
	[RawValue] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SensorData] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Tags]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FeedId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[User]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Location] [nvarchar](50) NOT NULL,
	[isActive] [bit] NOT NULL,
	[Image] [nvarchar](max) NULL,
	[isHuman] [bit] NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserFilter]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFilter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FilterID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
 CONSTRAINT [PK_UserFilter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserFollowedGroups]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFollowedGroups](
	[Id] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[GroupId] [int] NOT NULL,
	[CreationTimeSpan] [int] NOT NULL,
	[IsMandatory] [bit] NOT NULL,
 CONSTRAINT [PK_UserFollowedGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[FeedTags]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FeedTags]
AS
SELECT        dbo.[User].Name AS UserName, dbo.Human.FirstName, dbo.Human.LastName, dbo.Feed.Id, dbo.[User].Id AS UserId
FROM            dbo.Feed INNER JOIN
                         dbo.Tags ON dbo.Feed.Id = dbo.Tags.FeedId INNER JOIN
                         dbo.[User] ON dbo.Tags.UserId = dbo.[User].Id INNER JOIN
                         dbo.Human ON dbo.[User].Id = dbo.Human.UserId

GO
/****** Object:  View [dbo].[FeedView]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FeedView]
AS
SELECT        dbo.[User].Name AS Username, dbo.[User].Id AS UserId, dbo.FeedDataType.Name AS Type, dbo.Feed.CreationTimeStamp, dbo.Feed.Text, dbo.Feed.FilePath, dbo.FeedPriority.Name AS PrioCategory, 
                         dbo.FeedPriority.Value AS PrioValue, dbo.Feed.Id AS FeedId, dbo.[User].Location
FROM            dbo.Feed INNER JOIN
                         dbo.FeedDataType ON dbo.Feed.FeedType = dbo.FeedDataType.Name INNER JOIN
                         dbo.FeedPriority ON dbo.Feed.FeedPriorityId = dbo.FeedPriority.Id INNER JOIN
                         dbo.[User] ON dbo.Feed.FeedPublisherId = dbo.[User].Id

GO
/****** Object:  View [dbo].[HumanUser]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[HumanUser]
AS
SELECT        dbo.[User].Id, dbo.[User].Name, dbo.Human.FirstName, dbo.Human.LastName, dbo.Human.PhoneNumber, dbo.Human.Email, dbo.[User].Location
FROM            dbo.Human INNER JOIN
                         dbo.[User] ON dbo.Human.UserId = dbo.[User].Id

GO
/****** Object:  View [dbo].[SensorUser]    Script Date: 2014-01-13 20:52:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SensorUser]
AS
SELECT        dbo.[User].Name, dbo.Sensor.MIN_Critical, dbo.Sensor.MAX_Critical, dbo.Sensor.Metric, dbo.[User].Location
FROM            dbo.Sensor INNER JOIN
                         dbo.[User] ON dbo.Sensor.UserId = dbo.[User].Id

GO
ALTER TABLE [dbo].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_ActivityType] FOREIGN KEY([Type])
REFERENCES [dbo].[ActivityType] ([Type])
GO
ALTER TABLE [dbo].[Activity] CHECK CONSTRAINT [FK_Activity_ActivityType]
GO
ALTER TABLE [dbo].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_Feed] FOREIGN KEY([FeedId])
REFERENCES [dbo].[Feed] ([Id])
GO
ALTER TABLE [dbo].[Activity] CHECK CONSTRAINT [FK_Activity_Feed]
GO
ALTER TABLE [dbo].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Activity] CHECK CONSTRAINT [FK_Activity_User]
GO
ALTER TABLE [dbo].[Feed]  WITH CHECK ADD  CONSTRAINT [FK_Feed_FeedDataType] FOREIGN KEY([FeedType])
REFERENCES [dbo].[FeedDataType] ([Name])
GO
ALTER TABLE [dbo].[Feed] CHECK CONSTRAINT [FK_Feed_FeedDataType]
GO
ALTER TABLE [dbo].[Feed]  WITH CHECK ADD  CONSTRAINT [FK_Feed_FeedPriority] FOREIGN KEY([FeedPriorityId])
REFERENCES [dbo].[FeedPriority] ([Id])
GO
ALTER TABLE [dbo].[Feed] CHECK CONSTRAINT [FK_Feed_FeedPriority]
GO
ALTER TABLE [dbo].[FeedComments]  WITH CHECK ADD  CONSTRAINT [FK_FeedComments_Feed] FOREIGN KEY([FeedId])
REFERENCES [dbo].[Feed] ([Id])
GO
ALTER TABLE [dbo].[FeedComments] CHECK CONSTRAINT [FK_FeedComments_Feed]
GO
ALTER TABLE [dbo].[FeedContainedGroups]  WITH CHECK ADD  CONSTRAINT [FK_FeedContainedGroups_FeedGroup] FOREIGN KEY([GroupId])
REFERENCES [dbo].[FeedGroup] ([Id])
GO
ALTER TABLE [dbo].[FeedContainedGroups] CHECK CONSTRAINT [FK_FeedContainedGroups_FeedGroup]
GO
ALTER TABLE [dbo].[FollowedSensor]  WITH CHECK ADD  CONSTRAINT [FK_FollowedSensor_Human] FOREIGN KEY([HumanId])
REFERENCES [dbo].[Human] ([Id])
GO
ALTER TABLE [dbo].[FollowedSensor] CHECK CONSTRAINT [FK_FollowedSensor_Human]
GO
ALTER TABLE [dbo].[FollowedSensor]  WITH CHECK ADD  CONSTRAINT [FK_FollowedSensor_Sensor] FOREIGN KEY([SensorId])
REFERENCES [dbo].[Sensor] ([Id])
GO
ALTER TABLE [dbo].[FollowedSensor] CHECK CONSTRAINT [FK_FollowedSensor_Sensor]
GO
ALTER TABLE [dbo].[Human]  WITH CHECK ADD  CONSTRAINT [FK_Human_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Human] CHECK CONSTRAINT [FK_Human_User]
GO
ALTER TABLE [dbo].[SavedFilter]  WITH CHECK ADD  CONSTRAINT [FK_SavedFilter_FeedDataType] FOREIGN KEY([Type])
REFERENCES [dbo].[FeedDataType] ([Name])
GO
ALTER TABLE [dbo].[SavedFilter] CHECK CONSTRAINT [FK_SavedFilter_FeedDataType]
GO
ALTER TABLE [dbo].[SavedFilter]  WITH CHECK ADD  CONSTRAINT [FK_SavedFilter_Location] FOREIGN KEY([Location])
REFERENCES [dbo].[Location] ([Place])
GO
ALTER TABLE [dbo].[SavedFilter] CHECK CONSTRAINT [FK_SavedFilter_Location]
GO
ALTER TABLE [dbo].[SavedFilter]  WITH CHECK ADD  CONSTRAINT [FK_SavedFilter_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[SavedFilter] CHECK CONSTRAINT [FK_SavedFilter_User]
GO
ALTER TABLE [dbo].[Sensor]  WITH CHECK ADD  CONSTRAINT [FK_Sensor_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Sensor] CHECK CONSTRAINT [FK_Sensor_User]
GO
ALTER TABLE [dbo].[SensorData]  WITH CHECK ADD  CONSTRAINT [FK_SensorData_Sensor] FOREIGN KEY([SensorId])
REFERENCES [dbo].[Sensor] ([Id])
GO
ALTER TABLE [dbo].[SensorData] CHECK CONSTRAINT [FK_SensorData_Sensor]
GO
ALTER TABLE [dbo].[Tags]  WITH CHECK ADD  CONSTRAINT [FK_Tags_Feed] FOREIGN KEY([FeedId])
REFERENCES [dbo].[Feed] ([Id])
GO
ALTER TABLE [dbo].[Tags] CHECK CONSTRAINT [FK_Tags_Feed]
GO
ALTER TABLE [dbo].[Tags]  WITH CHECK ADD  CONSTRAINT [FK_Tags_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([Id])
GO
ALTER TABLE [dbo].[Tags] CHECK CONSTRAINT [FK_Tags_User]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Location] FOREIGN KEY([Location])
REFERENCES [dbo].[Location] ([Place])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Location]
GO
ALTER TABLE [dbo].[UserFilter]  WITH CHECK ADD  CONSTRAINT [FK_UserFilter_SavedFilter] FOREIGN KEY([FilterID])
REFERENCES [dbo].[SavedFilter] ([ID])
GO
ALTER TABLE [dbo].[UserFilter] CHECK CONSTRAINT [FK_UserFilter_SavedFilter]
GO
ALTER TABLE [dbo].[UserFollowedGroups]  WITH CHECK ADD  CONSTRAINT [FK_UserFollowedGroups_FeedGroup] FOREIGN KEY([GroupId])
REFERENCES [dbo].[FeedGroup] ([Id])
GO
ALTER TABLE [dbo].[UserFollowedGroups] CHECK CONSTRAINT [FK_UserFollowedGroups_FeedGroup]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Feed"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 253
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Tags"
            Begin Extent = 
               Top = 192
               Left = 271
               Bottom = 305
               Right = 441
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Human"
            Begin Extent = 
               Top = 158
               Left = 682
               Bottom = 288
               Right = 852
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 479
               Bottom = 136
               Right = 649
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FeedTags'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FeedTags'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Feed"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 219
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "FeedDataType"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 85
               Right = 441
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FeedPriority"
            Begin Extent = 
               Top = 182
               Left = 414
               Bottom = 295
               Right = 584
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 687
               Bottom = 136
               Right = 857
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FeedView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FeedView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Human"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 231
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'HumanUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'HumanUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Sensor"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 184
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 153
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SensorUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SensorUser'
GO
USE [master]
GO
ALTER DATABASE [ABBConnect] SET  READ_WRITE 
GO
