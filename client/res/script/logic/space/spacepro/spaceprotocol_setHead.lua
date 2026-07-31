
--[[
== 接口说明 ==
  * 接口名称: 更新头像
  * 接口地址: /role/upload_avatar 

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 角色id   ||
|| img_type | string | true | 图片类型, 包括:gif|jpg|jpeg|png ||
|| img_data | string | true | 图片二进制流 ||
--]]

local Spaceprotocol_setHead = {}
--strUrl = "http://192.168.32.2:8803/role/upload_avatar?serverkey=1101961001&roleid=4097&img_type=jpg&img_data=123"
function Spaceprotocol_setHead.request(nnRoleId,strImageData)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.setHead
    local strProtocolParam = tostring(nProtocolId)

    strImageType = getSpaceManager():getSendPicTypeString()

    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&img_type="..strImageType
    strData = strData.."&img_data="..strImageData
   

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)
end

--cjson
function Spaceprotocol_setHead.process(strData,vstrParam)
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
    local mapRoot = json.decode(strData)
    local mapInfo = mapRoot.data
    if not mapInfo then
        return
    end
    --]]

    local spManager = require("logic.space.spacemanager").getInstance()
    local strHeadUrl = pJson_data.valueString
    gGetSpaceManager():SpaceJson_dispose(pJson_root)

    local roleSpaceInfoData = spManager.roleSpaceInfoData

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.clearHeadPic)

    gGetSpaceManager():DeleteImageWithUrlKey(roleSpaceInfoData.strHeadUrl)

    roleSpaceInfoData.strHeadUrl = strHeadUrl

    if roleSpaceInfoData.strHeadUrl=="" then
        return
    end
    require("logic.space.spacepro.spaceprotocol_getHead").request(roleSpaceInfoData.strHeadUrl)

    local strMsg = require("utils.mhsdutils").get_msgtipstring(162149)
    GetCTipsManager():AddMessageTip(strMsg)
    
end


return Spaceprotocol_setHead