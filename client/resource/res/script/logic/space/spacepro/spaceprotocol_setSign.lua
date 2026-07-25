
--[[

== 接口说明 ==
  * 接口名称: 更新签名
  * 接口地址: /role/update_signature 

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 角色id   ||
|| signature | string | true | 签名内容 ||


#调用实例
http://192.168.41.5:8803/role/update_signature?serverkey=s1&roleid=1&signature=哈哈哈哈<alert></alert>'afafa"fffff


#结果实例
{"errno":"","message":"","data":true}

--]]

local Spaceprotocol_setSign = {}

function Spaceprotocol_setSign.request(nnRoleId,strSign)
    if not strSign then 
        return
    end
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.setSign
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..strSign --2

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&signature="..strSign

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--cjson
function Spaceprotocol_setSign.process(strData,vstrParam)
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    if #vstrParam < 2 then
        return
    end
    local strSign = vstrParam[2]

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    
    --local mapRoot = json.decode(strData)
    if pJson_data.valueInt==1 then
        eventManager:pushCmd(Eventmanager.eCmd.setSign,vstrParam)
    end
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
end


return Spaceprotocol_setSign