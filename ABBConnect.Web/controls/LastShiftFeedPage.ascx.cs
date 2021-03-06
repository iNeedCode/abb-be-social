﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using BLL;

/*
 * Written by: 
 * Project: Social Media in the Process Automation Industry (ABB Connect)
 */

/// <summary>
/// Logic for rendering feed page.
/// </summary>
public partial class controls_LastShiftFeedPage : System.Web.UI.UserControl
{
    // Default Feed Settings
    public int PageSize = 10;
    public int LastFeedId = 0;
    public bool IsLoadMoreVisible = true;

    public int FilterUserId = -1;
    public string FilterLocation = null;

    protected void Page_Load(object sender, EventArgs e)
    {
     
    }

    /// <summary>
    /// Loading and rendering feeds for the page.
    /// </summary>
    public void RenderFeedPage()
    {        
        FeedManager feedManager = new FeedManager();
        List<Feed> singlePageFeeds = new List<Feed>();

        try
        {
            singlePageFeeds = feedManager.LoadLastShiftFeeds(-1);
        }
        catch
        {}
        FeedRepeater.DataSource = singlePageFeeds;
        FeedRepeater.DataBind();      
    }

    /// <summary>
    /// Rendering feed data: content, comments, tags and load more link.
    /// </summary>
    protected void FeedRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {      
        Literal l = new Literal();
        HtmlAnchor a = new HtmlAnchor();
        HtmlGenericControl hgc = new HtmlGenericControl();
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            /* Determine feedType (
             * , Sensor) and render innerMessage (FeedContent) for it (TextMessage, SensorWarning, SensorGauge)
             * 
             */
           
            Feed currentFeed = ((Feed)e.Item.DataItem);
            HumanFeed currentHumanFeed = (HumanFeed)currentFeed;

            l = (Literal)e.Item.FindControl("litFeedPosterName");
            l.Text = currentHumanFeed.Owner.FirstName + " " + currentHumanFeed.Owner.LastName;

            // Render Content 
            l = (Literal)e.Item.FindControl("litFeedContent");
            l.Text = l.Text + currentFeed.Content;
            if(currentHumanFeed.MediaFilePath != String.Empty)
            {
                //Generate thumbnail container
                string thumbnailHTML = "<a href='' class='thumbnail'><img src='" + currentHumanFeed.MediaFilePath +  "'></a>";
                l.Text = l.Text + "<hr>" + thumbnailHTML;
            }
          
            // Render Comments
            Repeater feedCommentsRepeater = (Repeater)e.Item.FindControl("feedCommentsRepeater");
            
            // Reverse loaded Comments order because of mobile BLL
            if (currentFeed.Comments.Count <= 5)
            {
                feedCommentsRepeater.DataSource = currentFeed.Comments.OrderBy(c => c.TimeStamp);
                feedCommentsRepeater.DataBind();
                ((HtmlGenericControl)e.Item.FindControl("feed_show_all_comments")).Attributes.Add("class", "feed-show-all-comments-container dont-show");     
            }

            // Render Tags
            HtmlInputText hit = (HtmlInputText)e.Item.FindControl("feed_input_tags");
            string feedTags = string.Empty;

            if (currentFeed.Tags.Count > 0)
            {
                foreach (Human tagedHuman in currentFeed.Tags)
                {
                    //group the name_surname and the ID, which will be used in a text-value manner
                    feedTags = feedTags + "," + tagedHuman.FirstName + " " + tagedHuman.LastName+"||"+tagedHuman.ID;
                }
                // Quick fix for laziness
                if (feedTags.Length > 0)
                {
                    feedTags = feedTags.Remove(0, 1);
                }
            }
            //else
            //{
            //    feedTags = feedTags + "Unfortunately there are no tags available";
            //}
            hit.Attributes.Add("value", feedTags);
        }
    }

    /// <summary>
    /// Determining the state of Load more container and rendering data.
    /// </summary>
    protected override void Render(HtmlTextWriter writer)
    {
        RenderChildren(writer);
    }
}