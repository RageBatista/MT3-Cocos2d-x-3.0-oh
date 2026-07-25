require "logic.dialog"

CaptureDialog = {}
setmetatable(CaptureDialog, Dialog)
CaptureDialog.__index = CaptureDialog

local _instance
function CaptureDialog.getInstance()
	if not _instance then
		_instance = CaptureDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function CaptureDialog.getInstanceAndShow()
	if not _instance then
		_instance = CaptureDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CaptureDialog.getInstanceNotCreate()
	return _instance
end

function CaptureDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CaptureDialog.ToggleOpenClose()
	if not _instance then
		_instance = CaptureDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CaptureDialog.GetLayoutFileName()
	return "capture.layout"
end

function CaptureDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CaptureDialog)
	return self
end

function CaptureDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_frame = winMgr:getWindow("ShareDialog")
    self.m_setTopWnd = winMgr:getWindow("ShareDialog/top")
    self.m_text = winMgr:getWindow("ShareDialog/text")
    self.m_doCapture = false
    self.m_shareType = -1
    self.m_shareChannel = -1

    local serverName = gGetLoginManager():GetSelectServer()
    local pos = string.find(serverName, "-")
    if pos then
        serverName = string.sub(serverName, 1, pos - 1)
    end


    local strbuilder = StringBuilder.new()
    strbuilder:Set("parameter1", gGetDataManager():GetMainCharacterName()) 
    strbuilder:Set("parameter2", serverName)
    strbuilder:Set("parameter3", "www.locojoy.com")
    local str = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(190036))
    self.m_text:setText(str)
    strbuilder:delete()

    self.shareIcon = ""
    self.shareTitle = ""
    self.shareDescrib = ""
    self.url = ""
end

function CaptureDialog:createSharePic(topWnd, sType, sChannel)
    self.m_shareType = sType
    self.m_shareChannel = sChannel

    local vecScale = CEGUI.Vector3(0.8, 0.8, 1)
    topWnd:GetWindow():setGeomScale(vecScale)
    topWnd:GetWindow():setClippedByParent(false)

    self.m_frame:addChildWindow(topWnd:GetWindow())

    self.mTimeOut = 500
end

function CaptureDialog:setParameters(shareIcon, shareTitle, shareDescrib, url)
    self.shareIcon = shareIcon
    self.shareTitle = shareTitle
    self.shareDescrib = shareDescrib
    self.url = url
end

function CaptureDialog:run(delta)
    if not _instance then return end 

    if self.mTimeOut then
        if (self.mTimeOut > 0) then
            self.mTimeOut = self.mTimeOut - delta;
            if (self.mTimeOut <= 0) then
                if self.m_frame then
                    self.m_frame:setUsingAutoRenderingSurface(true)
                    self.m_frame:subscribeEvent("EndRender", CaptureDialog.onRenderEnded, self)
                    self.m_doCapture = true
                end
            end
        end
    end

    if self.mCaptureFinished then
        self.m_frame:removeEvent("EndRender")
        require "logic.share.sharedlg".DestroyDialog()
        if self.m_shareType == SHARE_TYPE_CHARACTOR then
            require "logic.characterinfo.characterlabel".DestroyDialog()
        elseif self.m_shareType == SHARE_TYPE_PET then
            require "logic.pet.petdetaildlg".DestroyDialog()
        elseif self.m_shareType == SHARE_TYPE_5V5 then
        end
        self:callShareSdkToShare()
        CaptureDialog.DestroyDialog()
    end
end

function CaptureDialog:callShareSdkToShare()
    gGetGameApplication():shareToPlatform(self.m_shareChannel, eShareType_Picture, self.shareTitle, self.shareDescrib, gGetGameApplication():getCaptureDir(), self.url)
end

function CaptureDialog:onRenderEnded(arg)
    if self.m_frame and self.m_doCapture then
        self.m_frame:trySaveRenderedImageToFile(gGetGameApplication():getCaptureDir())
        self.m_frame:setUsingAutoRenderingSurface(false)
        self.m_doCapture = false
        self.mCaptureFinished = true;
    end
end

return CaptureDialog