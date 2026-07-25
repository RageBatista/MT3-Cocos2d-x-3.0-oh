------------------------------------------------------------------
-- 宠物技能领悟
------------------------------------------------------------------
require "logic.dialog"
require "logic.costconfirmbox"
require "logic.pet.petskillidentifyyiwang"
PetSkillIdentifyLingWu = {}
setmetatable(PetSkillIdentifyLingWu, Dialog)
PetSkillIdentifyLingWu.__index = PetSkillIdentifyLingWu
local petDatadump
local skillneddmoney
local skillnedditem
local _instance
function PetSkillIdentifyLingWu.getInstance()
	if not _instance then
		_instance = PetSkillIdentifyLingWu:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetSkillIdentifyLingWu.getInstanceAndShow()
	if not _instance then
		_instance = PetSkillIdentifyLingWu:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetSkillIdentifyLingWu.getInstanceNotCreate()
	return _instance
end

function PetSkillIdentifyLingWu.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetSkillIdentifyLingWu.ToggleOpenClose()
	if not _instance then
		_instance = PetSkillIdentifyLingWu:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetSkillIdentifyLingWu.GetLayoutFileName()
	return "petfashurenlingwu_mtg.layout"
end

function PetSkillIdentifyLingWu:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetSkillIdentifyLingWu)
	return self
end

function PetSkillIdentifyLingWu:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self:GetWindow():setRiseOnClickEnabled(false)
	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petfashurenzheng_mtg/bg/text2bg/scroll"))
	self.identifyBtn = CEGUI.toPushButton(winMgr:getWindow("petfashurenzheng_mtg/bg/btnxuanze"))
	self.costMoney = winMgr:getWindow("petfashurenzheng_mtg/bg/textbg/textzhi")
	self.ownMoney = winMgr:getWindow("petfashurenzheng_mtg/bg/textbg/textzhi1")
	
	self.tishiwb1 = winMgr:getWindow("petfashurenzheng_mtg/bg/ccyycc/ccy1")
	self.tishiwb2 = winMgr:getWindow("petfashurenzheng_mtg/bg/ccyycc/ccy2")
	
    

	self.xiangqing = winMgr:getWindow("petfashurenzheng_mtg/xiangqing")
	
	self.xuexitips = CEGUI.toRichEditbox(winMgr:getWindow("petfashurenzheng_mtg/bs2/zt21"))
	self.xuexitips:Clear()
    self.xuexitips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7414)))
    self.xuexitips:Refresh()
	
	self.skilldoc = CEGUI.toRichEditbox(winMgr:getWindow("petfashurenzheng_mtg/skilldoc"))
	self.skilldoc1 = winMgr:getWindow("petfashurenzheng_mtg/bg/text/jnlb111")
	self.colseBtn = CEGUI.toPushButton(winMgr:getWindow("petfashurenzheng_mtg/guanbi"))
	self.needitem = CEGUI.Window.toItemCell(winMgr:getWindow("petfashurenzheng_mtg/bg/needitem")) 

	self.identifyBtn:subscribeEvent("Clicked", PetSkillIdentifyLingWu.handleIdentifyClicked, self)
	self.colseBtn:subscribeEvent("Clicked", PetSkillIdentifyLingWu.handleCloseClicked, self)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.ownMoney:setText(MoneyFormat(roleItemManager:GetPackMoney()))
end

function PetSkillIdentifyLingWu:setIsIdentifyViewOrNot(isIdentify)
	self.viewType = (isIdentify and 1 or 0)

	if not isIdentify then
		self.identifyBtn:setText(MHSD_UTILS.get_resstring(7209)) 
		self:GetWindow():setText(MHSD_UTILS.get_resstring(11813))
	end
end

function PetSkillIdentifyLingWu:setPetData(petData)---宠物学习接口-需要对接服务端下发数据
    petDatadump = petData
    if not petData then
        return
    end
    self.petData = petData
    self:setIsIdentifyViewOrNot( petData:getIdentifiedSkill()==nil and true or false )
    local num = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getSize()
    local lingwuallskill
    local n = 0
    local row = 0 
    for i=1, num do
        local skill = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(i)
        local cell = self:createCell(skill)
        self.scroll:addChildWindow(cell.window)

        local xOffset = 8 + (cell.window:getPixelSize().width + 10) * (n % 6) 

     
        local yOffset = 5 + (cell.window:getPixelSize().height + 10) * row

        SetPositionOffset(cell.window, xOffset, yOffset)

        if n == 0 then
            self.lastSelectedBtn = cell.window
            self.lastSelectedBtn:setSelected(true)
        end
        n = n + 1

        -- 技能窗口换行
        if n % 6 == 0 then 
            row = row + 1 
        end
    end
	
    local num = self.petData:getSkilllistlen()
    local petName = self.petData.name
    local maxSkillCount = 8
    local remainingSkillCount = maxSkillCount - num

    self.xiangqing:setText("[colour='FF33FF00']" .. petName .. "[/colour][colour='FFFFFFFF']拥有[/colour][colour='FF33FF00']" .. num .. "[/colour][colour='FFFFFFFF']个技能，还可学习[/colour][colour='FF33FF00']" .. remainingSkillCount .. "[/colour][colour='FFFFFFFF']个技能[/colour]")
    --[[local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if conf then
        local price = (self.viewType==1 and conf.certificationcost or conf.cancelcertificationcost)
        self.costMoney:setText(MoneyFormat(0))
        if price > MoneyNumber(self.ownMoney:getText()) then
            self.costMoney:setProperty("BorderEnable", "True")
        end
    end--]]
	self.identifyBtn:setEnabled(false)
end

function PetSkillIdentifyLingWu:createCell(skill)
	local cell = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefix = tostring(skill.skillid)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskilllingwucell_mtg.layout", prefix))
	cell.skillBox = CEGUI.toSkillBox(winMgr:getWindow(prefix .. "petskilllingwucell_mtg/item"))
	cell.name = winMgr:getWindow(prefix .. "petskilllingwucell_mtg/name")
	cell.window:EnableClickAni(false)
	SetPetSkillBoxInfotm(cell.skillBox, skill.skillid, self.petData)
	cell.name:setText(skill.skillname)
	cell.window:setID(skill.skillid)
	cell.window:setID2(skill.id)
	cell.skillBox:subscribeEvent("MouseClick", PetSkillIdentifyLingWu.handleSkillClicked, self)
	cell.window:subscribeEvent("SelectStateChanged", PetSkillIdentifyLingWu.handleCellClicked, self)
	
	return cell
end

function PetSkillIdentifyLingWu:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local wnd = CEGUI.toWindowEventArgs(args).window
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local pos = cell:GetScreenPos()
	SetPositionOffset(tip:GetWindow(), pos.x+100, pos.y)
end

function PetSkillIdentifyLingWu:handleCellClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local idx = wnd:getID2()
	
	local skillitem = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).addneeditem
	local skillitemnum = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).addneeditemnum
	local skilldoc = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).skilldoc
	local skilldoc1 = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).skilldoc1
	
    skillneddmoney = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).addneedmoney
	local washitem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(skillitem)
	skillnedditem = skillitemnum.."个"..washitem.name
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curItemNum = roleItemManager:GetItemNumByBaseID(skillitem)
	self.identifyBtn:setEnabled(curItemNum >= skillitemnum)
	if curItemNum >= skillitemnum then 
        self.tishiwb1:setVisible(true) 
        self.tishiwb2:setVisible(false) 
    else
        self.tishiwb1:setVisible(false)
        self.tishiwb2:setVisible(true)
    end
--	local skillnedditema = curItemNum.."个"..washitem.name
	local skillnedditema = "当前拥有 "..curItemNum.." 个"..washitem.name
	self.costMoney:setText(skillnedditem)
	self.ownMoney:setText(skillnedditema)
	self.skilldoc:Clear()
    self.skilldoc:AppendParseText(CEGUI.String(skilldoc)) 
    self.skilldoc:Refresh() 
	self.skilldoc1:setText(skilldoc1)
	local img = gGetIconManager():GetImageByID(washitem.icon)
	self.needitem:SetImage(img)
	if self.lastSelectedBtn == wnd then
		return
	end
	self.lastSelectedBtn = wnd
end

function PetSkillIdentifyLingWu:CheckClickOutside(args)
    local function check(wnd)
        local pTargetWnd = CheckTipsWnd.GetCursorWindow()
        if wnd == pTargetWnd then return true end

        if pTargetWnd then
            return pTargetWnd:isAncestor(wnd)
        else
            return false
        end
    end
    if self:IsVisible() and not check(self:GetWindow()) then
        self:DestroyDialog()
    end
end

function PetSkillIdentifyLingWu:handleConfirmIdentify()
	local p = require("protodef.fire.pb.pet.cpetskillcertificationlingwu").Create()
	p.petkey = self.petData.key
	p.skillid = self.lastSelectedBtn:getID()
	p.isconfirm = self.viewType
	LuaProtocolManager:send(p)
	self.DestroyDialog()
end

function PetSkillIdentifyLingWu:handleIdentifyClicked(args)
	if not self.petData or not self.lastSelectedBtn or not self.viewType then
        GetCTipsManager():AddMessageTipById(193502) 
		return
	end

    if GetBattleManager():IsInBattle() then    
	    if self.petData.key == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(131451) 
		    return
	    end
    end
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if not conf then return end
	if self.viewType == 1 then 	
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(191234))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(7207)
		local num =skillnedditem
		CostConfirmBox.show(msg, des, num, PetSkillIdentifyLingWu.handleConfirmIdentify, self, PetSkillIdentifyLingWu.DestroyDialog)

	elseif self.viewType == 0 then	
		local skill = self.petData:getIdentifiedSkill()
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(skill.skillid))
		sb:Set("parameter4", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(191234))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(7207)
		local num = skillnedditem
		CostConfirmBox.show(msg, des, num, PetSkillIdentifyLingWu.handleConfirmIdentify, self, PetSkillIdentifyLingWu.DestroyDialog)
	end
	self:SetVisible(false)
end

function PetSkillIdentifyLingWu:handleCloseClicked(args)
    self:DestroyDialog()
end

return PetSkillIdentifyLingWu
