
--[[

== 接口说明 ==
  * 接口名称: 人气列表
  * 接口地址: /bbs/popularity_timeline

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 当前角色 ||
|| page | int | true | 页面, 从1开始 ||

#调用实例
http://192.168.41.5:8803/bbs/popularity_timeline?serverkey=s1&roleid=1&to_roleid=1

#结果实例
{"errno":"","message":"","data":[{"bbs_popularity_id":"1","roleid":"1","to_roleid":"1","status":"0",
"create_time":"1459862489","name":"\u6708\u4eae","avatar":"0","level":"0"}]}

--]]

local Spaceprotocol_popularityList = {}

function Spaceprotocol_popularityList.request(nnRoleId,nPage)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.popularityList
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nPage --2


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&bbs_popularity_id="..nPage

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
--[1] = {to_roleid="16385" is_get="0" create_time="1461829291" name="u65afu84ddu5a1cu5a25u8ff7" avatar="2" status="0" level="1" roleid="8193" bbs_popularity_id="1" }
function Spaceprotocol_popularityList.process(strData,vstrParam)
     if #vstrParam < 2 then
        return
    end
    local nPage = tonumber(vstrParam[2])   

    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end
    local nArrayNum = pJson_data.size
    if nArrayNum==0 then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    --[[
    local mapRoot = json.decode(strData)
    local vPopularityList = mapRoot.data
    if not vPopularityList  then
        return
    end
    local nNum =  require("utils.tableutil").tablelength(vPopularityList)
    if nNum==0 then
        return
    end
    --]]

    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    if nPage==0 then
        spManager.vPopularityList = {}
    end

   -- local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    local pJson_array = pJson_data --gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    local pJson_onePopularity = pJson_array.child

    for nIndex=1,nArrayNum do
        local onePopularity = {}
        --Spaceprotocol.readPopu(onePopularity,onePopularityServer)

        Spaceprotocol.readOnePopu(onePopularity,pJson_onePopularity)
        pJson_onePopularity = pJson_onePopularity.next

        table.insert(spManager.vPopularityList,onePopularity)
    end
   
   if nPage==0 then
        eventManager:pushCmd(Eventmanager.eCmd.reloadPopularityList)
   else
        eventManager:pushCmd(Eventmanager.eCmd.refreshPopularityListDownNextPage)
   end
   local Spacemanager = require("logic.space.spacemanager")
   spManager:updateListRoleLevel(Spacemanager.eListType.popu)
    
    gGetSpaceManager():SpaceJson_dispose(pJson_root)


end


return Spaceprotocol_popularityList