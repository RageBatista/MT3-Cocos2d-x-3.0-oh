
--[[


== 接口说明 ==
  * 接口名称: 发布新留言
  * 接口地址: /bbs/create

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 当前角色 ||
|| to_roleid | int | true | 目标角色 ||
|| content | int | true | 留言内容 ||
|| reply_id | int | true | 回复id ||
|| gift_type | int | true | 礼物类型,1玫瑰花,2金兰花,3同心结 ||
|| is_popularity | int | true | 是否踩一下 ||

#调用实例
http://192.168.41.5:8803/bbs/create?serverkey=s1&roleid=1&to_roleid=2&content=发发的发&reply_id=0&gift_type=0&is_popularity=0

#结果实例
{"errno":"","message":"","data":{"bbs_id":"2","roleid":"1","to_roleid":"2","status":"0","gift_type":"0","reply_id":"0","reply_roleid":"0","create_time":"1459862276","content":"\u53d1\u53d1\u7684\u53d1","name":"\u6708\u4eae","avatar":"0","level":"0","reply_name":"","reply_avatar":"","reply_level":0}}

#字段说明
bbs_id 留言id
roleid 角色id
to_roleid 被回复者角色id
gift_type 礼物类型,0表无礼物,1玫瑰花,2金兰花,3同心结
reply_id 回复的留言id
reply_roleid 被回复的评论角色id
content 留言内容
name 留言者名字
avatar 留言者头像
level 留言者等级
reply_name 被回复人id
reply_avatar 被回复人头像
reply_level 被回复人等级


--]]
--http://192.168.41.5:8803/bbs/create?serverkey=s1&roleid=1&to_roleid=2&content=发发的发&reply_id=0&gift_type=0&is_popularity=0
--strUrl = "http://192.168.32.2:8803/role/upload_sound?serverkey=30&roleid=16385&to_roleid=16385&content=<T t="88" c="FFFFFFFF"></T>&reply_id=0&gift_type=<T t="88" c="FFFFFFFF"></T>&is_popularity=<T t="88" c="FFFFFFFF"></T>"
local Spaceprotocol_liuyan = {}

function Spaceprotocol_liuyan.request(nnRoleId,nnTargetRoleId,strContent,nToBbsId,nGiftType,nCai)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.liuyan
    local strProtocolParam = tostring(nProtocolId)

    if nToBbsId==-1 then
        nToBbsId = 0
    end


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&to_roleid="..nnTargetRoleId
    strData = strData.."&content="..strContent
    strData = strData.."&reply_id="..nToBbsId
    strData = strData.."&gift_type=".."0"
    strData = strData.."&is_popularity="..nCai

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_liuyan.process(strData,vstrParam)
    --[[
    local MapRoot = json.decode(strData)
    local oneLeftServer = MapRoot.data
    if not oneLeftServer then
        return
    end
    --]]
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end
    --------------
    local spManager = require("logic.space.spacemanager").getInstance()
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    --------------

    local oneLeftWord = {}
    --Spaceprotocol.readLeftWord(oneLeftWord,oneLeftServer)
    ---------------
    Spaceprotocol.readOneLeaveWord(oneLeftWord,pJson_data);
    gGetSpaceManager():SpaceJson_dispose(pJson_root)
    ----------------

    table.insert(spManager.vLeaveWord,1,oneLeftWord)

    eventManager:pushCmd(Eventmanager.eCmd.reloadLeftWord)
    eventManager:pushCmd(Eventmanager.eCmd.liuyanResult)

    local Spacemanager = require("logic.space.spacemanager")
    spManager:updateListRoleLevel(Spacemanager.eListType.bbs)

end


return Spaceprotocol_liuyan