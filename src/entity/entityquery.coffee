elasticSearchClient = require('../index/index').elasticSearchClient

entity_xml = require('./../xml/entityxml')

query = (query_control, callback) ->
  elasticSearchClient.search('umls', 'entity', {
    "query" : {
      "term" : { "entity.descriptions.value" : query_control.match_value } 
      } 
    },{ size : query_control.max_to_return })
    .on('data', (data) ->
      entity_directory =
        entity_summaries : []

      for hit in JSON.parse(data).hits.hits
        entity =
          code_system : hit._source.code_system
          name : hit._source.name
          description : hit._source.descriptions[0].value

        entity_directory.entity_summaries.push(entity)

      callback(entity_directory)
    )
    .on('done', () ->
      #
    )
    .on('error', (error) ->
      console.log(error)
    )
    .exec()

module.exports.query = query