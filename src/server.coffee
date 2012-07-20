restify = require 'restify'
entity_xml = require('./xml/entityxml')
dbpool = require './db/dbpool'
entityread = require './entity/entityread'
entityquery = require './entity/entityquery'

server = restify.createServer(
  formatters: 
    'application/xml': (req, res, body) ->      
      return body
)

server.use(restify.queryParser())

entity_read_by_name_response = (req, res, next) ->      
  res.header('Content-Type','application/xml')

  entity_name = req.params.entity_name      
  code_system = req.params.code_system

  dbpool.pool.acquire( 
    (pool_err, connection) ->
      entityread.read_by_name(
        connection, 
        code_system, 
        entity_name,
        (entity) ->
          res.contentType = 'application/xml'            
          res.send(entity_xml.build_entity(entity))
          dbpool.pool.release(connection)))

entity_query_response = (req, res, next) ->      
  res.header('Content-Type','application/xml')
  res.contentType = 'application/xml'  

  query_control = 
    max_to_return : 10
    match_value : req.query.matchvalue

  query_result = entityquery.query(
    query_control,
    (entity_directory) ->
      res.send(entity_xml.build_entity_directory(entity_directory))
  )

start_server = () ->
  server.get('/codesystem/:code_system/entity/:entity_name', entity_read_by_name_response )
  server.get('/entities', entity_query_response )
		    
  server.listen(8080, () -> 
    console.log('%s listening at %s', server.name, server.url) )
    

start_server()


