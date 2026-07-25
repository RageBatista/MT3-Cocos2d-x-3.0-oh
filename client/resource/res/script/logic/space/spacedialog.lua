require "logic.dialog"

Spacedialog = {}
setmetatable(Spacedialog, Dialog)
Spacedialog.__index = Spacedialog

Spacedialog.eSpaceType = 
{
    friendAround=1,
    leftChat=2,
    mySay=3
}

local _instance
function Spacedialog.getInstance()
	if not _instance then
		_instance = Spacedialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spacedialog.getInstanceAndShow()
	if not _instance then
		_instance = Spacedialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spacedialog.getInstanceNotCreate()
	return _instance
end

function Spacedialog.DestroyDialog()
    require("logic.space.spacelabel").DestroyDialog()
end


function Spacedialog:OnClose()
    self:removeEvent()
    for k,dlg in pairs(self.vSpaceDlg) do
        if dlg then
            dlg:DestroyDialog()
        end
    end 

	Dialog.OnClose(self)
	_instance = nil
end

function Spacedialog.ToggleOpenClose()
	if not _instance then
		_instance = Spacedialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Spacedialog.GetLayoutFileName()
	return "kongjian.layout"
end

function Spacedialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spacedialog)
    self:clearData()
	return self
end

function Spacedialog:clearData()
    self.vSpaceDlg = {}
   
    self.curDlg  = nil
    self.roleSpaceInfoData = {}

end

function Spacedialog:removeEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleInfoHttp,self,Spacedialog.refreshRoleInfoHttp)
    eventManager:removeEvent(Eventmanager.eCmd.refreshRoleInfoGs,self,Spacedialog.refreshRoleInfoGs)
    eventManager:removeEvent(Eventmanager.eCmd.setSign,self,Spacedialog.setSign)

    eventManager:removeEvent(Eventmanager.eCmd.refreshLocation,self,Spacedialog.refreshLocation)
    eventManager:removeEvent(Eventmanager.eCmd.showHeadPic,self,Spacedialog.showHeadPic)
    eventManager:removeEvent(Eventmanager.eCmd.delHeadResult,self,Spacedialog.delHeadResult)
    
    eventManager:removeEvent(Eventmanager.eCmd.clearHeadPic,self,Spacedialog.clearHeadPic)
end

function Spacedialog:registerEvent()
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()

    eventManager:addEvent(Eventmanager.eCmd.refreshRoleInfoHttp,self,Spacedialog.refreshRoleInfoHttp)
    eventManager:addEvent(Eventmanager.eCmd.refreshRoleInfoGs,self,Spacedialog.refreshRoleInfoGs)
    eventManager:addEvent(Eventmanager.eCmd.setSign,self,Spacedialog.setSign)

    eventManager:addEvent(Eventmanager.eCmd.refreshLocation,self,Spacedialog.refreshLocation)
    eventManager:addEvent(Eventmanager.eCmd.showHeadPic,self,Spacedialog.showHeadPic)
    eventManager:addEvent(Eventmanager.eCmd.delHeadResult,self,Spacedialog.delHeadResult)

     eventManager:addEvent(Eventmanager.eCmd.clearHeadPic,self,Spacedialog.clearHeadPic)

end

function Spacedialog:clearHeadPic()
    
   self.imageHead:setProperty("Image", "")
end

function Spacedialog:delHeadResult()
    self:refreshHeadVisible(false)
end

function Spacedialog:refreshLocation(vstrParam)
    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local strLocation = roleSpaceInfoData.strLocation 
    self.btnLocation:setText("")
    if strLocation=="" or strLocation=="0" then
        self.labelLocation:setText(self.strOldLocationTitle)
    else
        self.labelLocation:setText(strLocation)
    end    
end

function Spacedialog:clickLocation()
     local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    if nnShowRoleId==nnMyRoleId then
    else
        return
    end

    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local strLocation = roleSpaceInfoData.strLocation 
    --[[
    if strLocation=="" or strLocation=="0" then
        
        --LocationDetector:GetInstance():setFinishCallbackFunction("Spacemanager_OnGetLocation")
        --LocationDetector:GetInstance():startDetect()

       require("logic.space.spacesetaddressdialog").getInstanceAndShow()

    else
        self:delLocation_showconfirm()
    end 
    --]]

    require("logic.space.spacesetaddressdialog").getInstanceAndShow()
end

function Spacedialog:delLocation()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    local strPlace = "0"
    local fLongitude = "0"
   local fLatitude = "0"
   require("logic.space.spacepro.spaceprotocol_setLocation").request(nnMyRoleId,strPlace,fLongitude,fLatitude)
end

function Spacedialog:delLocation_showconfirm()

    local strMsg =  require("utils.mhsdutils").get_msgtipstring(162167) 
    gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Spacedialog.clickConfirmBoxOk_delLocation,
	self,
	Spacedialog.clickConfirmBoxCancel_delLocation,
	self)

end

function Spacedialog:clickConfirmBoxOk_delLocation()
    self:delLocation()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spacedialog:clickConfirmBoxCancel_delLocation()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end








function Spacedialog:setSign(vstrParam)
    if #vstrParam <2 then
        return
    end
    local strSign = vstrParam[2]
    self.editboxSignName:Clear()
    self.editboxSignName:AppendText(CEGUI.String(strSign),self.signColor)

    self.editboxSignName:Refresh()
end

function Spacedialog:refreshRoleInfoGs(vstrParam)
    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData

    self:refreshRoleInfo(roleSpaceInfoData)
end


function Spacedialog:refreshRoleInfoHttp(vstrParam)
    --local vparam = vstrParam
    local spManager = require("logic.space.spacemanager").getInstance()
    local roleSpaceInfoData = spManager.roleSpaceInfoData

    local nNewMsgCount = roleSpaceInfoData.nNewMsgCount
    local nPopularityCount = roleSpaceInfoData.nPopularityCount 
    local nReceiveGiftCount = roleSpaceInfoData.nReceiveGiftCount 
    local strSoundUrl = roleSpaceInfoData.strSoundUrl
    local strHeadUrl = roleSpaceInfoData.strHeadUrl
    local strHeadVerify = roleSpaceInfoData.strHeadVerify 
    local strSign = roleSpaceInfoData.strSign
    local strLocation = roleSpaceInfoData.strLocation 

    --self.labelWeizhi:setText(strLocation)
    self:refreshLocation()

    if strSign ~= "" then
        self.editboxSignName:Clear()
        self.editboxSignName:AppendText(CEGUI.String(strSign),self.signColor)
        self.editboxSignName:Refresh()
        self.labelPlaceholder:setVisible(false)

        gGetFriendsManager():updateFriendSign(getSpaceManager():getCurRoleId(), strSign)
    end

    self:refreshHeadVisible(false)

    if strHeadUrl ~= "" then
        local pImage = gGetSpaceManager():GetCeguiImageWithUrl(strHeadUrl)
        if not pImage then
            self:requestHeadPic()
        else
            self:showHeadPic()
        end
    end
    
    local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    if nnShowRoleId==nnMyRoleId then
        self.editboxSignName:setReadOnly(false)
    else
        self.editboxSignName:setReadOnly(true)
    end

end

function Spacedialog:showHeadPic(vstrParam)
    
    local spManager = getSpaceManager()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local strHeadUrl = roleSpaceInfoData.strHeadUrl

    local pImage = gGetSpaceManager():GetCeguiImageWithUrl(strHeadUrl)
    if not pImage then
        return
    end
    local strImageName = strHeadUrl.."imageName"
    local strImageSetName = strHeadUrl.."imagesetName"
    local strPath = "set:"..strImageSetName.." ".."image:"..strImageName
    self.imageHead:setProperty("Image", strPath)
    self:refreshHeadVisible(true)

end

function Spacedialog:requestHeadPic()
    local spManager = getSpaceManager()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local strHeadUrl = roleSpaceInfoData.strHeadUrl

    require("logic.space.spacepro.spaceprotocol_getHead").request(strHeadUrl)
end

function Spacedialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    SetPositionOfWindowWithLabel(self:GetWindow())

    self.itemCellHead = CEGUI.toItemCell(winMgr:getWindow("kongjian_mtg/zuo/zhaopian"))
    self.imageHead = winMgr:getWindow("kongjian_mtg/zuo/moxingditu/static")
    self.imageHead:subscribeEvent("MouseClick", Spacedialog.clickShowEditPic, self)

	self.btnHeadChange = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/zhaopian/btnqiehuan")) 
    self.btnHeadChange:subscribeEvent("MouseClick", Spacedialog.clickModelShow, self)

    self.nodeModelBg = winMgr:getWindow("kongjian_mtg/zuo/moxingditu")   
	self.imageRoleModel = winMgr:getWindow("kongjian_mtg/zuo/moxing")
	
   	self.cckongjiantips = CEGUI.toRichEditbox(winMgr:getWindow("kongjian_mtg/cctsc1/kongjiantsc1"))
	self.cckongjiantips:Clear()
    self.cckongjiantips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7561)))
    self.cckongjiantips:Refresh()
	
	self.btnModelChange = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/zhaopian/btnqiehuan1")) --qiehuan
	self.btnModelAdd = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/zhaopian/btntianjia")) --tianjia zhanpian
    self.btnModelChange:subscribeEvent("MouseClick", Spacedialog.clickHeadShow, self)
    self.btnModelAdd:subscribeEvent("MouseClick", Spacedialog.clickShowEditPic, self)

    self.btnModelChange:setVisible(false)
    self.btnModelAdd:setVisible(true)

    self.itemCellHead:setVisible(false)
    self.imageRoleModel:setVisible(true)


	self.imageJob = winMgr:getWindow("kongjian_mtg/zuo/textbg/zhiye")
	self.labelRoleName = winMgr:getWindow("kongjian_mtg/zuo/textbg/zhiye1")
	self.labelLevel = winMgr:getWindow("kongjian_mtg/zuo/level")
	self.labelFamilyJob = winMgr:getWindow("kongjian_mtg/zuo/bg2/text1")
	self.labelSignName = winMgr:getWindow("kongjian_mtg/zuo/qianmingban/shuoming")

    self.labelPlaceholder = winMgr:getWindow("kongjian_mtg/zuo/qianmingban/shuoming")

	self.editboxSignName = CEGUI.toRichEditbox(winMgr:getWindow("kongjian_mtg/zuo/qianmingban/dianji")) --toRichEditbox --toEditbox
   -- self.editboxSignName:SetTextAcceptMode(CEGUI.eTextAcceptMode_OnlyEnter)
	--self.editboxSignName:setWordWrapping(false)
	--self.editboxSignName:SetBackGroundEnable(false)
	--self.editboxSignName:SetForceHideVerscroll(true)

    --self.editboxSignName:SetShieldSpace(true)
    local nMaxLen = getSpaceManager().nMaxSign
	self.editboxSignName:setMaxTextLength(nMaxLen)
	--self.editboxSignName:SetFrameEnabled(false)
	--self.editboxSignName:SetNormalColourRect(0xff50321a)
	--self.editboxSignName:subscribeEvent("TextChanged", Spacedialog.OnTextChanged, self)
    self.editboxSignName:subscribeEvent("KeyboardTargetWndChanged", Spacedialog.OnKeyboardTargetWndChanged, self)
    --self.editboxSignName:subscribeEvent("KeyDown", Spacedialog.OnKeyboardKeyDown, self)
    self.editboxSignName:subscribeEvent("Activated", Spacedialog.HandleKeyEditActivate, self) 
    self.editboxSignName:subscribeEvent("Deactivated", Spacedialog.HandleKeyEditDeactivate, self) 

    self.signColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))--fffff2df --ff50321a
    self.editboxSignName:SetColourRect(self.signColor)

	self.btnVoice = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/qianmingban/btnyuyin"))
    self.btnVoice:subscribeEvent("MouseClick", Spacedialog.clickVoice, self)

	self.labelRoleId = winMgr:getWindow("kongjian_mtg/zuo/shuziid1")
	self.familyName = winMgr:getWindow("kongjian_mtg/zuo/gonghui1")
	self.btnWeizhi = CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/btnweizhi"))
	self.labelWeizhi = winMgr:getWindow("kongjian_mtg/zuo/weizhi")

    self.btnLocation =  CEGUI.toPushButton(winMgr:getWindow("kongjian_mtg/zuo/btnweizhi")) 
    self.btnLocation:subscribeEvent("MouseClick", Spacedialog.clickLocation, self)
    self.strOldLocationTitle = self.btnLocation:getText()
    self.btnLocation:setVisible(true)

    self.labelLocation = winMgr:getWindow("kongjian_mtg/zuo/weizhi")
  


    self.bgRightNode = winMgr:getWindow("kongjian_mtg/1")

    self:registerEvent()

    self:requestRoleInfo()

end




function Spacedialog:HandleKeyEditActivate(args)
    return true
end

function Spacedialog:HandleKeyEditDeactivate(args)
    local nnRoleId = getSpaceManager():getMyRoleId()
    local nnShowRoleId = getSpaceManager():getCurRoleId()

    if nnRoleId~=nnShowRoleId then
        return
    end

    local strSign = self.editboxSignName:GetPureText() --"1"

    local nLen = self.editboxSignName:GetCharCount() --string.len(strSign)
    local nMaxLen = getSpaceManager().nMaxSign
    if nLen > nMaxLen then
        local strShowTip = require("utils.mhsdutils").get_resstring(11544)
        local sb = StringBuilder.new()
        sb:Set("parameter1",nMaxLen)
        strShowTip = sb:GetString(strShowTip)
        sb:delete()

		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end


    --local strSign = self.editboxSignName:getText()
    if strSign=="" then
        return
    end
    require("logic.space.spacepro.spaceprotocol_setSign").request(nnRoleId,strSign)

    local send = require "protodef.fire.pb.friends.csetsign":new()
    send.signcontent = strSign
    require "manager.luaprotocolmanager":send(send)
    return true
end

function Spacedialog:OnKeyboardKeyDown(args)
--[[
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd ~= self.editboxSignName then
        return
    end
    local nnRoleId = getSpaceManager():getMyRoleId()
    local strSign = self.editboxSignName:GetPureText()

    require("logic.space.spacepro.spaceprotocol_setSign").request(nnRoleId,strSign)
    --]]
end


function Spacedialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.editboxSignName then
        self.labelPlaceholder:setVisible(false)
    elseif self.editboxSignName:GetPureText() == "" then
        self.labelPlaceholder:setVisible(true)
    end
end

function Spacedialog:requestRoleInfo()
    local spLabel =  require("logic.space.spacelabel").getInstanceNotCreate()
    if not spLabel then
        return
    end
    local nnRoleId = spLabel.showRoleData.nnRoleId
    require("logic.space.spacepro.spaceprotocol_roleInfo").request(nnRoleId)
    
    local p = require "protodef.fire.pb.friends.cgetspaceinfo":new()
	p.roleid = nnRoleId
	require "manager.luaprotocolmanager":send(p)
    
    local Spacemanager = require("logic.space.spacemanager")
    local nReqType = Spacemanager.eReqRoleInfoType.spaceInfo


    local crequestspaceroleinfo = require "protodef.fire.pb.friends.crequestspaceroleinfo":new()
    crequestspaceroleinfo.roleid = nnRoleId
    crequestspaceroleinfo.reqtype = nReqType
	require "manager.luaprotocolmanager":send(crequestspaceroleinfo)    

end

function Spacedialog:clickVoice(args)
    local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    local spManager = getSpaceManager()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    
    if nnShowRoleId ~= nnMyRoleId then
        
        local strCurSoundUrl = gGetSpaceManager():GetCurSoundUrl()
        local strRoleSoundUrl = roleSpaceInfoData.strSoundUrl
        if strRoleSoundUrl=="" then
            return
        end

        if strCurSoundUrl==strRoleSoundUrl then
            local strSounFilePath = getSpaceManager():getTempSoundFilePath()
            if gGetGameConfigManager() and gGetGameConfigManager():isPlayEffect() then
                SimpleAudioEngine:sharedEngine():playEffect(strSounFilePath)
		    end
        else
            local nAutoPlay = 1
            require("logic.space.spacepro.spaceprotocol_getVoice").request(roleSpaceInfoData.strSoundUrl,nAutoPlay) 
        end
        return
    end
    
    if roleSpaceInfoData.strSoundUrl == "" then
        local strMsg = require "utils.mhsdutils".get_resstring(11527) 
	    local msgManager = gGetMessageManager()

	    gGetMessageManager():AddConfirmBox(eConfirmNormal,
	    strMsg,
	    Spacedialog.clickConfirmBoxOk_recordVoice,
	    self,
	    Spacedialog.clickConfirmBoxCancel_recordVoice,
	    self)
	     
    else
       require("logic.space.spaceeditvoicedialog").getInstanceAndShow()
    end
end

function Spacedialog:clickConfirmBoxOk_recordVoice()
     require("logic.space.spacerecorddialog").getInstanceAndShow()
     --gGetMessageManager():CloseCurrentShowMessageBox()
     local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spacedialog:clickConfirmBoxCancel_recordVoice()
    --gGetMessageManager():CloseCurrentShowMessageBox()
    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spacedialog:checkEquipEffect(roleSprite, quality)
    if quality ~= 0 then
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
        if record.effectId ~= 0 then
            self.m_pPackEquipEffect = roleSprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(record.effectId), false);
            --if self.m_pPackEquipEffect then
                --self.m_pPackEquipEffect:SetScale(2,2)
            --end
        end
    end
end

function Spacedialog:refreshRoleInfo(roleSpaceInfoData)
    if not roleSpaceInfoData then
        return
    end
    
    local nnRoleId  = roleSpaceInfoData.nnRoleId 
    local nModelId = roleSpaceInfoData.nModelId 
    local nJobId = roleSpaceInfoData.nJobId
    local strUserName = roleSpaceInfoData.strUserName
    local nLevel = roleSpaceInfoData.nLevel
    local strRoleTitle = roleSpaceInfoData.strRoleTitle
    local strFactionName = roleSpaceInfoData.strFactionName
    local mapComponents = roleSpaceInfoData.mapComponents
    ---------------------
    local s = self.imageRoleModel:getPixelSize()
	local roleSprite = gGetGameUIManager():AddWindowSprite(self.imageRoleModel, nModelId, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5, true)
    
    for i, v in pairs(mapComponents) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            roleSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            roleSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            roleSprite:UpdateWeaponColorParticle(v)
        end
        if mapComponents[60] then -- Ì××°ÌØÐ§
            self:checkEquipEffect(roleSprite, mapComponents[60])
        end
    end


	roleSprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
	roleSprite:PlayAction(eActionStand)
    local schoolTable=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nJobId)
    if schoolTable and schoolTable.id ~= -1 then
	    self.imageJob:setProperty("Image", schoolTable.schooliconpath)
    end
    self.labelRoleName:setText(strUserName)
    local strLvzi = require "utils.mhsdutils".get_resstring(11330)
    local strLv = strLvzi..tostring(nLevel)
    self.labelLevel:setText(strLv)
    
    self.labelRoleId:setText(tostring(nnRoleId))
    self.familyName:setText(strFactionName)

    self.labelFamilyJob:setText(strRoleTitle)
end

function Spacedialog:clickShowEditPic(args)
    
    --[[
    local pTestImage = gGetSpaceManager():getTestCocos2dImage("testhead.png")
    local bIsToRGB = false
    local strTempPath = gGetSpaceManager():GetTempFilePath()
    local strSaveFileName = "spacepic.png"
    local strTempPathFile = strTempPath..strSaveFileName
    gGetSpaceManager():SaveImageToCurString(pTestImage,bIsToRGB,strTempPathFile)
    --local strImageString =  gGetSpaceManager():ImageToStringConstChar(pTestImage,bIsToRGB,strPathFile)
    local Spaceprotocol = require("logic.space.spaceprotocol")

    local strImageData = Spaceprotocol.strFileDataParam --"$filedata$"
    local nnRoleId = getSpaceManager():getMyRoleId()
    require("logic.space.spacepro.spaceprotocol_setHead").request(nnRoleId,strImageData)
    --]]
    
    
    --print("strImageString="..strImageString)
    --local vImageChar = std.vector_BYTE_()
    --gGetSpaceManager():ImageToVector(pTestImage,bIsToRGB,strPathFile,vImageChar)
    --local strImageString = ""
    --for nIndex=0,vImageChar:size()-1 do
    --    local charOne = vImageChar[nIndex]
    --    strImageString = strImageString..charOne
    --end

    --[[
    local pTestImage = gGetSpaceManager():getTestCeguiImage("testhead.png")
    self.itemCellHead:SetImage(pTestImage)
    self:refreshHeadVisible(true)
    --]]

    
    local nnShowRoleId = getSpaceManager():getCurRoleId()
    local nnMyRoleId =  getSpaceManager():getMyRoleId()
    if nnShowRoleId ~= nnMyRoleId then

        return
    end
    local Spaceselpicdialog = require("logic.space.spaceselpicdialog")
    local selPicDialog = Spaceselpicdialog.getInstanceAndShow()
    selPicDialog:setDelegate(self,Spaceselpicdialog.eCallBackType.clickCamera ,Spacedialog.clickCamera)
    selPicDialog:setDelegate(self,Spaceselpicdialog.eCallBackType.clickPhoto ,Spacedialog.clickPhoto)
    selPicDialog:setDelegate(self,Spaceselpicdialog.eCallBackType.clickDel ,Spacedialog.clickDel)

end


function Spacedialog:clickCamera(selPicDialog)
    
    local SpaceManager = require("logic.space.spacemanager")
    local spManager = getSpaceManager()
    spManager:registerCallBack(Spacemanager.ePhotoCallBackType.setHead)
    local photoPicker = PhotoPicker:shared()
    photoPicker:openCamera()

    --wangbin test
    --local pCocosImage = gGetSpaceManager():getTestCocos2dImage("testhead.png")
    --getSpaceManager():setHeadGetIamgeFromPhone(pCocosImage)
end

function Spacedialog:clickPhoto(selPicDialog)
    local SpaceManager = require("logic.space.spacemanager")

    local spManager = getSpaceManager()
    spManager:registerCallBack(Spacemanager.ePhotoCallBackType.setHead)
    local photoPicker = PhotoPicker:shared()
    photoPicker:openAlbum()
end

function Spacedialog:clickDel(selPicDialog)
     local strMsg =  require("utils.mhsdutils").get_msgtipstring(162165) 
    gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Spacedialog.clickConfirmBoxOk_delPic,
	self,
	Spacedialog.clickConfirmBoxCancel_delPic,
	self)
end

function Spacedialog:delPicHead()
       local nnRoleId = getSpaceManager():getMyRoleId()
    require("logic.space.spacepro.spaceprotocol_delHead").request(nnRoleId)

    local spManager = require("logic.space.spacemanager").getInstance()

   local Eventmanager = require "logic.space.eventmanager"
   local eventManager = Eventmanager.getInstance()
   eventManager:pushCmd(Eventmanager.eCmd.clearHeadPic)

   gGetSpaceManager():DeleteImageWithUrlKey(spManager.roleSpaceInfoData.strHeadUrl)
   spManager.roleSpaceInfoData.strHeadUrl = ""

   eventManager:pushCmd(Eventmanager.eCmd.delHeadResult)
end


function Spacedialog:clickConfirmBoxOk_delPic()
    self:delPicHead()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spacedialog:clickConfirmBoxCancel_delPic()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end




function Spacedialog:clickHeadShow(args)
    self:refreshHeadVisible(true)
end

function Spacedialog:clickModelShow(args)
    self:refreshHeadVisible(false)
end

function Spacedialog:clickHead(args)
    
end

function Spacedialog:refreshHeadVisible(bHeadVisible)
    local spManager = getSpaceManager()
    local nnCurShowRoleId = spManager:getCurRoleId()
    local nnMyRoleId = spManager:getMyRoleId()

    local roleSpaceInfoData = spManager.roleSpaceInfoData
    local strHeadUrl = roleSpaceInfoData.strHeadUrl


    if bHeadVisible then
        self.itemCellHead:setVisible(true)
        self.nodeModelBg:setVisible(false)
        
    else
        self.itemCellHead:setVisible(false)
        self.nodeModelBg:setVisible(true)

        if strHeadUrl=="" then
            if nnMyRoleId==nnCurShowRoleId then
                self.btnModelAdd:setVisible(true)
            else
                self.btnModelAdd:setVisible(false)
            end
            self.btnModelChange:setVisible(false)
        else
            self.btnModelAdd:setVisible(false)
            self.btnModelChange:setVisible(true)
        end
    end
end

function Spacedialog:createSpaceDlg(nSpaceType)
    local dlg = nil
    if nSpaceType==Spacedialog.eSpaceType.friendAround then
        dlg = require"logic.space.friendarounddialog".create()
        dlg.nSpaceType = nSpaceType
    elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
        dlg = require"logic.space.spaceliuyandialog".create()
    elseif nSpaceType==Spacedialog.eSpaceType.mySay then
        dlg = require"logic.space.friendarounddialog".create()
        dlg.nSpaceType = nSpaceType
    end
    self.vSpaceDlg[nSpaceType] = dlg
    return dlg
end


function Spacedialog:getDialogWithType(nSpaceType)
    local dlg = self.vSpaceDlg[nSpaceType]
    if not dlg then
        dlg = self:createSpaceDlg(nSpaceType)
    end
    return dlg
end

function Spacedialog:requestHttpInfo(nSpaceType,nnRoleId)

   local nnMyRoleId = getSpaceManager():getMyRoleId()

   if nSpaceType==Spacedialog.eSpaceType.friendAround then
        if nnRoleId ~= nnMyRoleId then
            return
        end
        local nPreId = 0 --nPreId
        require("logic.space.spacepro.spaceprotocol_selfFriendAround").request(nnRoleId,nPreId)
    elseif nSpaceType==Spacedialog.eSpaceType.leftChat then
        local nPreId = 0
        require("logic.space.spacepro.spaceprotocol_bbsList").request(nnRoleId,nPreId)
    elseif nSpaceType==Spacedialog.eSpaceType.mySay then
        local nPreId = 0
        require("logic.space.spacepro.spaceprotocol_selfSayState").request(nnRoleId,nPreId)
    end
end


function Spacedialog:showDlgWithType(nSpaceType)
    local spLabel =  require("logic.space.spacelabel").getInstanceNotCreate()
    if not spLabel then
        return
    end
    local nnShowRoleId = spLabel.showRoleData.nnRoleId
    self:requestHttpInfo(nSpaceType,nnShowRoleId)
    ---------------------------
    if self.curDlg then
        self.bgRightNode:removeChildWindow(self.curDlg.m_pMainFrame)
    end
    local dlg = self:getDialogWithType(nSpaceType)
    if dlg then
        self.bgRightNode:addChildWindow(dlg.m_pMainFrame)
        dlg.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 0)))
        dlg:refreshUI()
        self.curDlg = dlg
    end
end

return Spacedialog