
--[[

== 接口说明 ==
  * 接口名称: 显示我的动态列表
  * 接口地址: /status/user_timeline

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 角色id ||
|| page | int | true | 页面,从1开始 ||

#调用实例
http://192.168.41.5:8803/status/user_timeline?serverkey=s1&roleid=1&page=1


#结果实例
{"errno":"","message":"","data":[{"status_id":"31","roleid":"1","status":"0","create_time":"1459856336","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","avatar":"0","level":"0","favorites":[],"comments":[]},{"status_id":"30","roleid":"1","status":"0","create_time":"1459856248","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","avatar":"0","level":"0","favorites":[],"comments":[]},{"status_id":"29","roleid":"1","status":"0","create_time":"1459856222","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","avatar":"0","level":"0","favorites":[],"comments":[]},{"status_id":"28","roleid":"1","status":"0","create_time":"1459853477","content":"\u5927\u53d1\u53d1\u7684","img_url":"","comment_count":"0","favorite_count":"0","name":"\u6708\u4eae","avatar":"0","level":"0","favorites":[],"comments":[]}]}


--]]

local Spaceprotocol_selfSayState = {}

--self say  list
--http://192.168.41.5:8803/status/user_timeline?serverkey=s1&roleid=1&page=1
function Spaceprotocol_selfSayState.request(nnRoleId,nPage)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.selfSayState
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nPage --2

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&status_id="..nPage

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)


    
end

function Spaceprotocol_selfSayState.process(strData,vstrParam)
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

    local Spaceprotocol = require("logic.space.spaceprotocol")
   

    --[[
    local MapRoot = json.decode(strData)
    local vRoleDataServer = MapRoot.data
    if not vRoleDataServer then
        return
    end

     local nNum =  require("utils.tableutil").tablelength(vRoleDataServer)
    if nNum==0 then
        return
    end
    --]]

    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()


    if nPage==0 then
        spManager.vMySayState = {}
    end

    --local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    local pJson_array =  pJson_data--gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    local pJson_roleStateData = pJson_array.child

    for nIndex=1,nArrayNum  do
        local roleStateData = {}
        --Spaceprotocol.readRoleStateData(roleStateData,roleStateDataServer)
        Spaceprotocol.readOneState(roleStateData,pJson_roleStateData)
        pJson_roleStateData = pJson_roleStateData.next
        table.insert(spManager.vMySayState,roleStateData)
    end
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    

    if nPage==0 then
        eventManager:pushCmd(Eventmanager.eCmd.reloadMySayList)
    else
        eventManager:pushCmd(Eventmanager.eCmd.refreshMySayListDownNextPage)
    end
    
    spManager.nMyStatePageHaveDown = nPage
     local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.selfState)
end





return Spaceprotocol_selfSayState