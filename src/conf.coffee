server_context =
  server_root : "http://some/server"

database =
  username: "lexgrid"
  password: "lexgrid"
  database: "umls"
  port    : "3307"
  host    : "bmidev3"
  pool_max: 10
  pool_min: 2

index = 
  host: "bmidev4"
  port: 9200

module.exports.server_context = server_context
module.exports.database = database
module.exports.index = index