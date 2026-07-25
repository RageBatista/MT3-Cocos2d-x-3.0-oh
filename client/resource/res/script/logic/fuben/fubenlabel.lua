require "utils.mhsdutils"
require "logic.dialog"

require "logic.fuben.fubendlg"


Fubenlabel = {}
setmetatable(Fubenlabel, Dialog)
Fubenlabel.__index = Fubenlabel

local _instance


function Fubenlabel.getInstance()
	if not _instance then
		_instance = Fubenlabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
	
end

function Fubenlabel.getInstanceNotCreate()
	return _instance
end

function Fubenlabel.getInstanceOrNot()
	return _instance
end

function Fubenlabel.getInstanceAndShow()
	if not _instance then
		_instance = Fubenlabel.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function Fubenlabel.DestroyDialog()
	LogInfo("Fubenlabel.DestroyDialog()")
	if _instance then
		
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Fubenlabel:OnClose()
	LogInfo("Fubenlabel:OnClose()")
	local dlg = self.fubenDlg
	if dlg then
		self:removeEvent(dlg:GetWindow())
			
		dlg:OnClose()
		dlg = nil
	end
	Dialog.OnClose(self)
	_instance = nil
end


function Fubenlabel:subscribeEvent(wnd)
	LogInfo("Fubenlabel:subscribeEvent(wnd)")
	wnd:subscribeEvent("AlphaChanged", Fubenlabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", Fubenlabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", Fubenlabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", Fubenlabel.handleDlgStateChange, self)
end

function Fubenlabel:removeEvent(wnd)
	LogInfo("Fubenlabel:removeEvent(wnd)")
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function Fubenlabel:handleDlgStateChange(args)
	LogInfo("Fubenlabel:handleDlgStateChange(args)")

	local dlg = self.fubenDlg
	if dlg then
			if dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
				self:SetVisible(true)
				return
			end
	end
	self:SetVisible(false)
end


function Fubenlabel.GetLayoutFileName()
	return "lable.layout"
end

function Fubenlabel:new()
    local self = {}
	self = Dialog:new()
    setmetatable(self, Fubenlabel)
	self:ClearData()
    return self
end

function Fubenlabel:ClearData()
	self.vBtn = {}
	self.fubenDlg  = nil
end

function Fubenlabel:OnCreate()
	local prefix = "Fubenlabel"
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	local vAllBtn = {}
	for i = 1, 4 do
		local wndname = i == 1 and prefix.."Lable/button" or prefix.."Lable/button"..i-1
		local btn = CEGUI.Window.toPushButton(winMgr:getWindow(wndname))
        btn:SetMouseLeaveReleaseInput(false)
		local strImageRedName = prefix.."Lable/button/image"..i
		local imageRed =  winMgr:getWindow(strImageRedName)
		imageRed:setVisible(false)
		btn.imageRed = imageRed
		vAllBtn[i] = btn
		btn:setVisible(false)
		
	end
	
	for nIndex=1,2 do 
		local btn = vAllBtn[nIndex]
		self.vBtn[nIndex] = btn
		btn:setVisible(true)
	end
	
	
	local vStrTitle = {}
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11050)
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11051)
	
		
	for nIndex=1,#self.vBtn do 
		local btn = self.vBtn[nIndex]
		local strTitle = vStrTitle[nIndex]
		btn:setText(strTitle)
		btn:EnableClickAni(false)
		btn.nId = nIndex
		btn:subscribeEvent("MouseButtonUp", Fubenlabel.HandleClickBtn, self)		
	end
	
	self.fubenDlg = require("logic.fuben.fubendlg").getInstance()
	self:subscribeEvent(self.fubenDlg:GetWindow())
	
	self.nBtnId = 1
	self:RefreshBtnSel()
end

function Fubenlabel:HandleClickBtn(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	local nId = clickWin.nId
	
	self:showDlg(nId)
end

function Fubenlabel:SetRedPointVisible(nIndex,bVisible)
	if 	nIndex<1 or 
		nIndex>4 or 
		nIndex>#self.vBtn
		then
		return
	end
	local btnLabel = self.vBtn[nIndex]
	btnLabel.imageRed:setVisible(bVisible)
end


function Fubenlabel:showDlg(nDiff)
	self.nBtnId = nDiff
	self.fubenDlg:clickDiff(nDiff)
	self:RefreshBtnSel()
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.fubenDlg:GetWindow())

end

function Fubenlabel:RefreshBtnSel()
	for i = 1, #self.vBtn do 
		local paneBtn = self.vBtn[i]
		local btnTitle = CEGUI.Window.toPushButton(paneBtn)
		if btnTitle.nId ~= self.nBtnId then
			btnTitle:SetPushState(false)
		else
			btnTitle:SetPushState(true)
		end	
	end
end


function Fubenlabel:RefreshItemTips(item)
end

return Fubenlabel


