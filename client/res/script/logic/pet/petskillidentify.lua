------------------------------------------------------------------
-- 宠物法术认证
------------------------------------------------------------------
require "logic.dialog"
require "logic.costconfirmbox"

PetSkillIdentify = {}
setmetatable(PetSkillIdentify, Dialog)
PetSkillIdentify.__index = PetSkillIdentify

local _instance
function PetSkillIdentify.getInstance()
	if not _instance then
		_instance = PetSkillIdentify:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetSkillIdentify.getInstanceAndShow()
	if not _instance then
		_instance = PetSkillIdentify:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetSkillIdentify.getInstanceNotCreate()
	return _instance
end

function PetSkillIdentify.DestroyDialog()
	if _instance then
	_instance.identifyBtn.animation:stop()--停止
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetSkillIdentify.ToggleOpenClose()
	if not _instance then
		_instance = PetSkillIdentify:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetSkillIdentify.GetLayoutFileName()
	return "petfashurenzheng_mtg.layout"
end

function PetSkillIdentify:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetSkillIdentify)
	return self
end

function PetSkillIdentify:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetSkillIdentify:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petfashurenzheng_mtg/bg/text2bg/scroll"))
	self.identifyBtn = CEGUI.toPushButton(winMgr:getWindow("petfashurenzheng_mtg/bg/btnxuanze"))
	self:addButtonAnimation(self.identifyBtn, "studyBtnPress")
	self.costMoney = winMgr:getWindow("petfashurenzheng_mtg/bg/textbg/textzhi")
	self.ownMoney = winMgr:getWindow("petfashurenzheng_mtg/bg/textbg/textzhi1")
	self.identifyText = winMgr:getWindow("petfashurenzheng_mtg/bg/textqingxuanze")
	self.nonIdentifyText = winMgr:getWindow("petfashurenzheng_mtg/bg/nonidentifytext")

	self.identifyBtn:subscribeEvent("Clicked", PetSkillIdentify.handleIdentifyClicked, self)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.ownMoney:setText(MoneyFormat(roleItemManager:GetPackMoney()))
end

function PetSkillIdentify:setIsIdentifyViewOrNot(isIdentify)
	self.viewType = (isIdentify and 1 or 0)
	self.identifyText:setVisible(isIdentify)
	self.nonIdentifyText:setVisible(not isIdentify)
	if not isIdentify then
		self.identifyBtn:setText(MHSD_UTILS.get_resstring(11120)) --取消认证
		self:GetWindow():setText(MHSD_UTILS.get_resstring(11806))
	end
end

function PetSkillIdentify:setPetData(petData)
	if not petData then
		return
	end
	self.petData = petData
	self:setIsIdentifyViewOrNot( petData:getIdentifiedSkill()==nil and true or false )

	local num = self.petData:getSkilllistlen()
	local n = 0
	for i=1, num do
		local skill = self.petData:getSkill(i)
		local upgradeConfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillupgrade"):getRecorder(skill.skillid)
		if (self.viewType == 1 and upgradeConfig.iscancertification == 1) or (self.viewType == 0 and skill.certification ~= 1) then
			local cell = self:createCell(skill)
			self.scroll:addChildWindow(cell.window)
			SetPositionOffset(cell.window, 8, 5+(cell.window:getPixelSize().height+5)*n)
			if n==0 then
				self.lastSelectedBtn = cell.window
                self.lastSelectedBtn:setSelected(true)
			end
			n = n+1
		end
	end
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if conf then
        local price = (self.viewType==1 and conf.certificationcost or conf.cancelcertificationcost)
	    self.costMoney:setText(MoneyFormat(price))
        if price > MoneyNumber(self.ownMoney:getText()) then
            self.costMoney:setProperty("BorderEnable", "True")
        end
    end
end

function PetSkillIdentify:createCell(skill)
	local cell = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefix = tostring(skill.skillid)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskillhuishoucell_mtg.layout", prefix))
	cell.skillBox = CEGUI.toSkillBox(winMgr:getWindow(prefix .. "petskillhuishoucell_mtg/item"))
	cell.name = winMgr:getWindow(prefix .. "petskillhuishoucell_mtg/name")
	cell.window:EnableClickAni(false)

	SetPetSkillBoxInfo(cell.skillBox, skill.skillid, self.petData)
	cell.name:setText(SkillBoxControl.GetSkillNamebyID(skill.skillid))
	
	cell.window:setID(skill.skillid)
	cell.skillBox:subscribeEvent("MouseClick", PetSkillIdentify.handleSkillClicked, self)
	cell.window:subscribeEvent("SelectStateChanged", PetSkillIdentify.handleCellClicked, self)
	
	return cell
end

function PetSkillIdentify:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local pos = cell:GetScreenPos()
	SetPositionOffset(tip:GetWindow(), pos.x+100, pos.y)
end

function PetSkillIdentify:handleCellClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	if self.lastSelectedBtn == wnd then
		return
	end
	self.lastSelectedBtn = wnd
end

function PetSkillIdentify:handleConfirmIdentify()
	local p = require("protodef.fire.pb.pet.cpetskillcertification").Create()
	p.petkey = self.petData.key
	p.skillid = self.lastSelectedBtn:getID()
	p.isconfirm = self.viewType

    local price = MoneyNumber(self.costMoney:getText())
    local needMoney = price - MoneyNumber(self.ownMoney:getText())
	if needMoney > 0 then
		--GET MONEY
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needMoney, price, p)
	else
		LuaProtocolManager:send(p)
	end

	self.DestroyDialog()
end

function PetSkillIdentify:handleIdentifyClicked(args)
	if not self.petData or not self.lastSelectedBtn or not self.viewType then
        GetCTipsManager():AddMessageTipById(150067) --需要选择一个技能进行认证
		return
	end


    if GetBattleManager():IsInBattle() then    
	    if self.petData.key == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(131451) --战斗中不能进行此操作
		    return
	    end
    end
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if not conf then return end
	if self.viewType == 1 then 	--认证
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(150065))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(11118)
		local num = conf.certificationcost
		CostConfirmBox.show(msg, des, num, PetSkillIdentify.handleConfirmIdentify, self, PetSkillIdentify.DestroyDialog)

	elseif self.viewType == 0 then	--取消认证
		local skill = self.petData:getIdentifiedSkill()
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(skill.skillid))
		sb:Set("parameter4", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(150066))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(11119)
		local num = conf.cancelcertificationcost
		CostConfirmBox.show(msg, des, num, PetSkillIdentify.handleConfirmIdentify, self, PetSkillIdentify.DestroyDialog)
	end
	self:SetVisible(false)
end

return PetSkillIdentify
