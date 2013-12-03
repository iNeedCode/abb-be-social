﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PortableTransformationLayer.ABBConnectServiceRef;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.IO;
using System.Net;
using System.Net.Http;

namespace PortableTransformationLayer
{
    public class SensorData: ISensorData
    {
        private Connection urlServer;

        public SensorData()
        {
            urlServer = new Connection();
        }

        public async Task<ABBConnectServiceRef.GetSensorInformation_Result> GetSensorInformation(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri(urlServer.Url);
            var response = await client.GetStringAsync("GetSensorInfo?id=" + id.ToString()).ConfigureAwait(false);
            return JsonConvert.DeserializeObject<GetSensorInformation_Result>(response);  
        }

        public async Task<List<ABBConnectServiceRef.GetHistoricalDataFromSensor_Result>> GetHistoricalDataFromSensor(int id, DateTime startingTime, DateTime endingTime)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri(urlServer.Url);
            var response = await client.GetStringAsync("GetPastSensorData?id=" + id.ToString() 
                + "&start=" + startingTime.ToString() + "&end=" + endingTime.ToString()).ConfigureAwait(false);
            return JsonConvert.DeserializeObject<List<GetHistoricalDataFromSensor_Result>>(response); 
        }

        public async Task<int> GetLastSensorValue(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri(urlServer.Url);
            var response = await client.GetStringAsync("GetLastSensorValue?id=" + id.ToString()).ConfigureAwait(false);
            return JsonConvert.DeserializeObject<int>(response);  
        }
    }
}
