﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public class UserFeed: Feed
    {
        public UserFeed()
        {
            owner = new User();
            mediaFilePath = "";
        }

        private User owner;
        public User Owner
        {
            get
            {
                return owner;
            }
            set
            {
                owner = value;
            }
        }

        private string mediaFilePath;
        public string MediaFilePath
        {
            get
            {
                return mediaFilePath;
            }
            set
            {
                mediaFilePath = value;
            }
        }
    }
}
