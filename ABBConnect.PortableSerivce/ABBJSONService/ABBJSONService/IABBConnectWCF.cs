﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace ABBJSONService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IService1" in both code and config file together.
    [ServiceContract]
    public interface IABBConnectWCF
    {
        [OperationContract]
        [WebInvoke]
        bool LogIn(string username, string password);

        [OperationContract]
        [WebInvoke]
        GetHumanInformation_Result GetHumanInformation(string id);

        [OperationContract]
        [WebInvoke]
        GetHumanInformationByUsername_Result GetHumanInformationByUsername(string username);

        [OperationContract]
        [WebInvoke]
        List<GetLatestXFeeds_Result> GetLatestXFeeds(string X);

        [OperationContract]
        [WebInvoke]
        List<GetLatestXFeedsFromId_Result> GetLatestXFeedsFromId(string X, string Id);

        [OperationContract]
        [WebInvoke]
        int PostFeed(string id, string text, string filepath, string prioId);

        [OperationContract]
        [WebInvoke]
        List<GetPriorityCategories_Result> GetCategories();

        [OperationContract]
        [WebInvoke]
        List<GetAllSensors_Result> GetAllSensors();

        [OperationContract]
        [WebInvoke]
        List<GetFeedComments_Result> GetFeedComments(string feedId);

        [OperationContract]
        [WebInvoke]
        List<GetFeedTags_Result> GetFeedTags(string feedId);

        [OperationContract]
        [WebInvoke]
        List<GetAllHumanFeeds_Result> GetHumanFeeds();

        [OperationContract]
        [WebInvoke]
        List<GetAllHumanFeedsByFilter_Result> GetHumanFeedsByFilter(string location, string startingTime, string endingTime);

        [OperationContract]
        [WebInvoke]
        List<GetAllSensorFeeds_Result> GetSensorFeeds();

        [OperationContract]
        [WebInvoke]
        List<GetAllSensorFeedsByFilter_Result> GetSensorFeedsByFilter(string location, string startingTime, string endingTime);

        [OperationContract]
        [WebInvoke]
        List<GetUserFeeds_Result> GetUserFeeds();

        [OperationContract]
        [WebInvoke]
        List<GetUserFeedsByFilter_Result> GetUserFeedsByFilter(string location, string startingTime, string endingTime);

        [OperationContract]
        [WebInvoke]
        List<string> GetLocations();

        [OperationContract]
        [WebInvoke]
        GetSensorInformation_Result GetSensorInformation(string id);

        [OperationContract]
        [WebInvoke]
        List<GetHistoricalDataFromSensor_Result> GetHistoricalDataFromSensor(string id, string startingTime, string endingTime);

        [OperationContract]
        [WebInvoke]
        int GetLastSensorValue(string id);

        [OperationContract]
        [WebInvoke]
        bool PostComment(string feedId, string username, string text);

        [OperationContract]
        [WebInvoke]
        bool AddTag(string feedId, string username);

        [OperationContract]
        [WebInvoke]
        bool FollowSensor(string humanId, string sensorId);

        [OperationContract]
        [WebInvoke]
        List<GetLatestFeedsByFilter_Result> GetLatestFeedsByFilter(string location, string startingTime, string endingTime);

        [OperationContract]
        [WebInvoke]
        List<GetFeedsByFilter_Result> GetFeedsByFilter(string name, string location, string startingTime, string endingTime, string feedType);
        
        [OperationContract]
        [WebInvoke]
        List<GetLatestXFeeds_Result> GetXFeedsByFilter(string id, string location, string startingTime, string endingTime, string feedType, string startId, string numFeeds);

        [OperationContract]
        [WebInvoke]
        int SaveFilter(string userId, string filterName, string startingTime, string endingTime, string location, string feedType);

        [OperationContract]
        [WebInvoke]
        bool AddFilterUser(string userId, string filterId);

        [OperationContract]
        [WebInvoke]
        List<GetUserSavedFilters_Result> GetSavedFilter(string userId);
    }

}
