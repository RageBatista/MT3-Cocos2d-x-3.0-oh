
Spacemanager = {}
Spacemanager.__index = Spacemanager
local _instance = nil

Spacemanager.strSendStateUrlKey = "sendstateurl"

Spacemanager.nUIStatePicWidth = 200
Spacemanager.nUIStatePicHeight = 200

Spacemanager.nUIHeadWidth = 200
Spacemanager.nUIHeadHeight = 200

Spacemanager.nSendPicWidth = 350
Spacemanager.nSendPicHeight = 350




Spacemanager.eReqRoleInfoType=
{
    spaceInfo=1,
    clickRoleName=2,

}

Spacemanager.PixelFormat=
{
    PF_RGB=0,
    PF_RGBA=1,
}

Spacemanager.eListType=
{
    friendState=1,
    selfState=2,
    bbs=3,
    popu=4,
    recGift=5,
    bbs_npc=6,
}

Spacemanager.ePhotoCallBackType=
{
    setHead=1,
    sendState=2,
}
function Spacemanager_OnGetLocation(bRet)
    if not bRet then
        return
    end
    local nCount = LocationDetector:GetInstance():getLocationCount()
    if nCount==0 then
        return
    end

    local locationData =  LocationDetector:GetInstance():getLocation(0)
    if not locationData then
        return
    end

    local strPlace = locationData.mName
    local fLongitude = locationData.mLongitude
    local fLatitude = locationData.mLatitude

    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    --require("logic.space.spacepro.spaceprotocol_setLocation").request(nnMyRoleId,strPlace,fLongitude,fLatitude)
    local setLocationDlg = require("logic.space.spacesetaddressdialog").getInstanceNotCreate()
    if not setLocationDlg then
        return
    end
    setLocationDlg:getLocationCallBack(strPlace,fLongitude,fLatitude)
end

function Spacemanager_OnUserSelectPhoto()

    local photopPicker = PhotoPicker:shared()

    if photopPicker:getSelectedPhotoCount() <= 0 then
        return
    end
    local pCocosImage = photopPicker:getSelectedPhoto()
    if not pCocosImage then
        return
    end

    local nSelPicType = getSpaceManager().nSelPicType
    if nSelPicType==Spacemanager.ePhotoCallBackType.setHead then
        getSpaceManager():setHeadGetIamgeFromPhone(pCocosImage)
    elseif nSelPicType==Spacemanager.ePhotoCallBackType.sendState then
        getSpaceManager():sendStateGetImageResultFromPhone(pCocosImage)
    end
end

function Spacemanager_OnUserCancelSelectPhoto()
end

function Spacemanager:setHeadGetIamgeFromPhone(pCocosImage)

    local nUIHeadWidth = Spacemanager.nUIHeadWidth
    local nUIHeadHeight = Spacemanager.nUIHeadHeight
    gGetSpaceManager():ImageScaleToRect(pCocosImage,nUIHeadWidth,nUIHeadHeight) 

      local nnRoleId = getSpaceManager():getMyRoleId()
      local Spaceprotocol = require("logic.space.spaceprotocol")
      local strImageData = Spaceprotocol.strFileDataParam --"$filedata$"
      getSpaceManager():saveImageToCurString(pCocosImage)

      local nLength = gGetSpaceManager():GetCurStringLength()
        if nLength > getSpaceManager().nPicLengthMax then
            local strShowTip = require("utils.mhsdutils").get_msgtipstring(162168)
		    GetCTipsManager():AddMessageTip(strShowTip)
            return
        end

      require("logic.space.spacepro.spaceprotocol_setHead").request(nnRoleId,strImageData)
end

function Spacemanager:sendStateGetImageResultFromPhone(pCocosImage)
    
    local nSendPicWidth = Spacemanager.nSendPicWidth
    local nSendPicHeight = Spacemanager.nSendPicHeight
    gGetSpaceManager():ImageScaleToRect(pCocosImage,nSendPicWidth,nSendPicHeight)

    local strUrlKey = Spacemanager.strSendStateUrlKey

    local sendStateDlg = require("logic.space.spacesendstatedialog").getInstanceNotCreate()
    if sendStateDlg then
        sendStateDlg.itemCellHead:SetImage(nil)
    end

    gGetSpaceManager():DeleteImageWithUrlKey(strUrlKey)


    local bAutoDelete = true
    getSpaceManager():saveImageToCurString(pCocosImage)
    local bSaveCocosImage = true
    getSpaceManager():saveCeguiImageWithUrl(bAutoDelete,bSaveCocosImage,strUrlKey)

    
   local vstrParam = {}
   vstrParam[1] = strUrlKey
   local Eventmanager = require "logic.space.eventmanager"
   local eventManager = Eventmanager.getInstance()
   eventManager:pushCmd(Eventmanager.eCmd.sendStateGetImageResult,vstrParam)

end



function Spacemanager:saveImageToCurString(pCocosImage)
    if not pCocosImage then
        return
    end

    local bIsToRGB = getSpaceManager():isSaveFileToRGB()
    local strTempPathFile = getSpaceManager():getTempPicPathFile()
    gGetSpaceManager():SaveImageToCurString(pCocosImage,bIsToRGB,strTempPathFile)

end

function Spacemanager:getSendStateCocosImage()
    local strUrlKey = Spacemanager.strSendStateUrlKey
    local pCocosImage = gGetSpaceManager():GetCocosImageWithUrl(strUrlKey)
    return pCocosImage
end

function Spacemanager:registerCallBack(nSelPicType)
    self.nSelPicType = nSelPicType
    local photoPicker = PhotoPicker:shared()
    photoPicker:setOnSelectedCallback("Spacemanager_OnUserSelectPhoto")
    photoPicker:setOnCancelCallback("Spacemanager_OnUserCancelSelectPhoto")

end

function getSpaceManager()
    local spManager = require("logic.space.spacemanager").getInstance()
    return spManager
end

function Spacemanager:getTempPicFileName() 
    local bIsToRGB = getSpaceManager():isSaveFileToRGB()
    if bIsToRGB then
        return "spacepic.jpg" 
    else
        return "spacepic.png" 
    end
    
end
function Spacemanager:getTempSoundFileName() 
    return "spacesound.mp3"
end

function Spacemanager:getImageFormat()
    local bIsToRGB = getSpaceManager():isSaveFileToRGB()
    if bIsToRGB then
        return Spacemanager.PixelFormat.PF_RGB
    else
        return Spacemanager.PixelFormat.PF_RGBA
    end
    
end

function Spacemanager:isSaveFileToRGB()
    return true --jpg==true  
end

function Spacemanager:getSendPicTypeString()
     local bIsToRGB = getSpaceManager():isSaveFileToRGB()
    if bIsToRGB then
        return "jpg";
    else
        return "png"
    end
end

function Spacemanager:getNormalTextColor()
    return "ff50321a"
end

function Spacemanager:getTempSoundFilePath()
    local strTempPath = gGetSpaceManager():GetTempFilePath()
    local strSaveFileName = self:getTempSoundFileName()
    local strTempPathFile = strTempPath..strSaveFileName
    return strTempPathFile
end

function Spacemanager:saveCeguiImageWithUrl(bAutoDelete, bSaveCocosImage ,strUrl)
    
    local nImageType = self:getImageFormat()
    if strUrl and string.find(strUrl, ".png") then 
       nImageType = Spacemanager.PixelFormat.PF_RGBA 
    end
    
    local Spaceprotocol = require("logic.space.spaceprotocol")
    local nSaveMax = Spaceprotocol.nSavePicMax
    local nHaveIamgeCount = gGetSpaceManager():GetSaveImageCount()
    if nHaveIamgeCount >= nSaveMax then
        --gGetSpaceManager():DeleteTopImage()
    end

    local strImageName = strUrl.."imageName"
    local strImageSetName = strUrl.."imagesetName"
    local strTempPicPathFile = getSpaceManager():getTempPicPathFile()
    local ceguiImage = gGetSpaceManager():SaveCeguiImageWithUrl(strTempPicPathFile,bAutoDelete,bSaveCocosImage,strUrl,strImageName,strImageSetName,nImageType)
    return ceguiImage
end


function Spacemanager:getTempPicPathFile()
    local strTempPath = gGetSpaceManager():GetTempFilePath()
    local strSaveFileName = self:getTempPicFileName()
    local strTempPathFile = strTempPath..strSaveFileName
    return strTempPathFile
end



function Spacemanager:new()
    local self = {}
    setmetatable(self, Spacemanager)
	self:clearData()
    return self
end


function Spacemanager.Destroy()
    if _instance then 
        _instance:clearData()
        _instance = nil
    end
end

function Spacemanager:toCorrectModelId(nShapeId)
     if nShapeId then
        local createRoleTable = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(nShapeId)
        if createRoleTable then
            nShapeId = createRoleTable.model
        end
    end
    return nShapeId
end

function Spacemanager:resetRoleData(roleSpaceInfoData)
    roleSpaceInfoData.nnRoleId = 0
    roleSpaceInfoData.nModelId = 0
    roleSpaceInfoData.nJobId = 0
    roleSpaceInfoData.strUserName = ""
    roleSpaceInfoData.nLevel = 0
    roleSpaceInfoData.strRoleTitle = ""
    roleSpaceInfoData.strFactionName = ""

    roleSpaceInfoData.nNewMsgCount = 0
    roleSpaceInfoData.nPopularityCount = 0
    roleSpaceInfoData.nReceiveGiftCount =0
    roleSpaceInfoData.strSoundUrl =""
    roleSpaceInfoData.strHeadUrl = ""
    roleSpaceInfoData.nHeadVerify = -1
    roleSpaceInfoData.strLocation = "" 
    roleSpaceInfoData.strSign = "" 
    roleSpaceInfoData.strPlace = "" 
end


function Spacemanager:getCurRoleId()
    local spLabel = require("logic.space.spacelabel").getInstanceNotCreate()
    if not spLabel then
        return -1
    end
    return spLabel.showRoleData.nnRoleId
end

function Spacemanager:getMyRoleId()
    local nnRoleId = gGetDataManager():GetMainCharacterID()
    return nnRoleId
end

function Spacemanager:clearData()
    self.roleSpaceInfoData = {}
    self:resetRoleData(self.roleSpaceInfoData)

    self.vFriendSay = {}

    self.vLeaveWord = {}
    self.nBbsPageHaveDown = 0

    self.vMySayState = {}
    self.nMyStatePageHaveDown=0

    self.vPopularityList = {}
    self.nPopuPageHaveDown =0

    self.vReceiveGiftData = {}   
    self.nRecGiftPageHaveDown=0

    self.nMaxSendState = 50
    self.nMaxLenBbs = 50
    self.nMaxSign = 30

    -------------------
    self.nHomeShowCommentNum=2
    self.nBbsNumInPage = 5
    self.nStateInPage = 4
    self.nRecGiftNumInPage = 5
    self.nPopuNumInPage = 8
    self.nCommentInPage = 10

    self.mapRoleLevel = {}
    self.nSelPicType = 0

    gGetSpaceManager():DeleteAllImage()

    self.strNpcSpaceRoleId = "9223372036854775807"

   self.nGiftNum = 0
   self.nRenqiNum = 0
   self.nRecGiftNum = 0

   self.vLeaveWord_npc = {}
   self.nBbsPageHaveDown_npc = 0

   self.nPicLengthMax= 300*1024

end

function Spacemanager:getRoleLevel(nnRoleId)
    return mapRoleLevel[nnRoleId]
end


function Spacemanager:updateListRoleLevel(nType)
    local vListData = nil
    if nType == Spacemanager.eListType.friendState then
        vListData = self.vFriendSay
    elseif nType == Spacemanager.eListType.selfState then
        vListData = self.vMySayState
    elseif nType == Spacemanager.eListType.bbs then
        vListData = self.vLeaveWord
    elseif nType == Spacemanager.eListType.popu then
        vListData = self.vPopularityList
    elseif nType == Spacemanager.eListType.recGift then
        vListData = self.vReceiveGiftData
    elseif nType == Spacemanager.eListType.bbs_npc then
        vListData = self.vLeaveWord_npc
    end

    if not vListData then
        return
    end

    local vNeedReqRoleId = {}
    for nIndex=1,#vListData do
        local oneData = vListData[nIndex]
        local nnRoleId = oneData.nnRoleId
        local nLevelInGs = self.mapRoleLevel[nnRoleId]
        if not nLevelInGs then
            vNeedReqRoleId[#vNeedReqRoleId + 1] = nnRoleId
        else    
            oneData.nLevel = nLevelInGs
        end
    end
    self:sendGetRoleLevel(vNeedReqRoleId,nType)
end


function Spacemanager:sendGetRoleLevel(vRoleId,nType)
    
    local cgetroleslevel = require("protodef.fire.pb.friends.cgetroleslevel"):new()
    cgetroleslevel.roles = vRoleId
    cgetroleslevel.gettype = nType
	require "manager.luaprotocolmanager":send(cgetroleslevel)

end


function Spacemanager:recGetRoleLevel(mapRoleLevel,nType)
    local vListData = nil
    if nType == Spacemanager.eListType.friendState then
        vListData = self.vFriendSay
    elseif nType == Spacemanager.eListType.selfState then
        vListData = self.vMySayState
    elseif nType == Spacemanager.eListType.bbs then
        vListData = self.vLeaveWord
    elseif nType == Spacemanager.eListType.popu then
        vListData = self.vPopularityList
    elseif nType == Spacemanager.eListType.recGift then
        vListData = self.vReceiveGiftData
    elseif nType == Spacemanager.eListType.bbs_npc  then
        vListData = self.vLeaveWord_npc
    end
    if not vListData then
        return
    end

    for nnRoleIdNew,nLevelNew in pairs(mapRoleLevel) do
        if not nLevelNew then
            nLevelNew = 1
        end
        self.mapRoleLevel[nnRoleIdNew] = nLevelNew
        self:updateRoleLevel(vListData,nnRoleIdNew,nLevelNew)
    end

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshRoleLevel)
end

function Spacemanager:updateRoleLevel(vListData,nnRoleIdNew,nLevelNew)
    for nIndex=1,#vListData do
        local oneData = vListData[nIndex]
        if oneData.nnRoleId == nnRoleIdNew then
            oneData.nLevel = nLevelNew
        end
    end
end


function Spacemanager:deleteState(nStateId,nSpaceType)
    local Spacedialog = require("logic.space.spacedialog")
    local vState = nil
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        vState = self.vFriendSay
    elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
    elseif nSpaceType==Spacedialog.eSpaceType.mySay then
       vState = self.vMySayState
    end

    for nIndex=1, #vState do 
        local oneState = vState[nIndex]
        if oneState.nStateId==nStateId then
            table.remove(vState,nIndex)
            return
        end
    end

end

function Spacemanager:deleteBbs(nBbsId)
    for k,bbsData in pairs(self.vLeaveWord) do
        if nBbsId==bbsData.nBbsId then
            table.remove(self.vLeaveWord,k)
        end
    end
end

function Spacemanager:sortFriendSay()
--[[
    table.sort(self.vFriendSay, function (v1, v2)
		return v1.nnSendTime < v2.nnSendTime
	end)
    --]]
end

function Spacemanager:sortMyState()
--[[
    table.sort(self.vMySayState, function (v1, v2)
		return v1.nnSendTime < v2.nnSendTime
	end)
    --]]
end

function Spacemanager:sortMyState()
--[[
    table.sort(self.vMySayState, function (v1, v2)
		return v1.nnSendTime < v2.nnSendTime
	end)
    --]]
end


function Spacemanager:deleteComment(nStateId,nCommentId,nSpaceType)
    local Spacedialog = require("logic.space.spacedialog")

    local vState = nil
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        vState = self.vFriendSay
    elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
    elseif nSpaceType==Spacedialog.eSpaceType.mySay then
       vState = self.vMySayState
    end
    local oneStateData = self:getOneStateData(vState,nStateId)
    if not oneStateData then
        return
    end

    for k,commentData in pairs(oneStateData.vSayToRole) do
        if commentData.nCommentId == nCommentId then
            table.remove(oneStateData.vSayToRole,k)
        end
    end
    oneStateData.nSayToCount = oneStateData.nSayToCount -1
    if oneStateData.nSayToCount < 0 then
        oneStateData.nSayToCount = 0
    end
    
end



function Spacemanager:isHaveStateDataWithLikeRoleId(vState,nStateId,nnClickRoleId)
    local oneState = nil
   for k,oneStateData in pairs(vState) do
        if  nStateId==oneStateData.nStateId then
            oneState = oneStateData
            for nIndex=1,#oneStateData.vLikeRole do
                local oneLikeData = oneStateData.vLikeRole[nIndex]
                if oneLikeData.nnRoleId == nnClickRoleId then
                      return true,oneState
                end
            end
        end
   end 
   return false,oneState

end

function Spacemanager:getOneStateData(vState,nStateId)
    for k,oneStateData in pairs(vState) do
        if nStateId==oneStateData.nStateId then
            return oneStateData
        end
   end
   return nil
end

function Spacemanager:updateClickLike(nnClickRoleId,strClickRoleName,nnTargetRoleId,nStateId,bLike,nSpaceType) 
    local Spacedialog = require("logic.space.spacedialog")

    local vState = nil
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        vState = self.vFriendSay
    elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
    elseif nSpaceType==Spacedialog.eSpaceType.mySay then
       vState = self.vMySayState
    end

    if bLike==true then
        local bHave,oneState  = self:isHaveStateDataWithLikeRoleId(vState,nStateId,nnClickRoleId)
        if bHave==false and oneState then
            
            local likeData = {}
            likeData.strUserName = strClickRoleName
            likeData.nnRoleId = nnClickRoleId
            table.insert(oneState.vLikeRole,1,likeData)
            
        end
    else
        for k,oneStateData in pairs(vState) do
        
            if oneStateData.nStateId == nStateId then
                for nIndex=1,#oneStateData.vLikeRole do
                    local oneLikeData = oneStateData.vLikeRole[nIndex]
                    if oneLikeData.nnRoleId == nnClickRoleId then
                        if bLike==false then
                            table.remove(oneStateData.vLikeRole,nIndex)
                            return
                        end
                    end
                end
            end
        end

    end
end

function Spacemanager:reqRoleInfo(nnRoleId)
    --local Spacemanager = require("logic.space.spacemanager")

     gGetFriendsManager():SetContactRole(nnRoleId, true)
--[[
    local nReqType = Spacemanager.eReqRoleInfoType.clickRoleName

    local crequestspaceroleinfo = require "protodef.fire.pb.friends.crequestspaceroleinfo":new()
    crequestspaceroleinfo.roleid = nnRoleId
    crequestspaceroleinfo.reqtype = nReqType
	require "manager.luaprotocolmanager":send(crequestspaceroleinfo)  
    --]]

end

function Spacemanager:openSpace(nnRoleId,nRoleLevel)
   local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(334).value
    local nOpenSpaceLevel = tonumber(strValue)

    local nMyLevel = gGetDataManager():GetMainCharacterLevel()
        if nMyLevel < nOpenSpaceLevel then
        local strNotOpen = require("utils.mhsdutils").get_resstring(11541)
        GetCTipsManager():AddMessageTip(strNotOpen)
        return
    end

    if not nRoleLevel then --self
    else
        if nRoleLevel < nOpenSpaceLevel then
             local strNotOpen = require("utils.mhsdutils").get_msgtipstring(162154)
             GetCTipsManager():AddMessageTip(strNotOpen)
            return
        end
    end

      --GetCTipsManager():AddMessageTipById(160061)

    self:clearData()
    --debugrequire("logic.z_test") --wangbin test
    

    local roleData = {}
    roleData.nnRoleId = nnRoleId
    self:showOpenSpaceDlg(roleData)
end

function Spacemanager:showOpenSpaceDlg(showRoleData)
    require("logic.space.spacelabel").DestroyDialog()
    require("logic.space.spacelabel").getInstanceAndShow(showRoleData)
end

function Spacemanager:addComment(commentData,nSpaceType)
    local Spacedialog = require("logic.space.spacedialog")

    local vState = nil
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        vState = self.vFriendSay
    elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
    elseif nSpaceType==Spacedialog.eSpaceType.mySay then
       vState = self.vMySayState
    end
    local nnRoleId = commentData.nnRoleId
    local nStateId = commentData.nStateId

    local oneStateData = self:getOneStateData(vState,nStateId)
    if not oneStateData then
        return
    end
    table.insert(oneStateData.vSayToRole,1,commentData)

    oneStateData.nSayToCount = oneStateData.nSayToCount + 1
end


function Spacemanager:getStringToRichContent(strSayContent,textColor)
    local strSayContentLink = "<T t=\""..strSayContent.."\" "
    strSayContentLink = strSayContentLink.."TextColor=\""..textColor.."\" "
    strSayContentLink = strSayContentLink.."/>"
    return strSayContentLink
end

--[[
function DisplayInfo:new()
	local self = {}
	setmetatable(self, DisplayInfo)
		self.DISPLAY_ITEM = 1
		self.DISPLAY_PET = 2
		self.DISPLAY_TASK = 8
		self.DISPLAY_TEAM_APPLY = 9
		self.DISPLAY_ROLL_ITEM = 11
		self.DISPLAY_ACTIVITY_ANSWER = 12
		self.DISPLAY_LIVEDIE = 13
		self.DISPLAY_BATTLE = 14

	self.displaytype = 0
	self.roleid = 0
	self.shopid = 0
	self.counterid = 0
	self.uniqid = 0
	self.teamid = 0

	return self
end

--]]


function Spacemanager:getUserNameLink(nnRoleId,strUserName)
    
    local strUserNameLink = "["..strUserName.."]"
    strUserNameLink = "<P t=\""..strUserNameLink.."\" "  --link P
    strUserNameLink = strUserNameLink.."roleid=\""..tostring(nnRoleId).."\" "
    strUserNameLink = strUserNameLink.."type=\""..tostring(15).."\" "  --DISPLAY_ITEM
    --strUserNameLink = strUserNameLink.."key=\""..tostring(0).."\" "
    --strUserNameLink = strUserNameLink.."baseid=\""..tostring(0).."\" "  --4 =user type 3=anye
    --strUserNameLink = strUserNameLink.."shopid=\""..tostring(0).."\" "
    --strUserNameLink = strUserNameLink.."counter=\""..tostring(0).."\" "
    --strUserNameLink = strUserNameLink.."bind=\""..tostring(0).."\" "
    --strUserNameLink = strUserNameLink.."loseefftime=\""..tostring(0).."\" "
    strUserNameLink = strUserNameLink.."TextColor=\"".."ff02972c".."\" "
    strUserNameLink = strUserNameLink.."/>"
    return strUserNameLink
end

function Spacemanager.getInstance()
	if not _instance then
		_instance = Spacemanager:new()
	end
	return _instance
end


function Spacemanager:beginRecord()
    local bCanRecord = gGetWavRecorder():canRecord()
    if bCanRecord then
		gGetWavRecorder():start() 
    end
end

function Spacemanager:stopRecord()
    gGetWavRecorder():stop() 

    gGetVoiceManager():ResumeEffectForLua()
    local BackMusic = gGetGameConfigManager():GetConfigValue("sound")
    if BackMusic ~= 0 then
        gGetVoiceManager():ResumeMusicForLua()
    end
end

--year-month-day
function Spacemanager:getSendTimeString(nnsendTime)
    local nnServerTime = gGetServerTime()	
    nnServerTime = nnServerTime /1000

	local time = StringCover.getTimeStruct(nnsendTime)
	local year = time.tm_year + 1900
	local month = time.tm_mon + 1
	local day = time.tm_mday
	local hour = time.tm_hour
	local minute = time.tm_min
	local second = time.tm_sec
	local strTime = string.format("%04d-%02d-%02d", year, month, day)

    local nPassSecond = nnServerTime - nnsendTime
    if nPassSecond < 60*60 then
        local nPassMinute = math.floor(nPassSecond/60)
        if nPassMinute <= 0 then
            nPassMinute = 1
        end

        --strTime = string.format("%02d:%02d:%02d", hour, minute, second)
        --11554 $parameter1$·ÖÖÓÇ°
        strTime = require("utils.mhsdutils").get_resstring(11554)
        local sb = StringBuilder.new()
        sb:Set("parameter1",nPassMinute)
        strTime = sb:GetString(strTime)
        sb:delete()

    elseif nPassSecond < 24*60*60 then
        --strTime = string.format("%02d:%02d:%02d", hour, minute, second)
        local nPassHour = math.floor(nPassSecond/(60*60))
        strTime = require("utils.mhsdutils").get_resstring(11555)
        local sb = StringBuilder.new()
        sb:Set("parameter1",nPassHour)
        strTime = sb:GetString(strTime)
        sb:delete()
    end
    return strTime

end

function Spacemanager:getSendTimeStringMonthDay(nnsendTime)
     local nnServerTime = gGetServerTime()	
    nnServerTime = nnServerTime /1000

	local time = StringCover.getTimeStruct(nnsendTime)
	local year = time.tm_year + 1900
	local month = time.tm_mon + 1
	local day = time.tm_mday
	local hour = time.tm_hour
	local minute = time.tm_min
	local second = time.tm_sec

    local strTime = string.format("%02d-%02d", month, day)
    return strTime
end

function Spacemanager:getStateCanDel(stateData)
    --local nCurShowRoleId = self:getCurRoleId()
    local nMyRoleId = self:getMyRoleId()

    local nRoleIdInState = stateData.nnRoleId
    if nRoleIdInState==nMyRoleId then
        return true
    end
    return false
end

function Spacemanager:getCommentCanDel(commentData)
    local nMyRoleId = self:getMyRoleId()
    local nnRoleIdSender = commentData.sendRole.nnRoleId
    if nMyRoleId==nnRoleIdSender then
        return true
    end
    local nStateId = commentData.nStateId

    local oneStateData = self:getOneStateData(self.vFriendSay,nStateId)
    if not oneStateData then
        return false
    end
    if oneStateData.nnRoleId==nMyRoleId then
        return true
    end
    return false

end

function Spacemanager:getBbsCanDel(bbsData)
    local nCurShowRoleId = self:getCurRoleId()
    local nMyRoleId = self:getMyRoleId()
    local nnRoleIdSender = bbsData.nnRoleId

    if nMyRoleId==nnRoleIdSender then
        return true
    end
    if nMyRoleId==nCurShowRoleId then
        return true
    end
    return false
end


function Spacemanager:stringReplaceToColor(strContent,strNewColor)
    if not string.find(strContent, "c=\"") then 
        return strContent
    end
    strContent = string.gsub(strContent, "c=['\"][fF]+['\"]", "c='"..strNewColor.."'")
    return strContent
end


return Spacemanager
