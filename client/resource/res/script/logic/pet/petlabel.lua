require "utils.mhsdutils"
require "logic.dialog"
require "logic.pet.petpropertydlgnew"
require "logic.pet.petlianyaodlg"
require "logic.pet.petfeeddlg"
require "logic.pet.petaddskillbook"
require "logic.pet.petgallerydlg"
require "logic.LabelDlg"

PetLabel = {}
setmetatable(PetLabel, Dialog)
PetLabel.__index = PetLabel

local _instance
local Dlgs =
{
	PetPropertyDlgNew,
	PetLianYaoDlg,
	PetFeedDlg,
	-- PetGalleryDlg
}

function PetLabel.getInstance()
	if not _instance then
		_instance = PetLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetLabel.getInstanceNotCreate()
	return _instance
end

function PetLabel.GetLayoutFileName()
	return "lablekong.layout"
end

function PetLabel:OnCreate()
	local prefix = enumLabel.enumPetLabel
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.dialogs = {}
	self.curDialog = nil
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	-- self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button3"))
    -- self.m_pButton4:SetMouseLeaveReleaseInput(false)
	self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button4"))
    self.m_pButton5:SetMouseLeaveReleaseInput(false)
	
	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11100))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11101))
	self.m_pButton3:setText(MHSD_UTILS.get_resstring(11102))
	-- self.m_pButton4:setText(MHSD_UTILS.get_resstring(11103))
	self.m_pButton5:setVisible(false);
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	-- self.m_pButton4:EnableClickAni(false)
	self.m_pButton5:EnableClickAni(false)
	
	self.m_pButton1:subscribeEvent("Clicked", PetLabel.HandleLabel1BtnClicked, self);
	self.m_pButton2:subscribeEvent("Clicked", PetLabel.HandleLabel2BtnClicked, self);
	self.m_pButton3:subscribeEvent("Clicked", PetLabel.HandleLabel3BtnClicked, self);
	-- self.m_pButton4:subscribeEvent("Clicked", PetLabel.HandleLabel4BtnClicked, self);
	
	self.selectedPetKey = 0
end


function PetLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, PetLabel)
	return self
end

function PetLabel.DestroyDialog()
	LogInfo("petlabel destroy dialog")
	if _instance then
		--close all
		for _,v in pairs(Dlgs) do
			local dlg = v.getInstanceNotCreate()
			if dlg then
				_instance:removeEvent(dlg:GetWindow())
				dlg.DestroyDialog()
			end
		end
		
		PetAddSkillBook.CloseIfExist()
		
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetLabel.hide()
	if _instance then
        PetAddSkillBook.CloseIfExist()

		for _,v in pairs(_instance.dialogs) do
			v:SetVisible(false)
		end
		
		_instance:GetWindow():setVisible(false)
	end
end

function PetLabel.Show(index)
    
	if GetBattleManager():IsInBattle() and MainPetDataManager.getInstance():GetPetNum() == 0 then
		print('no pet')
	    GetCTipsManager():AddMessageTipById(150078) --你还没有宠物
		return
	end

    if MainPetDataManager.getInstance():GetPetNum() == 0 then
        index = 4
    end
	
	index = index or 1
	
	if not _instance then
		PetLabel.getInstance():ShowOnly(index)
	else
		_instance:GetWindow():setVisible(true)
		_instance:ShowOnly(index)
	end
	
	if _instance.curDialog and _instance.curDialog.refreshAll then
		local petData = _instance:getSelectedPetData() or MainPetDataManager.getInstance():getPet(1)
		_instance.curDialog:refreshAll(petData)
	end
end

function PetLabel.ShowStarDlg()
	PetLabel.Show(2)
end

function PetLabel.ShowXiLianView()
    PetLabel.Show(2)
	PetLianYaoDlg.getInstance():showXiLianView()
end

function PetLabel.ShowLearnSkillView()
	PetLabel.Show(2)
	PetLianYaoDlg.getInstance():showLearnSkillView()
end

function PetLabel.ShowFeedView(itembaseid)
    PetLabel.Show(3)
    PetFeedDlg.getInstance():selectFeedItem(itembaseid)
end

function PetLabel:setButtonPushed(idx)
	for i=1,3 do
		self["m_pButton" .. i]:SetPushState(i==idx)
	end
end

function PetLabel:ShowOnly(index)
     if MainPetDataManager.getInstance():GetPetNum() == 0 then
        if index==1 then
             GetCTipsManager():AddMessageTipById(162058)
             
        elseif index==2 then
             GetCTipsManager():AddMessageTipById(162059)
             
        elseif index==3 then
             GetCTipsManager():AddMessageTipById(162060)
             
        end
        -- index = 4
   end

	self:setButtonPushed(index)
	
	if self.curDialog and self.curDialog:IsVisible() and self.curIdx == index then
		return
	end
	self.curIdx = index
	
	if self.curDialog then
		self.curDialog:SetVisible(false)
        if self.curDialog.petlistWnd then
            self.standpos = self.curDialog.petlistWnd:getVerticalScrollPosition()
        end
	end
	
	if index ~= 2 then
		PetAddSkillBook.CloseIfExist()
	end
	
	
	local petData = self:getSelectedPetData() or MainPetDataManager.getInstance():getPet(1)
	if index == 1 then
		local isNew = false
		self.curDialog, isNew = self:getDialog(PetPropertyDlgNew)		
		if petData and not isNew then
			self.curDialog:refreshAll(petData)
		end
        if self.standpos and self.curDialog.petlistWnd then
            self.curDialog.petlistWnd:setVerticalScrollPosition(self.standpos)
		end
	elseif index == 2 then
		self.curDialog = self:getDialog(PetLianYaoDlg)
		self.curDialog:refreshAll(petData)
        if self.standpos and self.curDialog.petlistWnd then
            self.curDialog.petlistWnd:setVerticalScrollPosition(self.standpos)
		end
		
	elseif index == 3 then
		self.curDialog = self:getDialog(PetFeedDlg)
		self.curDialog:refreshAll(petData)
        if self.standpos and self.curDialog.petlistWnd then
            self.curDialog.petlistWnd:setVerticalScrollPosition(self.standpos)
		end
		
	-- elseif index == 4 then
		-- self.curDialog = self:getDialog(PetGalleryDlg)
	end

	self:SetVisible(true)
	self.dialogs[index] = self.curDialog
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function PetLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
		return dlg, true
	end

	dlg:SetVisible(true)
	return dlg, false
end

function PetLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	PetLabel.getInstance():ShowOnly(1)
	return true
end
function PetLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	PetLabel.getInstance():ShowOnly(2)
	return true
end
function PetLabel:HandleLabel3BtnClicked(e)
	LogInfo("label 3 clicked")
	PetLabel.getInstance():ShowOnly(3)
	return true
end
-- function PetLabel:HandleLabel4BtnClicked(e)
	-- LogInfo("label 4 clicked")
	-- PetLabel.getInstance():ShowOnly(4)
	-- return true
-- end

function PetLabel:setSelectedPetKey(key)
	self.selectedPetKey = key
end

function PetLabel:getSelectedPetData()
	if self.selectedPetKey then
		return MainPetDataManager.getInstance():FindMyPetByID(self.selectedPetKey)
	end
end

function PetLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", PetLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Shown", PetLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", PetLabel.HandleDlgStateChange, self)
	-- wnd:subscribeEvent("InheritAlphaChanged", PetLabel.HandleDlgStateChange, self)
end

function PetLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	-- wnd:removeEvent("InheritAlphaChanged")
end

function PetLabel:HandleDlgStateChange(args)
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			return true
		end
	end
	self:SetVisible(false)
end

return PetLabel
