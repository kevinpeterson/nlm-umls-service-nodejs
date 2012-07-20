read_by_name = (connection, code_system, entity_name, callback) ->
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
        entity = null

        if statement_results.length > 0          
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
            
        callback(entity))

module.exports.read_by_name = read_by_name