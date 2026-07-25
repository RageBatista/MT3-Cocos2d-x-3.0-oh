require "utils.mhsdutils"
require "logic.dialog"
require "logic.skill.gonghuiskilldlg"
require "logic.skill.characterskillupdatedlg"
require "logic.skill.xiulianskilldlg"

SkillLable = {}

setmetatable(SkillLable, Dialog)
SkillLable.__index = SkillLable

local _instance

function SkillLable.getInstance()
	if not _instance then
		_instance = SkillLable:new()
		_instance:OnCreate()
	end
	return _instance
end

function SkillLable.getInstanceNotCreate()
	return _instance
end

function SkillLable.GetLayoutFileName()
	return "Lable.layout"
end

function SkillLable:OnCreate()
	Dialog.OnCreate(self,nil, "skill")
	self:GetWindow():setRiseOnClickEnabled(false)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow("skillLable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow( "skillLable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow( "skillLable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow( "skillLable/button3"))
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
	self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow( "skillLable/button4"))
    self.m_pButton5:SetMouseLeaveReleaseInput(false)

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(3014))


	if gGetDataManager():GetMainCharacterLevel() >= 35 then
		self.m_pButton2:setText(MHSD_UTILS.get_resstring(3039))
	else
		self.m_pButton2:setVisible(false)
	end

	-- ÐÞÁ¶¼¼ÄÜ
	if gGetDataManager():GetMainCharacterLevel() >= 45 then
		self.m_pButton3:setText(MHSD_UTILS.get_resstring(3015))
	else
		self.m_pButton3:setVisible(false)
	end

    self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)

	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:EnableClickAni(false)

	self.m_pButton1:subscribeEvent("Clicked", SkillLable.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", SkillLable.HandleLabel2BtnClicked, self)
	self.m_pButton3:subscribeEvent("Clicked", SkillLable.HandleLabel3BtnClicked, self)
	self.m_pButton4:subscribeEvent("Clicked", SkillLable.HandleLabel4BtnClicked, self)

end


function SkillLable:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, SkillLable)
	return self
end



function SkillLable.DestroyDialog()	
	if _instance then

		if CharacterSkillUpdateDlg.getInstanceOrNot() then
			_instance:RemoveEvent(CharacterSkillUpdateDlg.getInstanceOrNot():GetWindow())
			CharacterSkillUpdateDlg.getInstanceOrNot():CloseDialog()
		end
		
		if XiulianSkillDlg.getInstanceOrNot() then
			_instance:RemoveEvent(XiulianSkillDlg.getInstanceOrNot():GetWindow())
			XiulianSkillDlg.getInstanceOrNot():CloseDialog()
		end
		
		
		
		if GonghuiSkillDlg.getInstanceOrNot() then
			_instance:RemoveEvent(GonghuiSkillDlg.getInstanceOrNot():GetWindow())
			GonghuiSkillDlg:getInstanceOrNot():CloseDialog()
		end

		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end	
end

function SkillLable.Show(index)
	index = index or 1
	SkillLable.getInstance()
	_instance:ShowOnly(index)	
end


function SkillLable:setButtonPushed(idx)
	local function getBtn(idx)
		return  (idx==1 and self.m_pButton1 or
		(idx==2 and self.m_pButton2 or
		(idx==3 and self.m_pButton3 or
		(idx==4 and self.m_pButton4 or
		(idx==5 and self.m_pButton5)))))
	end
	local btn = getBtn(self.m_index)
	if btn then
		btn:SetPushState(false)
	end
	
	btn = getBtn(idx)
	if btn then
		btn:SetPushState(true)
	end
end


function SkillLable:ShowOnly(index)
	self:setButtonPushed(index)
	self.m_index = index
    gCommon.skillIndex = index

	
	if CharacterSkillUpdateDlg.getInstanceOrNot() then
		CharacterSkillUpdateDlg.getInstanceOrNot():GetWindow():setVisible(false)
	end	
	
	
	if GonghuiSkillDlg.getInstanceOrNot() then
		GonghuiSkillDlg.getInstanceOrNot():GetWindow():setVisible(false)
	end
	
	local dlg = nil
	if index == 1 then
		if CharacterSkillUpdateDlg.getInstanceOrNot() then
			dlg = CharacterSkillUpdateDlg.getInstanceAndShow()
		else
			dlg = CharacterSkillUpdateDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 2 then
		if GonghuiSkillDlg.getInstanceOrNot() then
			dlg = GonghuiSkillDlg.getInstanceAndShow()
		else
			dlg = GonghuiSkillDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	    local p = require("protodef.fire.pb.skill.liveskill.crequestattr").Create()
        local attr = {}
        attr[1] = fire.pb.attr.AttrType.ENERGY
	    p.attrid = attr
	    LuaProtocolManager:send(p)	
	elseif index == 3 then
		
		if XiulianSkillDlg.getInstanceOrNot() then
			dlg = XiulianSkillDlg.getInstanceAndShow()
		else
			dlg = XiulianSkillDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	end

	if dlg then
		self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlg:GetWindow())
	end
end

function SkillLable:HandleLabel1BtnClicked(e)
	SkillLable.getInstance():ShowOnly(1)	
	return true
end

function SkillLable:HandleLabel2BtnClicked(e)
	SkillLable.getInstance():ShowOnly(2)	
	return true
end

function SkillLable:HandleLabel3BtnClicked(e)
	SkillLable.getInstance():ShowOnly(3)	
	return true
end

function SkillLable:HandleLabel4BtnClicked(e)
	SkillLable.getInstance():ShowOnly(4)
	return true
end

function SkillLable:SubscribeEvent(pWnd)
	pWnd:subscribeEvent("AlphaChanged", SkillLable.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Shown", SkillLable.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Hidden", SkillLable.HandleDlgStateChange, self)
	pWnd:subscribeEvent("InheritAlphaChanged", SkillLable.HandleDlgStateChange, self)
end

function SkillLable:RemoveEvent(pWnd)
	pWnd:removeEvent("AlphaChanged")
	pWnd:removeEvent("Shown")
	pWnd:removeEvent("Hidden")
	pWnd:removeEvent("InheritAlphaChanged")
end

function SkillLable:HandleDlgStateChange(args)
	if CharacterSkillUpdateDlg:getInstanceOrNot() then
		local pWnd = CharacterSkillUpdateDlg.getInstanceOrNot():GetWindow()
		if pWnd and pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 and self:GetWindow() then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	if GonghuiSkillDlg.getInstanceOrNot() then
		local pWnd = GonghuiSkillDlg.getInstanceOrNot():GetWindow()
		if pWnd and pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 and self:GetWindow() then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	if XiulianSkillDlg.getInstanceOrNot() then
		local pWnd = XiulianSkillDlg.getInstanceOrNot():GetWindow()
		if pWnd and pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 and self:GetWindow() then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	

	self:GetWindow():setVisible(false)
	return true
end

return SkillLable
