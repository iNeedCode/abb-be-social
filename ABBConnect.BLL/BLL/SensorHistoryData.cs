﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BLL
{
    public class SensorHistoryData
    {
        public SensorHistoryData(Sensor owner)
        {
            this.owner = owner;
            this.startingTime = DateTime.MinValue;
            this.endingTime = DateTime.MinValue;
        }

        private Sensor owner;
         public Sensor Owner
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
         private DateTime startingTime; 
            public DateTime StartingTime
        {
            get
            {
                return startingTime;
            }
            set
            {
                startingTime = value;
            }
        }
            private DateTime endingTime;
            public DateTime EndingTime
            {
                get
                {
                    return endingTime;
                }
                set
                {
                    endingTime = value;
                }
            }
    }
}
