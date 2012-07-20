conf = require '../conf'

ElasticSearchClient = require('elasticsearchclient')

serverOptions =
  host: conf.index.host
  port: conf.index.port
  
elasticSearchClient = new ElasticSearchClient(serverOptions)

module.exports.elasticSearchClient = elasticSearchClient