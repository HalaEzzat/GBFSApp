const axios = require('axios');
const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

const PROVIDERS = {
  Careem_BIKE: 'https://dubai.publicbikesystem.net/customer/gbfs/v2/gbfs.json',
  Bike_Nordelta: 'https://nordelta.publicbikesystem.net/ube/gbfs/v1/',
  Ecobici: 'https://buenosaires.publicbikesystem.net/ube/gbfs/v1/'
};

module.exports.fetchStats = async () => {
  const timestamp = Math.floor(Date.now() / 1000);

  for (const [provider, url] of Object.entries(PROVIDERS)) {
    try {
      // Step 1: Fetch the main GBFS feed to get the station_status URL
      const feedResponse = await axios.get(url);
      const stationStatusUrl = feedResponse.data.data.en.feeds.find(feed => feed.name === "station_status").url;

      // Step 2: Fetch the station status data
      const statusResponse = await axios.get(stationStatusUrl);
      const statusData = statusResponse.data;

      let vehicleCount = 0;
      if (statusData.data.stations) {
        vehicleCount = statusData.data.stations.reduce((sum, station) => sum + station.num_bikes_available, 0);
      } else if (statusData.data.bikes) {
        vehicleCount = statusData.data.bikes.length;
      }

      // Step 3: Save to DynamoDB
      await dynamoDb.put({
        TableName: process.env.DYNAMODB_TABLE,
        Item: { provider, timestamp, vehicleCount }
      }).promise();
    } catch (error) {
      console.error(`Failed to fetch data for ${provider}:`, error);
    }
  }
};
