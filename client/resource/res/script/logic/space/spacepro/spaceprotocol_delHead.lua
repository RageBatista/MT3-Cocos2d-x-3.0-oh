
--[[

--]]

local Spaceprotocol_delHead = {}
function Spaceprotocol_delHead.request(nnRoleId)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.delHead
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
function Spaceprotocol_delHead.process(strData,vstrParam)
   
   local strMsg = require("utils.mhsdutils").get_msgtipstring(162150)
    GetCTipsManager():AddMessageTip(strMsg)
end


return Spaceprotocol_delHead