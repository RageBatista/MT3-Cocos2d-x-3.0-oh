require "logic.dialog"
require "logic.space.spacedialog"

Spacelabel = {}
setmetatable(Spacelabel, Dialog)
Spacelabel.__index = Spacelabel

local _instance

local nPrefix = 0

function Spacelabel.getInstance()
	if not _instance then
		_instance = Spacelabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
	
end

function Spacelabel.getInstanceNotCreate()
	return _instance
end



function Spacelabel.getInstanceAndShow(roleData)
	if not _instance then
		_instance = Spacelabel.new()
		_instance:OnCreate(roleData)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Spacelabel.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Spacelabel:OnClose()

	LogInfo("Spacelabel:OnClose()")
	local dlg = require"logic.space.spacedialog".getInstanceNotCreate()
	if dlg then
		self:removeEvent(dlg:GetWindow())
		dlg:OnClose()
		dlg = nil
	end
    getSpaceManager():clearData()
	Dialog.OnClose(self)
	_instance = nil
end


function Spacelabel:subscribeEvent(wnd)
	LogInfo("Spacelabel:subscribeEvent(wnd)")
	wnd:subscribeEvent("AlphaChanged", Spacelabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", Spacelabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", Spacelabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", Spacelabel.handleDlgStateChange, self)
end

function Spacelabel:removeEvent(wnd)
	LogInfo("Spacelabel:removeEvent(wnd)")
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function Spacelabel:handleDlgStateChange(args)
	LogInfo("Spacelabel:handleDlgStateChange(args)")
    local dlg = require"logic.space.spacedialog".getInstanceNotCreate()
	if dlg then
		if dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			return
		end
	end
	self:SetVisible(false)
end


function Spacelabel.GetLayoutFileName()
	return "lablekj.layout"
end

function Spacelabel:new()
    local self = {}
	self = Dialog:new()
    setmetatable(self, Spacelabel)
	self:ClearData()
    return self
end

function Spacelabel:ClearData()
	self.vBtn = {}
    self.showRoleData = {}
    self.nSpaceType = 0
end

function Spacelabel:OnCreate(roleData)
    if not roleData.nnRoleId then
        roleData.nnRoleId = getSpaceManager():getMyRoleId()
    end 

    self.showRoleData = roleData
    local nnMyRoelId = getSpaceManager():getMyRoleId()

	local prefix = "Spacelabel"..nPrefix
    nPrefix = nPrefix + 1
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)

    local nHaveBtn = 3
    if self.showRoleData.nnRoleId ~= nnMyRoelId then
        nHaveBtn = 2
    end
    local vAllBtn = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	for i = 1, 4 do
		local wndname = i == 1 and prefix.."Lable/button" or prefix.."Lable/button"..i-1
		local btn = CEGUI.Window.toPushButton(winMgr:getWindow(wndname))
        btn:SetMouseLeaveReleaseInput(false)
		local strImageRedName = prefix.."Lable/button/image"..i
		local imageRed =  winMgr:getWindow(strImageRedName)
		imageRed:setVisible(false)
		btn.imageRed = imageRed     
	    btn:setVisible(false)	
        vAllBtn[#vAllBtn + 1] = btn
	end

    for nIndex=1,nHaveBtn do 
		local btn = vAllBtn[nIndex]
		self.vBtn[nIndex] = btn
		btn:setVisible(true)
	end
	-----------------------------
	local vStrTitle = {}
    local vBtnId = {}

    local nnMyRoelId = getSpaceManager():getMyRoleId()

    if self.showRoleData.nnRoleId ~= nnMyRoelId then
        --vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11409)
	    
	    vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11410)--11411
        vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11411)--11410
	    --vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2922)

        
        vBtnId[#vBtnId +1] = Spacedialog.eSpaceType.leftChat
        vBtnId[#vBtnId +1] = Spacedialog.eSpaceType.mySay

    else
        vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11409)
	    vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11410)
	    vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11411)
	    --vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2922)

        vBtnId[#vBtnId +1] = Spacedialog.eSpaceType.friendAround
        vBtnId[#vBtnId +1] = Spacedialog.eSpaceType.leftChat
        vBtnId[#vBtnId +1] = Spacedialog.eSpaceType.mySay
    end
	
		
	for nIndex=1,#self.vBtn do 
		local btn = self.vBtn[nIndex]
		local strTitle = vStrTitle[nIndex]
		btn:setText(strTitle)
		btn:EnableClickAni(false)
		btn.nId = vBtnId[nIndex]
		btn:subscribeEvent("MouseButtonUp", Spacelabel.HandleClickBtn, self)		
	end

    self.spaceDlg = require"logic.space.spacedialog".getInstanceAndShow()
    self:subscribeEvent(self.spaceDlg:GetWindow())
   
    self:clickBtn(vBtnId[1])
    --local Spacedialog = require"logic.space.spacedialog"
    --self:showDlg(Spacedialog.eSpaceType.friendAround)
end

function Spacelabel:clickBtn(nId)
    self:RefreshBtnSel()
    if self.nSpaceType == nId then
        return
    end
	self:showDlg(nId)
end

function Spacelabel:HandleClickBtn(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	local nId = clickWin.nId

    self:clickBtn(nId)
end

function Spacelabel:showDlg(nType)
	self.nSpaceType = nType
    self.spaceDlg:showDlgWithType(nType)
	self:RefreshBtnSel()
end


function Spacelabel:SetRedPointVisible(nIndex,bVisible)
	if 	nIndex<1 or 
		nIndex>4 or 
		nIndex>#self.vBtn
		then
		return
	end
	local btnLabel = self.vBtn[nIndex]
    if btnLabel then
	    btnLabel.imageRed:setVisible(bVisible)
    end
end


function Spacelabel:RefreshBtnSel()
	for i = 1, #self.vBtn do 
		local paneBtn = self.vBtn[i]
		local btnTitle = CEGUI.Window.toPushButton(paneBtn)
		if btnTitle.nId ~= self.nSpaceType then
			btnTitle:SetPushState(false)
		else
			btnTitle:SetPushState(true)
		end	
	end
end


return Spacelabel
