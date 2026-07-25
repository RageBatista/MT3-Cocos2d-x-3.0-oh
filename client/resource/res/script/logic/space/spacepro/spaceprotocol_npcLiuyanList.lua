
--[[

== 接口说明 ==
  * 接口名称: 留言列表
  * 接口地址: /bbs/bbs_timeline

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 当前角色 ||
|| page | int | true | 页面, 从1开始 ||


#调用实例
http://192.168.41.5:8803/bbs/bbs_timeline?serverkey=s1&roleid=1&page=1

#结果实例
{"errno":"","message":"","data":
[{"bbs_id":"5","roleid":"1","to_roleid":"1","status":"0","gift_type":"0","reply_id":"0","reply_roleid":"0",
"create_time":"1459862401","content":"\u53d1\u53d1\u7684\u53d1","name":"\u6708\u4eae","avatar":"0","level":"0"}]}

--]]

local Spaceprotocol_npcLiuyanList = {}
function Spaceprotocol_npcLiuyanList.request(strRoleId,nPage)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.npcLiuyanList
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nPage


    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local strServerId = Spaceprotocol.getServerId()

    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..strRoleId
    strData = strData.."&bbs_id="..nPage

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)


end


--c json
--strData = "{"errno":"server_notexist","message":"server_notexist","data":null}"
function Spaceprotocol_npcLiuyanList.process(strData,vstrParam)
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

    --nId,nSpaceType
    ---------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    ---------------

    local Spaceprotocol = require("logic.space.spaceprotocol")
    if nPage == 0 then
        spManager.vLeaveWord_npc = {}
    end
    ---------
    local pJson_array = pJson_data-- gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    local pJson_oneLeaveWord = pJson_array.child
    -----------

    local spManager = require("logic.space.spacemanager").getInstance()
    for nIndex=1,nArrayNum do
        local oneLeftWord = {}
        --Spaceprotocol.readLeftWord(oneLeftWord,oneLeftServer)
        Spaceprotocol.readOneLeaveWord(oneLeftWord,pJson_oneLeaveWord)
        pJson_oneLeaveWord = pJson_oneLeaveWord.next
        table.insert(spManager.vLeaveWord_npc, oneLeftWord)
    end

    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    -------------------------
    if nPage==0 then
        eventManager:pushCmd(Eventmanager.eCmd.reloadNpcSpaceBbs)
    else
        eventManager:pushCmd(Eventmanager.eCmd.refreshNpcBbs_downNextPage)
    end
    spManager.nBbsPageHaveDown_npc = nPage

    local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.bbs_npc)

end


return Spaceprotocol_npcLiuyanList