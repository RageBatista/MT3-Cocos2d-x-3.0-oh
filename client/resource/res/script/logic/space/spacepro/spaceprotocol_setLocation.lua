
--[[



--]]

local Spaceprotocol_setLocation = {}

function Spaceprotocol_setLocation.request(nnRoleId,strPlace,fLongitude,fLatitude)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.setLocation
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..strPlace --2

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&place="..strPlace
    strData = strData.."&longitude="..fLongitude
    strData = strData.."&latitude="..fLatitude

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--cjson
function Spaceprotocol_setLocation.process(strData,vstrParam)

    if #vstrParam <2 then
        return
    end
    local strPlace = vstrParam[2]


    local spManager = require("logic.space.spacemanager").getInstance()
    spManager.roleSpaceInfoData.strLocation = strPlace

    -------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    -----------
    local Spacedialog = require("logic.space.spacedialog")
    eventManager:pushCmd(Eventmanager.eCmd.refreshLocation)

end


return Spaceprotocol_setLocation