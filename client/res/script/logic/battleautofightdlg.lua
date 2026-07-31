require "logic.dialog"
require "utils.mhsdutils"
require "logic.guajicfg"
require "logic.battle.battleskilltip"

BattleAutoFightDlg = {}
setmetatable(BattleAutoFightDlg, Dialog)
BattleAutoFightDlg.__index = BattleAutoFightDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BattleAutoFightDlg.getInstance()
    if not _instance then
        _instance = BattleAutoFightDlg:new()
        _instance:OnCreate()
    end
    return _instance
end
function BattleAutoFightDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = BattleAutoFightDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
		_instance:InitAllSkill()
    end
    
    return _instance
end

function BattleAutoFightDlg.getInstanceNotCreate()
    return _instance
end

function BattleAutoFightDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			BattleSkillTip.DestroyDialog()
			_instance:OnClose()		
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function BattleAutoFightDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BattleAutoFightDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
			_instance:HideSkillBG()
		else
			_instance:SetVisible(true)
			_instance:InitAllSkill()
		end
	end
end
function BattleAutoFightDlg.GetLayoutFileName()
    return "BattleAuto.layout"
end

function BattleAutoFightDlg.CSetVisible(b)
	if _instance then
		if b == true then
			_instance:InitAllSkill()
		else
			_instance:HideSkillBG()
		end
		_instance:SetVisible(b)
	end
end
function BattleAutoFightDlg.CSetAutoFight(b)
	if _instance then
		_instance:SetAutoFight(b)
	end
end


function BattleAutoFightDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pBtnCancel = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/Cancel"))
	self.m_SkillRoot = winMgr:getWindow("BattleAuto/guajiskill")	
	self.m_SkillBG = winMgr:getWindow("BattleAuto/guajiskill/bg")

	self.m_SkillBGPosYscale = self.m_SkillBG:getYPosition().scale
	self.m_SkillBGPosYoffset = self.m_SkillBG:getYPosition().offset
	
	self.m_SkillBGTitlePalyer = winMgr:getWindow("BattleAuto/text1")	
	self.m_SkillBGTitlePet = winMgr:getWindow("BattleAuto/text")
	
	self.m_OperateTypePlayer = 0
	self.m_OperateIDPlayer = 0
	
	self.m_OperateTypePet = 0
	self.m_OperateIDPet = 0
	
	self.m_PlayerOrPet = 0
	
	self.m_PetIsDie = true
	
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false
	
	
	self.m_tSkillInfoArr = {}
		
	for i = 1, 9 do
		local SkillInfo = {}
		SkillInfo.pBtn = tolua.cast(winMgr:getWindow("BattleAuto/guajiskill/bg/skill" .. tostring(i)),"CEGUI::SkillBox")--CEGUI.toSkillBox ok too
		SkillInfo.pBtn:subscribeEvent("MouseClick", BattleAutoFightDlg.HandleSkill, self)
		SkillInfo.pBtn:subscribeEvent("SKillBoxClick", BattleAutoFightDlg.HandleSkillDown, self)
		
		SkillInfo.pBtn:subscribeEvent("MouseButtonUp", BattleAutoFightDlg.HandleSkillUp, self)
				
		SkillInfo.pBtn:setID(i)
		SkillInfo.pCheck = winMgr:getWindow("BattleAuto/guajiskill/bg/check" .. tostring(i))
		SkillInfo.ID = 0
		self.m_tSkillInfoArr[i] = SkillInfo
	end	
	
	self.m_listSkillText =  { }

    for i = 1 , 9 do
        self.m_listSkillText[i] = winMgr:getWindow("BattleAuto/guajiskill/bg/text"..i)
    end
	
	
	--self.m_pBtnCheck1 = winMgr:getWindow("BattleAuto/guajiskill/bg/check1")
		
	self.m_pBtnAtt = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/guajiskill/bg/fight"))
	self.m_pBtnDef = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/guajiskill/bg/defense"))
	self.m_pCheckAtt = winMgr:getWindow("BattleAuto/guajiskill/bg/checkatt")
	self.m_pCheckDef = winMgr:getWindow("BattleAuto/guajiskill/bg/checkdef")
	
	self.m_pBtnPlayer = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/xitongzhandou/2/renwu"))
	self.m_pBtnPet = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/xitongzhandou/2/chongwu"))
	self.m_pBtnPlayerSkill = tolua.cast(winMgr:getWindow("BattleAuto/xitongzhandou/2/renwuskill"),"CEGUI::SkillBox")
	self.m_pBtnPetSkill = tolua.cast(winMgr:getWindow("BattleAuto/xitongzhandou/2/chongwuskill"),"CEGUI::SkillBox")
	--self.m_pBtnGuaJi = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/xitongzhandou/shezhi"))	
    
	self.m_DaoJiShi = winMgr:getWindow("BattleAuto/xitongzhandou/daojishi")

	
    self.m_pBtnCancel:subscribeEvent("Clicked", BattleAutoFightDlg.HandleAutoFigntClicked, self)
	
	self.m_pBtnAtt:subscribeEvent("Clicked", BattleAutoFightDlg.HandleAtt, self)
	self.m_pBtnDef:subscribeEvent("Clicked", BattleAutoFightDlg.HandleDef, self)

	self.m_pBtnPlayer:subscribeEvent("Clicked", BattleAutoFightDlg.HandlePlayer, self)
	self.m_pBtnPet:subscribeEvent("Clicked", BattleAutoFightDlg.HandlePet, self)
	self.m_pBtnPlayerSkill:subscribeEvent("MouseClick", BattleAutoFightDlg.HandlePlayerSkill, self)
	self.m_pBtnPetSkill:subscribeEvent("MouseClick", BattleAutoFightDlg.HandlePetSkill, self)
	self.m_pBtnPlayerSkill:subscribeEvent("SKillBoxClick", BattleAutoFightDlg.HandlePlayerSkillDown, self)
	self.m_pBtnPetSkill:subscribeEvent("SKillBoxClick", BattleAutoFightDlg.HandlePetSkillDown, self)
	--self.m_pBtnGuaJi:subscribeEvent("Clicked", BattleAutoFightDlg.HandleGuaJi, self)    

	self:HideSkillBG()
	
	self:HideSkillTip()
	
	self:SetDaoJiShi(0)
	
	self:SetAutoFight(GetBattleManager():IsAutoOperate())
	
    local plane=winMgr:getWindow("BattleAuto")
    plane:moveToBack()
	
	if CEGUI.System:getSingleton():getModalTarget() then
		self:GetWindow():setAlpha(0)
	end
end

function BattleAutoFightDlg:run(delta)
	--do return end
	if _instance:IsVisible() ~= false then
		local PetData = MainPetDataManager.getInstance():GetBattlePet()
		local PetIsDie = false
		if PetData == nil or PetData.battlestate ~= 0 then
			PetIsDie = true
		else
			local Pethp = PetData:getAttribute(80)
			if Pethp <= 0 then
				PetIsDie = true
			end
		end
		if PetIsDie == true then
			self.m_pBtnPet:setVisible(false)
			self.m_pBtnPetSkill:setVisible(false)
		else
			if self.m_PetIsDie == true then
				self.m_OperateTypePet = GetBattleManager():GetAutoCommandOperateType(1)
				self.m_OperateIDPet = GetBattleManager():GetAutoCommandOperateID(1)
				self:InitPlayerOrPetSkill(1,self.m_OperateTypePet,self.m_OperateIDPet)
			end
		end
		self.m_PetIsDie = PetIsDie
		
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		if pTargetWnd ~= nil then
			if self.m_TipShow == false then
				if self.m_DownSkill ~= nil then
					if self.m_DownSkill == pTargetWnd or pTargetWnd:isAncestor(self.m_DownSkill) then
						self.m_TipTime = self.m_TipTime + delta
						if self.m_TipTime >= 500 then
							--local SkillIndex = self:GetSelSkillIndex(self.m_DownSkill)
							--if SkillIndex > 0 then
								BattleSkillTip.getInstance():SetSkill(self.m_DownSkill:GetSkillID())
								self.m_TipShow = true
							--end
						end
					else
						if pTargetWnd == nil then
							self.m_DownSkill = nil
						end
					end
				end
			end
		else
			self.m_DownSkill = nil
		end
	end
end

------------------- private: -----------------------------------
function BattleAutoFightDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BattleAutoFightDlg)
	self.m_bEscClose = false

-- by bayaer, 2015-05-07

	self.pNormalBegin = "set:fightui image:automatic"
	self.pPushedBegin = "set:fightui image:automatic"
	self.pNormalStop = "set:fightui image:quxiao"
	self.pPushedStop = "set:fightui image:quxiao"
	
	
    return self
end
function BattleAutoFightDlg:HandleAutoFigntClicked(args)
	if GetBattleManager():IsAutoOperate() then
        GetBattleManager():EndAutoOperate()

		local DaoJiShi = self.m_DaoJiShi:getText() 
		if DaoJiShi == "0" then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(150221)
			end
		end
		
	else
		GetBattleManager():BeginAutoOperate()
    end
	self:SetAutoFight(GetBattleManager():IsAutoOperate())
    return true
end 

function BattleAutoFightDlg:SetAutoFight(bAutofight)
	if bAutofight then
		if GetBattleManager():IsInBattle() then		--new add
			self:SetVisible(true)
		end
		self.m_pBtnCancel:setProperty("NormalImage",self.pNormalStop)
		self.m_pBtnCancel:setProperty("PushedImage",self.pPushedStop)
		if CharacterOperateDlg.getInstanceNotCreate() then
			CharacterOperateDlg.getInstanceNotCreate():getCancelBtn():setProperty("NormalImage",self.pNormalStop)
			CharacterOperateDlg.getInstanceNotCreate():getCancelBtn():setProperty("PushedImage",self.pPushedStop)
		end
		self:InitAllSkill()
	else
		if GetBattleManager():IsInBattle() then		--new add
			self:SetVisible(false)
		end
		self:HideSkillBG()
		self.m_pBtnCancel:setProperty("NormalImage","")
		self.m_pBtnCancel:setProperty("PushedImage","")
		if CharacterOperateDlg.getInstanceNotCreate() then
			CharacterOperateDlg.getInstanceNotCreate():getCancelBtn():setProperty("NormalImage",self.pNormalBegin)
			CharacterOperateDlg.getInstanceNotCreate():getCancelBtn():setProperty("PushedImage",self.pPushedBegin)
		end
	end
end

function BattleAutoFightDlg:InitAllSkill()
	self:HideSkillBG()
	self.m_OperateTypePlayer = GetBattleManager():GetAutoCommandOperateType(0)
	self.m_OperateIDPlayer = GetBattleManager():GetAutoCommandOperateID(0)
    
	if self.m_OperateTypePlayer == 2 then--技能
        if GetBattleManager():IsInPVPBattle() == true then
            local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(self.m_OperateIDPlayer)
            if skillconfig and skillconfig.isonlypve == 1 then
                self.m_OperateTypePlayer = 1
	            GetBattleManager():SetAutoCommandOperateType(0,self.m_OperateTypePlayer)
	            GetBattleManager():SetAutoCommandOperateID(0,self.m_OperateIDPlayer)	
            end
        end
    end

	self:InitPlayerOrPetSkill(0,self.m_OperateTypePlayer,self.m_OperateIDPlayer)
	
	local PetData = MainPetDataManager.getInstance():GetBattlePet()
	if PetData ~= nil and PetData.battlestate == 0 then
		local Pethp = PetData:getAttribute(80)
		if Pethp > 0 then
			self.m_PetIsDie = false
			self.m_OperateTypePet = GetBattleManager():GetAutoCommandOperateType(1)
			self.m_OperateIDPet = GetBattleManager():GetAutoCommandOperateID(1)
			self:InitPlayerOrPetSkill(1,self.m_OperateTypePet,self.m_OperateIDPet)
		end
	end
end
function BattleAutoFightDlg:InitPlayerOrPetSkill(PlayerOrPet,OperateType,OperateID)
	if PlayerOrPet == 0 then
		self:InitSkill(OperateType,OperateID,self.m_pBtnPlayer,self.m_pBtnPlayerSkill)
	else
		self:InitSkill(OperateType,OperateID,self.m_pBtnPet,self.m_pBtnPetSkill)
	end
end
function BattleAutoFightDlg:InitSkill(OperateType,OperateID,Btn,BtnSkill)
	if OperateType == 2 then--技能
        if GetBattleManager():IsInPVPBattle() == true then
            local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(OperateID)
            if skillconfig and skillconfig.isonlypve == 1 then
                OperateType = 1
            end
        end
    end
	if OperateType == 2 then--技能
		Btn:setVisible(false)		
		BtnSkill:setVisible(true)
		SkillBoxControl.SetSkillInfo(BtnSkill,OperateID,0)
	else
		BtnSkill:setVisible(false)
		Btn:setVisible(true)
		local SrcBtn = nil
		if OperateType == 1 then--普通攻击
			SrcBtn = self.m_pBtnAtt
		else--if OperateType == 4 then--防御
			SrcBtn = self.m_pBtnDef
		end
		local NormalImage = SrcBtn:getProperty("NormalImage")
		local PushedImage = SrcBtn:getProperty("PushedImage")
		local HoverImage = SrcBtn:getProperty("HoverImage")
		Btn:setProperty("NormalImage",NormalImage)
		Btn:setProperty("PushedImage",PushedImage)
		Btn:setProperty("HoverImage",HoverImage)
	end
end

function BattleAutoFightDlg:ShowSkillBG(PlayerOrPet)--0Player,1Pet
	if PlayerOrPet == 0 then
        if self.m_SkillBG:isVisible() then
            self:HideSkillBG()
        else
	        self.m_SkillBG:setVisible(true)
	        self.m_PlayerOrPet = PlayerOrPet
		    self.m_SkillBGTitlePalyer:setVisible(true)
		    self.m_SkillBGTitlePet:setVisible(false)
		    self:ShowSkillPlayer()
		    self:SetSel(self.m_OperateTypePlayer,self.m_OperateIDPlayer)
        end

	else
        if self.m_SkillBG:isVisible() then
            self:HideSkillBG()
        else
	        self.m_SkillBG:setVisible(true)
	        self.m_PlayerOrPet = PlayerOrPet
		    self.m_SkillBGTitlePalyer:setVisible(false)
		    self.m_SkillBGTitlePet:setVisible(true)
		    self:ShowSkillPet()
		    self:SetSel(self.m_OperateTypePet,self.m_OperateIDPet)
        end
	end
end
function BattleAutoFightDlg:ShowSkillPlayer()
	local SkillIDArr = RoleSkillManager.getInstance():GetRoleBattleSkillIDArr()
	self:ShowSkill(SkillIDArr, 0)
end
function BattleAutoFightDlg:ShowSkillPet()
	local SkillIDArr = require("logic.battle.battlemanager").getInstance():GetPetBattleSkillIDArr()
	self:ShowSkill(SkillIDArr, 1)
end
function BattleAutoFightDlg:ShowSkill(SkillIDArr, playerorpet)
	
	
	for i = 1, #(self.m_listSkillText) do
		self.m_listSkillText[i]:setVisible(false)
	end
	if GetBattleManager():IsInPVPBattle() == true then
        local sCount = #SkillIDArr
	    for i = 0, sCount - 1 do
            local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(self.m_tSkillInfoArr[i + 1].ID)
            if skillconfig and skillconfig.isonlypve == 1 then
                OperateType = 1
            end
	    end
    end
	local SkillCount = #SkillIDArr
    local k = 1
	for i = 0, SkillCount - 1 do
        local bshow = true
        if GetBattleManager():IsInPVPBattle() == true then
             local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cskillconfig"):getRecorder(SkillIDArr[i+1])
             if skillconfig and skillconfig.isonlypve == 1 then
                bshow = false
            end
        end
        if bshow then
		    self.m_tSkillInfoArr[k].ID = SkillIDArr[i+1]
		    SkillBoxControl.SetSkillInfo(self.m_tSkillInfoArr[k].pBtn, self.m_tSkillInfoArr[k].ID, 0)
		    self.m_tSkillInfoArr[k].pBtn:setVisible(true)
		
		--设置技能名称
            self.m_listSkillText[k]:setVisible(true)
        if playerorpet == 0 then 
			--CSchoolSkillitem
			    local skilltypecfg = BeanConfigManager.getInstance():GetTableByName("skill.cschoolskillitem"):getRecorder(self.m_tSkillInfoArr[k].ID)
			local name = skilltypecfg.skillabbrname
                self.m_listSkillText[k]:setText(skilltypecfg.skillabbrname)
        elseif playerorpet == 1 then --角色宠物名称
   			    local skillBase = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(self.m_tSkillInfoArr[k].ID)
			local name = skillBase.skillname
                self.m_listSkillText[k]:setText(skillBase.skillname)
        end
		    k = k + 1
         end
	end
	if SkillCount < 1 then
		self.m_SkillBG:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 90 * 3))
		self.m_SkillBG:setHeight(CEGUI.UDim(0,168))
	else
		if SkillCount < 4 then
			self.m_SkillBG:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 90 * 2))
			self.m_SkillBG:setHeight(CEGUI.UDim(0,265))
		else
			if SkillCount < 7 then
				self.m_SkillBG:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 90 * 1))
				self.m_SkillBG:setHeight(CEGUI.UDim(0,385))
			else
				self.m_SkillBG:setYPosition(CEGUI.UDim(self.m_SkillBGPosYscale,self.m_SkillBGPosYoffset + 90 * 0))
				self.m_SkillBG:setHeight(CEGUI.UDim(0,505))
			end
		end
	end
end
function BattleAutoFightDlg:HideSkillBG()
	--self.m_pBtnPlayer:setVisible(false)
	--self.m_pBtnPlayerSkill:setVisible(false)	
	--self.m_pBtnPet:setVisible(false)
	--self.m_pBtnPetSkill:setVisible(false)
	self:HideSkillTip()
	self.m_SkillBG:setVisible(false)
	self:HideAllSkill()
	self:HideAllCheck()
end
function BattleAutoFightDlg:HideSkillTip()
	self.m_DownSkill = nil
	self.m_TipTime = 0
	self.m_TipShow = false
	BattleSkillTip.DestroyDialog()
end
function BattleAutoFightDlg:HideAllSkill()
	for i = 1, 9 do
		self.m_tSkillInfoArr[i].pBtn:setVisible(false)
		--self.m_tSkillInfoArr[i].pCheck:setVisible(false)
	end
end
function BattleAutoFightDlg:HideAllCheck()
	for i = 1, 9 do
		self.m_tSkillInfoArr[i].pCheck:setVisible(false)
	end
	self.m_pCheckAtt:setVisible(false)
	self.m_pCheckDef:setVisible(false)
end
function BattleAutoFightDlg:GetSelSkillIndex(Window)
	for i = 1, 9 do
		if self.m_tSkillInfoArr[i].pBtn == Window then
			return i
		end
	end
	return 0
end
function BattleAutoFightDlg:HandleSkill(args)
	local e = CEGUI.toWindowEventArgs(args)
	local SkillIndex = self:GetSelSkillIndex(e.window)
	if self.m_TipShow == true then
		--self:HideSkillTip()
	else
		if SkillIndex > 0 then
			self:SelSkill(self.m_PlayerOrPet,2,self.m_tSkillInfoArr[SkillIndex].ID)
			self:InitPlayerOrPetSkill(self.m_PlayerOrPet,2,self.m_tSkillInfoArr[SkillIndex].ID)
		end
		self:HideSkillBG()
	end
end
function BattleAutoFightDlg:HandleSkillDown(args)
	self:HideSkillTip()
	local e = CEGUI.toWindowEventArgs(args)
	local SkillIndex = self:GetSelSkillIndex(e.window)	
	if SkillIndex > 0 then
		self.m_DownSkill = e.window
	end
end
function BattleAutoFightDlg:HandleSkillUp(args)
	local e = CEGUI.toWindowEventArgs(args)
	local SkillIndex = self:GetSelSkillIndex(e.window)
		
end
function BattleAutoFightDlg:SelSkill(PlayerOrPet,OperateType,OperateID)
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
	
	BattleAutoFightDlg.CSendAutoOperateData(PlayerOrPet,OperateType,OperateID)
	
end
function BattleAutoFightDlg:SkillIDToIndex(SkillID)
	for i = 1, 9 do
		if SkillID == self.m_tSkillInfoArr[i].ID then
			return i
		end
	end
	return 0;
end
function BattleAutoFightDlg:SetSel(OperateType,OperateID)
	if OperateType == 2 then--技能
		local SkillIndex = self:SkillIDToIndex(OperateID)
		if SkillIndex > 0 then
			self.m_tSkillInfoArr[SkillIndex].pCheck:setVisible(true)
		end
	else
		if OperateType == 1 then--普通攻击
			self.m_pCheckAtt:setVisible(true)
		else--if OperateType == 4 then--防御
			self.m_pCheckDef:setVisible(true)
		end
	end	
end
function BattleAutoFightDlg:HandleAtt(args)
	self:SelSkill(self.m_PlayerOrPet,1,0)
	self:InitPlayerOrPetSkill(self.m_PlayerOrPet,1,0)
	self:HideSkillBG()
end
function BattleAutoFightDlg:HandleDef(args)
	self:SelSkill(self.m_PlayerOrPet,4,0)
	self:InitPlayerOrPetSkill(self.m_PlayerOrPet,4,0)
	self:HideSkillBG()
end
function BattleAutoFightDlg:HandlePlayer(args)
  --  self:ShowSkillBG(0) -----这是打开自动技能的面板
  GuaJiAIDlg.getInstanceAndShow()---这是打开自动辅助的面板
end
function BattleAutoFightDlg:HandlePet(args)
	self:ShowSkillBG(1)
end
function BattleAutoFightDlg:HandlePlayerSkill(args)
	if self.m_TipShow == true then
	else
		--self:ShowSkillBG(0) -----这是打开自动技能的面板
        GuaJiAIDlg.getInstanceAndShow()---这是打开自动辅助的面板
        self.m_DownSkill = nil
	end
end
function BattleAutoFightDlg:HandlePetSkill(args)
	if self.m_TipShow == true then
	else
		self:ShowSkillBG(1)
        self.m_DownSkill = nil
	end
end
function BattleAutoFightDlg:HandlePlayerSkillDown(args)
	self:HideSkillTip()
	local e = CEGUI.toWindowEventArgs(args)	
	self.m_DownSkill = e.window
end
function BattleAutoFightDlg:HandlePetSkillDown(args)
	self:HideSkillTip()
	local e = CEGUI.toWindowEventArgs(args)	
	self.m_DownSkill = e.window
end
function BattleAutoFightDlg:HandleGuaJi(args)
    local dlg = GuaJiAIDlg.getInstanceAndShow()
end
function BattleAutoFightDlg.CSetDaoJiShi(t)
	if _instance then 
		_instance:SetDaoJiShi(t)
	end
end
function BattleAutoFightDlg:SetDaoJiShi(t)
	if t ~= 0 then
		self.m_DaoJiShi:setVisible(true)
	else
		self.m_DaoJiShi:setVisible(false)
	end
	self.m_DaoJiShi:setText(tostring(t))
end

function BattleAutoFightDlg.CSendAutoOperateData(PlayerOrPet,OperateType,OperateID)
	--new add, send the skill type id
	if PlayerOrPet == 0 then
		local p = require "protodef.fire.pb.hook.csetcharopt":new()
		p.charoptype = OperateType
		p.charopid = OperateID
		require "manager.luaprotocolmanager":send(p)
	else
		local p = require "protodef.fire.pb.hook.csetpetopt":new()
		p.petoptype = OperateType
		p.petopid = OperateID
		require "manager.luaprotocolmanager":send(p)
	end
end

return BattleAutoFightDlg
