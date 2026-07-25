
--[[

== 接口说明 ==
  * 接口名称: 更新声音
  * 接口地址: /role/upload_sound 

== 接口参数 ==
|| **名称** | **类型** |**必须**| **说明** ||
|| serverkey | int/string | true | 区服 ||
|| roleid | int | true | 角色id   ||
|| sound_type | string | t}
rue | 声音类型, 包括:mp3 ||
|| sound_data | string | true | 声音二进制流 ||



--]]

local Spaceprotocol_setVoice = {}

function Spaceprotocol_setVoice.request(nnRoleId,strVoiceData)
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.setVoice

    local strProtocolParam = tostring(nProtocolId)


    local strServerId = Spaceprotocol.getServerId()
    local strData = "serverkey="..strServerId
    strData = strData.."&roleid="..nnRoleId
    strData = strData.."&sound_type="..Spaceprotocol.strVoiceType
    strData = strData.."&sound_data="..strVoiceData

    local strUrl = Spaceprotocol.getUrlApi(nProtocolId) 
    local nHttpType = Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_setVoice.process(strData,vstrParam)

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

    local strSoundUrl = pJson_data.valueString
    gGetSpaceManager():SpaceJson_dispose(pJson_root)

    local spManager = getSpaceManager()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    roleSpaceInfoData.strSoundUrl = strSoundUrl

    if roleSpaceInfoData.strSoundUrl=="" then
        return
    end
    local nAutoPlay = 0
    require("logic.space.spacepro.spaceprotocol_getVoice").request(roleSpaceInfoData.strSoundUrl,nAutoPlay)


end


return Spaceprotocol_setVoice