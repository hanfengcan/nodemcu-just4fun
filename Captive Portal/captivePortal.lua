local htmlServer = require "server"
local dnsServer = require "dnsServer"

dnsServer.startdnsServer()
htmlServer.startServer(function (sck, method, path, query)
  print(method, path, query)
end)
