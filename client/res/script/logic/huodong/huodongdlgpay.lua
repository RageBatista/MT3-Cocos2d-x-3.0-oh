require "logic.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

--活动主界面     wjf create 

HuodongDlgPay = {}
setmetatable(HuodongDlgPay, Dialog)
HuodongDlgPay.__index = HuodongDlgPay

local _instance
--日常活动btn
local richangBtnID = 11
--狩猎活动btn
local shoulieBtnID = 12
--限时活动btn
local xianshiBtnID = 13
--即将开启btn
local jijiangBtnID = 14
--日常活动
local richanType = 1
--狩猎活动
local shoulieType = 2
--限时活动
local xianshiType = 3
--即将开启
local jijiangType = 4
--误差 
local errordis = 0.001
--窗口宽度
local winWidth = 688
function HuodongDlgPay.getInstance()
	if not _instance then
		_instance = HuodongDlgPay:new()
		_instance:OnCreate()
	end
	return _instance
end

function HuodongDlgPay.getInstanceAndShow()
	
	if not _instance then
		_instance = HuodongDlgPay:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function HuodongDlgPay.getInstanceNotCreate()
	return _instance
end

function HuodongDlgPay.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			for index in pairs( _instance.m_cells ) do
				local cell = _instance.m_cells[index]
				if cell then
					cell:OnClose(false, false)
					cell = nil
				end
			end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function HuodongDlgPay.ToggleOpenClose()
	if not _instance then
		_instance = HuodongDlgPay:new()
		_instance:OnCreate()
        _instance:SetVisible(false)
	else
		if _instance:IsVisible() then
			
		else
			_instance:SetVisible(true)
		end
	end
end

function HuodongDlgPay.GetLayoutFileName()
	return "huodong-dianka.layout"
end

function HuodongDlgPay:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HuodongDlgPay)
	return self
end



function HuodongDlgPay:OnCreate()
	LogInfo("enter HuodongDlgPay OnCreate")
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	--日常活动
    --self.m_shoulieNumTxt = winMgr:getWindow("huodong/di/shouliecishu")
    
	self.m_richangBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("huodong/anniu1"))
	self.m_richangBtn:subscribeEvent("MouseClick", self.HandleClick, self)
	self.m_richangBtn:setID(richangBtnID)
	--日常活动默认选中状态
	--self.m_richangBtn:SetPushState(true)

    self.m_shoulieBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("huodong/anniu2"))
	self.m_shoulieBtn:subscribeEvent("SelectStateChanged", HuodongDlgPay.HandleClick, self)
	self.m_shoulieBtn:setID(shoulieBtnID)
    
	--限时活动
	self.m_xianshiBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("huodong/anniu4"))
	self.m_xianshiBtn:subscribeEvent("SelectStateChanged", HuodongDlgPay.HandleClick, self)
	self.m_xianshiBtn:setID(xianshiBtnID)
	--即将开启
	self.m_jijiangBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("huodong/anniu3"))
	self.m_jijiangBtn:subscribeEvent("SelectStateChanged", HuodongDlgPay.HandleClick, self)
	self.m_jijiangBtn:setID(jijiangBtnID)
	--周历
	self.m_zhouliBtn = CEGUI.Window.toPushButton(winMgr:getWindow("huodong/zhouli"))
	self.m_zhouliBtn:subscribeEvent("MouseClick", HuodongDlgPay.HandleZhouliClick, self)
	--列表
	self.m_scrollReward = CEGUI.toScrollablePane(winMgr:getWindow("huodong/di/liebiao"))
	self.m_scrollReward:EnableHorzScrollBar(true)
	--进度条
	self.m_progressAct = CEGUI.toProgressBar(winMgr:getWindow("huodong/jindu"))

    --推送
    self.m_tuiSongBtn = CEGUI.toPushButton(winMgr:getWindow("huodong/tuisongshezhi"))
    self.m_tuiSongBtn:subscribeEvent("Clicked", HuodongDlgPay.HandleTuiSongClick, self)
	
    --下面的6个道具框
	self.itemCell20 = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin1"))
    self.itemCell20Grey = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin1/huitu"))
	self.itemCell20:subscribeEvent("MouseClick",HuodongDlgPay.HandleItemClicked,self)
	self.itemCell40 = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin2"))
    self.itemCell40Grey  = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin2/huitu"))
	self.itemCell40:subscribeEvent("MouseClick",HuodongDlgPay.HandleItemClicked,self)
	self.itemCell60 = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin3"))
    self.itemCell60Grey  = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin3/huitu"))
	self.itemCell60:subscribeEvent("MouseClick",HuodongDlgPay.HandleItemClicked,self)
	self.itemCell80 = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin4"))
    self.itemCell80Grey  = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin4/huitu"))
	self.itemCell80:subscribeEvent("MouseClick",HuodongDlgPay.HandleItemClicked,self)
	self.itemCell150 = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin5"))
    self.itemCell150Grey  = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin5/huitu"))
	self.itemCell150:subscribeEvent("MouseClick",HuodongDlgPay.HandleItemClicked,self)
	self.itemCell200 = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin6"))
    self.itemCell200Grey  = CEGUI.Window.toItemCell(winMgr:getWindow("huodong/wupin6/huitu"))
	self.itemCell200:subscribeEvent("MouseClick",HuodongDlgPay.HandleItemClicked,self)
	self.m_txthuoyue1 = winMgr:getWindow("huodong/huoyue1")
	self.m_txthuoyue2 = winMgr:getWindow("huodong/huoyue2")
	self.m_txthuoyue3 = winMgr:getWindow("huodong/huoyue3")
	self.m_txthuoyue4 = winMgr:getWindow("huodong/huoyue4")
	self.m_txthuoyue5 = winMgr:getWindow("huodong/huoyue5")
	self.m_txthuoyue6 = winMgr:getWindow("huodong/huoyue6")
	self.m_imgAct = winMgr:getWindow("huodong/jindu/zhi")
	self.m_txtAct = winMgr:getWindow("huodong/jindu/zhi/zhi1")
	self.m_cells = {}

    self.XianshiHongdian = winMgr:getWindow("huodong/anniu2/hongdian")
	self.XianshiHongdian:setVisible(false)
    self.m_NotHasActivity = winMgr:getWindow("huodong/di/wuhuodong")
    
	self.m_type = 0
    self.m_txtYilingqu = winMgr:getWindow("huodong/textyil1")
	--self.m_imgYilingquBg = winMgr:getWindow("huodong/di1")
    self.m_btnDongjie = CEGUI.toPushButton(winMgr:getWindow("huodong/dongjie"))	

	self.m_txtShuangbei = winMgr:getWindow("huodong/textyil")
	self.m_btnDoubleLingqu = CEGUI.toPushButton(winMgr:getWindow("huodong/lingqu"))

	self.m_btnIntro2 = CEGUI.toPushButton(winMgr:getWindow("huodong/btntishi"))

    self.m_btnDongjie:subscribeEvent("Clicked", HuodongDlgPay.HandleBtnDongjieClick, self)
	self.m_btnDoubleLingqu:subscribeEvent("Clicked", HuodongDlgPay.HandleBtnDoubleLingquClick, self)
	self.m_btnIntro2:subscribeEvent("Clicked", HuodongDlgPay.HandleBtnIntro2Click, self)
    
    self.m_nCanDoublePtr = 0
	self.m_nGotDoublePtr = 0
    self.m_nOfflineExp  = 0

      	--请求冰封王座状态
	local p = require("protodef.fire.pb.instancezone.bingfeng.ccanenterbingfeng"):new()
	LuaProtocolManager:send(p)

    self:SetSrvData()
    self:RefreshBtn()

    --刷新界面
    self.refreshUI()


end

function HuodongDlgPay.createDlg(activities, activevalue, chests, recommend, closeids)
    --根据服务器发来的数据更新界面
	if HuoDongManager.getInstanceNotCreate() then
		local huodongManager = HuoDongManager.getInstanceNotCreate()
        --各个活动的次数 活跃度 等
		huodongManager.m_activities = activities
        --当期活跃度
		huodongManager.m_activevalue = activevalue
        --道具领取情况
		huodongManager.m_chests = chests
        --推荐
		huodongManager.m_recommend = recommend

        huodongManager.m_closeids = closeids
        --是否应该显示主界面 活动按钮的小红点
		huodongManager.hasHongdianAll = false
        --请求限时活动数据
        local p = require("protodef.fire.pb.mission.cgetactivityinfo"):new()
	    LuaProtocolManager:send(p)
	end
	
end
function HuodongDlgPay.refreshUI()
    --刷新界面
	if HuoDongManager.getInstanceNotCreate() then
		local huodongManager = HuoDongManager.getInstanceNotCreate()
		local  dlgInstance = HuodongDlgPay.getInstance()
		dlgInstance:refreshActiveGift()
		dlgInstance:refreshlist(dlgInstance.m_type)
        dlgInstance:SortTable()
		huodongManager:getHasActivity()
	end
end
function HuodongDlgPay:refreshActiveGift()
	--更新活跃度礼包奖励
	self.m_txthuoyue1:setVisible(false)
	self.m_txthuoyue2:setVisible(false)
	self.m_txthuoyue3:setVisible(false)
	self.m_txthuoyue4:setVisible(false)
	self.m_txthuoyue5:setVisible(false)
	self.m_txthuoyue6:setVisible(false)
	self.itemCell20Grey:setVisible(false)
    self.itemCell40Grey:setVisible(false)
    self.itemCell60Grey:setVisible(false)
    self.itemCell80Grey:setVisible(false)
    self.itemCell150Grey:setVisible(false)
    self.itemCell200Grey:setVisible(false)
	local activevalue = HuoDongManager.getInstanceNotCreate().m_activevalue


	local index = 0
    -- t通用配置表 里面存放的最大活跃度值
    local recordmacactvalue = GameTable.common.GetCCommonTableInstance():getRecorder(173)
    if IsPointCardServer() then
        recordmacactvalue = BeanConfigManager.getInstance():GetTableByName("fushi.ccommondaypay"):getRecorder(8)
    end
	local macactvalue = tonumber(recordmacactvalue.value)
	-- 活跃度进度条
	self.m_progressAct:setProgress(activevalue/math.floor(macactvalue))
	--活跃度
	self.m_txtAct:setText(tostring(activevalue));
	local activeluemax = macactvalue
    --如果活跃度超过最大数量
	if activevalue > activeluemax then
		activevalue = activeluemax
	end
    --当前活跃度图片 坐标计算
	local x = CEGUI.UDim(0, 1 + (self.m_progressAct:getWidth().offset )/ activeluemax  * activevalue - self.m_imgAct:getWidth().offset  / 2)
	local y = self.m_imgAct:getPosition().y
	local pos = CEGUI.UVector2(x,y)
	self.m_imgAct:setPosition(pos)
    local indexIDs
    if not IsPointCardServer() then
        indexIDs = BeanConfigManager.getInstance():GetTableByName("mission.cactivegiftbox"):getAllID()
    else
        indexIDs = BeanConfigManager.getInstance():GetTableByName("mission.cpointcardactivegiftbox"):getAllID()
    end
    --给每一个道具设置坐标和属性
	for _, v in pairs(indexIDs) do
		local record
        if not IsPointCardServer() then
            record = BeanConfigManager.getInstance():GetTableByName("mission.cactivegiftbox"):getRecorder(v)
        else
            record = BeanConfigManager.getInstance():GetTableByName("mission.cpointcardactivegiftbox"):getRecorder(v)
        end
		local chest= HuoDongManager.getInstanceNotCreate().m_chests[record.id]
        if index == 0 then
            
			local iconManager = gGetIconManager()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.itemid)
            if itemAttrCfg then
			    self.itemCell20:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            end
			self.itemCell20:setID(v)
            SetItemCellBoundColorByQulityItemWithId(self.itemCell20,record.itemid)
			self.m_txthuoyue1:setText(record.text)
			local x = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local x1 = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local y = self.itemCell20:getPosition().y
			local y1 = self.m_txthuoyue1:getPosition().y
			local pos = CEGUI.UVector2(x,y)
			local pos1 = CEGUI.UVector2(x1,y1)
			self.itemCell20:setPosition(pos)
			self.m_txthuoyue1:setPosition(pos1)
			self.m_txthuoyue1:setVisible(true)
			--删除特效
			gGetGameUIManager():RemoveUIEffect(self.itemCell20)
            --还未领取添加特效
			if (chest == 0 or chest == nil) and  activevalue>= record.needactvalue  then
                NewRoleGuideManager.getInstance():AddParticalToWnd(self.itemCell20, true)
			end
            --领取过了
			if chest == 1 then
                self.itemCell20Grey:setVisible(true)
			end
			index = index + 1
		elseif index == 1 then
			local iconManager = gGetIconManager()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.itemid)
            if itemAttrCfg then
			    self.itemCell40:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            end
			self.itemCell40:setID(v)
            SetItemCellBoundColorByQulityItemWithId(self.itemCell40,record.itemid)
			self.m_txthuoyue2:setText(record.text)
			local x = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local x1 = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local y = self.itemCell40:getPosition().y
			local y1 = self.m_txthuoyue2:getPosition().y
			local pos = CEGUI.UVector2(x,y)
			local pos1 = CEGUI.UVector2(x1,y1)
			self.itemCell40:setPosition(pos)
			self.m_txthuoyue2:setPosition(pos1)
			self.m_txthuoyue2:setVisible(true)
			gGetGameUIManager():RemoveUIEffect(self.itemCell40)
			if (chest == 0 or chest == nil) and  activevalue>= record.needactvalue  then
                 NewRoleGuideManager.getInstance():AddParticalToWnd(self.itemCell40, true)
			end
			if chest == 1 then
                self.itemCell40Grey:setVisible(true)
			end
			index = index + 1
		elseif index == 2 then
			local iconManager = gGetIconManager()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.itemid)
            if itemAttrCfg then
			    self.itemCell60:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            end
			self.itemCell60:setID(v)
            SetItemCellBoundColorByQulityItemWithId(self.itemCell60,record.itemid)
			self.m_txthuoyue3:setText(record.text)
			local x = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue+ 30)
			local x1 = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue+ 30)
			local y = self.itemCell60:getPosition().y
			local y1 = self.m_txthuoyue3:getPosition().y
			local pos = CEGUI.UVector2(x,y)
			local pos1 = CEGUI.UVector2(x1,y1)
			self.itemCell60:setPosition(pos)
			self.m_txthuoyue3:setPosition(pos1)
			self.m_txthuoyue3:setVisible(true)
			gGetGameUIManager():RemoveUIEffect(self.itemCell60)
			if (chest == 0 or chest == nil)  and  activevalue>= record.needactvalue then
                NewRoleGuideManager.getInstance():AddParticalToWnd(self.itemCell60, true)
			end
			if chest == 1 then
                self.itemCell60Grey:setVisible(true)
			end
			index = index + 1
		elseif index == 3 then
			local iconManager = gGetIconManager()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.itemid)
            if itemAttrCfg then
			    self.itemCell80:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            end
			self.itemCell80:setID(v)
            SetItemCellBoundColorByQulityItemWithId(self.itemCell80,record.itemid)
			self.m_txthuoyue4:setText(record.text)
			local x = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local x1 = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local y = self.itemCell80:getPosition().y
			local y1 = self.m_txthuoyue4:getPosition().y
			local pos = CEGUI.UVector2(x,y)
			local pos1 = CEGUI.UVector2(x1,y1)
			self.itemCell80:setPosition(pos)
			self.m_txthuoyue4:setPosition(pos1)
			self.m_txthuoyue4:setVisible(true)
			gGetGameUIManager():RemoveUIEffect(self.itemCell80)
			if (chest == 0 or chest == nil) and  activevalue>= record.needactvalue then
                NewRoleGuideManager.getInstance():AddParticalToWnd(self.itemCell80, true)
			end
			if chest == 1 then
                self.itemCell80Grey:setVisible(true)
			end
			index = index + 1
		elseif index == 4 then
			local iconManager = gGetIconManager()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.itemid)
            if itemAttrCfg then
			    self.itemCell150:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            end
			self.itemCell150:setID(v)
            SetItemCellBoundColorByQulityItemWithId(self.itemCell150,record.itemid)
			self.m_txthuoyue5:setText(record.text)
			local x = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local x1 = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local y = self.itemCell150:getPosition().y
			local y1 = self.m_txthuoyue5:getPosition().y
			local pos = CEGUI.UVector2(x,y)
			local pos1 = CEGUI.UVector2(x1,y1)
			self.itemCell150:setPosition(pos)
			self.m_txthuoyue5:setPosition(pos1)
			self.m_txthuoyue5:setVisible(true)
			gGetGameUIManager():RemoveUIEffect(self.itemCell150)
			if (chest == 0 or chest == nil) and  activevalue>= record.needactvalue then
                NewRoleGuideManager.getInstance():AddParticalToWnd(self.itemCell150, true)
			end
			if chest == 1 then
                self.itemCell120Grey:setVisible(true)
			end
			index = index + 1
		elseif index == 5 then
			local iconManager = gGetIconManager()
			local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(record.itemid)
            if itemAttrCfg then
			    self.itemCell200:SetImage(iconManager:GetItemIconByID(itemAttrCfg.icon))
            end
			self.itemCell200:setID(v)
            SetItemCellBoundColorByQulityItemWithId(self.itemCell200,record.itemid)
			self.m_txthuoyue6:setText(record.text)
			local x = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local x1 = CEGUI.UDim(0, 1 +  math.floor(winWidth) * record.needactvalue / macactvalue + 30)
			local y = self.itemCell200:getPosition().y
			local y1 = self.m_txthuoyue6:getPosition().y
			local pos = CEGUI.UVector2(x,y)
			local pos1 = CEGUI.UVector2(x1,y1)
			self.itemCell200:setPosition(pos)
			self.m_txthuoyue6:setPosition(pos1)
			self.m_txthuoyue6:setVisible(true)
			gGetGameUIManager():RemoveUIEffect(self.itemCell200)
			if (chest == 0 or chest == nil) and  activevalue>= record.needactvalue then
                NewRoleGuideManager.getInstance():AddParticalToWnd(self.itemCell200, true)
			end
			if chest == 1 then
                self.itemCell120Grey:setVisible(true)
			end
			index = index + 1
		end
		
	end
end

function HuodongDlgPay:HandleTuiSongClick(arg)
    require "logic.systemsettingtuisongdlg".getInstanceAndShow()
end

--点击道具
function HuodongDlgPay:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local index = e.window:getID()
    local record
    if not IsPointCardServer() then
        record = BeanConfigManager.getInstance():GetTableByName("mission.cactivegiftbox"):getRecorder(index)
    else
        record = BeanConfigManager.getInstance():GetTableByName("mission.cpointcardactivegiftbox"):getRecorder(index)
    end

	local activevalue = HuoDongManager.getInstanceNotCreate().m_activevalue
    local chest= HuoDongManager.getInstanceNotCreate().m_chests[record.id]
    --如果还未领取  直接发送协议领取道具
	if (chest == 0 or chest == nil) and activevalue>= record.needactvalue then
        local p = require("protodef.fire.pb.mission.activelist.cdrawgiftbox"):new()
        p.id = record.id
	    LuaProtocolManager:send(p)
	else
       --如果是领取过了弹出tips
    	local Commontipdlg = require "logic.tips.commontipdlg"
		local commontipdlg = Commontipdlg.getInstanceAndShow()
		local nType = Commontipdlg.eNormal
		local nItemId = record.itemid
		commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
	end
	
	
	
end
function HuodongDlgPay:refreshshoulieNum()
--    local shoulieList = {}
--    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getAllID()
--    for _, v in pairs(tableAllId) do
--        local huodongManager = HuoDongManager.getInstanceNotCreate()
--		local record = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getRecorder(v)
--        if record.type == shoulieType then
--            table.insert(shoulieList, v)
--        end
--    end
--    local huodongManager = HuoDongManager.getInstanceNotCreate()
--    local num = 0
--    for _, v in pairs(shoulieList) do
--        if huodongManager.m_activities[v] then
--            num = num + huodongManager.m_activities[v]
--        end
--    end
--    local strbuilder = StringBuilder:new()
--    strbuilder:Set("parameter1", tostring(num))
--    local content = strbuilder:GetString(MHSD_UTILS.get_resstring(11583))
--    self.m_shoulieNumTxt:setText(content)
end
function HuodongDlgPay:refreshlist(atype)
	--清除所有cell
    
    --self.XianshiHongdian:setVisible(false)


    self.m_NotHasActivity:setVisible(false)
	for index in pairs( self.m_cells ) do
		local cell = self.m_cells[index]
		if cell then
			cell:OnClose(false, false)
			cell = nil
		end
	end
  	self.m_cells = {}
	self.m_scrollReward:cleanupNonAutoChildren()
    --当前时间
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
    --计算星期
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
	
	local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday

    local index = 0

    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getAllID()
    for _, v in pairs(tableAllId) do
        --活动配置表新
        local huodongManager = HuoDongManager.getInstanceNotCreate()
		local record = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getRecorder(v)
		local data = gGetDataManager():GetMainCharacterData()
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
        --是否为今天活动
        local serverid = record.serverid
        local blnIsServer  = false
        if serverid == "0" or serverid == nil then
            blnIsServer = true
        elseif string.find(serverid, ";") then
            local strTable = StringBuilder.Split(serverid, ";")
            for _,v in pairs(strTable) do
                if v == tostring(gGetLoginManager():getServerID()) then
                    blnIsServer = true
                    break
                end
            end
        else
            if tostring(gGetLoginManager():getServerID()) == serverid then
                blnIsServer = true
            end
        end
        if blnIsServer then
		    local blntoday = false
            --时间是否合适可以开启
		    local blnIsOpen = false
            --是否超过时间
            local blnOutTime = false
            local strStartTime = ""
		    --如果不是定时活动直接直接确定为当天活动
		    if tonumber(record.actid) == -1 or record.type == 2 then
                if record.times == "0" then 
                    local activityinfos = HuoDongManager.getInstanceNotCreate().m_activityinfos
                    for i,v in pairs(activityinfos) do
                        if v.activityid == record.serversend then
                            if v.activitystate == 1 then
                                blntoday = true
			                    blnIsOpen = true
                                break
                            end
                        end 
                    end
                else
                    local strWeeks = StringBuilder.Split(record.times,",")
                    for k,v in pairs(strWeeks) do
                        if v == tostring(curWeekDay) then
                            blntoday = true
			                blnIsOpen = true
                            break
                        end 
                    end
                end


		    else
			    --如果是定时活动
                local tableAllId = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getAllID()
                for _, v in pairs(tableAllId) do
				    local actScheculed = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getRecorder(v)
				    --去定时活动表找对应活动
				    if actScheculed.activityid == tonumber(record.actid) then
                        strStartTime = actScheculed.startTime
                        strStartTime2 = actScheculed.startTime2
					    --如果该活动为固定日期开放
					    if actScheculed.weekrepeat == 0 then
						    local starty, startm, startd, starth, startmin, starts = string.match(actScheculed.startTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
						    startd = tonumber(startd)
						    starty = tonumber(starty)
						    startm = tonumber(startm)
						    --判断有没有日期
						    if not string.find(actScheculed.startTime, "-") then
							    blntoday = true
							    local actstarttimehour, actstarttimemin, actstarttimesec = string.match(actScheculed.startTime, "(%d+):(%d+):(%d+)")
							    local actendtimehour, actendtimemin, actendtimesec = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
							    local actstartAll = actstarttimehour * 3600 + actstarttimemin * 60 + actstarttimesec
							    local actendAll = actendtimehour * 3600 + actendtimemin * 60 + actendtimesec
							    local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
							    --判断时间
							    if actnowAll> actstartAll and actnowAll<actendAll then
								    blnIsOpen = true
							    end
                                if actnowAll > actendAll then
                                    blnOutTime = true
                                end
							    break
						    elseif starty == yearCur and startm == monthCur and startd == dayCur then
							    blntoday = true
							    local actstarttime = {}
							    actstarttime.year, actstarttime.month, actstarttime.day, actstarttime.hour, actstarttime.min, actstarttime.sec = string.match(actScheculed.startTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
							    local actendtime = {}
							    actendtime.year, actendtime.month, actendtime.day, actendtime.hour, actendtime.min, actendtime.sec = string.match(actScheculed.endTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
							    if time > os.time(actstarttime) and time < os.time(actendtime) then
                                    --时间正确可以开启
								    blnIsOpen = true
                                    blnOutTime = true
							    end
							    break
						    end
						    --判断一周的哪天
					    elseif actScheculed.weekrepeat == curWeekDay then
						    blntoday = true
						    local actstarttimehour, actstarttimemin, actstarttimesec = string.match(actScheculed.startTime, "(%d+):(%d+):(%d+)")
						    local actendtimehour, actendtimemin, actendtimesec = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
						    local actstartAll = actstarttimehour * 3600 + actstarttimemin * 60 + actstarttimesec
						    local actendAll = actendtimehour * 3600 + actendtimemin * 60 + actendtimesec
						    local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
						    --判断时间
						    if actnowAll> actstartAll and actnowAll<actendAll then
							    blnIsOpen = true
						    end
                            if actnowAll > actendAll then
                                blnOutTime = true
                            end
						    break
					    end
				    end
			    end
		    end
            --如果不是即将开启
		    if atype ~= jijiangType then
			    --判断等级
                local blnCloseGm = true
                for i, v in pairs(huodongManager.m_closeids) do
                    if v == record.id then
                        blnCloseGm =false
                    end
                end

                if MT3.ChannelManager:IsAndroid() == 1 then
                    if record.id == 122 then
                        if not Config.IsLocojoy() then
                            blnCloseGm = false
                         end
                    end
                end

                if blntoday and record.isopen == 1 and blnCloseGm then
				    if record.level <= nLvl and nLvl <= record.maxlevel then
                    
					    --判断类型
                        if blnIsOpen and record.type == xianshiType then
                            if record.maxnum >=0 then
						        if huodongManager.m_activities[record.id] ~= nil then
							        local num = huodongManager.m_activities[record.id].num
							        if num <  record.maxnum then
                                        --主界面活动小红点
                                        if record.link ~= 0 then
                                    	    --huodongManager.hasHongdianAll = true
                                            --self.XianshiHongdian:setVisible(true)
                                        end

							        end
						        else
							        local num = 0
							        if num <  record.maxnum then
                                        --主界面活动小红点
                                        if record.link ~= 0 then
                                    	    --huodongManager.hasHongdianAll = true
                                            --self.XianshiHongdian:setVisible(true)
                                        end
							        end
						        end
					        end
                        end

					
					    if record.type == atype then
                            --配置每一个活动cell的坐标
                            if record.id == 216 then
                                if huodongManager.m_boxuezhe == false then
                                    blnIsOpen = false
                                end
                            end
                            local curCell = nil
                            curCell = require "logic.huodong.huodongcell".CreateNewDlg(self.m_scrollReward, index + 1)
                            local disy = 0
                            if atype == shoulieType then
                                disy = 70
                            end
						    local x = CEGUI.UDim(0, 1 + index * curCell.m_width)
						    local y = CEGUI.UDim(1, 100)
						    local pos = CEGUI.UVector2(x,y)
						    curCell:GetWindow():setPosition(pos)
						    table.insert(self.m_cells,curCell)
                            curCell.m_sort = record.sort
                            curCell.m_type = atype
                            curCell.m_OutTime = blnOutTime
                            local activities = HuoDongManager.getInstanceNotCreate().m_activities
                            local activitynum = 0
                            if activities[record.id] ~= nil then
		                        activitynum = activities[record.id].num
	                        end
	                        if activitynum == nil then
		                        activitynum = 0
	                        end

                            local blnnum = false
	                        if activitynum >= record.maxnum then
		                        blnnum = true
	                        end
	                        if record.maxnum  <= 0 then
		                        blnnum = false
	                        end
						    curCell.m_id = record.id
					        if record.level > nLvl then
						        curCell.m_hasTime = false
					        else
						        if blnIsOpen  then
                            	    curCell.m_hasTime = true  
						        else
                                    curCell.m_hasTime = false
                                    local starttimehourTxt, actstarttimeminTxt, actstarttimesecTxt = string.match(strStartTime2, "(%d+):(%d+):(%d+)")
                                    curCell.m_txtTime = starttimehourTxt..":"..actstarttimeminTxt
						        end
					        end
                            curCell:RefreshShow()
                            if curCell.m_tuijian == 1 then
                                curCell.m_sort = 0
                            end
                            if curCell.m_id == 103 then
                                local huodongmanager = HuoDongManager.getInstanceNotCreate()
                                if huodongmanager then
                                    if huodongmanager.m_HeroTrial == 1 then
                                        curCell.m_sort = record.level + 100000
                                    elseif huodongmanager.m_HeroTrial == 2 then
                                        curCell.m_sort  = record.level  + 1000000 
                                    end 
                                end
                            else
                                if blnnum and  record.maxnum > 0 then
                                    --如果是完成的任务往后排
                                    curCell.m_sort  = record.level  + 1000000 
                                end 
                            end
                            if blnOutTime then
                                curCell.m_sort = record.level  + 2000000 
                            end
                            index = index +1
					    end
				    end
                end
		    else
			    --如果等级超过 
                local recordLevelDis = GameTable.common.GetCCommonTableInstance():getRecorder(264)
			    if record.level > nLvl and nLvl + recordLevelDis.value >= record.level and record.isopen == 1 then
				    local curCell = require "logic.huodong.huodongcell".CreateNewDlg(self.m_scrollReward, index + 1)
				    local x = CEGUI.UDim(0, 1 + index * curCell.m_width)
				    local y = CEGUI.UDim(0, 1)
				    local pos = CEGUI.UVector2(x,y)
				    curCell:GetWindow():setPosition(pos)
				    table.insert(self.m_cells, curCell)
                    curCell.m_sort = record.level
				    curCell.m_id = record.id
                    curCell.m_type = atype
				    if record.level > nLvl then
					    curCell.m_hasTime = false
				    else
					    if blnIsOpen  then
                            curCell.m_hasTime = true
					    else
                            curCell.m_hasTime = false
                            local starttimehourTxt, actstarttimeminTxt, actstarttimesecTxt = string.match(strStartTime, "(%d+):(%d+):(%d+)")
                            curCell.m_txtTime = starttimehourTxt..":"..actstarttimeminTxt
					    end
				    end
					
				    curCell:RefreshShow()
				    index = index +1
			    end
				
		    end
        end
	end
    if index == 0 then
        self.m_NotHasActivity:setVisible(true)
    end
    if self.m_type == shoulieType then
        self:refreshshoulieNum()
    end
    
end

function HuodongDlgPay.HasOpenActicity()
    if not gGetDataManager() then
        return
    end
    if not gGetDataManager():GetMainCharacterData() then
        return
    end
    local  dlgInstance = HuodongDlgPay.getInstanceNotCreate()
    if dlgInstance then 
        dlgInstance.XianshiHongdian:setVisible(false)
        
    end

	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
	
	local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday
	--重新创建cell
    local huodongManager = HuoDongManager.getInstanceNotCreate()
    huodongManager.hasHongdianAll = false
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getAllID()
    local index = 0
    for _, v in pairs(tableAllId) do
		local record = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getRecorder(v)
		local data = gGetDataManager():GetMainCharacterData()
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
        local atype = record.type
		--是否点击即将开启
        local serverid = record.serverid
        local blnIsServer  = false
        if serverid == "0" or serverid == nil then
            blnIsServer = true
        elseif string.find(serverid, ";") then
            local strTable = StringBuilder.Split(serverid, ";")
            for _,v in pairs(strTable) do
                if v == tostring(gGetLoginManager():getServerID()) then
                    blnIsServer = true
                    break
                end
            end
        else
            if tostring(gGetLoginManager():getServerID()) == serverid then
                blnIsServer = true
            end
        end
        if blnIsServer then
		    local blntoday = false
		    local blnIsOpen = false
            local strStartTime = ""
        
            local blnCloseGm = true
            for i, v in pairs(huodongManager.m_closeids) do
                if v == record.id then
                    blnCloseGm =false
                end
            end
            if atype == xianshiType and record.isopen == 1 and blnCloseGm then
                --如果不是定时活动直接直接确定为当天活动
		        if tonumber(record.actid) == -1 or record.type == 2 then
                    if record.times == "0" then
                        local activityinfos = HuoDongManager.getInstanceNotCreate().m_activityinfos
                        for i,v in pairs(activityinfos) do
                            if v.activityid == record.serversend then
                                if v.activitystate == 1 then
                                    blntoday = true
			                        blnIsOpen = true
                                    break
                                end
                            end 
                        end
                    else
                        local strWeeks = StringBuilder.Split(record.times,",")
                        for k,v in pairs(strWeeks) do
                            if v == tostring(curWeekDay) then
                                blntoday = true
			                    blnIsOpen = true
                                break
                            end 
                        end
                    end
		        else
			        --如果是定时活动
                    local tableAllId = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getAllID()
                    for _, v in pairs(tableAllId) do
				        local actScheculed = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getRecorder(v)
				        --去定时活动表找对应活动
				        if actScheculed.activityid == tonumber(record.actid) then
                            strStartTime = actScheculed.startTime
					        --如果该活动为固定日期开放
					        if actScheculed.weekrepeat == 0 then
						        local starty, startm, startd, starth, startmin, starts = string.match(actScheculed.startTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
						        startd = tonumber(startd)
						        starty = tonumber(starty)
						        startm = tonumber(startm)
						        --判断有没有日期
						        if not string.find(actScheculed.startTime, "-") then
							        blntoday = true
							        local actstarttimehour, actstarttimemin, actstarttimesec = string.match(actScheculed.startTime, "(%d+):(%d+):(%d+)")
							        local actendtimehour, actendtimemin, actendtimesec = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
							        local actstartAll = actstarttimehour * 3600 + actstarttimemin * 60 + actstarttimesec
							        local actendAll = actendtimehour * 3600 + actendtimemin * 60 + actendtimesec
							        local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
							        --判断时间
							        if actnowAll> actstartAll and actnowAll<actendAll then
								        blnIsOpen = true
							        end
							        break
						        elseif starty == yearCur and startm == monthCur and startd == dayCur then
							        blntoday = true
							        local actstarttime = {}
							        actstarttime.year, actstarttime.month, actstarttime.day, actstarttime.hour, actstarttime.min, actstarttime.sec = string.match(actScheculed.startTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
							        local actendtime = {}
							        actendtime.year, actendtime.month, actendtime.day, actendtime.hour, actendtime.min, actendtime.sec = string.match(actScheculed.endTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
							        if time > os.time(actstarttime) and time < os.time(actendtime) then
								        blnIsOpen = true
							        end
							        break
						        end
						        --判断一周的哪天
					        elseif actScheculed.weekrepeat == curWeekDay then
						        blntoday = true
						        local actstarttimehour, actstarttimemin, actstarttimesec = string.match(actScheculed.startTime, "(%d+):(%d+):(%d+)")
						        local actendtimehour, actendtimemin, actendtimesec = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
						        local actstartAll = actstarttimehour * 3600 + actstarttimemin * 60 + actstarttimesec
						        local actendAll = actendtimehour * 3600 + actendtimemin * 60 + actendtimesec
						        local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
						        --判断时间
						        if actnowAll> actstartAll and actnowAll<actendAll then
							        blnIsOpen = true
						        end
						        break
					        end
				        end
			        end
		        end
		
		        if blntoday then
			        --判断等级
			        if record.level <= nLvl and blnIsOpen and nLvl<= record.maxlevel and record.link ~= 0 then
				        --判断类型
				    
				        if record.maxnum >=0 and record.type == xianshiType then
					        if huodongManager.m_activities[record.id] ~= nil then
						        local num = huodongManager.m_activities[record.id].num
						        if num <  record.maxnum then
                                    local blnBoxuezhe = true
                            	    if record.id == 216 then
                                        blnBoxuezhe = huodongManager.m_boxuezhe
                                    end
                                    if blnBoxuezhe then
                                        local linkOnece = true
                                        if huodongManager.m_RedpackDis[record.id] then
                                            if huodongManager.m_RedpackDis[record.id] == 1 then
                                                linkOnece = flase
                                            end
                                        end
                                        if linkOnece then

                                	        huodongManager.hasHongdianAll = true
                                            if dlgInstance then 
                                                dlgInstance.XianshiHongdian:setVisible(true)
                                            end
                                        end
                                        if dlgInstance then
                                            if dlgInstance.m_type == 0 then
                                                if HuoDongManager.getInstanceNotCreate().hasHongdianAll then
                                                    dlgInstance.m_type = 3
                                                    dlgInstance.m_xianshiBtn:setSelected(true,false)
                                                else
                                                    dlgInstance.m_type = 1
                                                    dlgInstance.m_richangBtn:setSelected(true,false)
                                                end 
                                            end
                                        end
                                        return
                                    end
						        end
					        else
						        local num = 0
						        if num <  record.maxnum and record.type == xianshiType then
                                    local blnBoxuezhe = true
                            	    if record.id == 216 then
                                        blnBoxuezhe = huodongManager.m_boxuezhe
                                    end
                                    if blnBoxuezhe then
                                        local linkOnece = true
                                        if huodongManager.m_RedpackDis[record.id] then
                                            if huodongManager.m_RedpackDis[record.id] == 1 then
                                                linkOnece = flase
                                            end
                                        end
                                        if linkOnece then
                                            huodongManager.hasHongdianAll = true
                                            if dlgInstance then 
                                                dlgInstance.XianshiHongdian:setVisible(true)
                                            end
                                        end
                                        if dlgInstance then
                                            if dlgInstance.m_type == 0 then
                                                if HuoDongManager.getInstanceNotCreate().hasHongdianAll then
                                                    dlgInstance.m_type = 3
                                                    dlgInstance.m_xianshiBtn:setSelected(true,false)
                                                else
                                                    dlgInstance.m_type = 1
                                                    dlgInstance.m_richangBtn:setSelected(true,false)
                                                end 
                                            end
                                        end
                                        return
                                    end
						        end
					        end
				        end
			        end
		        end
            end
        end
	end
    if dlgInstance then
        if dlgInstance.m_type == 0 then
            if HuoDongManager.getInstanceNotCreate().hasHongdianAll then
                dlgInstance.m_type = 3
                dlgInstance.m_xianshiBtn:setSelected(true,false)
            else
                dlgInstance.m_type = 1
                dlgInstance.m_richangBtn:setSelected(true,false)
            end 
        end
    end

    local indexIDs
    if not IsPointCardServer() then
        indexIDs = BeanConfigManager.getInstance():GetTableByName("mission.cactivegiftbox"):getAllID()
    else
        indexIDs = BeanConfigManager.getInstance():GetTableByName("mission.cpointcardactivegiftbox"):getAllID()
    end
    for _, v in pairs(indexIDs) do
        local huodongManager = HuoDongManager.getInstanceNotCreate()
        if huodongManager then
	        local record
            if not IsPointCardServer() then
                record = BeanConfigManager.getInstance():GetTableByName("mission.cactivegiftbox"):getRecorder(v)
            else
                record = BeanConfigManager.getInstance():GetTableByName("mission.cpointcardactivegiftbox"):getRecorder(v)
            end
	        local chest= HuoDongManager.getInstanceNotCreate().m_chests[record.id]
            local activevalue = HuoDongManager.getInstanceNotCreate().m_activevalue
            if (chest == 0 or chest == nil) and  activevalue>= record.needactvalue  then
                huodongManager.hasHongdianAll = true
                return
            end
        end
    end
end
--给活动排序
function HuodongDlgPay:SortTable()
    --即将开启按等级排序
    if self.m_type == jijiangType then
        table.sort(self.m_cells, function (v1, v2)
		    local recorda = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getRecorder(v1.m_id)
            local recordb = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynewpay"):getRecorder(v2.m_id)
		    return recorda.level < recordb.level
	    end)
    else
        --[[
        table.sort(self.m_cells, function (v1, v2)
		    local recorda = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynew"):getRecorder(v1.m_id)
            local recordb = BeanConfigManager.getInstance():GetTableByName("mission.cactivitynew"):getRecorder(v2.m_id)
		    return recorda.sort < recordb.sort
	    end)
        ]]--
        --不是即将开启的按照完成和id进行排序
        table.sort(self.m_cells, function(a,b) return a.m_sort<b.m_sort end)
    end

    -- 参加排序
    if self.m_type == xianshiType then
        local CellsOpen = {}
        local CellsNotOpen = {}
        for i,v in pairs(self.m_cells) do
            if v.m_Open == 1 then
                table.insert(CellsOpen, v)
            end
        end
        for i,v in pairs(self.m_cells) do
            if v.m_Open ~= 1 then
                table.insert(CellsNotOpen, v)
            end
        end
        self.m_cells = {}
        for i,v in pairs(CellsOpen) do
            table.insert(self.m_cells, v)
        end
        for i,v in pairs(CellsNotOpen) do
            table.insert(self.m_cells, v)
        end
    end

    --修改坐标
    for i,v in pairs(self.m_cells) do
		local x = CEGUI.UDim(0, 1 + (i -1) * v.m_width)
		local y = CEGUI.UDim(0, 1)
		local pos = CEGUI.UVector2(x,y)
		v:GetWindow():setPosition(pos)
    end 
end

function HuodongDlgPay:HandleClick(args)
	--日常活动、限时活动、即将开启点击
	LogInfo("enter HuodongDlgPay HandleClick")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if id == richangBtnID then
		self.m_type = richanType
        --self.m_shoulieNumTxt:setVisible(false)
    elseif id == shoulieBtnID then
		self.m_type = shoulieType
        --self.m_shoulieNumTxt:setVisible(true)
	elseif id == xianshiBtnID then
		self.m_type = xianshiType
        --self.m_shoulieNumTxt:setVisible(false)
	elseif id == jijiangBtnID then
		self.m_type = jijiangType
        --self.m_shoulieNumTxt:setVisible(false)
	end
    self:refreshlist(self.m_type)
    self:SortTable()
	return true
end
function HuodongDlgPay:HandleZhouliClick(args)
	LogInfo("enter HuodongDlgPay HandleZhouliClick")
	local zhouli = require "logic.huodong.huodongzhoulidlg"
	if not zhouli.getInstanceNotCreate() then
		zhouli.getInstanceAndShow()
	end
	return true
end
function HuodongDlgPay:SetSrvData(  )
	local list = HookManager.getInstance():GetHookData()
	if list == nil or #list == 0 then
		return
	end
	self.m_nCanDoublePtr = list[1]
	self.m_nGotDoublePtr = list[2]
	self.m_nOfflineExp  = list[3]
end
function HuodongDlgPay:HandleBtnDongjieClick(args)
	local p = require "protodef.fire.pb.hook.cfreezedpoint":new()
	require "manager.luaprotocolmanager":send(p)
end
local itemkey = 0
function HuodongDlgPay:HandleBtnDoubleLingquClick(args)
    local function ClickYes(self, args)
        local nUserId = gGetDataManager():GetMainCharacterID()

	    require "protodef.fire.pb.item.cappenditem"
	    local useItem = CAppendItem.Create()
        useItem.keyinpack = itemkey
        useItem.idtype = 2
        useItem.id = nUserId
	    LuaProtocolManager.getInstance():send(useItem)

        itemkey = 0
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
    local function ClickYes2(self, args)
        text  =  GameTable.common.GetCCommonTableInstance():getRecorder(266).value
        local cost = tonumber(text)
        local moneynum = gGetDataManager():GetYuanBaoNumber()
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        local tipid = 162032
        if manager then
            if manager.m_isPointCardServer then
                tipid = 160118
                moneynum = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_GoldCoin)
                cost = cost * tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(143).value)
            end

        end

        --符石不够或者金币不足
        if moneynum<cost then
            GetCTipsManager():AddMessageTipById(tipid)
        else
            --发送协议
            local send = require "protodef.fire.pb.hook.cbuydpoint":new()
            require "manager.luaprotocolmanager":send(send)
        end
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
	if self.m_nCanDoublePtr <= 0 then
        --在没有点数的情况下先判断背包中是否有可以使用的物品,再充值并且使用掉
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local text  =  GameTable.common.GetCCommonTableInstance():getRecorder(265).value
        local id = tonumber(text)
        local itemkeys = roleItemManager:GetItemKeyListByBag(1)
        local len = itemkeys:size()
        for i = 0,(len - 1) do
             local item = roleItemManager:FindItemByBagAndThisID(itemkeys[i], 1)
             if item:GetObjectID() == id  then
                itemkey = item:GetThisID()
                local msg = MHSD_UTILS.get_msgtipstring(162028)
                gGetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes,self,MessageManager.HandleDefaultCancelEvent,MessageManager)
              return
             end
        end
        --没有物品
        local msg = MHSD_UTILS.get_msgtipstring(162029)
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                msg = MHSD_UTILS.get_msgtipstring(300007)
            end 
        end
        gGetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes2,self,MessageManager.HandleDefaultCancelEvent,MessageManager)     
		return true
	end
	
	local p = require "protodef.fire.pb.hook.cgetdpoint":new()
	require "manager.luaprotocolmanager":send(p)
end

function HuodongDlgPay:HandleBtnIntro2Click(args)
	print("HuodongDlgPay:HandleInfoClick()")
	local title = MHSD_UTILS.get_resstring(11134)
	local strAllString = MHSD_UTILS.get_resstring(11135)
	local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(strAllString, title)
end

function HuodongDlgPay:RefreshBtn()
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", self.m_nGotDoublePtr)
	local  str = MHSD_UTILS.get_resstring(11236)
	self.m_txtYilingqu:setText("  "..strbuilder:GetString(MHSD_UTILS.get_resstring(11236)))
	
    strbuilder:delete()
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", self.m_nCanDoublePtr)
	local  str = MHSD_UTILS.get_resstring(11235)
	self.m_txtShuangbei:setText("  "..strbuilder:GetString(MHSD_UTILS.get_resstring(11235)))
    strbuilder:delete()
	if self.m_nGotDoublePtr <= 0 then
		self.m_btnDongjie:setVisible(false)
		--self.m_txtYilingqu:setVisible(false)
		--self.m_imgYilingquBg:setVisible(false)
	else
		self.m_btnDongjie:setVisible(true)
		--self.m_txtYilingqu:setVisible(true)
		--self.m_imgYilingquBg:setVisible(true)
	end
end

return HuodongDlgPay
