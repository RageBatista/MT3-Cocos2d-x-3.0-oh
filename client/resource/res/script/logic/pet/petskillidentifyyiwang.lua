------------------------------------------------------------------

------------------------------------------------------------------
require "logic.dialog"
require "logic.costconfirmbox"
PetSkillIdentifyYiWang = {}
setmetatable(PetSkillIdentifyYiWang, Dialog)
PetSkillIdentifyYiWang.__index = PetSkillIdentifyYiWang
local petDatadump
local skillnedditem
local skillneddmoney
local _instance
function PetSkillIdentifyYiWang.getInstance()
	if not _instance then
		_instance = PetSkillIdentifyYiWang:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetSkillIdentifyYiWang.getInstanceAndShow()
	if not _instance then
		_instance = PetSkillIdentifyYiWang:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetSkillIdentifyYiWang.getInstanceNotCreate()
	return _instance
end

function PetSkillIdentifyYiWang.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetSkillIdentifyYiWang.ToggleOpenClose()
	if not _instance then
		_instance = PetSkillIdentifyYiWang:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetSkillIdentifyYiWang.GetLayoutFileName()
	return "petfashurenyiwang_mtg.layout"
end

function PetSkillIdentifyYiWang:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetSkillIdentifyYiWang)
	return self
end

function PetSkillIdentifyYiWang:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petqimenyiwang_mtg/bg/text2bg/scroll"))
	self.identifyBtn = CEGUI.toPushButton(winMgr:getWindow("petqimenyiwang_mtg/bg/btnxuanze"))
	self.costMoney = winMgr:getWindow("petqimenyiwang_mtg/bg/textbg/textzhi")
	self.ownMoney = winMgr:getWindow("petqimenyiwang_mtg/bg/textbg/textzhi1")
	self.needitem = CEGUI.Window.toItemCell(winMgr:getWindow("petqimenyiwang_mtg/bg/needitem")) 
	self.colseBtn = CEGUI.toPushButton(winMgr:getWindow("petqimenyiwang_mtg/guanbi"))
	self.skilldoc = CEGUI.toRichEditbox(winMgr:getWindow("petqimenyiwang_mtg/skilldoc"))
	self.skilldoc1 = winMgr:getWindow("petqimenyiwang_mtg/bg/text/jnlb111")
	self.identifyBtn:subscribeEvent("Clicked", PetSkillIdentifyYiWang.handleIdentifyClicked, self)
	self.colseBtn:subscribeEvent("Clicked", PetSkillIdentifyYiWang.handleCloseClicked, self)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.ownMoney:setText(0)
end

function PetSkillIdentifyYiWang:setIsIdentifyViewOrNot(isIdentify)
	self.viewType = (isIdentify and 1 or 0)
	if not isIdentify then
		self.identifyBtn:setText(MHSD_UTILS.get_resstring(11120)) 
		self:GetWindow():setText(MHSD_UTILS.get_resstring(11806))
	end
end

function PetSkillIdentifyYiWang:setPetData(petData)
    petDatadump = petData
    if not petData then
        return
    end
    self.petData = petData
    self:setIsIdentifyViewOrNot( petData:getIdentifiedSkill()==nil and true or false )
    local num = self.petData:getSkilllistlen()
    local n = 0 
    local row = 0 
    local columnCount = 3 

    for i=1, num do
        local skill = self.petData:getSkill(i)
        local skillid = skill.skillid 

        -- 判断技能是否为当前宠物的绑定技能
        if not self.petData:isSkillBind(skillid) then  
            local upgradeConfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillupgrade"):getRecorder(skill.skillid)
            
            local cell = self:createCell(skill)
            self.scroll:addChildWindow(cell.window)

            local xOffset = 8 + (cell.window:getPixelSize().width + 10) * (n % columnCount) 
            local yOffset = 5 + (cell.window:getPixelSize().height + 10) * row

            SetPositionOffset(cell.window, xOffset, yOffset)

            if n==0 then
                self.lastSelectedBtn = cell.window
                self.lastSelectedBtn:setSelected(true)
				
            end
            n = n + 1

            
            if n % columnCount == 0 then 
                row = row + 1 
                n = 0  
            end
        end
    end
    
  --[[  local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
     if conf then
       local price = (self.viewType==1 and conf.certificationcost or conf.cancelcertificationcost)
        self.costMoney:setText(MoneyFormat(0))
        if price > MoneyNumber(self.ownMoney:getText()) then
            self.costMoney:setProperty("BorderEnable", "True")
        end
    end--]]
end

function tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function PetSkillIdentifyYiWang:createCell(skill)
	local cell = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefix = tostring(skill.skillid)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskillyiwangcell_mtg.layout", prefix))
	cell.skillBox = CEGUI.toSkillBox(winMgr:getWindow(prefix .. "petskillyiwangcell_mtg/item"))
	cell.name = winMgr:getWindow(prefix .. "petskillyiwangcell_mtg/name")
	cell.window:EnableClickAni(false)

	SetPetSkillBoxInfotm(cell.skillBox, skill.skillid, self.petData)
	cell.name:setText(SkillBoxControl.GetSkillNamebyID(skill.skillid))
	cell.window:setID(skill.skillid)
	
	cell.skillBox:subscribeEvent("MouseClick", PetSkillIdentifyYiWang.handleSkillClicked, self)
	cell.window:subscribeEvent("SelectStateChanged", PetSkillIdentifyYiWang.handleCellClicked, self)
	
	return cell
end

function PetSkillIdentifyYiWang:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local wnd = CEGUI.toWindowEventArgs(args).window

	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local pos = cell:GetScreenPos()
	SetPositionOffset(tip:GetWindow(), pos.x+100, pos.y)
end

function PetSkillIdentifyYiWang:handleCellClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local idx = wnd:getID()
	
	local skilldoc = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllwxianshi"):getRecorder(idx).skilldoc
	local skilldoc1 = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllwxianshi"):getRecorder(idx).removeneeditemnum
	local skillitem = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllwxianshi"):getRecorder(idx).removeneeditem
	local skillitemnum = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllwxianshi"):getRecorder(idx).removeneeditemnum
    skillneddmoney = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllwxianshi"):getRecorder(idx).removeneedmoney
	local washitem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(skillitem)
	local skillName = SkillBoxControl.GetSkillNamebyID(idx)
    skillnedditem = "遗弃 ".. skillName .." 需 "..skillitemnum.."个"..washitem.name

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curItemNum = roleItemManager:GetItemNumByBaseID(skillitem)
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

function PetSkillIdentifyYiWang:handleConfirmIdentify()
	local p = require("protodef.fire.pb.pet.cpetskillcertificationyiwang").Create()
	p.petkey = self.petData.key
	p.skillid = self.lastSelectedBtn:getID()
	p.isconfirm = self.viewType
	LuaProtocolManager:send(p)
	self.DestroyDialog()
end

function PetSkillIdentifyYiWang:handleIdentifyClicked(args)
	if not self.petData or not self.lastSelectedBtn or not self.viewType then
        GetCTipsManager():AddMessageTipById(193501) 
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
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(191236))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(11712)
		local num =skillnedditem
		CostConfirmBox.show(msg, des, num, PetSkillIdentifyYiWang.handleConfirmIdentify, self, PetSkillIdentifyYiWang.DestroyDialog)

	elseif self.viewType == 0 then	
		local skill = self.petData:getIdentifiedSkill()
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(skill.skillid))
		sb:Set("parameter4", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(191236))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(11712)
		local num = skillnedditem
		CostConfirmBox.show(msg, des, num, PetSkillIdentifyYiWang.handleConfirmIdentify, self, PetSkillIdentifyYiWang.DestroyDialog)
	end
	self:SetVisible(false)
end

function PetSkillIdentifyYiWang:CheckClickOutside(args)
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

function PetSkillIdentifyYiWang:handleCloseClicked(args)
    self:DestroyDialog()
end

return PetSkillIdentifyYiWang
