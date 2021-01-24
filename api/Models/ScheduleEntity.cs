using Microsoft.Azure.Cosmos.Table;
using System;
using System.Collections.Generic;
using System.Text;

namespace CoffeeAndOpenSource.Api.Models
{
    public class ScheduleEntity : TableEntity
    {
        public ScheduleEntity()
        {
        }

        public ScheduleEntity(string guest, string date)
        {
            PartitionKey = guest;
            RowKey = date;
        }

        public string Guest { get; set; }

        public string GuestLink { get; set; }

        public string GuestHandle { get; set; }

        public string Topic { get; set; }

        public string YouTubeVideoId { get; set; }

        public bool IsPublished { get; set; }

        public string DateTimeAsString { get; set; }

        public DateTime DateTimeUTC { get; set; }
    }
}
