module = {}

local server = nil
local f = nil

okHeader = "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"

local function serverOnSent(sck, payload)
  local content = f.read(500)
--  print(content)
  if content then
    sck:send(content)
  else
    sck:close()
    sent = false
  end
end

local function serverOnReceive(sck, payload, callback)
  local _, _, method, path, query = string.find(payload, "([A-Z]+) (.+)?(.+) HTTP")
  if method == nil then
    _, _, method, path = string.find(payload, "([A-Z]+) (.+) HTTP")
  end
  callback(sck, method, path, query)
  if method ~= nil then
    if f then
      f.seek("set", 0)
    end
    sck:send(okHeader)
  end
end

function module.startServer(callback, path, p)
  local port = p or 80
  local exists = file.exists(path or "index.html")
  if server == nil then
    server = net.createServer()
    if server == nil then return false, "server create failed" end
    server:listen(80, function(sck)
      sck:on("receive", function(sck, payload)
        serverOnReceive(sck, payload, callback)
      end)
      sck:on("sent", function(sck, payload)
        serverOnSent(sck, payload)
      end)
    end)
  end
  if exists ~= true then return false, "file not exist" end
  f = file.open(path or "index.html")
  if f == nil then return false, "file open failed" end
  print("html server start, heap = "..node.heap())
  return true
end

function module.stopServer()
  if server ~= nil then
    server:close()
    server = nil
  end
  return result 
end

return module
