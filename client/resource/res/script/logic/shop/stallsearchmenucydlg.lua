------------------------------------------------------------------
-- 摆摊装备搜索菜单2
------------------------------------------------------------------
require "logic.dialog"

StallSearchMenucyDlg = {
	TYPE_EQUIP_ADDITIONAL_ATTR	= 1,  --装备附加属性
	TYPE_PET_SKILL				= 2	  --宠物技能
}
setmetatable(StallSearchMenucyDlg, Dialog)
StallSearchMenucyDlg.__index = StallSearchMenucyDlg


local equipAddionalAttrIds = {
    fire.pb.attr.EffectType.CONS_ABL,   --体质
	fire.pb.attr.EffectType.IQ_ABL,	    --智力
	fire.pb.attr.EffectType.STR_ABL,    --力量
	fire.pb.attr.EffectType.ENDU_ABL,   --耐力
    fire.pb.attr.EffectType.AGI_ABL     --敏捷
}


local _instance
function StallSearchMenucyDlg.getInstance()
	if not _instance then
		_instance = StallSearchMenucyDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallSearchMenucyDlg.getInstanceAndShow()
	if not _instance then
		_instance = StallSearchMenucyDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallSearchMenucyDlg.getInstanceNotCreate()
	return _instance
end

function StallSearchMenucyDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallSearchMenucyDlg.ToggleOpenClose()
	if not _instance then
		_instance = StallSearchMenucyDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallSearchMenucyDlg.GetLayoutFileName()
	return "baitansousuomenucydlg.layout"
end

function StallSearchMenucyDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallSearchMenucyDlg)
	return self
end

function StallSearchMenucyDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionScreenCenter(self:GetWindow())

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.inputText = winMgr:getWindow("baitansousuomenucydlg/text")
	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("baitansousuomenucydlg/content/scroll"))
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuomenucydlg/btn0"))
	self.resetBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuomenucydlg/btn1"))
	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("baitansousuomenucydlg/btn2"))


    self.cc_scroll = CEGUI.toScrollablePane(winMgr:getWindow("baitansousuomenucydlg/ccydbanc1/hdck1"))
    self.cc_scroll:EnableHorzScrollBar(true)

	self.cancelBtn:subscribeEvent("Clicked", StallSearchMenucyDlg.handleCancelClicked, self)
	self.resetBtn:subscribeEvent("Clicked", StallSearchMenucyDlg.handleResetClicked, self)
	self.sureBtn:subscribeEvent("Clicked", StallSearchMenucyDlg.handleSureClicked, self)

	self.checkSigns = {}
	self.choosedIDs = {}
	self.choosedNames = {}
	self.willCheckTipsWnd = false
end

function StallSearchMenucyDlg:loadEquipAddionalAttr()
	local t = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig")
	local colCount = 4
	local btnw = self.scroll:getPixelSize().width / colCount
	local btnh = 80
	for k,v in pairs(equipAddionalAttrIds) do
        local id = v - v % 10
		local cell= CEGUI.toGroupButton(self.winMgr:createWindow("TaharezLook/CellGroupButton"))
		cell:setSize(NewVector2(btnw, btnh))
		cell:EnableClickAni(false)
		cell:SetBorderEnable(false)
		cell:setID(v)
		self.scroll:addChildWindow(cell)
		local row = (k-1) % colCount
		local col = math.floor((k-1) / 4)
		cell:setPosition(NewVector2(btnw*row, btnh*col))

		local check = self.winMgr:createWindow("TaharezLook/StaticImage")
		check:setProperty("Image", "set:character image:character_img_xuanzhong1")
		check:setProperty("ImageSizeEnable", "False")
		check:setMousePassThroughEnabled(true)
		cell:addChildWindow(check)
		local s = check:getPixelSize()
		check:setPosition(NewVector2(btnw-s.width-5, btnh-s.height-5))
		check:setVisible(false)
		self.checkSigns[v] = check

		local conf = t:getRecorder(id)
		cell:setText(conf.name)

		cell:subscribeEvent("MouseClick", StallSearchMenucyDlg.handleCellClicked, self)
	end
end

function StallSearchMenucyDlg:loadPetSkill()
    local col = 8
    local intervX = 10
    local intervY = 5
    local cellw = (self.scroll:getPixelSize().width - intervX) / col - intervX
    
    local ids =	BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getAllID()
    for i=0, #ids-1 do
        local skillId = ids[i+1]
        local conf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skillId)
        local isShow = conf.isshow
        if isShow == 0 then
        else  
            local r = math.floor(i/col)
            local c = i % col
            local skillbox = CEGUI.toSkillBox(self.winMgr:createWindow("TaharezLook/SkillBox1"))
            skillbox:setSize(NewVector2(cellw, cellw))
            self.scroll:addChildWindow(skillbox)
            skillbox:setPosition(NewVector2(intervX+c*(cellw+intervX), intervY+r*(cellw+intervY)))

            SetPetSkillBoxInfond(skillbox, ids[i+1])

            skillbox:setID(ids[i+1])
            skillbox:setText(conf.skillname)

            local check = self.winMgr:createWindow("TaharezLook/StaticImage")
            check:setProperty("Image", "set:character image:character_img_xuanzhong1")
            check:setProperty("ImageSizeEnable", "False")
            check:setMousePassThroughEnabled(true)
            skillbox:addChildWindow(check)
            local s = check:getPixelSize()
            check:setPosition(NewVector2(cellw-s.width, cellw-s.height))
            check:setVisible(false)
            self.checkSigns[ids[i+1]] = check

            skillbox:subscribeEvent("MouseClick", StallSearchMenucyDlg.handleCellClicked, self)
        end
    end
end

function StallSearchMenucyDlg:setMenuType(t)
	self.menuType = t
	if t == StallSearchMenucyDlg.TYPE_EQUIP_ADDITIONAL_ATTR then
		self:loadEquipAddionalAttr()
	elseif t == StallSearchMenucyDlg.TYPE_PET_SKILL then
		self:loadPetSkill()
	end
end

function StallSearchMenucyDlg:setChoosedCallFunc(func, tar)
	self.choosedCallFunc = {func=func, tar=tar}
end

function StallSearchMenucyDlg:setChoosedIds(choosedIds)
	local t = nil
	if self.menuType == StallSearchMenucyDlg.TYPE_EQUIP_ADDITIONAL_ATTR then
		t = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig")
	elseif self.menuType == StallSearchMenucyDlg.TYPE_PET_SKILL then
		t = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig")
	end

	for _,v in pairs(choosedIds) do
		if self.checkSigns[v] then
			self.checkSigns[v]:setVisible(true)
			table.insert(self.choosedIDs, v)

			if self.menuType == StallSearchMenucyDlg.TYPE_EQUIP_ADDITIONAL_ATTR then
				local conf = t:getRecorder(v-v%10)
				table.insert(self.choosedNames, conf.name)
			elseif self.menuType == StallSearchMenucyDlg.TYPE_PET_SKILL then
				local conf = t:getRecorder(v)
				table.insert(self.choosedNames, conf.skillname)
			end
		end
	end
	self.inputText:setText(table.concat(self.choosedNames, " "))
end

function StallSearchMenucyDlg:handleCellClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	local check = self.checkSigns[btn:getID()]
	if check then
		if not check:isVisible() and #self.choosedIDs == 20 then
			GetCTipsManager():AddMessageTipById(190003) --最多只能选择20个技能
			return
		end

		check:setVisible(not check:isVisible())

		if check:isVisible() then
			table.insert(self.choosedIDs, 1, btn:getID())
			table.insert(self.choosedNames, 1, btn:getText())
		else
			for k,v in pairs(self.choosedIDs) do
				if v == btn:getID() then
					table.remove(self.choosedIDs, k)
					table.remove(self.choosedNames, k)
					break
				end
			end
		end

		self.inputText:setText(table.concat(self.choosedNames, " "))
	end
end

function StallSearchMenucyDlg:handleCancelClicked(args)
	StallSearchMenucyDlg.DestroyDialog()
end

function StallSearchMenucyDlg:handleResetClicked(args)
	self.choosedIDs = {}
	self.choosedNames = {}
	self.inputText:setText("")
	for _,v in pairs(self.checkSigns) do
		v:setVisible(false)
	end
end

function StallSearchMenucyDlg:handleSureClicked(args)
	if self.choosedCallFunc then
		self.choosedCallFunc.func(self.choosedCallFunc.tar, self.inputText:getText(), self.choosedIDs)
	end

	StallSearchMenucyDlg.DestroyDialog()
end

return StallSearchMenucyDlg