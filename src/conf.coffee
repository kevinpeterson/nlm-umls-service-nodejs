server_root = "http://some/server"

conf =
  username: "lexgrid"
  password: "lexgrid"
  database: "umls"
  port    : "3307"
  host    : "bmidev3"
  pool_max: 10
  pool_min: 2

module.exports.server_root = server_root
module.exports.conf = conf