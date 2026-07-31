
--[[


== 接口说明 ==
  * 接口名称: 获取角色资料
  * 接口地址: /role/show

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 角色id   ||

#调用实例
http://192.168.41.5:8803/role/show?serverkey=s1&roleid=1

#结果实例
{"errno":"",
"message":"",

"data":{
"roleid":"1",
"name":"\u6708\u4eae",
"avatar":"0",
"level":"0",
"msg_count":"0",
"signature":"",
"popularity_count":"0",
"gift_count":"0",
"sound_url":"",
"avatar_url":"",
"avatar_verify":"0"}}


#返回结果描述
roleid 角色id
name 角色名
avatar 角色头像,系统头像
level 等级

msg_count 新消息数
signature 签名
popularity_count 人气数
gift_count 礼物数
sound_url 语音地址
avatar_url 头像,自定义头像
avatar_verify 审核状态


--]]

local Spaceprotocol_roleInfo = {}


function Spaceprotocol_roleInfo.request(nnRoleId)
    
    local nnRoleShowId = getSpaceManager():getCurRoleId()
    local nnMyRole = getSpaceManager():getMyRoleId()
    local nIsSelf = 1
    if nnRoleShowId==nnMyRole then
        nIsSelf = 1
    else
         nIsSelf = 0
    end

    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.roleInfo
    local strProtocolParam = tostring(nProtocolId)

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&is_self="..nIsSelf

    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)


end
--strData = "
--strData = "
--[[
<div style="border:1px solid #990000;padding-left:20px;margin:0 0 10px 0;">

<h4>A PHP Error was encountered</h4>

<p>Severity: Notice</p>
<p>Message:  Undefined index: avatar_verify</p>
<p>Filename: controllers/Role.php</p>
<p>Line Number: 50</p>


	<p>B...
    --]]

--cjson
function Spaceprotocol_roleInfo.process(strData)
    
    if  string.find(strData,"<div") then 
        return
    end
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    if not pJson_root then
        return
    end
    local pJson_data = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    if not pJson_data then
        gGetSpaceManager():SpaceJson_dispose(pJson_root)
        return
    end

    --[[
    local mapRoot = json.decode(strData)--wangbin test
    local mapRoleData = mapRoot.data
    if not mapRoleData then
        return
    end
    --]]
    

    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local pJson = pJson_data
    roleSpaceInfoData.nnRoleId = tonumber(Spaceprotocol.getJsonString(pJson,"roleid","0")) --tonumber(mapRoleData.roleid)
    roleSpaceInfoData.nModelId = tonumber(Spaceprotocol.getJsonString(pJson,"avatar","0")) --tonumber(mapRoleData.avatar)

    if roleSpaceInfoData.nModelId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(roleSpaceInfoData.nModelId)
        if createRoleTable then
            roleSpaceInfoData.nModelId = createRoleTable.model
        end
    end
    roleSpaceInfoData.strUserName = Spaceprotocol.getJsonString(pJson,"name","") --mapRoleData.name
    roleSpaceInfoData.nLevel = tonumber(Spaceprotocol.getJsonString(pJson,"level","0")) --tonumber(mapRoleData.level)
    roleSpaceInfoData.strSign = Spaceprotocol.getJsonString(pJson,"signature","") --mapRoleData.signature

    roleSpaceInfoData.nNewMsgCount = 0--tonumber(Spaceprotocol.getJsonString(pJson,"msg_count","0")) --tonumber(mapRoleData.msg_count)
    roleSpaceInfoData.strSoundUrl = Spaceprotocol.getJsonString(pJson,"sound_url","") --mapRoleData.sound_url
    roleSpaceInfoData.strHeadUrl = Spaceprotocol.getJsonString(pJson,"avatar_url","") --mapRoleData.avatar_url
   -- roleSpaceInfoData.nHeadVerify = tonumber(Spaceprotocol.getJsonString(pJson,"avatar_verify","0")) --tonumber(mapRoleData.avatar_verify)
   roleSpaceInfoData.strLocation = Spaceprotocol.getJsonString(pJson,"place","")

    Spaceprotocol_roleInfo:toCorrectRoleData(roleSpaceInfoData)

    --local pJson_root = gGetSpaceManager():SpaceJson_create(strData)
    --local pJson_roleInfo = gGetSpaceManager():SpaceJson_getItem(pJson_root,"data")
    --roleSpaceInfoData.strSign = gGetSpaceManager():SpaceJson_getString(pJson_roleInfo,"signature","")
    gGetSpaceManager():SpaceJson_dispose(pJson_root)



    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshRoleInfoHttp)

end

function Spaceprotocol_roleInfo:toCorrectRoleData(roleSpaceInfoData)
    if not roleSpaceInfoData.nnRoleId then
        roleSpaceInfoData.nnRoleId = 0
    end
    if not roleSpaceInfoData.nModelId then
        roleSpaceInfoData.nModelId = 0
    end
    if not roleSpaceInfoData.strUserName then
        roleSpaceInfoData.strUserName = ""
    end
    if not roleSpaceInfoData.nLevel then
        roleSpaceInfoData.nLevel = 0
    end
    if not roleSpaceInfoData.strSign then
        roleSpaceInfoData.strSign = ""
    end
    if not roleSpaceInfoData.nNewMsgCount then
        roleSpaceInfoData.nNewMsgCount = 0
    end
    if not roleSpaceInfoData.strSoundUrl then
        roleSpaceInfoData.strSoundUrl = ""
    end
    if not roleSpaceInfoData.strHeadUrl then
        roleSpaceInfoData.strHeadUrl = ""
    end
    if not roleSpaceInfoData.nHeadVerify then
        roleSpaceInfoData.nHeadVerify = 0
    end
    if not roleSpaceInfoData.strPlace then
        roleSpaceInfoData.strPlace = ""
    end

end



return Spaceprotocol_roleInfo