module = {}

local dns_ip=wifi.ap.getip()
local i1,i2,i3,i4=dns_ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
local x00=string.char(0)
local x01=string.char(1)
local dns_str1=string.char(128)..x00..x00..x01..x00..x01..x00..x00..x00..x00
local dns_str2=x00..x01..x00..x01..string.char(192)..string.char(12)..x00..x01..x00..x01..x00..x00..string.char(3)..x00..x00..string.char(4)
local dns_strIP=string.char(i1)..string.char(i2)..string.char(i3)..string.char(i4)

local dnsServer = nil

-- get the question
local function decodeQuery(payload)
  local len = #payload
  local pos = 13
  local char = ""
  while string.byte(payload, pos) ~= 0 do
    pos = pos + 1
  end
  return string.sub(payload, 13, pos)
end

--start the dns server
function module.startdnsServer()
  if dnsServer == nil then
    dnsServer = net.createUDPSocket()
    dnsServer:on("receive", function(sck, data, port, ip)
      local id = string.sub(data, 1, 2)
      local query = decodeQuery(data)
      local response = id..dns_str1..query..dns_str2..dns_strIP
  --    print(string.byte(query, 1, #query))
  --    print(string.byte(response, 1, #response))
      sck:send(port, ip, response)
    end)
    
    dnsServer:listen(53)
    print("dns server start, heap = "..node.heap())
  end
  return true
end

--stop the dns server
function module.stopdnsServer()
  if dnsServer ~= nil then
    dnsServer:close()
    dnsServer = nil
  end
  return true
end

return module
