


local Spaceprotocol_getHead = {}

Spaceprotocol_getHead.nParamNum =2

function Spaceprotocol_getHead.request(strUrl)
    if not strUrl then
        return
    end
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.getHead
    local strProtocolParam = tostring(nProtocolId)
    strProtocolParam = strProtocolParam..","..strUrl --2

    local strData = ""
    local nHttpType = 0 --Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_getHead.process(strData,vstrParam)   
    
   if not strData then
        return
   end
   if #vstrParam < Spaceprotocol_getHead.nParamNum then
        return
   end
   local strUrl = vstrParam[2]
   local Spaceprotocol = require("logic.space.spaceprotocol")

   local pImage = gGetSpaceManager():GetCeguiImageWithUrl(strUrl)
   if not pImage  then
        local bAutoDelete = false
        local bSaveCocosImage = false
        local pCeguiImage = getSpaceManager():saveCeguiImageWithUrl(bAutoDelete,bSaveCocosImage,strUrl)
   end
   local Eventmanager = require "logic.space.eventmanager"
   local eventManager = Eventmanager.getInstance()
   eventManager:pushCmd(Eventmanager.eCmd.showHeadPic)
end


return Spaceprotocol_getHead