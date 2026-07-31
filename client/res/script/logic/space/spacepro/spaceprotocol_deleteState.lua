
--[[




--]]

local Spaceprotocol_deleteState = {}

Spaceprotocol_deleteState.nParamNum =3

function Spaceprotocol_deleteState.request(nnRoleId,nSpaceType,nStateId)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.deleteState
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nSpaceType
    strProtocolParam = strProtocolParam..","..nStateId --3


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&status_id="..nStateId

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--cjson
function Spaceprotocol_deleteState.process(strData,vstrParam)
    --id,nSpaceType,nStateId,nCommentId
    if #vstrParam < Spaceprotocol_deleteState.nParamNum then
        return
    end
    local nSpaceType = tonumber(vstrParam[2])
    local nStateId = tonumber(vstrParam[3])

    -------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    -----------

    spManager:deleteState(nStateId,nSpaceType)
    eventManager:pushCmd(Eventmanager.eCmd.delState,vstrParam)

end


return Spaceprotocol_deleteState