using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;
using CoffeeAndOpenSource.Api.Services;
using CoffeeAndOpenSource.Api.Models;

namespace CoffeeAndOpenSource.Api
{
    public class ScheduleApi
    {
        private readonly TableStorageService _tableService;

        public ScheduleApi(TableStorageService tableService)
        {
            _tableService = tableService;
        }

        [FunctionName("GetSchedule")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            return new OkObjectResult(await _tableService.GetSchedule("Schedule"));
        }
    }
}
