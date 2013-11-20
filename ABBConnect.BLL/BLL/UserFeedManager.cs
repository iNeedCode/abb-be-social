﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using DAL;

namespace BLL
{
    public class UserFeedManager: IUserFeedManager
    {
        private HumanFeedData humanPostDbData;

        public UserFeedManager()
        {
            this.humanPostDbData = new HumanFeedData();
        }

        // METHOD: GetAllUserFeeds

        public List<UserFeed> GetAllUserFeeds()
        {
            DataTable userFeedTable = humanPostDbData.GetAllUserFeeds();
            List<UserFeed> lsUsFeed = new List<UserFeed>();
            UserFeed usFeed = new UserFeed();
            FeedManager feedMng = new FeedManager();
            int tempInt = 0;
            bool castRes = false;

            foreach (DataRow row in userFeedTable.Rows)
            {
                 StringBuilder tempContainer = new StringBuilder();

                tempContainer.Append(AvoidStringNulls(row["FirstName"].ToString()));
                usFeed.Owner.FirstName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["LastName"].ToString()));
                usFeed.Owner.LastName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["Username"].ToString()));
                usFeed.Owner.UserName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["Text"].ToString()));
                usFeed.Content = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["PriorityCategory"].ToString()));
                usFeed.Category = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["CreationTimeStamp"].ToString()));
                if (tempContainer.ToString() == null)
                    usFeed.TimeStamp = DateTime.MinValue;
                else
                    usFeed.TimeStamp = Convert.ToDateTime(tempContainer.ToString());
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["Place"].ToString()));
                usFeed.Location = tempContainer.ToString();
                
                tempContainer.Clear();
                tempContainer.Append(row["FeedId"].ToString());

               castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
               {
                    usFeed.ID = tempInt;
                    usFeed.Tags = feedMng.LoadFeedTags(tempInt);
                    usFeed.Comments = feedMng.LoadFeedComments(tempInt);
                }

                tempContainer.Clear();
                tempContainer.Append(row["PrioValue"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                    usFeed.Priority = tempInt;

                if (tempContainer.ToString() == null)
                    usFeed.Category = "";
                else
                    usFeed.Category = tempContainer.ToString();


                tempContainer.Clear();

                lsUsFeed.Add(usFeed);
                usFeed = new UserFeed();
            }

            return lsUsFeed;
        }

        // METHOD: GetAllUserFeedsByFilter

         public List<UserFeed> GetAllUserFeedsByFilter(string location, DateTime startingTime, DateTime endingTime)
        {
            if (String.IsNullOrEmpty(location))
                location = null;

            DataTable userFeedTable = humanPostDbData.GetAllUserFeedsByFilter(location, startingTime, endingTime);
            List<UserFeed> lsUsFeed = new List<UserFeed>();
            UserFeed usFeed = new UserFeed();
            FeedManager feedMng = new FeedManager();
            int tempInt = 0;
            bool castRes = false;

            foreach (DataRow row in userFeedTable.Rows)
            {
                StringBuilder tempContainer = new StringBuilder();

                 tempContainer.Append(row["FirstName"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Owner.FirstName = "";
                else
                    usFeed.Owner.FirstName = tempContainer.ToString();

                tempContainer.Clear();
                tempContainer.Append(row["LastName"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Owner.LastName = "";
                else
                    usFeed.Owner.LastName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(row["UserName"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Owner.UserName = "";
                else
                    usFeed.Owner.UserName = tempContainer.ToString();

                tempContainer.Clear();

                tempContainer.Append(row["Text"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Content = "";
                else
                    usFeed.Content = tempContainer.ToString();

                tempContainer.Clear();
                 tempContainer.Append(row["PriorityCategory"].ToString());
                 if (tempContainer.ToString() == null)
                    usFeed.Category = "";
                else
                    usFeed.Category = tempContainer.ToString();

                usFeed.Category = tempContainer.ToString();
                tempContainer.Clear();
                
                tempContainer.Append((row["CreationTimeStamp"].ToString()));
                if (tempContainer.ToString() == null)
                    usFeed.TimeStamp = DateTime.MinValue;
                else
                    usFeed.TimeStamp = Convert.ToDateTime(tempContainer.ToString());
                tempContainer.Clear();
                tempContainer.Append(AvoidStringNulls(row["Place"].ToString()));
                usFeed.Location = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(row["FeedId"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                {
                    usFeed.ID = tempInt;
                    usFeed.Tags = feedMng.LoadFeedTags(tempInt);
                    usFeed.Comments = feedMng.LoadFeedComments(tempInt);
                }

                tempContainer.Clear();
                tempContainer.Append(row["PrioValue"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                    usFeed.Priority = tempInt;

                tempContainer.Clear();
                
                 lsUsFeed.Add(usFeed);
                 usFeed = new UserFeed();
            }

            return lsUsFeed;
        }

        
                //StringBuilder tempContainer = new StringBuilder();
                
        //public List<Feed> LoadUserFeeds(string userName)
        //{
        //    if (!string.IsNullOrEmpty(userName))
        //    {
        //        DataTable infoTable = humanPostDbData.GetUserFeeds(userName);
        //        List<Feed> feedList = new List<Feed>();

        //        foreach (DataRow row in infoTable.Rows)
        //        {
        //            UserFeed tempFeed = new UserFeed();

        //            foreach (DataColumn col in infoTable.Columns)
        //            {
        //                tempFeed.Owner.FirstName = row[col.ColumnName].ToString();
        //                tempFeed.Owner.LastName = row["LastName"].ToString();
        //                tempFeed.Owner.UserName = row["Username"].ToString();
        //                tempFeed.TimeStamp = Convert.ToDateTime(row["CreationTimeStamp"]);
        //                tempFeed.Content = row["Text"].ToString();
        //                tempFeed.MediaFilePath = row["FilePath"].ToString();
        //                tempFeed.Category = row["PriorityCategory"].ToString();

        //                int tempInt = CastStringToInt(row["PrioValue"].ToString());
        //                if (tempInt != -1)
        //                {
        //                    tempFeed.Priority = tempInt;
        //                }

        //                tempFeed.Location = row["Place"].ToString();

        //                tempInt = CastStringToInt(row["FeedId"].ToString());
        //                if (tempInt != -1)
        //                {
        //                    tempFeed.ID = tempInt;
        //                }
        //            }

        //            feedList.Add(tempFeed);
        //        }

        //        return feedList;
        //    }
        //    return null;
        //}


         // METHOD: LoadUserFeedsByFilter

        public List<UserFeed> LoadUserFeedsByFilter(string userName, string location, DateTime startingTime, DateTime endingTime)
        {
            List<UserFeed> lsUsFeed = new List<UserFeed>();

            if (String.IsNullOrEmpty(location))
                location = null;

            if (userName == null)
                return lsUsFeed;

            DataTable userFeedTable = humanPostDbData.GetUserFeedsByFilter(userName, location, startingTime, endingTime);
            UserFeed usFeed = new UserFeed();
            int tempInt = 0;
            bool castRes = false;
            FeedManager feedMng = new FeedManager();

            foreach (DataRow row in userFeedTable.Rows)
            {
                StringBuilder tempContainer = new StringBuilder();

                tempContainer.Append(AvoidStringNulls(row["FirstName"].ToString()));
                usFeed.Owner.FirstName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["LastName"].ToString()));
                usFeed.Owner.LastName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["Username"].ToString()));
                usFeed.Owner.UserName = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["Text"].ToString()));
                usFeed.Content = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["PriorityCategory"].ToString()));
                usFeed.Category = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["CreationTimeStamp"].ToString()));
                if (tempContainer.ToString() == null)
                    usFeed.TimeStamp = DateTime.MinValue;
                else
                    usFeed.TimeStamp = Convert.ToDateTime(tempContainer.ToString());
                tempContainer.Clear();

                tempContainer.Append(AvoidStringNulls(row["Place"].ToString()));
                usFeed.Location = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(row["FeedId"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                {
                    usFeed.ID = tempInt;
                    usFeed.Tags = feedMng.LoadFeedTags(tempInt);
                    usFeed.Comments = feedMng.LoadFeedComments(tempInt);
                }

                tempContainer.Clear();
                tempContainer.Append(row["PrioValue"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                    usFeed.Priority = tempInt;

                tempContainer.Clear();

                lsUsFeed.Add(usFeed);
                usFeed = new UserFeed();
            }

            return lsUsFeed;
        }

        private static bool CastStringToInt(string str, ref int returnValue)
        {
            bool result = false;

            try
            {
                returnValue = Convert.ToInt32(str);
                result = true;
            }
            catch (FormatException e)
            {
                Console.WriteLine("Input string is not a sequence of digits.");
            }
            catch (OverflowException e)
            {
                Console.WriteLine("The number cannot fit in an Int32.");
            }

            return result;
        }

        private static string AvoidStringNulls(string str)
        {
            string resStr = "";

            if (str != null)
                resStr = str;

            return resStr;
        }

        public List<Feed> LoadUserFeeds(string userName)
        {
            throw new NotImplementedException();
        }

        // METHOD: GetUserFeeds

        public List<UserFeed> GetUserFeeds(string userName)
        {
            DataTable userFeedTable = humanPostDbData.GetUserFeeds(userName);
            List<UserFeed> lsUsFeed = new List<UserFeed>();
            UserFeed usFeed = new UserFeed();
            FeedManager feedMng = new FeedManager();
            int tempInt = 0;
            bool castRes = false;

            foreach (DataRow row in userFeedTable.Rows)
            {
                StringBuilder tempContainer = new StringBuilder();
                tempContainer.Append(row["FirstName"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Owner.FirstName = "";
                else
                    usFeed.Owner.FirstName = tempContainer.ToString();

                tempContainer.Clear();
                tempContainer.Append(row["LastName"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Owner.LastName = "";
                else
                    usFeed.Owner.LastName = tempContainer.ToString();

                tempContainer.Clear();
                tempContainer.Append(row["Text"].ToString());

                if (tempContainer.ToString() == null)
                    usFeed.Content = null;
                else
                    usFeed.Content = tempContainer.ToString();

                tempContainer.Clear();

                tempContainer.Append(row["PriorityCategory"].ToString());
                 if (tempContainer.ToString() == null)
                    usFeed.Category = "";
                else
                    usFeed.Category = tempContainer.ToString();

                usFeed.Category = tempContainer.ToString();
                tempContainer.Clear();
                
                tempContainer.Append((row["CreationTimeStamp"].ToString()));
                if (tempContainer.ToString() == null)
                    usFeed.TimeStamp = DateTime.MinValue;
                else
                    usFeed.TimeStamp = Convert.ToDateTime(tempContainer.ToString());
                tempContainer.Clear();
                
                //tempContainer.Append(row["Id"].ToString());

                //castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                //if (castRes)
                  //  usFeed.Owner.ID = tempInt;

                //tempContainer.Clear();
                tempContainer.Append(AvoidStringNulls(row["Place"].ToString()));
                usFeed.Location = tempContainer.ToString();
                tempContainer.Clear();

                tempContainer.Append(row["FeedId"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                {
                    usFeed.ID = tempInt;
                    usFeed.Tags = feedMng.LoadFeedTags(tempInt);
                    usFeed.Comments = feedMng.LoadFeedComments(tempInt);
                }

                tempContainer.Clear();
                tempContainer.Append(row["PrioValue"].ToString());

                castRes = CastStringToInt(tempContainer.ToString(), ref tempInt);
                if (castRes)
                    usFeed.Priority = tempInt;

                tempContainer.Clear();
                
                 lsUsFeed.Add(usFeed);
                 usFeed = new UserFeed();
            }

            return lsUsFeed;
        }
    }
}
