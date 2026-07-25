require "utils.mhsdutils"
require "logic.dialog"
require "logic.LabelDlg"
require "logic.characterinfo.characterinfodlg"
require "logic.characterinfo.characterprodlg"
require "logic.characterinfo.characterxiulian"

CharacterLabel = {}
setmetatable(CharacterLabel, Dialog)
CharacterLabel.__index = CharacterLabel

local _instance
local Dlgs =
{
	CharacterProDlg,
	CharacterInfoDlg,
	CharacterPropertyAddPtrDlg,
	CharacterXiuxingDlg,
}

function CharacterLabel.getInstance()
	if not _instance then
		_instance = CharacterLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function CharacterLabel.getInstanceNotCreate()
	return _instance
end

function CharacterLabel.GetLayoutFileName()
	return "lable.layout"
end

function CharacterLabel:OnCreate()
	local prefix = enumLabel.enumCharacterLabel
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.curDialog = nil
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button3"))
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
	self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button4"))
    self.m_pButton5:SetMouseLeaveReleaseInput(false)
	
	self.m_pButton1:setText(MHSD_UTILS.get_resstring( 2694 ))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring( 2695 ))
	self.m_pButton3:setText(MHSD_UTILS.get_resstring( 10021 ))
	self.m_pButton4:setText("修\n行");
	self.m_pButton5:setVisible(false);
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:EnableClickAni(false)
	self.m_pButton5:EnableClickAni(false)
	
	self.m_pButton1:subscribeEvent("Clicked", CharacterLabel.HandleLabel1BtnClicked, self);
	self.m_pButton2:subscribeEvent("Clicked", CharacterLabel.HandleLabel2BtnClicked, self);
	self.m_pButton3:subscribeEvent("Clicked", CharacterLabel.HandleLabel3BtnClicked, self);
	self.m_pButton4:subscribeEvent("Clicked", CharacterLabel.HandleLabel4BtnClicked, self);
end


function CharacterLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, CharacterLabel)
	return self
end

function CharacterLabel.DestroyDialog()
	LogInfo("CharacterLabel destroy dialog")
	
	if _instance then
		for _,v in pairs(Dlgs) do
			local dlg = v.getInstanceNotCreate()
			if dlg then
				print("====================")
				print(_)
				_instance:removeEvent(dlg:GetWindow())
				dlg.DestroyDialog()
			end
		end
		_instance:OnClose()
		_instance = nil
	end
end

function CharacterLabel.Show(index)
	--�����������ʾ����
	CharacterLabel.getInstance()
	index = index or  1
	_instance:ShowOnly(index)
end


function CharacterLabel:setButtonPushed(idx)
	for i=1,4 do
		self["m_pButton" .. i]:SetPushState(i==idx)
	end
end

function CharacterLabel:ShowOnly(index)

	self:setButtonPushed(index)
	
	if self.curDialog then
		self.curDialog:SetVisible(false)
	end

	self.curIdx = index

	if index == 1 then
		self.curDialog = self:getDialog(CharacterProDlg)
	    local p = require("protodef.fire.pb.skill.liveskill.crequestattr").Create()
        local attr = {}
        attr[1] = fire.pb.attr.AttrType.ENERGY
	    p.attrid = attr
	    LuaProtocolManager:send(p)		
	elseif index == 2 then
		self.curDialog = self:getDialog(CharacterInfoDlg)
		
	elseif index == 3 then
		self.curDialog = self:getDialog(CharacterPropertyAddPtrDlg)
	elseif index == 4 then
		self.curDialog = self:getDialog(CharacterXiuxingDlg)
	end		

	self:SetVisible(true)
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function CharacterLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function CharacterLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	CharacterLabel.getInstance():ShowOnly(1)
	return true
end

function CharacterLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	CharacterLabel.getInstance():ShowOnly(2)
	return true
end

function CharacterLabel:HandleLabel3BtnClicked(e)
	LogInfo("label 2 clicked")
	CharacterLabel.getInstance():ShowOnly(3)
	return true
end

function CharacterLabel:HandleLabel4BtnClicked(e)
	LogInfo("label 2 clicked")
	CharacterLabel.getInstance():ShowOnly(4)
	return true
end
function CharacterLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", CharacterLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Shown", CharacterLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", CharacterLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", CharacterLabel.HandleDlgStateChange, self)
end

function CharacterLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function CharacterLabel:HandleDlgStateChange(args)
	if not self.curIdx or not Dlgs[self.curIdx] or not Dlgs[self.curIdx].getInstanceNotCreate() then
		return
	end
	local curWnd = Dlgs[self.curIdx].getInstanceNotCreate():GetWindow()
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), curWnd)
			return true
		end
	end
	
	self:SetVisible(false)
end


return CharacterLabel
