-- 公会升级界面

require "logic.dialog"
require "logic.family.familyshengjidialogcell"

familybuilddialog = { }
setmetatable(familybuilddialog, Dialog)
familybuilddialog.__index = familybuilddialog

local _instance
function familybuilddialog.getInstance()
    if not _instance then
        _instance = familybuilddialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function familybuilddialog.getInstanceAndShow()
    if not _instance then
        _instance = familybuilddialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function familybuilddialog.getInstanceNotCreate()
    return _instance
end

function familybuilddialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, familybuilddialog)
    return self
end

function familybuilddialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
            if Family.getInstanceNotCreate() then
                Family.getInstanceNotCreate():RefreshFamilyInfor()
                Family.getInstanceNotCreate():RefreshFamilyManager()
            end
        else
            _instance:ToggleOpenClose()
        end
    end
end

function familybuilddialog.ToggleOpenClose()
    if not _instance then
        _instance = familybuilddialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function familybuilddialog.GetLayoutFileName()
    return "familyshengjidialog.layout"
end

function familybuilddialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.data = require "logic.faction.factiondatamanager"
    self.factionLevel = self.data.factionlevel  -- 公会等级
    self.bankLevel = self.data.house[2]         -- 金库等级
    self.dragLevel = self.data.house[3]         -- 药房等级
    self.hotelLevel = self.data.house[4]        -- 旅店等级

    -- 房间标题
    self.m_TitleText = winMgr:getWindow("familyshengjidialog/level")

    -- 效果
    self.m_HelpText = CEGUI.toRichEditbox(winMgr:getWindow("familyshengjidialog/diban/text"))
    self.m_HelpText:getVertScrollbar():EnbalePanGuesture(false)

    -- 升级条件
    self.m_ConditionText = winMgr:getWindow("familyshengjidialog/tiaojian")

    -- 升级消耗
    self.levelUpCostBg = winMgr:getWindow("familyshengjidialog/xiaohao") 
    self.m_levelUpCostText = winMgr:getWindow("familyshengjidialog/xiaohao/dikuang/feiyong")

    -- 资金需求
    self.MaxNeedMoneyBg = winMgr:getWindow("familyshengjidialog/zijin")
    self.m_MaxNeedText = winMgr:getWindow("familyshengjidialog/xiaohao/dikuang/feiyong1")

    -- 拥有资金
    self.OwnedMoneyBg = winMgr:getWindow("familyshengjidialog/zijin2")
    self.m_OwnedMoneyText = winMgr:getWindow("familyshengjidialog/xiaohao/dikuang/feiyong12")

    -- 建筑列表
	self.m_list = winMgr:getWindow("familyshengjidialog/textbg/ss")
	
	
	-- 建筑图标
	self.c_icon = winMgr:getWindow("familyshengjidialog/icon")

    -- 升级按钮
    self.m_OkBtn = CEGUI.toPushButton(winMgr:getWindow("familyshengjidialog/shengji"))
    self.m_OkBtn:subscribeEvent("Clicked", familybuilddialog.OkBtnClicked, self)

    -- 关闭界面
	self.cc_btnClose = CEGUI.toPushButton(winMgr:getWindow("familyshengjidialog/close"))
    self.cc_btnClose:subscribeEvent("Clicked", familybuilddialog.btnCloseCallBack, self)
	
	
    -- 刷新建筑列表
    self:RefreshListView()
	


    -- 升级进度条
    --self.moneyBar = CEGUI.toProgressBar(winMgr:getWindow("familyshengjidialog/zijin/jindutiao"))
    --self.moneyText = winMgr:getWindow("familyshengjidialog/zijin/jindutiao/jindu")
end

-- 刷新建筑列表
function familybuilddialog:RefreshListView()
    local listSize = self.m_list:getPixelSize()
    if not self.m_ListEntrys then
        self.m_ListEntrys = TableView.create(self.m_list)
        self.m_ListEntrys:setViewSize(listSize.width, listSize.height)
        self.m_ListEntrys:setPosition(-1, 0)

        self.m_ListEntrys:setColumCount(4)
        self.m_ListEntrys:setDataSourceFunc(self, familybuilddialog.tableViewGetCellAtIndex)
    end

    local len = 4
    self.m_ListEntrys:setCellCountAndSize(len, 880, 680)
    self.m_ListEntrys:reloadData()

    -- 当前选中第一个建筑
    self.m_ListEntrys.visibleCells[0].m_Btn:setSelected(true)
end

-- 设置单个建筑信息
function familybuilddialog:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end

    if not cell then
        cell = FamilyShengjiDialogCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
    end
    if idx < 4 then
        local page = idx + 1
        local imageSet = self:GetImageSet(page)
        local name = self:GetName(page)
        local level = self:GetLevel(page)
        cell:SetBuildInfo(imageSet, name, level)
        cell.m_Btn:subscribeEvent("SelectStateChanged", familybuilddialog.OnCellSelectStateChanged, self)
        cell.m_Btn:setID(page)
    end

    return cell
end

-- 获取建筑图片
function familybuilddialog:GetImageSet(page)
    if page == 1 then
        return "set:family image:family_dating"
    elseif page == 2 then
        return "set:family image:family_jinku"
    elseif page == 3 then
        return "set:family image:family_yaofang"
    elseif page == 4 then
        return "set:family image:family_lvguan"
    else
        return ""
    end
end


-- 获取建筑名称
function familybuilddialog:GetName(page)
    if page == 1 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(7851).msg
    elseif page == 2 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(7852).msg
    elseif page == 3 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(7853).msg
    elseif page == 4 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(7854).msg
    else
        return ""
    end
end

-- 获取建筑等级
function familybuilddialog:GetLevel(page)
    if page == 1 then
        return self.factionLevel
    elseif page == 2 then
        return self.bankLevel
    elseif page == 3 then
        return self.dragLevel
    elseif page == 4 then
        return self.hotelLevel
    else
        return 0
    end
end

-- 建筑选中状态发生变化的回调
function familybuilddialog:OnCellSelectStateChanged(args)
    local windowEventArgs = CEGUI.toWindowEventArgs(args)
    self.m_currectPage = windowEventArgs.window:getID()

    -- 刷新建筑的详细数据
    self:refreshData(self.m_currectPage)

    -- 获取当前选中建筑的图标标识
    local imageSet = self:GetImageSet(self.m_currectPage)

    -- 设置 self.c_icon 的图片
    self.c_icon:setProperty("Image", imageSet) 
end

-- 点击升级确认按钮
function familybuilddialog:OkBtnClicked(args)
    local p = require("protodef.fire.pb.clan.crequestclanlevelup"):new()
    p.id = self.m_currectPage
    print(p.id .. "name")
    LuaProtocolManager:send(p)
end

-- 刷新建筑列表信息
function familybuilddialog:RefreshListInfo()
    if not self.m_ListEntrys then
        return
    end
    for k, v in pairs(self.m_ListEntrys.visibleCells) do
        local page = v.m_Btn:getID()
        local imageSet = self:GetImageSet(page)
        local name = self:GetName(page)
        local level = self:GetLevel(page)
        v:SetBuildInfo(imageSet, name, level)
    end
end

-- 刷新建筑的详细数据
function familybuilddialog:refreshData(page)
    local houseLevel, levelupcost, maxneedmoney, maxLevel, titleText, helpText, conditionText = self:getPageData(page)

    -- 房间标题
    self.m_TitleText:setText(titleText)

    -- 效果
    self.m_HelpText:Clear()
    self.m_HelpText:AppendParseText(helpText)
    self.m_HelpText:Refresh()

    -- 升级条件
    self.m_ConditionText:setText(conditionText)

    -- 升级消耗
    local str = require("logic.workshop.workshopmanager").getNumStrWithThousand(levelupcost)
    self.m_levelUpCostText:setText(str)

    -- 资金需求
    str = require("logic.workshop.workshopmanager").getNumStrWithThousand(maxneedmoney)
    self.m_MaxNeedText:setText(str)

    -- 拥有资金
    str = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.data.money)
    self.m_OwnedMoneyText:setText(str)

    if self.data.money < levelupcost or self.data.money < maxneedmoney then
        self.m_OwnedMoneyText:setProperty("TextColours", "FFFF3333")
    else
        self.m_OwnedMoneyText:setProperty("TextColours", "FF15B211")
    end

    -- 公会
    if page == 1 then
        
        local otherBuildLevel = 0
        for k, v in pairs(self.data.house) do
            otherBuildLevel = otherBuildLevel + v
        end

        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactionlobby"):getRecorder(houseLevel)

        -- 升级条件
        if houseLevel >= maxLevel  then
            self.m_ConditionText:setProperty("TextColours", "ff8c5e2a")
        elseif info and otherBuildLevel < info.othersum then
            self.m_ConditionText:setProperty("TextColours", "FFFF3333")
        else
            self.m_ConditionText:setProperty("TextColours", "FF15B211")
        end

        -- 升级按钮
        if (info and otherBuildLevel < info.othersum) or self.data.money < levelupcost or self.data.money < maxneedmoney then
            self.m_OkBtn:setEnabled(false)
        else
            self.m_OkBtn:setEnabled(true)
        end
    
    -- 其他建筑
    else

        -- 升级条件
        if houseLevel >= maxLevel  then
            self.m_ConditionText:setProperty("TextColours", "ff8c5e2a")
        elseif self.factionLevel <= houseLevel then
            self.m_ConditionText:setProperty("TextColours", "FFFF3333")
        else
            self.m_ConditionText:setProperty("TextColours", "FF06CC11")
        end

        -- 升级按钮
        if self.factionLevel <= houseLevel or self.data.money < levelupcost or self.data.money < maxneedmoney then
            self.m_OkBtn:setEnabled(false)
        else
            self.m_OkBtn:setEnabled(true)
        end

    end

    if houseLevel >= maxLevel  then
        self.levelUpCostBg:setVisible(false)
        self.MaxNeedMoneyBg:setVisible(false)
        self.OwnedMoneyBg:setVisible(false)
        self.m_OkBtn:setVisible(false)
    else
        self.MaxNeedMoneyBg:setVisible(true)
        self.levelUpCostBg:setVisible(true)
        self.OwnedMoneyBg:setVisible(true)
        self.m_OkBtn:setVisible(true)
    end
end

function familybuilddialog:getPageData(page)
    local houseLevel = 0
    local levelupcost = 0
    local maxneedmoney = self.data.costmax[page]
    local maxLevel = 0
    local titleText = ""
    local helpText = ""
    local conditionText = ""

    if page == 1 then
        houseLevel = self.factionLevel
    elseif page == 2 then
        houseLevel = self.bankLevel
    elseif page == 3 then
        houseLevel = self.dragLevel
    elseif page == 4 then
        houseLevel = self.hotelLevel
    end

    -- 公会
    if page == 1 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactionlobby"):getSize()
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11239))
       
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactionlobby"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11243).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(info.othersum))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11238).msg)
                strbuilder1:delete()
            end
        end

    -- 金库
    elseif page == 2 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getSize() - 1
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11240))
        
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11244).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(houseLevel + 1))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11247).msg)
                strbuilder1:delete()
            end
        end
    
    -- 药房
    elseif page == 3 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactiondrugstore"):getSize() - 1
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11241))
        
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiondrugstore"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11245).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(houseLevel + 1))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11247).msg)
                strbuilder1:delete()
            end
        end
    
    -- 旅馆
    elseif page == 4 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getSize() - 1
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11242))
        
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11246).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(houseLevel + 1))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11247).msg)
                strbuilder1:delete()
            end
        end

    end

    return houseLevel, levelupcost, maxneedmoney, maxLevel, titleText, helpText, conditionText
end

-- 处理刷新当前建筑的详细数据
function familybuilddialog.processRefreshData()
    if _instance then
        _instance.factionLevel = _instance.data.factionlevel
        _instance.bankLevel = _instance.data.house[2]
        _instance.dragLevel = _instance.data.house[3]
        _instance.hotelLevel = _instance.data.house[4]
        _instance:refreshData(_instance.m_currectPage)
        _instance:RefreshListInfo()
    end
end

function familybuilddialog:btnCloseCallBack(args)-- 关闭界面
    familybuilddialog.DestroyDialog()
end

return familybuilddialog
