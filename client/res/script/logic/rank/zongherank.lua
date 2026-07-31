require "logic.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "protodef.fire.pb.ranklist.crequestranklist"
require "protodef.rpcgen.fire.pb.ranklist.ranktype"
require "protodef.rpcgen.fire.pb.ranklist.flowerrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.rolezongherankrecord"
require "protodef.rpcgen.fire.pb.ranklist.rolerankrecord"
require "protodef.rpcgen.fire.pb.ranklist.petgraderankdata"


local FIRST_COLOR = "[colrect='tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751']"
ZongHeRank = { }
setmetatable(ZongHeRank, Dialog)
ZongHeRank.__index = ZongHeRank 
local _instance;
local typeEnum = RankType:new()  
function ZongHeRank.getInstance()
    LogInfo("enter ZongHeRank getInstance")
    if not _instance then
        _instance = ZongHeRank:new()
        _instance:OnCreate()
    end

    return _instance
end

function ZongHeRank.hide()
    if _instance then
        _instance:SetVisible(false)
    end
end

local getInstanceAndShowCallback = nil;

function ZongHeRank_AsyncLoadCallback(pWindow)
	if _instance then
		_instance.m_pMainFrame = pWindow;

		local bCloseIsHide = _instance.m_bCloseIsHide;
		_instance.m_bCloseIsHide = false;
		_instance:OnCreate();
		_instance.m_bCloseIsHide = bCloseIsHide;

		if getInstanceAndShowCallback then
			getInstanceAndShowCallback();
		end
	end
end

function ZongHeRank.getInstanceAndShow(cb)
    LogInfo("enter instance show")
    if not _instance then
        _instance = ZongHeRank:new()
        _instance:OnCreate()
    else
        LogInfo("set maincontrol visible")
        _instance:SetVisible(true)
    end

    return _instance
end

function ZongHeRank.getInstanceNotCreate()
    return _instance
end

function ZongHeRank:OnClose()
    Dialog.OnClose(self)
    _instance = nil
end

function ZongHeRank.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ZongHeRank.ToggleOpenClose()
    if not _instance then
        _instance = ZongHeRank:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ZongHeRank:processList(ranktype, myrank, list, page, hasmore, mytitle, takeAwardFlag, extdata, extdata1, extdata2, extdata3)
    self.m_iRankType = ranktype
    -- 为排行榜前八名的角色添加窗口精灵，精灵初始状态设置为透明
    gGetGameUIManager():AddWindowSprite(self.top1,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top2,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top3,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top4,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top5,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top6,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top7,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top8,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)

    -- 清空之前的排行榜数据，重置角色名称、角色等级的可见性，并为每个位置添加精灵
    for A = 1, 8 do
        self.rolename[A]:setText("")  -- 清空角色名称
        self.rolelv[A]:setVisible(false)  -- 隐藏角色等级
        local s1 = self.rolejuese[A]:getPixelSize()  -- 获取角色模型的尺寸
        -- 为角色模型添加精灵，并设置相对底部右边的偏移
        self.act[A] = gGetGameUIManager():AddWindowSprite(self.rolejuese[A], 0, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 65, true)
    end
    local showCount = math.min(#list, 8)
    if ranktype == 201 then
        for k = 1, showCount do
            local row = RoleZongheRankRecord:new()
            local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
            row:unmarshal(_os_)
            _os_:delete()
            local vipLevel = ""
            if row.viplevel then
                vipLevel = tostring(row.viplevel)
            end
            _instance:AddRow(
                row.Shape, row.color1, row.color2, row.components,
                row.rank - 1, row.roleid, tostring(row.rank), row.rolename,
                vipLevel, tostring(row.score)
            )
        end
    elseif ranktype == 202 then
        -- 人物榜必须使用 RoleRankRecord 反序列化；错用 RoleZongheRankRecord 会导致字段错位，
        -- 进而出现等级/战力显示错误、组件错读（武器/模型异常）等问题。
        for k = 1, showCount do
            local row = RoleRankRecord:new()
            local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
            row:unmarshal(_os_)
            _os_:delete()

            local level = row.level
            if level and level > 1000 then
                local zscs = math.modf(level / 1000)
                level = level - zscs * 1000
            end

            _instance:AddRow(
                row.shape, row.color1, row.color2, row.components,
                row.rank - 1, row.roleid, tostring(row.rank), row.rolename,
                "", tostring(level)
            )
        end
    else
        for k = 1, showCount do
            local row = PetGradeRankData:new()
            local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
            row:unmarshal(_os_)
            _os_:delete()
            _instance:AddRowx(
                row.Shape, row.colour, 0, 0,
                row.rank - 1, row.uniquepetid, tostring(row.rank),
                row.petname, row.nickname, tostring(row.petgrade)
            )
        end
    end
end


function ZongHeRank:FormatTime(time)
    if not time then
        return ""
    end
    local text = MHSD_UTILS.get_resstring(1239)
    if time == 0 then
        return  string.format(text, 0, 0)
    end
    if time < 1000 then
        return ""
    end
    local min = math.floor(time / 1000 / 60)
    local sec = time / 1000 - min * 60
    text = string.format(text, min, sec)
    return text
end



function ZongHeRank.TakeAwardSuccess(ranktype)
    LogInfo("ZongHeRank take award success")
    if _instance then
        if _instance.m_rankType == ranktype then
            _instance.m_pRewardBtn:setEnabled(false)
        end
    end
end

function ZongHeRank.GetLayoutFileName()
    return "zongherank.layout"
end

function ZongHeRank:OnCreate()
    LogInfo("enter ZongHeRank oncreate")
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    self.m_FontText = "simhei-12"
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.top1 = winMgr:getWindow("zongherank/top1/mode")
    self.top1name = winMgr:getWindow("zongherank/top1/name")

    self.top2 = winMgr:getWindow("zongherank/top2/mode")
    self.top2name = winMgr:getWindow("zongherank/top2/name")

    self.top3 = winMgr:getWindow("zongherank/top3/mode")
    self.top3name = winMgr:getWindow("zongherank/top3/name")

    self.top3 = winMgr:getWindow("zongherank/top3/mode")
    self.top3name = winMgr:getWindow("zongherank/top3/name")

    self.top4 = winMgr:getWindow("zongherank/top4/mode")
    self.top4name = winMgr:getWindow("zongherank/top4/name")

    self.top5 = winMgr:getWindow("zongherank/top5/mode")
    self.top5name = winMgr:getWindow("zongherank/top5/name")

    self.top6 = winMgr:getWindow("zongherank/top6/mode")
    self.top6name = winMgr:getWindow("zongherank/top6/name")

    self.top7 = winMgr:getWindow("zongherank/top7/mode")
    self.top7name = winMgr:getWindow("zongherank/top7/name")

    self.top8 = winMgr:getWindow("zongherank/top8/mode")
    self.top8name = winMgr:getWindow("zongherank/top8/name")
	
	--#11.10加
	self.mrt_bg1 = winMgr:getWindow("zongherank") --背景特效
	self.bgEffect = gGetGameUIManager():AddUIEffect(self.mrt_bg1, "spine/my_spine/minrentang", true)
    self.bgEffect:SetDefaultActName("animation2")--背景动画
	
	
	
	self.rolejuese = {}
    self.rolename = {}
    self.rolelv = {}
    self.act = {}

	for A=1 ,8 do --创建8个位置
		self.rolejuese[A] = winMgr:getWindow("zongherank/Back/actBg/act"..A)
		self.rolename[A] = winMgr:getWindow("zongherank/Back/actBg/act"..A.."/name")
		self.rolelv[A] = winMgr:getWindow("zongherank/Back/actBg/act"..A.."/lv")
		--self.rolejuese[A]:setVisible(false)
	end
	self.infobtn = winMgr:getWindow("zongherank/Back/actBg/tanhao")
	self.infoJM = winMgr:getWindow("zongherank/Back/actBg/info")
	self.infoJM:setVisible(false)

	self.infobtn:subscribeEvent("Clicked", ZongHeRank.openinfo, self)  --叹号按钮响应事件

    self.infobtn2 = winMgr:getWindow("zongherank/Back/actBg/tanhao2")
	self.infoJM2 = winMgr:getWindow("zongherank/Back/actBg/info2")
    self.infobtn2:setVisible(false)
	self.infoJM2:setVisible(false)

	self.infobtn2:subscribeEvent("Clicked", ZongHeRank.openinfo2, self)  --叹号按钮响应事件

    self.infobtn3 = winMgr:getWindow("zongherank/Back/actBg/tanhao3")
	self.infoJM3 = winMgr:getWindow("zongherank/Back/actBg/info3")
    self.infobtn3:setVisible(false)
	self.infoJM3:setVisible(false)

	self.infobtn3:subscribeEvent("Clicked", ZongHeRank.openinfo3, self)  --叹号按钮响应事件

	
	-------------------------------------------

-- 获取奖池表格数据



-------------------------------------------------------------

    self.m_iCurPage = 0

    local req = CRequestRankList.Create()
    req.ranktype = 201
    req.page = 0
    LuaProtocolManager.getInstance():send(req)
    self:loadTabPane()
	
    self.m_CloseBtnEx = winMgr:getWindow("zongherank/mask/x")	
	self.m_CloseBtnEx:subscribeEvent("Clicked", self.DestroyDialog, nil)


end

function ZongHeRank:openinfo()
    self.infoJM:setVisible(not self.infoJM:isVisible())
    local leixing = 1;
    local itemNum = 8;
    for A=1 ,5 do --创建8个位置
        local paiming = A
        ZongHeRank:InitializeItems(leixing,paiming,itemNum )
    end
end

function ZongHeRank:openinfo2()
	self.infoJM2:setVisible(not self.infoJM2:isVisible())
    local leixing = 2;
    local itemNum = 8;
    for A=1 ,5 do --创建8个位置
        local paiming = A
        ZongHeRank:InitializeItems(leixing,paiming,itemNum )
    end
end
function ZongHeRank:openinfo3()
self.infoJM3:setVisible(not self.infoJM3:isVisible())
    local leixing = 3;
    local itemNum = 8;
    for A=1 ,5 do --创建8个位置
        local paiming = A
        ZongHeRank:InitializeItems(leixing,paiming,itemNum )
    end
    
    
end

function ZongHeRank:loadTabPane()
    local winMgr = CEGUI.WindowManager:getSingleton();
    local tabCtrl = { id = 0, selectedIdx = 0 }
    self.m_pTabControl = tabCtrl
    tabCtrl.win = winMgr:getWindow("zongherank/levelanniu")
    tabCtrl.button1 = CEGUI.toGroupButton(winMgr:getWindow("zongherank/levelanniu/btn2"))
    tabCtrl.button2 = CEGUI.toGroupButton(winMgr:getWindow("zongherank/levelanniu/btn3"))
    tabCtrl.button3 = CEGUI.toGroupButton(winMgr:getWindow("zongherank/levelanniu/btn4"))

	self.btn1 = winMgr:getWindow("zongherank/Back/actBg/bq1")
    self.btn2 = winMgr:getWindow("zongherank/Back/actBg/bq2")
    self.btn3 = winMgr:getWindow("zongherank/Back/actBg/bq3")
	self.btn1:subscribeEvent("MouseButtonUp", ZongHeRank.handleGroupButtonClicked, self)
    self.btn2:subscribeEvent("MouseButtonUp", ZongHeRank.handleGroupButtonClicked, self)
    self.btn3:subscribeEvent("MouseButtonUp", ZongHeRank.handleGroupButtonClicked, self)

		--默认精锐榜
		self.btn1:setProperty("NormalImage", "set:my_window1 image:btn1")
		self.btn2:setProperty("NormalImage", "set:my_window1 image:btn2")
		self.btn3:setProperty("NormalImage", "set:my_window1 image:btn2")	

	
	
	
	
    tabCtrl.button1:subscribeEvent("SelectStateChanged", ZongHeRank.handleGroupButtonClicked, self)
    tabCtrl.button2:subscribeEvent("SelectStateChanged", ZongHeRank.handleGroupButtonClicked, self)
    tabCtrl.button3:subscribeEvent("SelectStateChanged", ZongHeRank.handleGroupButtonClicked, self)
	
	

    function tabCtrl:getTabButtonAtIndex(idx)
        return self["button" .. idx]
    end

    function tabCtrl:getSelectedTabIndex()
        return self.selectedIdx
    end

    function tabCtrl:getTabCount()
        return 2
    end

    function tabCtrl:setSelectedTabAtIndex(idx)
        if self["button" .. idx] then
            self["button" .. idx]:setSelected(true)
        end
        self.selectedIdx = idx;
    end

    function tabCtrl:setID(id)
        self.id = id
    end

    function tabCtrl:getID()
        return self.id
    end
end


function ZongHeRank:InitializeItems(leixing,paiming,itemNum)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local parentWindowName = "zongherank/info".. tostring(leixing).."/box".. tostring(paiming)
    local parentWindow = winMgr:getWindow(parentWindowName)


-- 创建子窗口中的道具格子 (item1 ~ item8)
local itemOffsets = {8, 57, 106, 155, 204, 253, 302, 351}
for i = 1, 8 do
    local itemName = "zongherank/info".. tostring(leixing).."/box".. tostring(paiming).."/item" .. i
    local itemWindow = winMgr:createWindow("TaharezLook/ItemCell22", itemName)
    itemWindow:setProperty("Font", "simhei-12")
    itemWindow:setProperty("Scale", "x:1 y:1 z:1")
    itemWindow:setProperty("EnableSound", "True")
    itemWindow:setProperty("LuaForDialog", "True")
    
    -- 动态设置偏移
    local leftOffset = itemOffsets[i]
    local rightOffset = leftOffset + 55 -- 每个格子宽度为 64
    itemWindow:setProperty("UnifiedAreaRect", string.format("{{0,%d},{0,3},{0,%d},{0,55}}", leftOffset, rightOffset))
    
    -- 添加到 boxWindow 中
    parentWindow:addChildWindow(itemWindow)
end

   if leixing ==3 then
    self.itemDayTable = BeanConfigManager.getInstance():GetTableByName("game.Crankawardcw"):getRecorder(paiming)
   elseif leixing ==2 then
    self.itemDayTable = BeanConfigManager.getInstance():GetTableByName("game.Crankawardrw"):getRecorder(paiming)
   elseif leixing ==1 then
    self.itemDayTable = BeanConfigManager.getInstance():GetTableByName("game.Crankaward"):getRecorder(paiming)
   end
    
    if not self.itemDayTable then
        return
    end


    -- 初始化物品格子
    self.skbh_item = {}

    -- 遍历物品格子并设置属性
    for a = 1, itemNum do
        -- 初始化格子
        self.skbh_item[a] = CEGUI.Window.toItemCell(winMgr:getWindow("zongherank/info".. tostring(leixing).."/box"..paiming.."/item" .. a))
        self.skbh_item[a]:subscribeEvent("TableClick", ZongHeRank.HandleClickItemCellTarget, self)

        -- 获取物品 ID 和数量
        local itemIdKey = "item" .. a .. "id"
        local itemNumKey = "item" .. a .. "num"

        local nItemId = self.itemDayTable[itemIdKey] or 0
        local nItemNum = self.itemDayTable[itemNumKey] or 0
        local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.itemDayTable[itemIdKey])
         if a == 1 and petAttrCfg then
                local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttrCfg.modelid)
	            local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
                self.skbh_item[a]:SetImage(image)
                self.skbh_item[a]:setID(nItemId)
            if nItemNum > 1 then
                self.skbh_item[a]:SetTextUnit(nItemNum)
            end
        end
  

        -- 如果物品 ID 大于 0，则进行设置
        if nItemId > 0 then
            -- 设置道具图片
            local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
            if itembean then
                self.skbh_item[a]:SetImage(gGetIconManager():GetItemIconByID(itembean.icon))
                self.skbh_item[a]:setID(nItemId)
            end

            -- 设置道具数量
            if nItemNum > 1 then
                self.skbh_item[a]:SetTextUnit(nItemNum)
            end
        end
    end
    --end
end


function ZongHeRank:HandleClickItemCellTarget(args)

	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
	local nItemId = index 
    local itembean = BeanConfigManager.getInstance():GetTableByName("item.SSItemToPet"):getRecorder(nItemId)
    if itembean then
        FirstChargeGiftPetDlg.getInstanceAndShow(itembean.petId)
    else
    	local Commontipdlg = require "logic.tips.commontipdlg"
	    local commontipdlg = Commontipdlg.getInstanceAndShow()
        local nType = Commontipdlg.eType.eNormal 
        commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end

function ZongHeRank:handleGroupButtonClicked(args)
    local btn = CEGUI.toWindowEventArgs(args).window
    if self.infoJM:isVisible() then
        self.infoJM:setVisible(false)
    end
    -- 如果 infoJM2 是可见的，隐藏它
    if self.infoJM2:isVisible() then
        self.infoJM2:setVisible(false)
    end
        -- 如果 infoJM3 是可见的，隐藏它
    if self.infoJM3:isVisible() then
            self.infoJM3:setVisible(false)
    end
	if(btn == self.btn1)then
		self.btn1:setProperty("NormalImage", "set:my_window1 image:btn1")
		self.btn2:setProperty("NormalImage", "set:my_window1 image:btn2")
		self.btn3:setProperty("NormalImage", "set:my_window1 image:btn2")	
        self.infobtn:setVisible(true)
        self.infobtn2:setVisible(false)
        self.infobtn3:setVisible(false)
        self.m_iRankType=201
        self.m_pTabControl.selectedIdx = 0;
        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    elseif(btn == self.btn2)then
		self.btn1:setProperty("NormalImage", "set:my_window1 image:btn2")
		self.btn2:setProperty("NormalImage", "set:my_window1 image:btn1")
		self.btn3:setProperty("NormalImage", "set:my_window1 image:btn2")	
        self.infobtn:setVisible(false)
        self.infobtn2:setVisible(true)
        self.infobtn3:setVisible(false)
        self.m_iRankType=202
        self.m_pTabControl.selectedIdx = 1;
        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    elseif(btn == self.btn3)then
		self.btn1:setProperty("NormalImage", "set:my_window1 image:btn2")
		self.btn2:setProperty("NormalImage", "set:my_window1 image:btn2")
		self.btn3:setProperty("NormalImage", "set:my_window1 image:btn1")	
        self.infobtn:setVisible(false)
        self.infobtn2:setVisible(false)
        self.infobtn3:setVisible(true)
        self.m_iRankType=203
        self.m_pTabControl.selectedIdx = 1;
        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    end
	
	---------
	
    if(btn == self.m_pTabControl.button1)then
        self.m_iRankType=201
        self.m_pTabControl.selectedIdx = 0;
        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    elseif(btn == self.m_pTabControl.button2)then
        self.m_iRankType=202
        self.m_pTabControl.selectedIdx = 1;
        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    elseif(btn == self.m_pTabControl.button3)then
        self.m_iRankType=203
        self.m_pTabControl.selectedIdx = 1;
        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    end
end


function ZongHeRank:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, ZongHeRank)

    return self
end



function ZongHeRank:HandleNextPage(args)
    LogInfo("ZongHeRank handle next page")
    if self.m_bHasMore then
        self.m_iCurPage = self.m_iCurPage + 1
        local BarPos = self.m_pMain:getVertScrollbar():getScrollPosition()
        self.m_pMain:getVertScrollbar():Stop()
        self.m_pMain:getVertScrollbar():setScrollPosition(BarPos)

        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)
    end
    return true
end

function ZongHeRank:AddRowx(Shape,color1,color2,components,rownum, id, col0, col1, col2, col3, col4, col5)
     local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(Shape)
        local shapex= petConf.modelid
        print("shapex"..shapex)
		local A = rownum+1
		
		self.rolename[A]:setVisible(true)
		self.rolelv[A]:setVisible(true)
		self.rolejuese[A]:setVisible(true)

		local s1 = self.rolejuese[A]:getPixelSize()
		self.act[A] = gGetGameUIManager():AddWindowSprite(self.rolejuese[A], shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5+20, true)
        self.rolename[A]:setText(col2)

        if self.m_iRankType == 202 then
            self.rolelv[A]:setText("Lv:" .. col3)
        else
            self.rolelv[A]:setText("战力:" .. col3)
        end

        if rownum==0 then
        local shapex=Shape
        local s1 = self.top1:getPixelSize()
        self.top1xx = gGetGameUIManager():AddWindowSprite(self.top1, shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top1name:setProperty("TextColours", textColor)
        self.top1name:setText(col1.."   vip:"..col2)
        self.top1xx:SetDyePartIndex(0, color1)
        self.top1xx:SetDyePartIndex(1, color2)
		
		
		
    end
    if rownum==1  then
        local shapex=Shape
        local s1 = self.top2:getPixelSize()
        self.top2xx = gGetGameUIManager():AddWindowSprite(self.top2, shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top2name:setProperty("TextColours", textColor)
        self.top2name:setText(col1.."   vip:"..col2)
        self.top2xx:SetDyePartIndex(0, color1)
        self.top2xx:SetDyePartIndex(1, color2)
    end
    if rownum==2  then
        local shapex=Shape
        local s1 = self.top3:getPixelSize()
        self.top3xx = gGetGameUIManager():AddWindowSprite(self.top3,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top3name:setProperty("TextColours", textColor)
        self.top3name:setText(col1.."   vip:"..col2)
        self.top3xx:SetDyePartIndex(0, color1)
        self.top3xx:SetDyePartIndex(1, color2)
    end
    if rownum==3  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top4:getPixelSize()
        self.top4xx = gGetGameUIManager():AddWindowSprite(self.top4,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top4name:setProperty("TextColours", textColor)
        self.top4name:setText(col1.."   vip:"..col2)
        self.top4xx:SetDyePartIndex(0, color1)
        self.top4xx:SetDyePartIndex(1, color2)
    end
    if rownum==4  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top5:getPixelSize()
        self.top5xx = gGetGameUIManager():AddWindowSprite(self.top5,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top5name:setProperty("TextColours", textColor)
        self.top5name:setText(col1.."   vip:"..col2)
        self.top5xx:SetDyePartIndex(0, color1)
        self.top5xx:SetDyePartIndex(1, color2)
    end
    if rownum==5  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top6:getPixelSize()
        self.top6xx = gGetGameUIManager():AddWindowSprite(self.top6,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top6name:setProperty("TextColours", textColor)
        self.top6name:setText(col1.."   vip:"..col2)
        self.top6xx:SetDyePartIndex(0, color1)
        self.top6xx:SetDyePartIndex(1, color2)
    end
    if rownum==6  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top7:getPixelSize()
        self.top7xx = gGetGameUIManager():AddWindowSprite(self.top7,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top7name:setProperty("TextColours", textColor)
        self.top7name:setText(col1.."  vip:"..col2)
        self.top7xx:SetDyePartIndex(0, color1)
        self.top7xx:SetDyePartIndex(1, color2)
    end
    if rownum==7  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top8:getPixelSize()
        self.top8xx = gGetGameUIManager():AddWindowSprite(self.top8,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top8name:setProperty("TextColours", textColor)
        self.top8name:setText(col1.."   vip:"..col2)
        self.top8xx:SetDyePartIndex(0, color1)
        self.top8xx:SetDyePartIndex(1, color2)
    end
end


function ZongHeRank:AddRow(Shape,color1,color2,components,rownum, id, col0, col1, col2, col3, col4, col5)
		local A = rownum+1
        local shapex=Shape
        local spriteComponents = {}
        if type(components) == "table" then
            spriteComponents = components
        end
        local weaponComponent = tonumber(spriteComponents[eSprite_Weapon]) or tonumber(spriteComponents[1]) or 0
        local horseComponent = tonumber(spriteComponents[eSprite_Horse]) or tonumber(spriteComponents[6]) or 0
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
		self.rolename[A]:setVisible(true)
		self.rolelv[A]:setVisible(true)
		self.rolejuese[A]:setVisible(true)
		local s1 = self.rolejuese[A]:getPixelSize()
		self.act[A] = gGetGameUIManager():AddWindowSprite(self.rolejuese[A], shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5+20, true)
		self.act[A]:SetSpriteComponent(eSprite_Weapon, weaponComponent)
		self.act[A]:SetSpriteComponent(eSprite_Horse, horseComponent)
		self.act[A]:SetDyePartIndex(0, color1)
        self.act[A]:SetDyePartIndex(1, color2)
        self.rolename[A]:setText(col1)
        if self.m_iRankType == 202 then
            self.rolelv[A]:setText("Lv:" .. col3)
        else
            self.rolelv[A]:setText("战力:" .. col3)
        end
    if rownum==0 then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top1:getPixelSize()
        self.top1xx = gGetGameUIManager():AddWindowSprite(self.top1, shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top1name:setProperty("TextColours", textColor)
        self.top1name:setText(col1.."   vip:"..col2)
        self.top1xx:SetDyePartIndex(0, color1)
        self.top1xx:SetDyePartIndex(1, color2)
    end
    if rownum==1  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top2:getPixelSize()
        self.top2xx = gGetGameUIManager():AddWindowSprite(self.top2, shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top2name:setProperty("TextColours", textColor)
        self.top2name:setText(col1.."   vip:"..col2)
        self.top2xx:SetDyePartIndex(0, color1)
        self.top2xx:SetDyePartIndex(1, color2)
    end
    if rownum==2  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top3:getPixelSize()
        self.top3xx = gGetGameUIManager():AddWindowSprite(self.top3,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top3name:setProperty("TextColours", textColor)
        self.top3name:setText(col1.."   vip:"..col2)
        self.top3xx:SetDyePartIndex(0, color1)
        self.top3xx:SetDyePartIndex(1, color2)
    end
    if rownum==3  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top4:getPixelSize()
        self.top4xx = gGetGameUIManager():AddWindowSprite(self.top4,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top4name:setProperty("TextColours", textColor)
        self.top4name:setText(col1.."   vip:"..col2)
        self.top4xx:SetDyePartIndex(0, color1)
        self.top4xx:SetDyePartIndex(1, color2)
    end
    if rownum==4  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top5:getPixelSize()
        self.top5xx = gGetGameUIManager():AddWindowSprite(self.top5,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top5name:setProperty("TextColours", textColor)
        self.top5name:setText(col1.."   vip:"..col2)
        self.top5xx:SetDyePartIndex(0, color1)
        self.top5xx:SetDyePartIndex(1, color2)
    end
    if rownum==5  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top6:getPixelSize()
        self.top6xx = gGetGameUIManager():AddWindowSprite(self.top6,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top6name:setProperty("TextColours", textColor)
        self.top6name:setText(col1.."   vip:"..col2)
        self.top6xx:SetDyePartIndex(0, color1)
        self.top6xx:SetDyePartIndex(1, color2)
    end
    if rownum==6  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top7:getPixelSize()
        self.top7xx = gGetGameUIManager():AddWindowSprite(self.top7,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top7name:setProperty("TextColours", textColor)
        self.top7name:setText(col1.."  vip:"..col2)
        self.top7xx:SetSpriteComponent(eSprite_Horse, horseComponent)
        self.top7xx:SetSpriteComponent(eSprite_Weapon, weaponComponent)
        self.top7xx:SetDyePartIndex(0, color1)
        self.top7xx:SetDyePartIndex(1, color2)
    end
    if rownum==7  then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top8:getPixelSize()
        self.top8xx = gGetGameUIManager():AddWindowSprite(self.top8,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top8name:setProperty("TextColours", textColor)
        self.top8name:setText(col1.."   vip:"..col2)
        self.top8xx:SetDyePartIndex(0, color1)
        self.top8xx:SetDyePartIndex(1, color2)
    end
end

function ZongHeRank:OnCloseBtnEx()
    self:DestroyDialog()
end

-- 行颜色
function ZongHeRank:GetRowColor(rownum)
    local color = "FF50321A"
    if rownum == 0 then
        color = "FFCC0000"
    elseif rownum == 1 then
        color = "FF009ddb"
    elseif rownum == 2 then
        color = "FF005B0F"
    end
    return color
end
return ZongHeRank
