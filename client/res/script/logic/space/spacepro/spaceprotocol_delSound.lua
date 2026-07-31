
--[[

--]]

local Spaceprotocol_delSound = {}
function Spaceprotocol_delSound.request(nnRoleId)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.delSound
    local strProtocolParam = tostring(nProtocolId)

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
   
    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--cjson
function Spaceprotocol_delSound.process(strData,vstrParam)

    local spManager = getSpaceManager()
    spManager.roleSpaceInfoData.strSoundUrl = ""

   local Eventmanager = require "logic.space.eventmanager"
   local eventManager = Eventmanager.getInstance()
   --eventManager:pushCmd(Eventmanager.eCmd.delHeadResult)

end


return Spaceprotocol_delSound