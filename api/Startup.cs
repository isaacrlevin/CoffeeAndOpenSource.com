using System;
using CoffeeAndOpenSource.Api.Services;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

[assembly: FunctionsStartup(typeof(CoffeeAndOpenSource.Api.Startup))]

namespace CoffeeAndOpenSource.Api
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddSingleton<TableStorageService, TableStorageService>();
        }
    }
}
