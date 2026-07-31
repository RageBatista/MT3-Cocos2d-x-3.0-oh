require "logic.dialog"

AutoFightSkillCell = {}
setmetatable(AutoFightSkillCell, Dialog)
AutoFightSkillCell.__index = AutoFightSkillCell

local _instance
function AutoFightSkillCell.getInstance()
	if not _instance then
		_instance = AutoFightSkillCell:new()
		_instance:OnCreate()
	end
	return _instance
end

function AutoFightSkillCell.getInstanceAndShow()
	if not _instance then
		_instance = AutoFightSkillCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function AutoFightSkillCell.getInstanceNotCreate()
	return _instance
end

function AutoFightSkillCell.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function AutoFightSkillCell.ToggleOpenClose()
	if not _instance then
		_instance = AutoFightSkillCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function AutoFightSkillCell.GetLayoutFileName()
	return "guajiskill_mtg.layout"
end

function AutoFightSkillCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, AutoFightSkillCell)
	return self
end

function AutoFightSkillCell:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_imgBg = winMgr:getWindow("guajiskill/bg")
	self.m_btnFight = CEGUI.toPushButton(winMgr:getWindow("guajiskill/bg/fight"))
	self.m_imgFight = winMgr:getWindow("guajiskill/bg/checkatt")
	self.m_btnDef = CEGUI.toPushButton(winMgr:getWindow("guajiskill/bg/defense"))
	self.m_imgDef = winMgr:getWindow("guajiskill/bg/checkdef")

	self.m_SkillBGTitlePet = winMgr:getWindow("text")
	self.m_SkillBGTitlePalyer = winMgr:getWindow("text1")	

	self.m_btnFight:subscribeEvent("Clicked", AutoFightSkillCell.HandleBtnFightClick, self)
	self.m_btnDef:subscribeEvent("Clicked", AutoFightSkillCell.HandleBtnDefClick, self)

	local hookdlg = MapChoseDlg.getInstanceNotCreate()

	self.m_SkillBGPosYscale = hookdlg.m_imgBg:getYPosition().scale
	self.m_SkillBGPosYoffset = hookdlg.m_imgBg:getYPosition().offset

    self.m_listSkillText =  { }

    for i = 1 , 9 do
        self.m_listSkillText[i] = winMgr:getWindow("guajiskill/bg/text"..i)
    end


    

	self.m_tSkillInfoArr = {}
	self.m_PlayerOrPet = 0 -- 0 为 人物， 1 为 宠物

	self.m_OperateTypePlayer = 0
	self.m_OperateIDPlayer = 0
	
	self.m_OperateTypePet = 0
	self.m_OperateIDPet = 0

	for i = 1, 9 do
		local SkillInfo = {}
		SkillInfo.pBtn = tolua.cast(winMgr:getWindow("guajiskill/bg/skill" .. tostring(i)),"CEGUI::SkillBox")
		SkillInfo.pBtn:subscribeEvent("MouseClick", AutoFightSkillCell.HandleSkill, self)
				
		SkillInfo.pBtn:setID(i)
		SkillInfo.pCheck = winMgr:getWindow("guajiskill/bg/check" .. tostring(i))
		SkillInfo.ID = 0
		self.m_tSkillInfoArr[i] = SkillInfo
	end	
	
	self.m_OperateTypePlayer = GetBattleManager():GetAutoCommandOperateType(0)
	self.m_OperateIDPlayer = GetBattleManager():GetAutoCommandOperateID(0)
	self.m_OperateTypePet = GetBattleManager():GetAutoCommandOperateType(1)
	self.m_OperateIDPet = GetBattleManager():GetAutoCommandOperateID(1)	

end


function AutoFightSkillCell:RefreshAll()
	if self.m_PlayerOrPet == 0 then
		self:ShowSkillBG(0)
	elseif self.m_PlayerOrPet == 1 then
		self:ShowSkillBG(1)		
	end
	
end

function AutoFightSkillCell:HandleBtnFightClick(args)

	
	local dlg = MapChoseDlg.getInstanceNotCreate()
	
	if dlg then
			
		if  self.m_PlayerOrPet == 0 then
			--这里调用挂机界面， 将选择的技能id传给界面
			dlg:SetRoleSkill( 1, SkillIndex )
		elseif self.m_PlayerOrPet == 1 then	
			dlg:SetPetSkill( 1, SkillIndex )
		end
	end
	self:SelSkill(self.m_PlayerOrPet,1,0)
	self:DestroyDialog()
end

function AutoFightSkillCell:HandleBtnDefClick(args)

	local dlg = MapChoseDlg.getInstanceNotCreate()
	
	if dlg then
			
		if  self.m_PlayerOrPet == 0 then
			--这里调用挂机界面， 将选择的技能id传给界面
			dlg:SetRoleSkill( 4, SkillIndex )
		elseif self.m_PlayerOrPet == 1 then	
			dlg:SetPetSkill( 4, SkillIndex )
		end
	end
	self:SelSkill(self.m_PlayerOrPet,4,0)
	self:DestroyDialog()
end

function AutoFightSkillCell:HandleSkill(args)
	local e = CEGUI.toWindowEventArgs(args)
	local SkillIndex = self:GetSelSkillIndex(e.window)
	local skillID = self.m_tSkillInfoArr[SkillIndex].ID
	
	--判断是什么人物还是宠物
	local dlg = MapChoseDlg.getInstanceNotCreate()
	
	if dlg then
			
		if  self.m_PlayerOrPet == 0 then
			--这里调用挂机界面， 将选择的技能id传给界面
			dlg:SetRoleSkill( 2, skillID )
		elseif self.m_PlayerOrPet == 1 then	
			dlg:SetPetSkill( 2, skillID )
		end
	end
	
	self:SelSkill(self.m_PlayerOrPet,2, skillID)
	self:DestroyDialog()
end

function AutoFightSkillCell:SetRoleOrPetID(id)
	self.m_PlayerOrPet = id	
end



function AutoFightSkillCell:ShowSkillPlayer()
	local SkillIDArr = RoleSkillManager.getInstance():GetRoleBattleSkillIDArr()
	local hookdlg = MapChoseDlg.getInstanceNotCreate()

	self.m_SkillBGPosYscale = hookdlg.m_btnFight:getYPosition().scale
	self.m_SkillBGPosYoffset = hookdlg.m_btnFight:getYPosition().offset
	self:ShowSkill(SkillIDArr, 0)
end
function AutoFightSkillCell:ShowSkillPet()
	local SkillIDArr = RoleSkillManager.getInstance():GetPetBattleSkillIDArr()
	local hookdlg = MapChoseDlg.getInstanceNotCreate()

	self.m_SkillBGPosYscale = hookdlg.m_btnDef:getYPosition().scale
	self.m_SkillBGPosYoffset = hookdlg.m_btnDef:getYPosition().offset
	
	self:ShowSkill(SkillIDArr, 1)
end




function AutoFightSkillCell:ShowSkill(SkillIDArr, playerorpet)

	for i = 1, #(self.m_listSkillText) do
		self.m_listSkillText[i]:setVisible(false)
	end

	local SkillCount = #SkillIDArr
	for i = 0, SkillCount - 1 do
		self.m_tSkillInfoArr[i + 1].ID = SkillIDArr[i+1]
		SkillBoxControl.SetSkillInfo(self.m_tSkillInfoArr[i + 1].pBtn, self.m_tSkillInfoArr[i + 1].ID, 0)
		self.m_tSkillInfoArr[i + 1].pBtn:setVisible(true)

        --设置技能名称
        self.m_listSkillText[i+1]:setVisible(true)
        if playerorpet == 0 then 
			local skilltypecfg = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(self.m_tSkillInfoArr[i + 1].ID)
			local name = skilltypecfg.skillabbrname
            self.m_listSkillText[i+1]:setText(skilltypecfg.skillabbrname)
        elseif playerorpet == 1 then --角色宠物名称
   			local skillBase = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(self.m_tSkillInfoArr[i + 1].ID)
			local name = skillBase.skillname
            self.m_listSkillText[i+1]:setText(skillBase.skillname)
        end
        
	end

    

	if SkillCount < 1 then
		self.m_imgBg:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 100 * 3 + 7))
		self.m_imgBg:setHeight(CEGUI.UDim(0,158))
	else
		if SkillCount < 4 then
			self.m_imgBg:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 100 * 2))
			self.m_imgBg:setHeight(CEGUI.UDim(0,265))
		else
			if SkillCount < 7 then
				self.m_imgBg:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 100 * 1 - 20))
				self.m_imgBg:setHeight(CEGUI.UDim(0,385))
			else
				self.m_imgBg:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 100 * 0 - 20))
				self.m_imgBg:setHeight(CEGUI.UDim(0,505))
			end
		end
	end
end

function AutoFightSkillCell:GetSelSkillIndex(Window)
	for i = 1, 9 do
		if self.m_tSkillInfoArr[i].pBtn == Window then
			return i
		end
	end
	return 0
end

--设置自动技能
function AutoFightSkillCell:SelSkill(PlayerOrPet,OperateType,OperateID)
	if PlayerOrPet == 0 then
		self.m_OperateTypePlayer = OperateType
		self.m_OperateIDPlayer = OperateID
        gCommon.RoleOperateType = OperateType
        gCommon.RoleSelecttedSkill = OperateID
	else
		self.m_OperateTypePet = OperateType
		self.m_OperateIDPet = OperateID
	    gCommon.PetOperateType = OperateType
        gCommon.PetSelecttedSkill = OperateID
	end
	GetBattleManager():SetAutoCommandOperateType(PlayerOrPet,OperateType)
	GetBattleManager():SetAutoCommandOperateID(PlayerOrPet,OperateID)
	if PlayerOrPet == 0 then
		local p = require "protodef.fire.pb.hook.csetcharopt":new()
		p.charoptype = OperateType
		p.charopid = OperateID
		require "manager.luaprotocolmanager":send(p)
	else
        local dlg = BattleAutoFightDlg.getInstanceNotCreate()
        if dlg then
	        dlg:InitPlayerOrPetSkill(1,OperateType,OperateID)
        end
		local p = require "protodef.fire.pb.hook.csetpetopt":new()
		p.petoptype = OperateType
		p.petopid = OperateID
		require "manager.luaprotocolmanager":send(p)
	end
	
end
function AutoFightSkillCell:SkillIDToIndex(SkillID)
	for i = 1, 9 do
		if SkillID == self.m_tSkillInfoArr[i].ID then
			return i
		end
	end
	return 0;
end
--这里设置攻击和防御的对勾
function AutoFightSkillCell:SetSel(OperateType,OperateID)
	if OperateType == 2 then--技能
		local SkillIndex = self:SkillIDToIndex(OperateID)
		if SkillIndex > 0 then
			self.m_tSkillInfoArr[SkillIndex].pCheck:setVisible(true)
		end
	else
		if OperateType == 1 then--普通攻击
			self.m_imgFight:setVisible(true)
		else--防御
			self.m_imgDef:setVisible(true)
		end
	end
end



function AutoFightSkillCell:ShowSkillBG(PlayerOrPet)
	self:HideSkillBG()
	self.m_imgBg:setVisible(true)
	if PlayerOrPet == 0 then
		self.m_SkillBGTitlePalyer:setVisible(true)
		self.m_SkillBGTitlePet:setVisible(false)
		self:ShowSkillPlayer()
		self:SetSel(self.m_OperateTypePlayer,self.m_OperateIDPlayer)
	else
		self.m_SkillBGTitlePalyer:setVisible(false)
		self.m_SkillBGTitlePet:setVisible(true)
		self:ShowSkillPet()
		self:SetSel(self.m_OperateTypePet,self.m_OperateIDPet)
	end
end
function AutoFightSkillCell:HideSkillBG()
	self.m_imgBg:setVisible(false)
	self:HideAllSkill()
	self:HideAllCheck()
end
function AutoFightSkillCell:HideSkillTip()

end
function AutoFightSkillCell:HideAllSkill()
	for i = 1, 9 do
		self.m_tSkillInfoArr[i].pBtn:setVisible(false)
	end
end
function AutoFightSkillCell:HideAllCheck()
	for i = 1, 9 do
		self.m_tSkillInfoArr[i].pCheck:setVisible(false)
	end
	self.m_imgFight:setVisible(false)
	self.m_imgDef:setVisible(false)
end
return AutoFightSkillCell
