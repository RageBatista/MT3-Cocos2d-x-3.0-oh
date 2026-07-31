
--[[


== 接口说明 ==
  * 接口名称: 删除留言
  * 接口地址: /bbs/destroy

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 当前角色 ||
|| bbs_id | int | true | 留言id ||

#调用实例
http://192.168.41.5:8803/bbs/destroy?serverkey=s1&roleid=1&bbs_id=2

#结果实例
{"errno":"","message":"","data":true}



--]]

local Spaceprotocol_deleteBbs = {}

function Spaceprotocol_deleteBbs.request(nnRoleId,nBbsId)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.deleteBbs
    local strProtocolParam = tostring(nProtocolId)

    --strProtocolParam = strProtocolParam..","..nSpaceType
    strProtocolParam = strProtocolParam..","..nBbsId --2


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&bbs_id="..nBbsId

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_deleteBbs.process(strData,vstrParam)
    --id,nSpaceType,nStateId,nCommentId
    if #vstrParam <2 then
        return
    end
    --local nSpaceType = tonumber(vstrParam[2])
    local nBbsId = tonumber(vstrParam[2])

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    -------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    -----------

    --local MapRoot = json.decode(strData)
    if pJson_data.valueInt == 1 then
        spManager:deleteBbs(nBbsId)
        eventManager:pushCmd(Eventmanager.eCmd.delBbs)
    end

    gGetSpaceManager():SpaceJson_dispose(pJson_root)
end


return Spaceprotocol_deleteBbs