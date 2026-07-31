


local Spaceprotocol_getVoice = {}

function Spaceprotocol_getVoice.request(strUrl,nAutoPlay)
    if not strUrl or strUrl=="" then
        return
    end
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nProtocolId = Spaceprotocol.eProId.getVoice
    local strProtocolParam = tostring(nProtocolId)

    strProtocolParam = strProtocolParam..","..nAutoPlay --2
    strProtocolParam = strProtocolParam..","..strUrl --3

    local strData = "" 
    local nHttpType = 0 -- get Type Spaceprotocol.nHttpType
    local nTimeout = Spaceprotocol.nTimeout
    gGetSpaceManager():SendRequest(strProtocolParam,strUrl,strData,nHttpType,nTimeout)

end

--cjson
function Spaceprotocol_getVoice.process(strData,vstrParam)
    if not strData then
        return
    end

    if #vstrParam < 3 then
        return
    end
    local nAutoPlay = tonumber(vstrParam[2])
    local strSoundUrl = vstrParam[3]

    local strSoundData = strData 
    local strSounFilePath = getSpaceManager():getTempSoundFilePath()
    gGetSpaceManager():SaveVoice(strSoundUrl, strSounFilePath)

    if nAutoPlay==1 then
        if gGetGameConfigManager() and gGetGameConfigManager():isPlayEffect() then
              SimpleAudioEngine:sharedEngine():playEffect(strSounFilePath)
		end
    end
end


return Spaceprotocol_getVoice