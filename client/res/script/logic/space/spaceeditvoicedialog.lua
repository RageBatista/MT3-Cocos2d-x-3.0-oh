require "logic.dialog"

Spaceeditvoicedialog = {}
setmetatable(Spaceeditvoicedialog, Dialog)
Spaceeditvoicedialog.__index = Spaceeditvoicedialog

local _instance

function Spaceeditvoicedialog.getInstance()
	if not _instance then
		_instance = Spaceeditvoicedialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function Spaceeditvoicedialog.getInstanceAndShow()
	if not _instance then
		_instance = Spaceeditvoicedialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Spaceeditvoicedialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spaceeditvoicedialog:OnClose()
	Dialog.OnClose(self)
end

function Spaceeditvoicedialog.GetLayoutFileName()
	return "kongjian2.layout"
end

function Spaceeditvoicedialog.getInstanceNotCreate()
	return _instance
end



function Spaceeditvoicedialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Spaceeditvoicedialog)
	return self
end

function Spaceeditvoicedialog:OnCreate()
    Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	
    self.btnPlay = CEGUI.toPushButton(winMgr:getWindow("kongjian2_mtg/yuyinjieshao/di/btnbofa")) 
    self.btnPlay:subscribeEvent("MouseClick", Spaceeditvoicedialog.clickPlay, self)

    self.btnDelVoice = CEGUI.toPushButton(winMgr:getWindow("kongjian2_mtg/yuyinjieshao/di/btnshanyu")) 
    self.btnDelVoice:subscribeEvent("MouseClick", Spaceeditvoicedialog.clickDelVoice, self)

    self.btnClose = CEGUI.toPushButton(winMgr:getWindow("kongjian2_mtg/yuyinjieshao/close")) 
    self.btnClose:subscribeEvent("MouseClick", Spaceeditvoicedialog.clickClose, self)

end


function Spaceeditvoicedialog:clickClose(args)
    Spaceeditvoicedialog.DestroyDialog()
end


function Spaceeditvoicedialog:clickPlay(args)
    local spManager = getSpaceManager()
    local roleSpaceInfoData = spManager.roleSpaceInfoData
    
    local strCurSoundUrl = gGetSpaceManager():GetCurSoundUrl()
    local strRoleSoundUrl = roleSpaceInfoData.strSoundUrl
    if strCurSoundUrl==strRoleSoundUrl then
        if gGetGameConfigManager() and gGetGameConfigManager():isPlayEffect() then
            local strSounFilePath = getSpaceManager():getTempSoundFilePath()
            SimpleAudioEngine:sharedEngine():unloadEffect(strSounFilePath)
            SimpleAudioEngine:sharedEngine():playEffect(strSounFilePath)
	    end
    else
        local nAutoPlay = 1
        require("logic.space.spacepro.spaceprotocol_getVoice").request(roleSpaceInfoData.strSoundUrl,nAutoPlay)
    end
end

function Spaceeditvoicedialog:clickDelVoice(args)

    local strMsg =  require("utils.mhsdutils").get_msgtipstring(162166) 
    gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Spaceeditvoicedialog.clickConfirmBoxOk_delVoice,
	self,
	Spaceeditvoicedialog.clickConfirmBoxCancel_delVoice,
	self)

end

function Spaceeditvoicedialog:clickConfirmBoxOk_delVoice()
    
     local nnRoleId = getSpaceManager():getMyRoleId()
    require("logic.space.spacepro.spaceprotocol_delSound").request(nnRoleId)
    Spaceeditvoicedialog.DestroyDialog()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Spaceeditvoicedialog:clickConfirmBoxCancel_delVoice()

    local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end



return Spaceeditvoicedialog