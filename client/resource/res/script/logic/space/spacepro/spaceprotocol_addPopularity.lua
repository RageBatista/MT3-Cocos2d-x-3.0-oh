
--[[

== 接口说明 ==
  * 接口名称: 增加人气记录列表
  * 接口地址: /bbs/add_popularity

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 当前角色 ||
|| to_roleid | int | true | 目标角色 ||
|| is_get | int | true | 是否获得回馈,0非,1是 ||


#调用实例
http://192.168.41.5:8803/bbs/add_popularity?serverkey=s1&roleid=1&to_roleid=1

#结果实例
{"errno":"","message":"","data":true}

#再次踩的返回值
{"errno":"bbs_addpopularity_repeat","message":"bbs_addpopularity_repeat","data":null}


--]]

local Spaceprotocol_addPopularity = {}

function Spaceprotocol_addPopularity.request(nnRoleId,nnTargetRoleId)
local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.addPopularity
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nnTargetRoleId 

    --local strUrl = Spaceprotocol.getUrl(nProtocolId) 

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local strServerId = Spaceprotocol.getServerId()

    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&to_roleid="..nnTargetRoleId

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--c json
function Spaceprotocol_addPopularity.process(strData,vstrParam)


end


return Spaceprotocol_addPopularity