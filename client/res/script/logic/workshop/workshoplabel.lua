--require "logic.label"
require "utils.mhsdutils"
require "logic.workshop.workshopxqnew"
require "logic.workshop.workshopdznew"
require "logic.workshop.workshopxlnew"
require "logic.workshop.workshopxilian"
require "logic.workshop.workshopaq"
require "logic.workshop.Attunement"
require "logic.workshop.zhuangbeiqh"
require "logic.workshop.Xingyinxilian"
--require "logic.zhuanzhi.zhuanzhibaoshi33"
require "logic.workshop.workshopmanager"

require "logic.dialog"

WorkshopLabel = {}
setmetatable(WorkshopLabel, Dialog)
WorkshopLabel.__index = WorkshopLabel

local _instance
local dlgs =
{
	WorkshopDzNew, 
	WorkshopXqNew, 
	ZhuangBeiRongLianDlg,
	Workshopxlnew,
	XingyinxilianDlg,
--	ZhuanZhiBaoShi33,
} 

WorkshopLabel.eDlgType=
{
    dazao=1,
    xiangqian=2,
    hecheng=3,
    xiuli=4,
	xilian=5,
	--aq=6,
}

function WorkshopLabel.getInstance()
	if not _instance then
		_instance = WorkshopLabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
	
end

function WorkshopLabel.getInstanceNotCreate()
	return _instance
end

function WorkshopLabel.getInstanceOrNot()
	return _instance
end

function WorkshopLabel.getInstanceAndShow()
	if not _instance then
		_instance = WorkshopLabel.new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function WorkshopLabel.DestroyDialog()
	LogInfo("WorkshopLabel.DestroyDialog()")
	if _instance then
		
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function WorkshopLabel:OnClose()
	LogInfo("WorkshopLabel:OnClose()")
	for i = 1, #dlgs do
		local dlg = dlgs[i].getInstanceOrNot()
		if dlg then
			self:removeEvent(dlg:GetWindow())
			
			dlg:OnClose()
			dlg = nil
		end
	end
	Dialog.OnClose(self)
	_instance = nil
end


function WorkshopLabel:subscribeEvent(wnd)
	LogInfo("WorkshopLabel:subscribeEvent(wnd)")
	wnd:subscribeEvent("AlphaChanged", WorkshopLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", WorkshopLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", WorkshopLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", WorkshopLabel.handleDlgStateChange, self)
end

function WorkshopLabel:removeEvent(wnd)
	LogInfo("WorkshopLabel:removeEvent(wnd)")
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function WorkshopLabel:handleDlgStateChange(args)
	LogInfo("WorkshopLabel:handleDlgStateChange(args)")
	for nIndex = 1, #dlgs do
		local dlg = dlgs[nIndex].getInstanceOrNot()
		if dlg then
			if dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.85 then
				self:SetVisible(true)
				return
			end
		end
		
	end
	--[[
	for _,v in pairs(self.dialogs) do
		if v:IsVisible() and v:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			return
		end
	end
	--]]
	
	self:SetVisible(false)
end


function WorkshopLabel.GetLayoutFileName()
	return "lable3.layout"
end

function WorkshopLabel:new()
    local self = {}
	self = Dialog:new()
    setmetatable(self, WorkshopLabel)
	self:ClearData()
    return self
end

function WorkshopLabel:ClearData()
	self.buttons = {}
end

function WorkshopLabel:OnCreate()
	local prefix = "WorkshopLabel"
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)

	local winMgr = CEGUI.WindowManager:getSingleton()
	for i = 1, 5 do
		local wndname = i == 1 and prefix.."Lable/button" or prefix.."Lable/button"..i-1
		local btn = CEGUI.Window.toPushButton(winMgr:getWindow(wndname))
        btn:SetMouseLeaveReleaseInput(false)
		local strImageRedName = prefix.."Lable/button/image"..i
		local imageRed =  winMgr:getWindow(strImageRedName)
		imageRed:setVisible(false)
		btn.imageRed = imageRed
		self.buttons[i] = btn
	end
	
	local vStrTitle = {}
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2682)
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2683)
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2684)
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2922)
	vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(11813)
	--vStrTitle[#vStrTitle + 1] = MHSD_UTILS.get_resstring(2683)

		
	for nIndex=1,#self.buttons do 
		local btn = self.buttons[nIndex]
		local strTitle = vStrTitle[nIndex]
		btn:setText(strTitle)
		btn:EnableClickAni(false)
		btn.nId = nIndex
		btn:subscribeEvent("MouseButtonUp", WorkshopLabel.HandleClickBtn, self)		

	end
end

function WorkshopLabel:HandleClickBtn(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local clickWin = mouseArgs.window
	local nId = clickWin.nId
	
    self:RefreshBtnSel()

    if self.nBtnId == nId then
        return
    end

	self:showDlg(nId)
end

function WorkshopLabel:showDlg(nType,nBagId,nItemKey)
	self.nBtnId = nType
	for nIndex = 1, #dlgs do
		
		if nType == nIndex then
			local dlg = dlgs[nIndex].getInstanceOrNot()
			if not dlg then
				dlg = dlgs[nIndex].getInstance()
				self:subscribeEvent(dlg:GetWindow())
                if nIndex==1 then
                    dlg:RefreshUI(nBagId,nItemKey)
                end
			end
             
            if nIndex ~= 1 then
                dlg:RefreshUI(nBagId,nItemKey)
            end
			
			dlg.m_LinkLabel = self
			dlg:SetVisible(true)

			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlg:GetWindow())

		else
			local dlg = dlgs[nIndex].getInstanceOrNot()
			if dlg and dlg:IsVisible() then
				dlg:SetVisible(false)
			end
		end
	end
	self:RefreshBtnSel()
	local waManager = require "logic.workshop.workshopmanager".getInstance()
	waManager.nShowType = nType
end

function WorkshopLabel:ShowDialog(nType, nBagId, nItemKey)
    if not nBagId then
        nBagId = 0
        nItemKey = 0
    end
	LogInsane("ShowDialog(nType, bagid, itemkey)="..nType)
	
    self:showDlg(nType,nBagId,nItemKey)
    local wsManager = require "logic.workshop.workshopmanager".getInstance()
	wsManager:RefreshRedPointInRightLabel()

    --[[
	local dlg = dlgs[nType].getInstanceOrNot()
	if not dlg then
		dlg = dlgs[nType].getInstance()
		self:subscribeEvent(dlg:GetWindow())
	end
			
	
	dlg:RefreshUI()
	dlg.m_LinkLabel = self
	dlg:SetVisible(true)
	--//============================

	self.nBtnId = nType
	self:RefreshBtnSel()
	local waManager = require "logic.workshop.workshopmanager".getInstance()
	waManager.nShowType = nType
    --]]
	
end

function WorkshopLabel.Show(nType, bagid, itemkey)
	LogInfo("WorkshopLabel.Show(nType, bagid, itemkey)")
	local wsLabel = WorkshopLabel.getInstance()
	wsLabel:ShowDialog(nType,bagid,itemkey)
end

function WorkshopLabel:SetRedPointVisible(nIndex,bVisible)
	if 	nIndex<1 or 
		nIndex>5 or 
		nIndex>#self.buttons
		then
		return
	end
	local btnLabel = self.buttons[nIndex]
	btnLabel.imageRed:setVisible(bVisible)
end




function WorkshopLabel:RefreshBtnSel()
	for i = 1, #self.buttons do 
		local paneBtn = self.buttons[i]
		local btnTitle = CEGUI.Window.toPushButton(paneBtn)
		if btnTitle.nId ~= self.nBtnId then
			btnTitle:SetPushState(false)
		else
			btnTitle:SetPushState(true)
		end	
	end
end

function WorkshopLabel:RefreshItemTips(item)
	for i = 1, #dlgs do
        if i ~= WorkshopLabel.eDlgType.hecheng then --3==hecheng 
		    local dlg = dlgs[i].getInstanceOrNot()
		    if dlg then
			    dlg:RefreshItemTips(item)
		    end
        end
	end
end

return WorkshopLabel
