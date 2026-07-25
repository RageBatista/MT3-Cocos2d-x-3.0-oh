require "logic.multimenu"

------------------------------------------------------------------
-- 宠物图鉴菜单
------------------------------------------------------------------
PetGalleryMenu = {}

function PetGalleryMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(PetGalleryMenu)
end

function PetGalleryMenu:getButtonCount()
	return 1
end

function PetGalleryMenu:setButtonTitles(buttons)
	buttons[1]:setText(MHSD_UTILS.get_resstring(11124))	--全部宠物
	buttons[1]:setID(0)
	buttons[1]:setID2(0)
end



------------------------------------------------------------------
-- 摆摊三级菜单
------------------------------------------------------------------
StallThirdMenu = {
	columnCount = 2,
	btnw = 160,
	btnh = 64,
	fixRow = 3,
	font = "simhei-12",
    savedCheckboxStates = {} --保存页签里checkbox的状态
}

function StallThirdMenu.toggleShowHide(thirdmenus, catalog1Id, thirdGroupCount)
    StallThirdMenu.thirdmenus = thirdmenus
    StallThirdMenu.catalog1Id = catalog1Id
    StallThirdMenu.thirdGroupCount = thirdGroupCount or 1
    StallThirdMenu.fixRow = ((catalog1Id == 3 or catalog1Id == 10) and 3 or 3)
    if StallThirdMenu.thirdGroupCount > 1 then
        StallThirdMenu.savedCheckboxStates[catalog1Id] = StallThirdMenu.savedCheckboxStates[catalog1Id] or {}
    end
	local menu = MultiMenu.toggleShowHide(StallThirdMenu)
    if menu then
        --装备物品添加品质选择功能
        local wnd
        local layoutName
        if catalog1Id == 3 then --珍品装备
            layoutName = "baitanshaixuan1"
            wnd = CEGUI.WindowManager:getSingleton():loadWindowLayout("baitanshaixuan1.layout")
        elseif catalog1Id == 10 then --任务物品
            layoutName = "baitanshaixuan2"
            wnd = CEGUI.WindowManager:getSingleton():loadWindowLayout("baitanshaixuan2.layout")
        end
        if wnd then
            local s = menu.window:getPixelSize()
            s.height = s.height + wnd:getPixelSize().height
            menu.window:setHeight(CEGUI.UDim(0,s.height))
            menu.window:addChildWindow(wnd)
            wnd:setYPosition(CEGUI.UDim(0, s.height-wnd:getPixelSize().height-5))
            menu.checkBoxes = {}
            local states = StallThirdMenu.savedCheckboxStates[catalog1Id]
            for i=1, StallThirdMenu.thirdGroupCount do
                local checkbox = CEGUI.toCheckbox(CEGUI.WindowManager:getSingleton():getWindow(layoutName .. "/checkbox" .. i))
                if checkbox then
                    menu.checkBoxes[i] = checkbox
                    checkbox:setID(i)
                    if states and states[i] == 0 then
                        checkbox:setSelected(false)
                    end
                    checkbox:subscribeEvent("CheckStateChanged", StallThirdMenu.handleCheckboxStateChanged, nil)
                end
            end
        end
    end
    return menu
end

function StallThirdMenu.handleCheckboxStateChanged(tar, args)
    local checkbox = CEGUI.toCheckbox(CEGUI.toWindowEventArgs(args).window)
    local states = StallThirdMenu.savedCheckboxStates[StallThirdMenu.catalog1Id]
    local unselectNum = 0
    for _,v in pairs(states) do
        if v == 0 then
            unselectNum = unselectNum + 1
        end
    end
    if unselectNum == StallThirdMenu.thirdGroupCount-1 and not checkbox:isSelected() then
        checkbox:setSelected(true)
    else
        states[checkbox:getID()] = (checkbox:isSelected() and 1 or 0)
    end
end

function StallThirdMenu:setButtonTitles(buttons)
	--如果只包含一个三级菜单，则显示区间段
	if self.thirdmenus:size() == 1 then
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(self.thirdmenus[0])
		for i=0, conf.valuerange:size()-2 do
			buttons[i+1]:setText(conf.valuerange[i]+1 .. "~" .. conf.valuerange[i+1])
			buttons[i+1]:setID(conf.valuerange[i]+1)
			buttons[i+1]:setID2(conf.valuerange[i+1])
		end
	else
		for i=0, self:getButtonCount()-1 do
			local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(self.thirdmenus[i])
			buttons[i+1]:setText(conf.name)
            if self.thirdGroupCount > 1 then
                buttons[i+1]:setID(i) --序号
            else
			    buttons[i+1]:setID(self.thirdmenus[i]) --id
            end
		end
	end
end

function StallThirdMenu:getButtonCount()
	if self.thirdmenus:size() == 1 then
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable")):getRecorder(self.thirdmenus[0])
		return conf.valuerange:size()-1
	end
	return self.thirdmenus:size()/StallThirdMenu.thirdGroupCount
end


------------------------------------------------------------------
-- 价格排序菜单
------------------------------------------------------------------
PriceOrderMenu = {
	btnw = 109,
	btnh = 64,
	font = "simhei-12"
}

function PriceOrderMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(PriceOrderMenu)
end

function PriceOrderMenu:getButtonCount()
	return 2
end

function PriceOrderMenu:setButtonTitles(buttons)
	buttons[1]:setText(MHSD_UTILS.get_resstring(11193) .. "  ")
	buttons[2]:setText(MHSD_UTILS.get_resstring(11193) .. "  ")
	
	local s = buttons[1]:getPixelSize()
	for i=1,2 do
		local arrow = CEGUI.WindowManager:getSingleton():createWindow("TaharezLook/StaticImage")
		arrow:setProperty("Image", i==1 and "set:common image:up" or "set:common image:dowm")
		arrow:setMousePassThroughEnabled(true)
        SetWindowSize(arrow, 20, 20)
		buttons[i]:addChildWindow(arrow)
		SetPositionOffset(arrow, s.width-5, s.height*0.5, 1, 0.5)
	end
end


------------------------------------------------------------------
-- 公会任命菜单
------------------------------------------------------------------
familyRenmingMenu = { 
    maxRow = 10,
	btnw = 200,
	btnh = 50,
	font = "simhei-12"
}

function familyRenmingMenu.toggleShowHide(DestInfor)
    familyRenmingMenu.m_DestInfor = DestInfor
	return MultiMenu.toggleShowHide(familyRenmingMenu)
end

function familyRenmingMenu:getButtonCount()
    --获得我的职务
    local myZhiwu =  require "logic.faction.factiondatamanager".GetMyZhiWu()
    --获得对方职务
    local destZhiwu = self.m_DestInfor.position
    --我的职务数据行
    local myRow =  BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(myZhiwu)
    --对方职务数据行
    local destRow =  BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(destZhiwu)
    --没有任命权限或对方不比自己职务低
    if myRow.renming == 0 or (destRow.poslevel <= myRow.poslevel) then
        return 0
    end

    --可以任命集合
    self.m_RenMingCollection = {}
    local len = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getSize()
    for i = 1, len do
        local conf =  BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(i) 
        if (conf and conf.poslevel > myRow.poslevel and conf.id ~= destRow.id) or (myRow.id == 1 and conf.id == 1) then
            if self:IsSucecced(myRow.id, conf.id) then
                table.insert(self.m_RenMingCollection, conf.id)
            end
        end
    end
    
    self.m_Lenth = #(self.m_RenMingCollection)
    self:setCloseCallBack(self.CloseCallback, self)
	return self.m_Lenth
end

-- 是否可以任命（排除不能任命的情况）
function familyRenmingMenu:IsSucecced(MyPosition , DestPosition)
    -- 第一军团长的不可任命集合
    local One = {8,9,10}
    -- 第二军团长的不可任命集合
    local Two = {7,9,10}
    -- 第三军团长的不可任命集合
    local Three = {7,8,10}
    -- 第四军团长的不可任命集合
    local Four = {7,8,9}

    -- key = 军团长职务ID , value = 军团长的不可任命集合
    local JunTuanZhang = 
    {
        [3] = One,
        [4] = Two,
        [5] = Three,
        [6] = Four
    }

    local infor = JunTuanZhang[MyPosition]
    if not infor then
        return true
    else
        for k,v in pairs(infor) do
            if DestPosition == v then
                return false
            end
        end
        return true
    end
end

function familyRenmingMenu:setButtonTitles(buttons)
    if not self.m_RenMingCollection then
        return
    end
    local i = 1
    for _, v in pairs(self.m_RenMingCollection) do
        local conf =  BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(v)
        buttons[i]:setText(conf.posname)
        buttons[i]:setID(v)
        buttons[i]:subscribeEvent("Clicked", familyRenmingMenu.HandlerReMing, self)
        i = i+1
    end
end

--刷新位置
function familyRenmingMenu:RefreshPos(x,y)
    SetPositionOffset(self.window, x , y, 0, 0)
end

function familyRenmingMenu:CloseCallback(target)
    if Familycaidan.getInstanceNotCreate() then
        Familycaidan.getInstanceNotCreate().IsCanClose = true
        Familycaidan.DestroyDialog()
    end
end

--任命按钮点击回调
function familyRenmingMenu:HandlerReMing(args)
	local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()
    self.m_SendID = id
    if self.m_SendID == 1 then
        --任命会长需要二级确认菜单
        local strContent = MHSD_UTILS.get_msgtipstring(150139) 
        if strContent then
            MessageBoxSimple.show(strContent, familyRenmingMenu.RemingCallback, self, nil, nil, nil, nil)
        end    
    else
        local p = require "protodef.fire.pb.clan.cchangeposition":new()
        p.memberroleid = self.m_DestInfor.roleid
        p.position = self.m_SendID
        require "manager.luaprotocolmanager":send(p)
    end

end

--任命确认
function familyRenmingMenu:RemingCallback(args)
    local p = require "protodef.fire.pb.clan.cchangeposition":new()
    p.memberroleid = self.m_DestInfor.roleid
    p.position = self.m_SendID
    require "manager.luaprotocolmanager":send(p)
end
