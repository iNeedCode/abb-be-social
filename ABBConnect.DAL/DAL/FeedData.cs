﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;

namespace DAL
{
    /// <summary>
    /// Class that allow to make operation on the feeds like retrieve old feeds, or publish new feeds and comments
    /// </summary>
    public class FeedData : Connection
    {
        private SqlConnection sqlConnection;
        private SqlCommand sqlCommand;

        /// <summary>
        /// Constructor that automatically instantiate the attribute of the class
        /// </summary>
        public FeedData()
            : base()
        {
            this.sqlConnection = base.GetConnection();
            this.sqlCommand = this.sqlConnection.CreateCommand();
        }

        /// <summary>
        /// Method that store a feed from a human user
        /// </summary>
        /// <param name="id">Integer that represent the ID of a human user</param>
        /// <param name="text">String that represent the content of the feed</param>
        /// <param name="filepath">String that represent the the path </param>
        /// <param name="prioId">Integer that represent the priority level of the feed</param>
        /// <returns>operation that contain the ID of the feed</returns>
        public int PostFeed(int id, string text, string filepath, int prioId)
        {
            int result = 0;

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {

                sqlConn.Open();
                string sqlQuery = "AddFeed";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlParameter param = new SqlParameter("@retFeedId", SqlDbType.Int);
                    param.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = id;
                    cmd.Parameters.Add("@text", SqlDbType.NVarChar).Value = text;
                    cmd.Parameters.Add("@filePath", SqlDbType.NVarChar).Value = filepath;
                    cmd.Parameters.Add("@feedPriorityId", SqlDbType.Int).Value = prioId;
                    cmd.Parameters.Add(param);

                    cmd.ExecuteNonQuery();

                    result = (int)cmd.Parameters["@retFeedId"].Value;
                }
                sqlConn.Close();
            }
            return result;
        }

        /// <summary>
        /// Method that retrieve all the comments of a feed
        /// </summary>
        /// <param name="feedId">Integer representing the ID of the feed</param>
        /// <returns>operation that contain the List of comments</returns>
        public List<GetFeedComments_Result> GetFeedComments(int feedId)
        {
            List<GetFeedComments_Result> comments = new List<GetFeedComments_Result>();

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {

                sqlConn.Open();
                string sqlQuery = "GetFeedComments";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@feedId", SqlDbType.Int).Value = feedId;
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ;
                        while (reader.Read())
                        {
                            GetFeedComments_Result comment = new GetFeedComments_Result();
                            comment.FirstName = (string)reader[0];
                            comment.LastName = (string)reader[1];
                            comment.UserName = (string)reader[2];
                            comment.CommentText = (string)reader[3];
                            comment.CreationTimeStamp = (DateTime)reader[4];


                            comments.Add(comment);
                        }
                    }
                }
                sqlConn.Close();
            }
            return comments;
        }

        /// <summary>
        /// Method that retrieve all human users referenced into a feed
        /// </summary>
        /// <param name="feedId">Integer representing the ID of the feed</param>
        /// <returns>operation that contain the List of tags</returns>
        public List<GetFeedTags_Result> GetFeedTags(int feedId)
        {
            List<GetFeedTags_Result> tags = new List<GetFeedTags_Result>();

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {

                sqlConn.Open();
                string sqlQuery = "GetFeedTags";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@feedId", SqlDbType.Int).Value = feedId;

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ;
                        while (reader.Read())
                        {
                            try
                            {
                                GetFeedTags_Result tag = new GetFeedTags_Result();
                                tag.UserName = (string)reader[0];
                                tag.FirstName = (string)reader[1];
                                tag.LastName = (string)reader[2];
                                tag.UserId = (int)reader[3];

                                tags.Add(tag);
                            }
                            catch
                            {
                                break;
                            }
                        }
                    }
                }
                sqlConn.Close();
            }
            return tags;
        }

        /// <summary>
        /// Method that store a comment made to a feed from a human user
        /// </summary>
        /// <param name="feedId">Integer that represent the ID of a feed</param>
        /// <param name="username">String that represent the username of the human user</param>
        /// <param name="text">String that rapresent the content of the comment</param>
        /// <returns> operation that contain a boolean that indicate if the operation succeed</returns>
        public bool PostComment(int feedId, string username, string text)
        {
            int iD = feedId;
            int rowsAffected = 0;

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {

                sqlConn.Open();
                string sqlQuery = "AddCommentToFeed";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@feedId", SqlDbType.Int).Value = iD;
                    cmd.Parameters.Add("@username", SqlDbType.NVarChar, 50).Value = username;
                    cmd.Parameters.Add("@text", SqlDbType.NVarChar).Value = text;

                    rowsAffected = cmd.ExecuteNonQuery();
                }
                sqlConn.Close();
            }

            if (rowsAffected > 0)
                return true;
            else
                return false;
        }

        /// <summary>
        /// Method that the reference to a user into a feed
        /// </summary>
        /// <param name="feedId">ID of the feed where the reference should be added</param>
        /// <param name="username">Username of the the user that should be reference in the feed</param>
        /// <returns> operation that contain a boolean that indicate if the operation succeed</returns>
        public bool AddTag(int feedId, string username)
        {
            int iD = feedId;
            int rowsAffected = 0;

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {

                sqlConn.Open();
                string sqlQuery = "AddTagToFeed";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@feedId", SqlDbType.Int).Value = iD;
                    cmd.Parameters.Add("@username", SqlDbType.NVarChar, 50).Value = username;

                    rowsAffected = cmd.ExecuteNonQuery();
                }
                sqlConn.Close();
            }

            if (rowsAffected > 0)
                return true;
            else
                return false;
        }

        /// <summary>
        /// Method that search and retrieve the feeds by all their attributes.
        /// If an attribute of the feed is not needed in the search it can be leaved empty for strings, MinValue for DateTime objects, or -1 for integers.
        /// </summary>
        /// <param name="id">Integer that represent the ID of the user, if not needed in the search put it -1</param>
        /// <param name="location">String that represent the location of the feed, if not needed in the search leave it empty</param>
        /// <param name="startingTime">Class that represent the date where the search begin, it must be older than the date where the search should stop;
        /// if  not needed in the search put it like MinValue</param>
        /// <param name="endingTime">Class that represent the date where the search end, it must be younger than the date where the search should start;
        /// if  not needed in the search put it like MinValue</param>
        /// <param name="feedType">String that represent the type of the feed: human or sensor;
        /// if not needed in the search put it like empty string</param>
        /// /// <param name="feedCategoryName">String that represent the category of the feed;
        /// if not needed in the search put it like empty string</param>
        /// <param name="startId"></param>
        /// <param name="numFeeds">Integer that represent the number of feeds that must be retrieved, if not needed in the search put it -1</param>
        /// <returns> operation that contain the List of feeds required</returns>
        public List<GetLatestXFeeds_Result> GetXFeedsByFilter(int id, string location, DateTime startingTime, DateTime endingTime, string feedType, string feedCategoryName, int startId, int numFeeds)
        {
            List<GetLatestXFeeds_Result> feeds = new List<GetLatestXFeeds_Result>();

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {
                sqlConn.Open();
                string sqlQuery = "GetXFeedsByFilter";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    try
                    {
                        if (id == -1)
                            cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = id;

                        if (location.Equals(""))
                            cmd.Parameters.Add("@location", SqlDbType.NVarChar, 50).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@location", SqlDbType.NVarChar, 50).Value = location;

                        if (startingTime == DateTime.MinValue)
                            cmd.Parameters.Add("@startTime", SqlDbType.DateTime).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@startTime", SqlDbType.DateTime).Value = startingTime;

                        if (endingTime == DateTime.MinValue)
                            cmd.Parameters.Add("@endTime", SqlDbType.DateTime).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@endTime", SqlDbType.DateTime).Value = endingTime;

                        if (feedType.Equals(""))
                            cmd.Parameters.Add("@FeedType", SqlDbType.NVarChar, 50).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@FeedType", SqlDbType.NVarChar, 50).Value = feedType;

                        if (feedCategoryName.Equals(""))
                            cmd.Parameters.Add("@feedCategoryName", SqlDbType.NVarChar, 50).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@feedCategoryName", SqlDbType.NVarChar, 50).Value = feedCategoryName;

                        if (startId == -1)
                            cmd.Parameters.Add("@startingFeedId", SqlDbType.Int).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@startingFeedId", SqlDbType.Int).Value = startId;

                        if (numFeeds == -1)
                            cmd.Parameters.Add("@numOfFeeds", SqlDbType.Int).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@numOfFeeds", SqlDbType.Int).Value = numFeeds;
                    }

                    catch (Exception)
                    {
                        cmd.Dispose();
                        sqlConn.Close();
                        return null;
                    }
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ;
                        while (reader.Read())
                        {
                            GetLatestXFeeds_Result feed = new GetLatestXFeeds_Result();
                            feed.Username = (string)reader[0];
                            feed.UserId = (int)reader[1];
                            feed.Type = (string)reader[2];
                            feed.CreationTimeStamp = (DateTime)reader[3];
                            feed.Text = (string)reader[4];
                            object sqlCell = reader[5];
                            feed.FilePath = (sqlCell == System.DBNull.Value)
                                ? ""
                                : (string)sqlCell;
                            feed.PrioCategory = (string)reader[6];
                            feed.PrioValue = (int)reader[7];
                            feed.FeedId = (int)reader[8];
                            feed.Location = (string)reader[9];

                            feeds.Add(feed);
                        }
                    }
                }
                sqlConn.Close();
            }
            return feeds;
        }

        /// <summary>
        /// Method that retrieve the feed with a specified ID
        /// </summary>
        /// <param name="feedId">ID of the feed where the reference should be added</param>
        /// <returns>operation that contain the feed rewuired</returns>
        public GetLatestXFeeds_Result GetFeedByFeedId(int feedId)
        {
            GetLatestXFeeds_Result feed = new GetLatestXFeeds_Result();

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {
                sqlConn.Open();
                string sqlQuery = "GetFeedByFeedId";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    try
                    {
                        cmd.Parameters.Add("@feedId", SqlDbType.Int).Value = feedId;
                    }

                    catch (Exception)
                    {
                        cmd.Dispose();
                        sqlConn.Close();
                        return null;
                    }
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ;
                        if (reader.Read())
                        {
                            feed.Username = (string)reader[0];
                            feed.UserId = (int)reader[1];
                            feed.Type = (string)reader[2];
                            feed.CreationTimeStamp = (DateTime)reader[3];
                            feed.Text = (string)reader[4];
                            object sqlCell = reader[5];
                            feed.FilePath = (sqlCell == System.DBNull.Value)
                                ? ""
                                : (string)sqlCell;
                            feed.PrioCategory = (string)reader[6];
                            feed.PrioValue = (int)reader[7];
                            feed.FeedId = (int)reader[8];
                            feed.Location = (string)reader[9];
                        }
                    }
                }
                sqlConn.Close();
            }
            return feed;
        }

        /// <summary>
        /// Method that updates the following state of a human user to a sensor
        /// </summary>
        /// <param name="humanId">the identifier of the human user</param>
        /// <param name="sensorId">the identifier of the sensor user</param>
        /// <returns></returns>
        public bool FollowSensor(int humanId, int sensorId)
        {
            int humanIntId = humanId;
            int sensorIntId = sensorId;
            int rowsAffected = 0;

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {

                sqlConn.Open();
                string sqlQuery = "AddFollowSensor";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@HumanUserId", SqlDbType.Int).Value = humanIntId;
                    cmd.Parameters.Add("@SensorUserId", SqlDbType.Int).Value = sensorIntId;

                    rowsAffected = cmd.ExecuteNonQuery();
                }
                sqlConn.Close();
            }

            if (rowsAffected > 0)
                return true;
            else
                return false;
        }

        /// <summary>
        /// Method that returns a specific amount of feeds from the last shift
        /// </summary>
        /// <param name="numFeeds">the number of feeds to be returned</param>
        /// <returns></returns>
        public List<GetLatestXFeeds_Result> GetFeedsFromLastShift(int numFeeds)
        {
            List<GetLatestXFeeds_Result> feeds = new List<GetLatestXFeeds_Result>();

            using (SqlConnection sqlConn = new SqlConnection("Data Source=" + Properties.Resources.Data_Source + "Initial Catalog=" + Properties.Resources.Initial_Catalog + "User id=" + Properties.Resources.User_id + "Password=" + Properties.Resources.Password))
            {
                sqlConn.Open();
                string sqlQuery = "GetFeedsFromLastShift";

                using (SqlCommand cmd = new SqlCommand(sqlQuery, sqlConn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    try
                    {
                        if (numFeeds == -1)
                            cmd.Parameters.Add("@numOfFeeds", SqlDbType.Int).Value = DBNull.Value;
                        else
                            cmd.Parameters.Add("@numOfFeeds", SqlDbType.Int).Value = numFeeds;
                    }

                    catch (Exception)
                    {
                        cmd.Dispose();
                        sqlConn.Close();
                        return null;
                    }
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ;
                        while (reader.Read())
                        {
                            GetLatestXFeeds_Result feed = new GetLatestXFeeds_Result();
                            feed.Username = (string)reader[0];
                            feed.UserId = (int)reader[1];
                            feed.Type = (string)reader[2];
                            feed.CreationTimeStamp = (DateTime)reader[3];
                            feed.Text = (string)reader[4];
                            object sqlCell = reader[5];
                            feed.FilePath = (sqlCell == System.DBNull.Value)
                                ? ""
                                : (string)sqlCell;
                            feed.PrioCategory = (string)reader[6];
                            feed.PrioValue = (int)reader[7];
                            feed.FeedId = (int)reader[8];
                            feed.Location = (string)reader[9];

                            feeds.Add(feed);
                        }
                    }
                }
                sqlConn.Close();
            }
            return feeds;
        }
    }
}
