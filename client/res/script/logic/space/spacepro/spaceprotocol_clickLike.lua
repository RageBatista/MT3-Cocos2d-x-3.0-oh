
--[[

== 接口说明 ==
  * 接口名称: 点赞, 第二次取消点赞
  * 接口地址: /status/update_favorite

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 角色id ||
|| status_id | int | true | 动态id||


#调用实例
http://192.168.41.5:8803/status/update_favorite?serverkey=s1&roleid=1&status_id=31

#结果实例
{"errno":"","message":"","data":true}

--]]


local Spaceprotocol_clickLike = {}

function Spaceprotocol_clickLike.request(nnClickRoleId,nnTargetRoleId,nStateId,nSpaceType)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.clickLike
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nnClickRoleId
    strProtocolParam = strProtocolParam..","..nnTargetRoleId
    strProtocolParam = strProtocolParam..","..nStateId
    strProtocolParam = strProtocolParam..","..nSpaceType

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnClickRoleId
    strData = strData.."&status_id="..nStateId

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

-- cjson
function Spaceprotocol_clickLike.process(strData,vstrParam)
     
     if #vstrParam < 5 then
        return 
    end

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end


    local Spacedialog = require("logic.space.spacedialog")
    local nnClickRoleId = tonumber(vstrParam[2])
    local strClickRoleName = gGetDataManager():GetMainCharacterName()
    local nnTargetRoleId = tonumber(vstrParam[3])
    local nStateId = tonumber(vstrParam[4])
   
    local bLike = false 
    if pJson_data.valueInt==1 then
        bLike = true 
    else
        bLike = false 
    end
    local nSpaceType = tonumber(vstrParam[5])

    local spManager = require("logic.space.spacemanager").getInstance()
    spManager:updateClickLike(nnClickRoleId,strClickRoleName,nnTargetRoleId,nStateId,bLike,nSpaceType) 

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshClickLike)

    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    
end


return Spaceprotocol_clickLike