﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ABBConnect___Windows_Phone
{
    class TestSensor
    {
        int ID, priority;

        public int Priority
        {
            get { return priority; }
            set { priority = value; }
        }

        public int ID1
        {
            get { return ID; }
            set { ID = value; }
        }
        DateTime timestamp;

        public DateTime Timestamp
        {
            get { return timestamp; }
            set { timestamp = value; }
        }
        string location, content, category;

        public string Category
        {
            get { return category; }
            set { category = value; }
        }
        
        public string Content
        {
            get { return content; }
            set { content = value; }
        }

        public string Location
        {
            get { return location; }
            set { location = value; }
        }

        string author;

        public string Author
        {
            get { return author; }
            set { author = value; }
        }

        public TestSensor()
        {

        }

    }
}
