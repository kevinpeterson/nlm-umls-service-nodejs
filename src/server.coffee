restify = require 'restify'
entity_xml = require('./xml/entityxml')
dbpool = require './db/dbpool'

server = restify.createServer(
  formatters: 
    'application/xml': (req, res, body) ->      
      return body
)

start_server = () ->
  respond = (req, res, next) ->      
    res.header('Content-Type','application/xml')

    entity_name = req.params.entity_name      
    code_system = req.params.code_system

    dbpool.pool.acquire( (pool_err, connection) ->
      connection.query(       
        """
        SELECT mc.CODE, mc.SAB, mc.STR, md.DEF    
          FROM MRCONSO mc
        LEFT JOIN MRRANK mr
          ON (mc.SAB = mr.SAB and mc.TTY = mr.TTY)  
        LEFT JOIN MRDEF md
          on mc.CUI = md.CUI and mc.AUI = md.AUI and mc.SAB = md.SAB
        WHERE mc.SAB = ? AND mc.CODE = ?    
        ORDER BY RANK DESC;

        """, [code_system, entity_name], 
          (err, statement_results) ->    

            if statement_results.length is 0
              res.contentType = 'application/xml'            
              res.send(entity_xml.build_unknown_entity(entity_name))  
            else
              if(err)            
                res.contentType = 'text';            
                res.send(err);          
              else    
                mrconso_results = statement_results
                entity = new Object();            
                entity.name = mrconso_results[0].CODE;            
                entity.code_system = mrconso_results[0].SAB;            
                entity.descriptions = new Array();

                for result in mrconso_results                         
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

                res.contentType = 'application/xml'            
                res.send(entity_xml.build_entity(entity))
                dbpool.pool.release(connection)))
                
    

  server.get('/codesystem/:code_system/entity/:entity_name', respond )
		    
  server.listen(8080, () -> 
    console.log('%s listening at %s', server.name, server.url) )
    

start_server()


