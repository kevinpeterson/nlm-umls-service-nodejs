poolModule = require('generic-pool')
conf = require '../conf'
mysql = require 'mysql'

pool = poolModule.Pool(
  name     : 'mysql'
  create   : (callback) ->
    connection = mysql.createConnection(
      host     : conf.database.host
      user     : conf.database.username
      password : conf.database.password
      database : conf.database.database
      port     : conf.database.port
      insecureAuth: true,
      multipleStatements: true)
 
    callback(null, connection)   
  destroy  : (connection) -> connection.end()
  max      : conf.database.pool_max
  min      : conf.database.pool_min
  idleTimeoutMillis : 30000
  log : false
  )

module.exports.pool = pool