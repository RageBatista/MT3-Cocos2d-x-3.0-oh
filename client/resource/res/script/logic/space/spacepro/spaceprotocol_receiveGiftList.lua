
--[[
== 接口说明 ==
  * 接口名称: 送礼物记录列表
  * 接口地址: /bbs/gift_timeline

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 当前角色 ||
|| page | int | true | 页面, 从1开始 ||


#调用实例
http://192.168.41.5:8803/bbs/gift_timeline?serverkey=s1&roleid=1&to_roleid=1

#结果实例
{"errno":"","message":"","data":[]}



--]]

local Spaceprotocol_receiveGiftList = {}
--strUrl = "http://192.168.32.2:8803/bbs/gift_timeline?serverkey=1101961001&roleid=0&page=1"
function Spaceprotocol_receiveGiftList.request(nnRoleId,nPage)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.receiveGiftList
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nPage

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&bbs_gift_id="..nPage

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end
--+		oneReceiveGiftServer	{to_roleid="20481" roleid="16385" gift_id="339104" create_time="1462507083" name="u6cd5u5e08u5b81u6b21" 
--avatar="1" status="0" level="1" bbs_gift_id="28" gift_count="1" }	

function Spaceprotocol_receiveGiftList.process(strData,vstrParam)
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
    local mapRoot = json.decode(strData)
    local vGiftList = mapRoot.data
    if not vGiftList  then
        return
    end

    local nNum =  require("utils.tableutil").tablelength(vGiftList)
    if nNum==0 then
        return
    end
    --]]

    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    if nPage==0 then
        spManager.vReceiveGiftData = {}
    end

    --local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    local pJson_array = pJson_data --gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    local pJson_oneLeaveWord = pJson_array.child

    for nIndex=1,nArrayNum  do
        local oneReceiveGift = {}
        --Spaceprotocol.readLeftWord(oneReceiveGift,oneReceiveGiftServer)
        Spaceprotocol.readOneReceiveGift(oneReceiveGift,pJson_oneLeaveWord)
        pJson_oneLeaveWord = pJson_oneLeaveWord.next
        table.insert(spManager.vReceiveGiftData,oneReceiveGift)
    end

    gGetSpaceManager():SpaceJson_dispose(pJson_root)

    if nPage==0 then
        eventManager:pushCmd(Eventmanager.eCmd.reloadRecGift)
    else
        eventManager:pushCmd(Eventmanager.eCmd.refreshReceiveGiftDownNextPage)
    end
    
    spManager.nRecGiftPageHaveDown = nPage
    local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.recGift)
end


return Spaceprotocol_receiveGiftList