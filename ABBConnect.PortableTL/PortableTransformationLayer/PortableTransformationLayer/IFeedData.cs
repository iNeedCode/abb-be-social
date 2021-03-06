﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PortableTransformationLayer.ABBConnectServiceRef;
using System.Threading.Tasks;

namespace PortableTransformationLayer
{
    interface IFeedData
    {
        Task<List<GetFeedComments_Result>> GetFeedComments(int feedId);
        Task<List<GetFeedTags_Result>> GetFeedTags(int feedId);
        Task<bool> PublishComment(int feedId, string username, string comment);
        Task<bool> AddFeedTag(int feedId, string username);
        Task<int> PublishFeed(int usrId, string text, string filepath, int prioId, byte[] image);
        Task<List<GetLatestXFeeds_Result>> GetFeedsByFilter(int userId, string location, DateTime startingTime, DateTime endingTime, string feedType, string categoryName, int startId, int numFeeds);
        Task<GetLatestXFeeds_Result> GetFeedByFeedId(int feedId);
        Task<List<GetLatestXFeeds_Result>> GetFeedsFromLastShift(int numFeeds);
    }
}
