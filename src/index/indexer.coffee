dbpool = require './../db/dbpool'
elasticSearchClient = require('index').elasticSearchClient

add_mappings = () ->
  elasticSearchClient.putMapping("umls", "entity",
  "entity" : {
    "properties" : {
      "name" : { "type" : "string" }
      "code_system" : { "type" : "string" }
      "descriptions" : {
        "properties" : {
          "value" : { "type" : "string" }
        }
      }
      "definitions" : {
        "properties" : {
          "value" : { "type" : "string" }
        }
      }
    }
  }).on('done', 
    (done) ->
      console.log("Mappings Created")
  ).on('error'
    (error) ->
      console.log(error)
  ).exec()

elasticSearchClient.createIndex("umls"
).on('done', 
  (done) ->
    console.log("Index Created")
    add_mappings()
).on('error'
  (error) ->
    console.log(error)
).exec()

build_index_entity = (rows) ->
  entity = new Object();            
  entity.name = rows[0].CODE
  entity.code_system = rows[0].SAB;            
  entity.descriptions = []

  for result in rows                        
    description = new Object()            
    description.value = result.STR;		              
    description.is_preferred = false
    entity.descriptions.push(description)

    definition_value = result.DEF
    if definition_value
      definition = new Object()      
      definition.value = definition_value

      entity.definitions ?= []
      entity.definitions.push(definition)

  entity.descriptions[0].is_preferred = true
  return entity
  
dbpool.pool.acquire( 
      (pool_err, connection) ->

        total_commands = 0
      
        current_code = null
        row_cache = []
        commands = []
        
        query = connection.query("""
          SELECT mc.CODE as CODE, mc.SAB as SAB, mc.STR as STR, md.DEF as DEF, mr.RANK as RANK
          FROM MRCONSO mc
          LEFT JOIN MRRANK mr
            ON (mc.SAB = mr.SAB and mc.TTY = mr.TTY)  
          LEFT JOIN MRDEF md
            on mc.CUI = md.CUI and mc.AUI = md.AUI and mc.SAB = md.SAB
          """)
        query
          .on('result', (row) ->
            connection.pause()
            
            found_code = row.CODE
            
            if not current_code?
              current_code = found_code
            if current_code == found_code
              row_cache.push(row)
            else 
              entity = build_index_entity(row_cache);
              id = entity.code_system + ":" + entity.name
              commands.push({ "index" : { "_index" : "umls", "_type" : "entity", "_id" : id} })
              commands.push(entity)
              total_commands++
              row_cache = []
              current_code = null
   
            if commands.length > 500000
              elasticSearchClient.bulk(commands,{})
              .on('done', (done) ->
                console.log("Indexed: " + total_commands)
                current_code = null
                row_cache = []
                commands = []
                connection.resume()
              ).exec()
            else
              connection.resume()
              

        query.on('end', () ->
          dbpool.pool.release(connection)
          elasticSearchClient.bulk(commands,{})
          .on('done', (done) ->
                console.log("Total Indexed: " + total_commands)
              ).exec()
          console.log("all rows have been received"))))


  
