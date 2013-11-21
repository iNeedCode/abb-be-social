﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using Transformation_Layer;

namespace BLL
{
    public class HumanFeedManager: IHumanFeedManager
    {
        private HumanFeedData humanPostDbData;

        public HumanFeedManager()
        {
            this.humanPostDbData = new HumanFeedData();
        }

        // METHOD: GetAllUserFeeds

        public List<HumanFeed> LoadAllHumanFeeds()
        {
            DataSet userFeedSet = humanPostDbData.GetAllHumanFeeds();
            List<HumanFeed> lsUsFeed = new List<HumanFeed>();
            HumanFeed usFeed = new HumanFeed();
            FeedManager feedMng = new FeedManager();
            int tempInt = 0;
            bool castRes = false;

            DataTable userFeedTable = userFeedSet.Tables[0];

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
                usFeed = new HumanFeed();
            }

            return lsUsFeed;
        }

        // METHOD: GetAllUserFeedsByFilter

         public List<HumanFeed> LoadAllHumanFeedsByFilter(string location, DateTime startingTime, DateTime endingTime)
        {
            if (String.IsNullOrEmpty(location))
                location = null;

            DataSet userFeedSet = humanPostDbData.GetAllHumanFeedsByFilter(location, startingTime, endingTime);
            List<HumanFeed> lsUsFeed = new List<HumanFeed>();
            HumanFeed usFeed = new HumanFeed();
            FeedManager feedMng = new FeedManager();
            int tempInt = 0;
            bool castRes = false;

            DataTable userFeedTable = userFeedSet.Tables[0];

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
                 usFeed = new HumanFeed();
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
    }
}