using CoffeeAndOpenSource.Api.Models;
using Microsoft.Azure.Cosmos.Table;
using Microsoft.Azure.Cosmos.Table.Queryable;
using Microsoft.Extensions.Configuration;
using Microsoft.OData.Edm;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace CoffeeAndOpenSource.Api.Services
{
    public class TableStorageService
    {
        private readonly IConfiguration _configuration;


        public TableStorageService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public CloudStorageAccount CreateStorageAccountFromConnectionString(string ConnectionString)
        {
            CloudStorageAccount storageAccount;
            try
            {
                storageAccount = CloudStorageAccount.Parse(ConnectionString);
            }
            catch (FormatException)
            {
                Console.WriteLine("Invalid storage account information provided. Please confirm the AccountName and AccountKey are valid in the app.config file - then restart the application.");
                throw;
            }
            catch (ArgumentException)
            {
                Console.WriteLine("Invalid storage account information provided. Please confirm the AccountName and AccountKey are valid in the app.config file - then restart the sample.");
                throw;
            }

            return storageAccount;
        }

        public async Task<CloudTable> CreateTableAsync(string tableName)
        {
            //string storageConnectionString = _configuration.GetValue<string>("AzureWebJobsStorage");

            // TODO, SUPER HACK - HAVE TO EDIT FILE DURING BUILD
            CloudStorageAccount storageAccount = CreateStorageAccountFromConnectionString("{CONNECTIONSTRING}");

            CloudTableClient tableClient = storageAccount.CreateCloudTableClient(new TableClientConfiguration());

            CloudTable table = tableClient.GetTableReference(tableName);
            if (await table.CreateIfNotExistsAsync())
            {
            }
            else
            {
            }
            return table;
        }

        public async Task<TableEntity> InsertOrMergeEntityAsync(TableEntity entity, string tableName)
        {
            if (entity == null)
            {
                throw new ArgumentNullException("entity");
            }
            try
            {
                var table = await CreateTableAsync(tableName);

                TableOperation insertOrMergeOperation = TableOperation.InsertOrMerge(entity);

                TableResult result = await table.ExecuteAsync(insertOrMergeOperation);
                TableEntity insertedStat = result.Result as TableEntity;

                return insertedStat;
            }
            catch (StorageException e)
            {
                Console.WriteLine(e.Message);
                throw;
            }
        }


        public async Task<List<ScheduleEntity>> GetSchedule(string tableName)
        {
            var table = await CreateTableAsync(tableName);

            var query = new TableQuery<ScheduleEntity>();


            var results = table.ExecuteQuery<ScheduleEntity>(query).ToList();

            var ordered = results.GroupBy(grp => grp.PartitionKey)
      .Select(g => g.OrderByDescending(grp => DateTime.Parse(grp.DateTimeAsString)).FirstOrDefault()).ToList();

            return ordered;
        }
    }
}
