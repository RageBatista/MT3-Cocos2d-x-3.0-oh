require "logic.dialog"
require "logic.family.familyyaoqingcommon"
require "logic.family.familyyaoqingdiacell"
require "logic.family.familyyaoqingshaixuan"

FamilyYaoQingDialog = {}
setmetatable(FamilyYaoQingDialog, Dialog)
FamilyYaoQingDialog.__index = FamilyYaoQingDialog

local _instance
function FamilyYaoQingDialog.getInstance()
	if not _instance then
		_instance = FamilyYaoQingDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyYaoQingDialog.getInstanceAndShow()
	if not _instance then
		_instance = FamilyYaoQingDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyYaoQingDialog.getInstanceNotCreate()
	return _instance
end

function FamilyYaoQingDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyYaoQingDialog.ToggleOpenClose()
	if not _instance then
		_instance = FamilyYaoQingDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyYaoQingDialog.GetLayoutFileName()
	return "familyyaoqing.layout"
end

function FamilyYaoQingDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyYaoQingDialog)
	return self
end

function FamilyYaoQingDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    -- 当前的排序方式
    self.m_SortMode = eSort_None

    -- 邀请列表
    self.m_List = CEGUI.toMultiColumnList(winMgr:getWindow("familyyaoqing/familyyaoqingMember"))

    -- 玩家名称相关
	self.m_Title_PlayerName = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/gonghuichengyuan")
    self.m_Title_PlayerName:subscribeEvent("MouseButtonDown", FamilyYaoQingDialog.Sort_Name, self)
	self.m_PlayerName_Up = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/gonghuichengyuan/up")
	self.m_PlayerName_Down = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/gonghuichengyuan/down")
    self.m_Sort_Name_Type = SORT_UP -- 排序类型初始化：升序

    -- 玩家性别相关
	self.m_Title_PlayerSex = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/lev")
    self.m_Title_PlayerSex:subscribeEvent("MouseButtonDown", FamilyYaoQingDialog.Sort_Sex, self)
	self.m_PlayerSex_Up = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/lev/up")
	self.m_PlayerSex_Down = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/lev/down")
    self.m_Sort_Sex_Type = SORT_DOWN -- 排序类型初始化：降序

    -- 玩家等级相关
	self.m_Title_PlayerLevel = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/zhiye")
    self.m_Title_PlayerLevel:subscribeEvent("MouseButtonDown", FamilyYaoQingDialog.Sort_Level, self)
	self.m_PlayerLevel_Up = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/zhiye/up")
	self.m_PlayerLevel_Down = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/zhiye/down")
    self.m_Sort_Level_Type = SORT_DOWN -- 排序类型初始化：降序

    -- 玩家职业相关
	self.m_Title_PlayerZhiYe = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/zhiwu")
    self.m_Title_PlayerZhiYe:subscribeEvent("MouseButtonDown", FamilyYaoQingDialog.Sort_ZhiYe, self)
	self.m_PlayerZhiYe_Up = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/zhiwu/up")
	self.m_PlayerZhiYe_Down = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/zhiwu/down")
    self.m_Sort_ZhiYe_Type = SORT_UP -- 排序类型初始化：升序

    -- 玩家综合战力相关
	self.m_Title_PlayerPingJia = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/benzhougongxian")
    self.m_Title_PlayerPingJia:subscribeEvent("MouseButtonDown", FamilyYaoQingDialog.Sort_PingJia, self)
	self.m_PlayerPingJia_Up = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/benzhougongxian/up")
	self.m_PlayerPingJia_Down = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/benzhougongxian/down")
    self.m_Sort_PingJia_Type = SORT_DOWN -- 排序类型初始化：降序

    -- 玩家VIP相关
	self.m_Title_PlayerVip = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/xianyougongxian")
    self.m_Title_PlayerVip:subscribeEvent("MouseButtonDown", FamilyYaoQingDialog.Sort_Vip, self)
	self.m_PlayerVip_Up = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/xianyougongxian/up")
	self.m_PlayerVip_Down = winMgr:getWindow("familyyaoqing/familyyaoqingMember/biaoti/xianyougongxian/down")
    self.m_Sort_Vip_Type = SORT_DOWN -- 排序类型初始化：降序

    -- 个人空间相关
	self.m_Btn_Space = CEGUI.toPushButton(winMgr:getWindow("familyyaoqing/leave3"))
	self.m_Btn_Space:subscribeEvent("Clicked", FamilyYaoQingDialog.onSpaceBtnClicked, self)
	self.m_PlayerName = winMgr:getWindow("wanjiamingzi")
	self.m_SpriteFrame = winMgr:getWindow("familyyaoqing/renwumoxing")

    -- 邀请加入
	self.m_Btn_YaoQing = CEGUI.toPushButton(winMgr:getWindow("familyyaoqing/leave"))
	self.m_Btn_YaoQing:subscribeEvent("Clicked", FamilyYaoQingDialog.onYaoQingBtnClicked, self)

    -- 联系玩家
	self.m_Btn_Connect = CEGUI.toPushButton(winMgr:getWindow("familyyaoqing/qunfaxiaoxi"))
	self.m_Btn_Connect:subscribeEvent("Clicked", FamilyYaoQingDialog.onConnectBtnClicked, self)

    -- 筛选
	self.m_Btn_ShaiXuan = CEGUI.toPushButton(winMgr:getWindow("familyyaoqing/jiemianshuoming"))
	self.m_Btn_ShaiXuan:subscribeEvent("Clicked", FamilyYaoQingDialog.onShaiXuanBtnClicked, self)

    -- 换一批
	self.m_Btn_Refresh = CEGUI.toPushButton(winMgr:getWindow("familyyaoqing/gonghuiliebiao"))
	self.m_Btn_Refresh:subscribeEvent("Clicked", FamilyYaoQingDialog.onRefreshBtnClicked, self)

    -- 搜索相关
	self.m_Input_Search = CEGUI.toRichEditbox(winMgr:getWindow("familyyaoqing/sousuolan"))
    self.m_Input_Search:setMaxTextLength(15)
	self.m_Btn_Search = CEGUI.toPushButton(winMgr:getWindow("familyyaoqing/sousuo"))
	self.m_Btn_Search:subscribeEvent("Clicked", FamilyYaoQingDialog.onSearchBtnClicked, self)

    -- 默认为不可见的控件
    self.m_Btn_Space:setVisible(false)
    self.m_PlayerName:setVisible(false)
    self.m_SpriteFrame:setVisible(false)
	self.m_PlayerName_Up:setVisible(false)
	self.m_PlayerName_Down:setVisible(false)
 	self.m_PlayerSex_Up:setVisible(false)
	self.m_PlayerSex_Down:setVisible(false)
	self.m_PlayerLevel_Up:setVisible(false)
	self.m_PlayerLevel_Down:setVisible(false)
	self.m_PlayerZhiYe_Up:setVisible(false)
	self.m_PlayerZhiYe_Down:setVisible(false)
	self.m_PlayerPingJia_Up:setVisible(false)
	self.m_PlayerPingJia_Down:setVisible(false)
	self.m_PlayerVip_Up:setVisible(false)
	self.m_PlayerVip_Down:setVisible(false)

    -- 请求邀请列表
    FamilyYaoQingCommon.RequestYaoQingList()

    -- 选中的列表项索引
    self.m_SelectedEntryIndex = -1
end

-------------------------------------------------------------------------------------------------------

-- 初始化显示邀请列表
function FamilyYaoQingDialog:InitListView()
    self.m_Btn_Space:setVisible(false)
    self.m_PlayerName:setVisible(false)
    self.m_SpriteFrame:setVisible(false)

    if self.m_SortMode == eSort_None then
        self:Sort_Name()
    elseif self.m_SortMode == eSort_Name then
        self:Sort_Name()
    elseif sortMode == eSort_Sex then
        self:Sort_Sex()
    elseif sortMode == eSort_Level then
        self:Sort_Level()
    elseif sortMode == eSort_ZhiYe then
        self:Sort_ZhiYe()
    elseif sortMode == eSort_PingJia then
        self:Sort_PingJia()
    elseif sortMode == eSort_Vip then
        self:Sort_Vip()
    end
    self:RefreshUserShow(0)
    --self:RefreshYaoQingListView()
end

-- 刷新邀请列表
function FamilyYaoQingDialog:RefreshYaoQingListView()
    if not self.m_ListEntrys then
        local listSize = self.m_List:getPixelSize()
        self.m_ListEntrys = TableView.create(self.m_List)
        self.m_ListEntrys:setViewSize(listSize.width, listSize.height - 60)
        self.m_ListEntrys:setPosition(18, 55)
        self.m_ListEntrys:setDataSourceFunc(self, FamilyYaoQingDialog.tableViewGetCellAtIndex)
    end

    local len = #FamilyYaoQingCommon.m_YaoQingList
    self.m_ListEntrys:setCellCountAndSize(len, 730, 43)
    self.m_ListEntrys:reloadData()

    -- 当前选中第一项
    if len > 0 and self.m_ListEntrys.visibleCells[0] then
        self.m_ListEntrys.visibleCells[0].m_Btn:setSelected(true)
    end
end

-- 设置单个列表项的数据
function FamilyYaoQingDialog:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end

    if not cell then
        cell = FamilyYaoQingDiaCell.CreateNewDlg(tableView.container)
    end
    if #FamilyYaoQingCommon.m_YaoQingList > idx then
        cell:SetCellInfo(FamilyYaoQingCommon.m_YaoQingList[idx + 1])
        cell.m_Btn:subscribeEvent("SelectStateChanged", FamilyYaoQingDialog.OnCellSelectStateChanged, self)
        cell.m_Btn:setID(idx + 1)
        if idx % 2 == 1 then
            cell.m_Btn:SetStateImageExtendID(1)
        else
            cell.m_Btn:SetStateImageExtendID(0)
        end
    end
    return cell
end

-- 列表项选中状态发生变化的回调
function FamilyYaoQingDialog:OnCellSelectStateChanged(args)
    local windowEventArgs = CEGUI.toWindowEventArgs(args)
    self.m_SelectedEntryIndex = windowEventArgs.window:getID() -1

    -- 刷新玩家显示
    self:RefreshUserShow(self.m_SelectedEntryIndex)
end

-- 刷新玩家显示
function FamilyYaoQingDialog:RefreshUserShow(idx)
    if #FamilyYaoQingCommon.m_YaoQingList > idx then
        local userInfo = FamilyYaoQingCommon.m_YaoQingList[idx + 1]
        if userInfo then
            self.m_Btn_Space:setVisible(flase)
            self.m_PlayerName:setVisible(true)
            self.m_SpriteFrame:setVisible(true)

            self.m_PlayerName:setText(userInfo.rolename)

		    local s = self.m_SpriteFrame:getPixelSize()
		    local sprite = gGetGameUIManager():AddWindowSprite(self.m_SpriteFrame, userInfo.shape, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, true)
		    sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
		    sprite:PlayAction(eActionStand)
            --染色
            for i, v in pairs(userInfo.components) do
                if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			        and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
                    sprite:SetSpriteComponent(i, v)
                elseif 50 <= i and i <= 59 then
                    sprite:SetDyePartIndex(i-50,v)
                elseif i == eSprite_Weapon then
                    sprite:UpdateWeaponColorParticle(v)      
                end
            end
            
            --武器
            if userInfo.components[1] then

                sprite:SetSpriteComponent(eSprite_Weapon, userInfo.components[1])
            end

            --装备特效
            if userInfo.components[60] then
                self:checkEquipEffect(sprite, userInfo.components[60])
            end
        end
    end
end
function FamilyYaoQingDialog:checkEquipEffect(roleSprite, quality)
    if quality ~= 0 then
        local record = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
        if record.effectId ~= 0 then
            roleSprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(record.effectId), false);
        end
    end
end
-------------------------------------------------------------------------------------------------------

-- 重置排序箭头为不可见
function FamilyYaoQingDialog:ResetSortArrow()
    self.m_PlayerName_Up:setVisible(false)
    self.m_PlayerName_Down:setVisible(false)
    self.m_PlayerSex_Up:setVisible(false)
    self.m_PlayerSex_Down:setVisible(false)
    self.m_PlayerLevel_Up:setVisible(false)
    self.m_PlayerLevel_Down:setVisible(false)
    self.m_PlayerZhiYe_Up:setVisible(false)
    self.m_PlayerZhiYe_Down:setVisible(false)
    self.m_PlayerPingJia_Up:setVisible(false)
    self.m_PlayerPingJia_Down:setVisible(false)
    self.m_PlayerVip_Up:setVisible(false)
    self.m_PlayerVip_Down:setVisible(false)
end

-- 根据排序方式设置排序类型和箭头显示
-- bDiffMode true = 该变量排序方式 false = 未改变排序方式
function FamilyYaoQingDialog:SetSortTypeAndArrow(sortMode, bDiffMode)
    if sortMode == eSort_Name then
        if not bDiffMode then
            if self.m_Sort_Name_Type == SORT_UP then
                self.m_Sort_Name_Type = SORT_DOWN
            elseif self.m_Sort_Name_Type == SORT_DOWN then
                self.m_Sort_Name_Type = SORT_UP
            end
        end
        self.m_PlayerName_Up:setVisible(self.m_Sort_Name_Type == SORT_UP)
        self.m_PlayerName_Down:setVisible(self.m_Sort_Name_Type == SORT_DOWN)
    elseif sortMode == eSort_Sex then
        if not bDiffMode then
            if self.m_Sort_Sex_Type == SORT_UP then
                self.m_Sort_Sex_Type = SORT_DOWN
            elseif self.m_Sort_Sex_Type == SORT_DOWN then
                self.m_Sort_Sex_Type = SORT_UP
            end
        end
        self.m_PlayerSex_Up:setVisible(self.m_Sort_Sex_Type == SORT_UP)
        self.m_PlayerSex_Down:setVisible(self.m_Sort_Sex_Type == SORT_DOWN)
    elseif sortMode == eSort_Level then
        if not bDiffMode then
            if self.m_Sort_Level_Type == SORT_UP then
                self.m_Sort_Level_Type = SORT_DOWN
            elseif self.m_Sort_Level_Type == SORT_DOWN then
                self.m_Sort_Level_Type = SORT_UP
            end
        end
        self.m_PlayerLevel_Up:setVisible(self.m_Sort_Level_Type == SORT_UP)
        self.m_PlayerLevel_Down:setVisible(self.m_Sort_Level_Type == SORT_DOWN)
    elseif sortMode == eSort_ZhiYe then
        if not bDiffMode then
            if self.m_Sort_ZhiYe_Type == SORT_UP then
                self.m_Sort_ZhiYe_Type = SORT_DOWN
            elseif self.m_Sort_ZhiYe_Type == SORT_DOWN then
                self.m_Sort_ZhiYe_Type = SORT_UP
            end
        end
        self.m_PlayerZhiYe_Up:setVisible(self.m_Sort_ZhiYe_Type == SORT_UP)
        self.m_PlayerZhiYe_Down:setVisible(self.m_Sort_ZhiYe_Type == SORT_DOWN)
    elseif sortMode == eSort_PingJia then
        if not bDiffMode then
            if self.m_Sort_PingJia_Type == SORT_UP then
                self.m_Sort_PingJia_Type = SORT_DOWN
            elseif self.m_Sort_PingJia_Type == SORT_DOWN then
                self.m_Sort_PingJia_Type = SORT_UP
            end
        end
        self.m_PlayerPingJia_Up:setVisible(self.m_Sort_PingJia_Type == SORT_UP)
        self.m_PlayerPingJia_Down:setVisible(self.m_Sort_PingJia_Type == SORT_DOWN)
    elseif sortMode == eSort_Vip then
        if not bDiffMode then
            if self.m_Sort_Vip_Type == SORT_UP then
                self.m_Sort_Vip_Type = SORT_DOWN
            elseif self.m_Sort_Vip_Type == SORT_DOWN then
                self.m_Sort_Vip_Type = SORT_UP
            end
        end
        self.m_PlayerVip_Up:setVisible(self.m_Sort_Vip_Type == SORT_UP)
        self.m_PlayerVip_Down:setVisible(self.m_Sort_Vip_Type == SORT_DOWN)
    end
end

-- 处理排序相关
function FamilyYaoQingDialog:doWithSortMode(sortMode)
    self:ResetSortArrow()
    self:SetSortTypeAndArrow(sortMode, self.m_SortMode ~= sortMode)
    self.m_SortMode = sortMode
end

-- 点击玩家名称排序
function FamilyYaoQingDialog:Sort_Name(args)
    -- 处理排序相关
    self:doWithSortMode(eSort_Name)
    -- 按玩家名称的排序类型排序
    FamilyYaoQingCommon.Sort(eSort_Name, self.m_Sort_Name_Type)
    -- 刷新邀请列表
    self:RefreshYaoQingListView()
end

-- 点击玩家性别排序
function FamilyYaoQingDialog:Sort_Sex(args)
    -- 处理排序相关
    self:doWithSortMode(eSort_Sex)
    -- 按玩家性别的排序类型排序
    FamilyYaoQingCommon.Sort(eSort_Sex, self.m_Sort_Sex_Type)
    -- 刷新邀请列表
    self:RefreshYaoQingListView()
end

-- 点击玩家等级排序
function FamilyYaoQingDialog:Sort_Level(args)
    -- 处理排序相关
    self:doWithSortMode(eSort_Level)
    -- 按玩家等级的排序类型排序
    FamilyYaoQingCommon.Sort(eSort_Level, self.m_Sort_Level_Type)
    -- 刷新邀请列表
    self:RefreshYaoQingListView()
end

-- 点击玩家职业排序
function FamilyYaoQingDialog:Sort_ZhiYe(args)
    -- 处理排序相关
    self:doWithSortMode(eSort_ZhiYe)
    -- 按玩家职业的排序类型排序
    FamilyYaoQingCommon.Sort(eSort_ZhiYe, self.m_Sort_ZhiYe_Type)
    -- 刷新邀请列表
    self:RefreshYaoQingListView()
end

-- 点击玩家综合战力排序
function FamilyYaoQingDialog:Sort_PingJia(args)
    -- 处理排序相关
    self:doWithSortMode(eSort_PingJia)
    -- 按玩家综合战力的排序类型排序
    FamilyYaoQingCommon.Sort(eSort_PingJia, self.m_Sort_PingJia_Type)
    -- 刷新邀请列表
    self:RefreshYaoQingListView()
end

-- 点击玩家VIP排序
function FamilyYaoQingDialog:Sort_Vip(args)
    -- 处理排序相关
    self:doWithSortMode(eSort_Vip)
    -- 按玩家VIP的排序类型排序
    FamilyYaoQingCommon.Sort(eSort_Vip, self.m_Sort_Vip_Type)
    -- 刷新邀请列表
    self:RefreshYaoQingListView()
end

-------------------------------------------------------------------------------------------------------

-- 点击个人空间
function FamilyYaoQingDialog:onSpaceBtnClicked(args)
    local userInfo = FamilyYaoQingCommon.m_YaoQingList[self.m_SelectedEntryIndex + 1]
    if userInfo then
        -- todo
    end
end

-- 点击邀请加入
function FamilyYaoQingDialog:onYaoQingBtnClicked(args)
    local userInfo = FamilyYaoQingCommon.m_YaoQingList[self.m_SelectedEntryIndex + 1]
    if userInfo then
        local datamanager = require "logic.faction.factiondatamanager"
        local ret =  datamanager.GetApplyTimeCollectionEntry(userInfo.roleid)
        if ret and gGetGameUIManager() then
            GetCTipsManager():AddMessageTipById(160608)
            return
        end
        local p = require "protodef.fire.pb.clan.cclaninvitation":new()
        p.guestroleid = userInfo.roleid
        require "manager.luaprotocolmanager":send(p)
        datamanager.AddApplyTimeCollection(userInfo.roleid)
    end
end

-- 点击联系玩家
function FamilyYaoQingDialog:onConnectBtnClicked(args)
    local userInfo = FamilyYaoQingCommon.m_YaoQingList[self.m_SelectedEntryIndex + 1]
    if userInfo then
        local cell = self.m_ListEntrys:getCellAtIdx(self.m_SelectedEntryIndex)
        if cell then
            if gGetFriendsManager() then
                gGetFriendsManager():RequestSetChatRoleID(userInfo.roleid)
                Family.DestroyDialog(true)
                FamilyYaoQingDialog.DestroyDialog()
            end
        end
    end
end

-- 点击筛选
function FamilyYaoQingDialog:onShaiXuanBtnClicked(args)
    local dlg = FamilyYaoQingShaiXuan.getInstanceAndShow()
    FamilyYaoQingCommon.ResetTmpShaiXuan()
    dlg:RefreshYaoQingUI()
end

-- 点击换一批
function FamilyYaoQingDialog:onRefreshBtnClicked(args)
    -- 请求邀请列表
    FamilyYaoQingCommon.RequestYaoQingList()
end

-- 点击搜索
function FamilyYaoQingDialog:onSearchBtnClicked(args)
	local text = self.m_Input_Search:GetPureText()
	local len = string.len(text)
	if len == 0 then
		GetCTipsManager():AddMessageTipById(145344)
		return
	end

	-- 发送公会邀请的搜索玩家请求
    local p = require "protodef.fire.pb.clan.crequestsearchrole":new()
	p.roleid = text
	LuaProtocolManager.getInstance():send(p)
end

-------------------------------------------------------------------------------------------------------

return FamilyYaoQingDialog