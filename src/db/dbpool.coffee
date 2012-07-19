poolModule = require('generic-pool')
conf = require '../conf'
mysql = require 'mysql'

pool = poolModule.Pool(
  name     : 'mysql'
  create   : (callback) ->
    connection = mysql.createConnection(
      host     : conf.conf.host
      user     : conf.conf.username
      password : conf.conf.password
      database : conf.conf.database
      port     : conf.conf.port
      insecureAuth: true,
      multipleStatements: true)
 
    callback(null, connection)   
  destroy  : (connection) -> connection.end()
  max      : conf.conf.pool_max
  min      : conf.conf.pool_min
  idleTimeoutMillis : 30000
  log : false
  )

module.exports.pool = pool