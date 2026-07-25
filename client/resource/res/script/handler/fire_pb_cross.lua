
local p = require "protodef.fire.pb.cross.sbegincorssserver"
function p:process()

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    if not jjManager then
        return 
    end

    jjManager:saveOldNormalServerInfo()


    local account = self.account
    local key = self.ticket  
	local servername = "cross" 
	local area = "crossarea"
    local host = self.crossip

    local nPort = math.random(self.crossport, self.crossport+(self.crossnum-1))

    local port = tostring(nPort)
	
    local serverid = 0 --1101961002 
    local channelid = "" 
	--gGetLoginManager():ClearConnections()
    gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverid, channelid)
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
    end

end