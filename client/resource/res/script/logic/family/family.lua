require "logic.dialog"
require "logic.family.familyxinxidiacell"
require "logic.family.familylabelframe"
require "logic.family.familycaidan"
require "logic.family.familyjiarudialog"
require "logic.family.familygaimingdialog"
require "logic.family.familyBuildDialog"
require "logic.family.familyzongzhidialog"
require "logic.family.familygaiming1dialog"

Family = { }
setmetatable(Family, Dialog)
Family.__index = Family

local _instance
function Family.getInstance()
    if not _instance then
        _instance = Family:new()
        _instance:OnCreate()
    end
    return _instance
end

function Family.getInstanceAndShow()
    if not _instance then
        _instance = Family:new()
        _instance:OnCreate()
    else
        _instance:RefreshShow()
        _instance:SetVisible(true)
    end
    return _instance
end

function Family.getInstanceNotCreate()
    return _instance
end

function Family.DestroyDialog(IsDestroyPage)
    if IsDestroyPage == nil then
        IsDestroyPage = true
    end
    if IsDestroyPage then
        if Familylabelframe.getInstanceNotCreate() then
            Familylabelframe.getInstanceNotCreate().DestroyDialog()
        end
    end
    if Familygaimingdialog.getInstanceNotCreate() then
        Familygaimingdialog.DestroyDialog()
    end
    -- 关闭本dialog
    if IsDestroyPage == nil then
        IsDestroyPage = true
    end
    if _instance then
	_instance.m_UpgradeBuildBtn.animation:stop()
	_instance.m_GoBackFamilyBtn.animation:stop()
	_instance.m_ChangedIdeaBtn.animation:stop()
	_instance.m_FamilyInforBtn.animation:stop()
	_instance.m_FamilyMoneyBtn.animation:stop()
        if not _instance.m_bCloseIsHide then
            -- 关闭tableview
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Family.ToggleOpenClose()
    if not _instance then
        _instance = Family:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Family.GetLayoutFileName()
    return "family.layout"
end

function Family:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Family)
    return self
end
-- 刷新显示
function Family:RefreshShow()
    -- 获得我的工会信息
    self.m_FactionData = require "logic.faction.factiondatamanager"
    self:ReFreshFamilyListView()
    self:RefreshOnlineMemberText(tostring(self.m_FactionData.GetOnlinePerson()))
end

function Family:addButtonAnimation(button, animationName)
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

function Family:OnCreate()
    Dialog.OnCreate(self)
    -- 获得我的工会信息
    self.m_FactionData = require "logic.faction.factiondatamanager"
    local winMgr = CEGUI.WindowManager:getSingleton()

    ----------------------------------------------------------------------------初始化成员在此处下方
    self.m_CurSort = 0
    self.m_LastSort = -1
    self.m_Sort1Type = 1
    -- 1 升序 -1 降序 0 重置
    self.m_Sort2Type = 1
    self.m_Sort3Type = 1
    self.m_Sort4Type = 1

    self.m_Process = CEGUI.toProgressBar(winMgr:getWindow("Family/Back3/zijindikuang"))

    -- 获得我的工会主旨文本
    self.m_IdeaText = CEGUI.toRichEditbox(winMgr:getWindow("Family/FamilyPurpose"))
	self.m_IdeaText:SetForceHideVerscroll(true)
    self.m_TitleName = winMgr:getWindow("Family/Back2/biaoti/zaixianchengyuan")
    self.m_NameUp = winMgr:getWindow("Family/Back2/biaoti/zaixianchengyuan/up")
    self.m_NameDown = winMgr:getWindow("Family/Back2/biaoti/zaixianchengyuan/down")
	self.GoldText = winMgr:getWindow("Family/gonghuizijin")
    self.m_TitleName:subscribeEvent("MouseButtonDown", Family.Sort1, self)
     
    self.m_TitleLevel = winMgr:getWindow("Family/Back2/biaoti/lev")
    self.m_TitleLevelUp = winMgr:getWindow("Family/Back2/biaoti/lev/up")
    self.m_TitleLevelDown = winMgr:getWindow("Family/Back2/biaoti/lev/down")
    self.m_TitleLevel:subscribeEvent("MouseButtonDown", Family.Sort2, self)

    self.m_ZhiYeTitle = winMgr:getWindow("Family/Back2/biaoti/zhiye")
    self.m_ZhiYeTitleUp = winMgr:getWindow("Family/Back2/biaoti/zhiye/up")
    self.m_ZhiYeTitleDown = winMgr:getWindow("Family/Back2/biaoti/zhiye/down")
    self.m_ZhiYeTitle:subscribeEvent("MouseButtonDown", Family.Sort3, self)
    
    self.m_TitleZhiWu = winMgr:getWindow("Family/Back2/biaoti/zhiwu")
    self.m_TitleZhiWuUp = winMgr:getWindow("Family/Back2/biaoti/zhiwu/up")
    self.m_TitleZhiWuDown = winMgr:getWindow("Family/Back2/biaoti/zhiwu/down")
    self.m_TitleZhiWu:subscribeEvent("MouseButtonDown", Family.Sort4, self)

    -- 帮派升级按钮
    self.m_UpgradeBuildBtn = CEGUI.toPushButton(winMgr:getWindow("Family/Back3/shengji"))
	self:addButtonAnimation(self.m_UpgradeBuildBtn, "studyBtnPress")
    self.m_UpgradeBuildBtn:subscribeEvent("Clicked", Family.UpgradeBuildBtnClicked, self)
    -- 返回帮派按钮
    self.m_GoBackFamilyBtn = CEGUI.toPushButton(winMgr:getWindow("Family/goback"))
	self:addButtonAnimation(self.m_GoBackFamilyBtn, "studyBtnPress")
    self.m_GoBackFamilyBtn:subscribeEvent("Clicked", Family.GoBackFamilyBtnClicked, self)
    -- 修改帮派宗旨按钮
    self.m_ChangedIdeaBtn = CEGUI.toPushButton(winMgr:getWindow("Family/change"))
	self:addButtonAnimation(self.m_ChangedIdeaBtn, "xstudyBtnPress")
	
    self.m_ChangedIdeaBtn:subscribeEvent("Clicked", Family.ChangedIdeaBtn, self)
    -- 在线人数文本
    self.m_OnineMemberText = winMgr:getWindow("Family/zaixianchengyuan/number")
    -- 改名信息按钮
    self.m_FamilyInforBtn = CEGUI.toPushButton(winMgr:getWindow("Family/Back1/text1"))
	self:addButtonAnimation(self.m_FamilyInforBtn, "xstudyBtnPress")
    self.m_FamilyInforBtn:subscribeEvent("Clicked", Family.FamilyInforBtnClicked, self)

--    -- 学徒tips按钮
--    self.m_XueTuTipsBtn = CEGUI.toPushButton(winMgr:getWindow("Family/Back1/text2"))
--    self.m_XueTuTipsBtn:subscribeEvent("Clicked", Family.XueTuTipsBtnClicked, self)

    -- 公会资金Tips按钮
    self.m_FamilyMoneyBtn = CEGUI.toPushButton(winMgr:getWindow("Family/Back3/text1"))
	self:addButtonAnimation(self.m_FamilyMoneyBtn, "xstudyBtnPress")
    self.m_FamilyMoneyBtn:subscribeEvent("Clicked", Family.FamilyMoneyBtnClicked, self)
    -- 公会分红Tips按钮
    self.m_FamilyFenHongBtn = CEGUI.toPushButton(winMgr:getWindow("Family/Back3/text2"))
    self.m_FamilyFenHongBtn:subscribeEvent("Clicked", Family.FamilyFenHongBtnClicked, self)
    -- 标签页
    -- 0 - 工会信息
    -- 1 - 工会管理
    self.m_Tab_0 = winMgr:getWindow("Family/Back1")
    self.m_Tab_1 = winMgr:getWindow("Family/Back3")
    -- 标签页
    self.m_TabButton_0 = CEGUI.toGroupButton(winMgr:getWindow("Family/gonghuixinxi"))
    self.m_TabButton_1 = CEGUI.toGroupButton(winMgr:getWindow("Family/gonghuiguanli"))
    self.m_TabButton_0:setID(1)
    self.m_TabButton_1:setID(2)
    self.m_TabButton_0:subscribeEvent("SelectStateChanged", Family.HandleSelectStateChanged, self)
    self.m_TabButton_1:subscribeEvent("SelectStateChanged", Family.HandleSelectStateChanged, self)



    -- 文本相关
    -- 公会管理相关文本
    self.m_GoldLevelText = winMgr:getWindow("Family/jinkulevel")        -- 金库等级
    self.m_DrugHouseLevelText = winMgr:getWindow("Family/yaofanglevel") -- 药房等级
    self.m_HoseLevelText = winMgr:getWindow("Family/lvguanlevel")       -- 旅馆等级
    self.GoldText = winMgr:getWindow("Family/gonghuizijin")             -- 公会资金
    self.m_RepairCostText = winMgr:getWindow("Family/gonghuiweihu")     -- 维护费用
    self.m_GiveMoneyText = CEGUI.toRichEditbox(winMgr:getWindow("Family/gonghuifenhong"))    -- 工资标准
    -- 公会信息相关文本
    self.m_FamilyNameText = winMgr:getWindow("Family/FamilyName")
--	self.m_FamilyName1Text = winMgr:getWindow("Family/FamilyName1")
    self.m_FamilyIDText = winMgr:getWindow("Family/FamilyID")
    self.m_FamilyLevelText = winMgr:getWindow("Family/FamilyLevel")
    self.m_PersonNumberText = winMgr:getWindow("Family/FamilyMemberNum")
    self.m_FamilyHostText = winMgr:getWindow("Family/FamilyManager")

    self.m_TabButton_0:setSelected(true)

    self.m_EntryCollection = CEGUI.toMultiColumnList(winMgr:getWindow("Family/FamilyMember"))

    self:RefreshShow()
    local datamanager = require "logic.faction.factiondatamanager"
    SetPositionOfWindowWithLabelbp(self:GetWindow())
end
function Family:ResetSortShow(CurSort)
    self.m_CurSort = CurSort
    if self.m_CurSort ~= self.m_LastSort then
        self.m_NameUp:setVisible(false)
        self.m_NameDown:setVisible(false)
        self.m_TitleLevelUp:setVisible(false)
        self.m_TitleLevelDown:setVisible(false)
        self.m_ZhiYeTitleUp:setVisible(false)
        self.m_ZhiYeTitleDown:setVisible(false)
        self.m_TitleZhiWuUp:setVisible(false)
        self.m_TitleZhiWuDown:setVisible(false)
    end
    self.m_LastSort = self.m_CurSort
end
-- 按职业排序
function Family:Sort4(args)
    self:ResetSortShow(4)
    self.m_Sort4Type = -1 * self.m_Sort4Type
    self.m_TitleZhiWuUp:setVisible(self.m_Sort4Type == 1)
    self.m_TitleZhiWuDown:setVisible(self.m_Sort4Type == -1)
    if self.m_Sort4Type == 0 then
        return
    end

    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByZhiWu(self.m_Sort4Type)
    self:ReFreshFamilyListView()
end
-- 按职业排序
function Family:Sort3(args)
    self:ResetSortShow(3)
    self.m_Sort3Type = -1 * self.m_Sort3Type
    self.m_ZhiYeTitleUp:setVisible(self.m_Sort3Type == 1)
    self.m_ZhiYeTitleDown:setVisible(self.m_Sort3Type == -1)
    if self.m_Sort3Type == 0 then
        return
    end

    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByZhiYe(self.m_Sort3Type)
    self:ReFreshFamilyListView()
end
-- 按level排序
function Family:Sort2(args)
    self:ResetSortShow(2)
    self.m_Sort2Type = -1 * self.m_Sort2Type
    self.m_TitleLevelUp:setVisible(self.m_Sort2Type == 1)
    self.m_TitleLevelDown:setVisible(self.m_Sort2Type == -1)
    if self.m_Sort2Type == 0 then
        return
    end

    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByLevel(self.m_Sort2Type)
    self:ReFreshFamilyListView()
end
-- 按名字排序
function Family:Sort1(args)
    self:ResetSortShow(1)
    self.m_Sort1Type = -1 * self.m_Sort1Type
    self.m_NameUp:setVisible(self.m_Sort1Type == 1)
    self.m_NameDown:setVisible(self.m_Sort1Type == -1)
    if self.m_Sort1Type == 0 then
        return
    end

    -- 刷新
    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.SortByID(self.m_Sort1Type)
    self:ReFreshFamilyListView()
end
-- 刷新职位
-- id 角色ID
-- pos 职务
function Family:RefreshPosition(id, pos)
    if not self.m_Entrys then
        return
    end
    if not self.m_Entrys.visibleCells then
        return
    end
    for _, v in pairs(self.m_Entrys.visibleCells) do
        if v.m_ID == id then
            local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(pos)
            if conf then
                v.m_ZhiWuText:setText(conf.posname)
            end
        end
    end
end
-- 刷新工会主旨
function Family:RefreshIdeaText()
    if self.m_IdeaText then
		self.m_IdeaText:Clear()
        self.m_IdeaText:AppendText(CEGUI.String(self.m_FactionData.factionaim), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff8c5e2a")))
		self.m_IdeaText:Refresh()
        self.m_IdeaText:HandleTop()
    end
end
-- 返回加入公会按钮
function Family:GoBackFamilyBtnClicked()
    if GetBattleManager():IsInBattle() then
        GetCTipsManager():AddMessageTipById(144879)
        self.DestroyDialog()
        return
    end
    local p = require "protodef.fire.pb.clan.centerclanmap":new()
    require "manager.luaprotocolmanager".getInstance():send(p)
    self.DestroyDialog()
end
-- 选择改变
function Family:HandleSelectStateChanged(args)
    self.m_Tab_0:setVisible(false)
    self.m_Tab_1:setVisible(false)
    local selectID = CEGUI.toWindowEventArgs(args).window:getID()
    if selectID == self.m_TabButton_0:getID() then
        self.m_Tab_0:setVisible(true)
        self:RefreshFamilyInfor()
    else
        self.m_Tab_1:setVisible(true)
        self:RefreshFamilyManager()
    end
end

-- 刷新公会管理
function Family:RefreshFamilyManager()
    self.m_GoldLevelText:setText(tostring(self.m_FactionData.house[2]))
    self.m_DrugHouseLevelText:setText(tostring(self.m_FactionData.house[3]))
    self.m_HoseLevelText:setText(tostring(self.m_FactionData.house[4]))


    local strNeedMoneyex = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.m_FactionData.money)
    self.GoldText:setText(strNeedMoneyex)

    local retLavel = 1
    local level = self.m_FactionData.factionlevel
    local level1 = self.m_FactionData.house[2]
    if level and level1 then
        retLavel = math.min(level, level1)
    end
    local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getRecorder(retLavel)
    if info then
        self.m_Process:setProgress(self.m_FactionData.money / info.limitmoney)
    end
    -- 维护费用
    local formatstr = MHSD_UTILS.get_resstring(11292)
    local strNeedMoney = 0
    if self.m_FactionData.costeverymoney then
        strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.m_FactionData.costeverymoney)
    end
    formatstr = string.gsub(formatstr, "%$parameter1%$", strNeedMoney)
    self.m_RepairCostText:setText(formatstr)

    -- 工资标准
    if info then
        local money = info.allbonus * 100 / 1000
        local strMsg = MHSD_UTILS.get_resstring(11558)
        local sb = StringBuilder:new()
        sb:SetNum("parameter1", money)
        strMsg = sb:GetString(strMsg)
        sb:delete()
        self.m_GiveMoneyText:Clear()
        self.m_GiveMoneyText:AppendParseText(CEGUI.String(strMsg))
        self.m_GiveMoneyText:Refresh()
    end
end

-- 刷新公会信息
function Family:RefreshFamilyInfor()
self.m_GoldLevelText:setText(tostring(self.m_FactionData.house[2]))
    self.m_DrugHouseLevelText:setText(tostring(self.m_FactionData.house[3]))
    self.m_HoseLevelText:setText(tostring(self.m_FactionData.house[4]))
    -- 获得我的工会信息
    if self.m_FactionData then
	    -- 标题帮派名字
	   -- self.m_FamilyName1Text:setText(self.m_FactionData.factionname)
        -- 刷新工会名字
        self.m_FamilyNameText:setText(self.m_FactionData.factionname)
		
        -- 刷新工会id
		local m_FamilyIDText_Prefix = require("utils.mhsdutils").get_resstring(7850) -- 编号前缀
        self.m_FamilyIDText:setText(m_FamilyIDText_Prefix .. self.m_FactionData.index) 

		
        -- 刷新工会等级
        self.m_FamilyLevelText:setText(self.m_FactionData.factionlevel)
        -- 刷新工会人数
        local len = #self.m_FactionData.members
        local text = string.format("%s/%s/%s", self.m_FactionData.GetOnlinePerson(), len, self.m_FactionData.GetMaxPersonNumber())
        self.m_PersonNumberText:setText(text)
		
		local strNeedMoneyex = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.m_FactionData.money)
    self.GoldText:setText(strNeedMoneyex)

    local retLavel = 1
    local level = self.m_FactionData.factionlevel
    local level1 = self.m_FactionData.house[2]
    if level and level1 then
        retLavel = math.min(level, level1)
    end
    local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getRecorder(retLavel)
    if info then
        self.m_Process:setProgress(self.m_FactionData.money / info.limitmoney)
    end
    -- 维护费用
    local formatstr = MHSD_UTILS.get_resstring(11292)
    local strNeedMoney = 0
    if self.m_FactionData.costeverymoney then
        strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.m_FactionData.costeverymoney)
    end
    formatstr = string.gsub(formatstr, "%$parameter1%$", strNeedMoney)
    self.m_RepairCostText:setText(formatstr)

    -- 工资标准
    if info then
        local money = info.allbonus * 100 / 1000
        local strMsg = MHSD_UTILS.get_resstring(11558)
        local sb = StringBuilder:new()
        sb:SetNum("parameter1", money)
        strMsg = sb:GetString(strMsg)
        sb:delete()
        self.m_GiveMoneyText:Clear()
        self.m_GiveMoneyText:AppendParseText(CEGUI.String(strMsg))
        self.m_GiveMoneyText:Refresh()
    end
		
		

        -- 刷新工会主旨
        self:RefreshIdeaText()
    end
end

-- 公会信息按钮回调
function Family:FamilyInforBtnClicked(args)
    -- 显示一级
    Familygaimingdialog.getInstanceAndShow()
end

-- 刷新在线人员文本
function Family:RefreshOnlineMemberText(args)
    self.m_OnineMemberText:setText(tostring(args))
end

---- 学徒tips按钮
--function Family:XueTuTipsBtnClicked(args)
--    local tips1 = require "logic.workshop.tips1"
--    local strTitle = MHSD_UTILS.get_resstring(11284)
--    local strContent = MHSD_UTILS.get_resstring(11175)
--    if tips1.getInstanceNotCreate() == nil then
--        local dlg = tips1.getInstanceAndShow(strContent, strTitle)
--        if dlg then
--            SetPositionScreenCenter(dlg:GetWindow())
--        end
--    else
--        -- 仅仅设置文本就可以了.
--        tips1.getInstanceNotCreate():RefreshData(strContent, strTitle)
--    end
--end

-- 公会资金Tips按钮
function Family:FamilyMoneyBtnClicked(args)
    local retLavel = 1
    local level = self.m_FactionData.factionlevel
    local level1 = self.m_FactionData.house[2]
    if level and level1 then
        retLavel = math.min(level, level1)
    end
    local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getRecorder(retLavel)
    if info then
        local str = MHSD_UTILS.get_resstring(11173)
        str = string.gsub(str, "%$parameter1%$", info.limitmoney / 10000)
        GetCTipsManager():AddMessageTip(str)
    end

end

-- 公会分红Tips按钮
function Family:FamilyFenHongBtnClicked(args)
    self.tips1 = require "logic.workshop.tips1"
    local strTitle = MHSD_UTILS.get_resstring(11283)
    local strContent = MHSD_UTILS.get_resstring(11174)
    self.tips1.getInstanceAndShow(strContent, strTitle)
end

-- 刷新公会成员列表(全部刷新)
function Family:ReFreshFamilyListView()

    if self.m_FactionData then
        self.m_OnLineCollection = self.m_FactionData.GetOnLineCollection()
        local len = #(self.m_OnLineCollection)
        -- 清空容器
        if self.m_Entrys then

        else
            local s = self.m_EntryCollection:getPixelSize()
            self.m_Entrys = TableView.create(self.m_EntryCollection)
            self.m_Entrys:setViewSize(620, 600)
            self.m_Entrys:setPosition(2, 50)
            self.m_Entrys:setDataSourceFunc(self, Family.tableViewGetCellAtIndex)
            self.m_Entrys:setContentOffset(0)
        end
        self.m_Entrys:setCellCountAndSize(len, 625, 50)

        -- 刷新工会现任会长
        local infor = self.m_FactionData.GetFamilyHost()
        if infor then
            self.m_FamilyHostText:setText(infor.rolename)
        end

    end
    self.m_Entrys:reloadData()
end

function Family:tableViewGetCellAtIndex(tableView, idx, cell)
    idx = idx + 1
    local SingleMember = self.m_OnLineCollection[idx]
    if not cell then
        if self.m_FactionData then
            cell = Familyxinxidiacell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
            cell.m_Btn:subscribeEvent("MouseButtonUp", Family.HandleCellClicked, self)
        end
    end
    cell.m_Btn:setGroupID(10)
    cell.m_Btn:setID(idx)
    if idx % 2 == 1 then
        cell.m_Btn:SetStateImageExtendID(1)
    else
        cell.m_Btn:SetStateImageExtendID(0)
    end
    cell:SetInfor(SingleMember)
    return cell
end
-- 点击公会成员弹出菜单
function Family:HandleCellClicked(args)
    local btn = CEGUI.toWindowEventArgs(args).window
    local id = btn:getID()
    -- 刷新选中状态
    for _, v in pairs(self.m_Entrys.visibleCells) do
        v.m_Btn:setSelected(false)
    end
    self.m_Entrys.visibleCells[id - 1].m_Btn:setSelected(true)
    self.SingleMember = self.m_OnLineCollection[id]
    local data = gGetDataManager():GetMainCharacterData()
    if self.SingleMember.roleid == data.roleid then
        return
    end
    -- 发送申请组队信息
    local send = require "protodef.fire.pb.team.crequesthaveteam":new()
    send.roleid = self.SingleMember.roleid
    require "manager.luaprotocolmanager":send(send)
end
-- 修改主旨按钮响应
function Family:ChangedIdeaBtn(args)

    if self.m_FactionData then
        local infor = self.m_FactionData.GetMyZhiWuInfor()
        if infor.changeidea == 0 and infor.id ~= -1 then
            local tips = MHSD_UTILS.get_msgtipstring(150127)
            GetCTipsManager():AddMessageTip(tips)
            return
        end
    end

    Familyzongzhidialog.getInstanceAndShow()
    if Familyzongzhidialog.getInstanceNotCreate() then
        Familyzongzhidialog.getInstanceNotCreate():SetText(self.m_FactionData.factionaim)
    end
end
-- 点击工会升级按钮
function Family:UpgradeBuildBtnClicked(args)
    familybuilddialog.getInstanceAndShow()
end

return Family
