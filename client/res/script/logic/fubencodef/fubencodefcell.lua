fubencodescell = {}

setmetatable(fubencodescell, Dialog)
fubencodescell.__index = fubencodescell
local prefix = 0

function fubencodescell.CreateNewDlg(parent)
	local newDlg = fubencodescell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function fubencodescell.GetLayoutFileName()
	return "moshouchuanqicell_mtg.layout"
end

function fubencodescell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fubencodescell)
	return self
end

function fubencodescell:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function fubencodescell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	self.imageFazhen = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/fazhen")
	self.cc_icon = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/fazhen/cczy")
	self.icon = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/fazhen/banshenxiang")
	self.textTongGuan = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/fazhen/yitongguan")
	self.textExplain = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/shuoming")
	self.btnFight = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/btnjinru"))
	self:addButtonAnimation(self.btnFight, "studyBtnPress")
	self.textIsThrough = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/weitongguan")
	self.title = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/title")
	self.textTitle = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/text")
	self.blackBg = winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/heimu")
	self.item1 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/item1"))
	self.item2 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/item2"))
	self.item3 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/item3"))
	self.item4 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/item4"))
	self.item5 = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "moshouchuanqicell_mtg/item5"))
	self.blackBg:setVisible(false)
	self.textTongGuan:setVisible(false)
end

function fubencodescell:HandleClickeBtn(args)
	
end

function fubencodescell:loadServerData( data )
	self.state = data.state
end

function fubencodescell:stopAnimation()
    if self.btnFight.animation then
        self.btnFight.animation:stop()
    end
end

function fubencodescell:refreshData( info )
	self.textTitle:setText(info.ccname)
	self.textExplain:setText(info.explain)
	--self.imageFazhen:setProperty("Image", info.image)
	self.cc_icon:setProperty("Image", info.image)
 	self.icon:setProperty("Image", gGetIconManager():GetImagePathByID(info.icon):c_str())

	local awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.award1)
    if awardInfo then
	    self.item1:setID(info.award1)
	    self.item1:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
        SetItemCellBoundColorByQulityItemWithId(self.item1,awardInfo.id)
	    self.item1:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
    end

	awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.award2)
    if awardInfo then
	    self.item2:setID(info.award2)
	    self.item2:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
        SetItemCellBoundColorByQulityItemWithId(self.item2,awardInfo.id)
	    self.item2:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
    end

	awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.award3)
    if awardInfo then
	    self.item3:setID(info.award3)
	    self.item3:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
        SetItemCellBoundColorByQulityItemWithId(self.item3,awardInfo.id)
	    self.item3:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
    end

	awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.award4)
    if awardInfo then
	    self.item4:setID(info.award4)
	    self.item4:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
        SetItemCellBoundColorByQulityItemWithId(self.item4,awardInfo.id)
	    self.item4:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
    end

	awardInfo = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.award5)
    if awardInfo then
	    self.item5:setID(info.award5)
	    self.item5:SetImage(gGetIconManager():GetItemIconByID(awardInfo.icon))
        SetItemCellBoundColorByQulityItemWithId(self.item5,awardInfo.id)
	    self.item5:subscribeEvent("TableClick", GameItemTable.HandleShowToolTipsWithItemID)
    end

	--[[if self.state == 0 then
		self.btnFight:setEnabled(false)
		self.blackBg:setVisible(true)
	elseif self.state == 2 then
		self.textTongGuan:setVisible(true)
	end]]
	
	 --0 未开启; 1 可以进入, 2 已经完成
    if self.state == 0 then
        self.btnFight:setEnabled(false)
        self.blackBg:setVisible(true)
        self.btnFight:setText(MHSD_UTILS.get_resstring(7900)) -- 未解锁
    elseif self.state == 1 then 
        self.btnFight:setEnabled(true) 
        self.btnFight:setText(MHSD_UTILS.get_resstring(7901)) -- 进  入
    elseif self.state == 2 then
        self.textTongGuan:setVisible(true)
        --self.btnFight:setEnabled(false) 
        self.btnFight:setText(MHSD_UTILS.get_resstring(7901)) -- 已完成
    end
end

return fubencodescell
