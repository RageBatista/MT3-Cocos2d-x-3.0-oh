


local Spaceprotocol_getPic = {}

function Spaceprotocol_getPic.request(strUrl)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.getPic
    local strProtocolParam = tostring(nProtocolId)
    strProtocolParam = strProtocolParam..","..strUrl --2

    --gGetSpaceManager():SendRequest(strProtocolParam,strUrl)

    local strData = "" -- "serverkey="..strServerId
    local nHttpType = 0 --get tyep --Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--cjson
function Spaceprotocol_getPic.process(strData,vstrParam)   
    if not strData then
        return
    end
   if #vstrParam < 2 then
        return
   end
   local strUrl = vstrParam[2]
   local Spaceprotocol = require("logic.space.spaceprotocol")
   local pImage = gGetSpaceManager():GetCeguiImageWithUrl(strUrl)
   if not pImage  then
        local bAutoDelete = true
        local bSaveCocosImage = false
        local pCeguiImage = getSpaceManager():saveCeguiImageWithUrl(bAutoDelete,bSaveCocosImage,strUrl)
   end

   local Eventmanager = require "logic.space.eventmanager"
   local eventManager = Eventmanager.getInstance()
   eventManager:pushCmd(Eventmanager.eCmd.getPicResult)
   

end


return Spaceprotocol_getPic