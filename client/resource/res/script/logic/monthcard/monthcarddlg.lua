require "logic.dialog"

MonthCardDlg = {}
setmetatable(MonthCardDlg, Dialog)
MonthCardDlg.__index = MonthCardDlg

local _instance
function MonthCardDlg.getInstance()
	if not _instance then
		_instance = MonthCardDlg:new()
		_instance:OnCreate()
	end
	return _instance
end
function MonthCardDlg.getInstanceAndShow()
	if not _instance then
		_instance = MonthCardDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function MonthCardDlg.getInstanceNotCreate()
	return _instance
end

function MonthCardDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function MonthCardDlg.remove()
     _instance = nil
end
function MonthCardDlg.ToggleOpenClose()
	if not _instance then
		_instance = MonthCardDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MonthCardDlg.GetLayoutFileName()
	return "yueka.layout"
end

function MonthCardDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MonthCardDlg)
	return self
end

function MonthCardDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_bg = winMgr:getWindow("yueka")
	self.m_btnBuy = CEGUI.toPushButton(winMgr:getWindow("yueka/chongzhi"))
    self.m_btnBuy:subscribeEvent("MouseClick",MonthCardDlg.HandleBuyClicked,self)
	self.m_btnCharge = CEGUI.toPushButton(winMgr:getWindow("yueka/lingqumianfeifu"))
    self.m_btnCharge:subscribeEvent("MouseClick",MonthCardDlg.HandleGetClicked,self)
	self.m_btnCharge1 = CEGUI.toPushButton(winMgr:getWindow("yueka/lingqudiankafu"))
    self.m_btnCharge1:subscribeEvent("MouseClick",MonthCardDlg.HandleGetClicked,self)
    self.m_text = winMgr:getWindow("yueka/yuekazige")
    self.m_days = winMgr:getWindow("yueka/yuekazigetianshu")
    self.m_textTitle = winMgr:getWindow("yueka/wenben1")
    self.AwardList = CEGUI.toScrollablePane(winMgr:getWindow("yuekacc/yuekaccy/cczksp"))

    self.m_img1 = winMgr:getWindow("yueka/zongjia")
    self.m_img2 = winMgr:getWindow("yueka/xianjia")
    self.m_img3 = winMgr:getWindow("yueka/zongjiashuzhi")
    self.m_img4 = winMgr:getWindow("yueka/xianjiashuliang")
    self.m_img5 = winMgr:getWindow("yueka/fushi1")
    self.m_img6 = winMgr:getWindow("yueka/fushi2")
    self.m_img7 = winMgr:getWindow("yueka/hongcha")
    self.m_img8 = winMgr:getWindow("yueka/zhekou")
    
    
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            self.m_btnBuy:setVisible(false)
            self.m_btnCharge:setVisible(false)
            self.m_btnCharge1:setVisible(true)
            self.m_days:setVisible(false)
            self.m_text:setVisible(false)
            self.m_textTitle:setText(MHSD_UTILS.get_resstring(11566))
            self.m_img1:setVisible(false)
            self.m_img2:setVisible(false)
            self.m_img3:setVisible(false)
            self.m_img4:setVisible(false)
            self.m_img5:setVisible(false)
            self.m_img6:setVisible(false)
            self.m_img7:setVisible(false)
            self.m_img8:setVisible(false)
        else
            self.m_btnBuy:setVisible(true)
            self.m_btnCharge:setVisible(true)
            self.m_btnCharge1:setVisible(false)
            self.m_days:setVisible(true)
            self.m_text:setVisible(true)
            self.m_textTitle:setText(MHSD_UTILS.get_resstring(11565))
        end
    end
    

    self.m_listCell = {}
    for i = 1, 8 do
		local cell = CEGUI.toItemCell(winMgr:getWindow("yueka/ditu/wupin" .. i ))
		cell:setID(i)
		cell:subscribeEvent("MouseClick",MonthCardDlg.HandleItemClicked,self)
		table.insert(self.m_listCell, cell)
    end
    self:RefreshItem()
    self:RefreshTimeAndBtn()
    self.AwardList:EnableHorzScrollBar(true)
    self.AwardList:EnableAllChildDrag(self.AwardList)
end

function MonthCardDlg:RefreshTimeAndBtn()
    local mgr = LoginRewardManager.getInstanceNotCreate()
    if mgr then
	    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                if mgr.m_monthcardGet == 0 then
                    self.m_btnCharge1:setEnabled(false)
                    local lrmgr = LoginRewardManager.getInstanceNotCreate()
                    if lrmgr then
                        if lrmgr.m_monthcardEndTime > gGetServerTime() then
                            self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11564))
                        else
                            self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11563))
                        end
                    end
                else
                    self.m_btnCharge1:setEnabled(true)
                    self.m_btnCharge1:setText(MHSD_UTILS.get_resstring(11563))
                end

            else
                if mgr.m_monthcardGet == 0 then
                    self.m_btnCharge:setEnabled(false)
                    local lrmgr = LoginRewardManager.getInstanceNotCreate()
                    if lrmgr then
                        if lrmgr.m_monthcardEndTime > gGetServerTime() then
                            self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11564))
                        else
                            self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11563))
                        end
                    end
                else
                    self.m_btnCharge:setEnabled(true)
                    self.m_btnCharge:setText(MHSD_UTILS.get_resstring(11563))
                end
            end
        end
    end
end
function MonthCardDlg:update()
    local mgr = LoginRewardManager.getInstanceNotCreate()
    if mgr then
        if mgr.m_monthcardEndTime > gGetServerTime() then
            local time = mgr.m_monthcardEndTime - gGetServerTime()
            time = time / 1000 / 60 / 60 / 24
            time = math.floor(time)
            self.m_days:setText(tostring(time)..MHSD_UTILS.get_resstring(317))
            if time > 1 then
                self.m_days:setProperty("TextColours", "FF005B0F")
            else
                self.m_days:setProperty("TextColours", "FFFF0000")
            end
        else
            self.m_days:setText("0"..MHSD_UTILS.get_resstring(317))
            self.m_days:setProperty("TextColours", "FFFF0000")
        end
    end
end
function MonthCardDlg:HandleBuyClicked(args)
    local function ClickYes(self, args)
        -- local money = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
        -- if money < tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(360).value) then
            -- gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            -- CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_HearthStone, 0, 0, 0, 0)
            -- return true
        -- end
    local XilianshiItemId1 = GameTable.common.GetCCommonTableInstance():getRecorder(670)
	local XilianshiItemId = tonumber(XilianshiItemId1.value)
	local xilianshiCount = RoleItemManager.getInstance():GetItemNumByBaseID(XilianshiItemId1)
	if xilianshiCount < 0 then 
		GetCTipsManager():AddMessageTipById(193445)
		return
	end
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        local p = require("protodef.fire.pb.fushi.monthcard.cbuymonthcard"):new()
	    LuaProtocolManager:send(p)
    end
    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        end
        return true
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_resstring(11562), ClickYes, 
    self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))    
end
function MonthCardDlg:HandleGetClicked(args)
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    local p = require("protodef.fire.pb.fushi.monthcard.cgrabmonthcardrewardall"):new()
    LuaProtocolManager:send(p)    
end
function MonthCardDlg:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
    local strTable = "fushi.cmonthcardconfig"
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
	local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(index)

    if cfg then
    	local Commontipdlg = require "logic.tips.commontipdlg"
	    local commontipdlg = Commontipdlg.getInstanceAndShow()
	    local nType = Commontipdlg.eType.eNormal
	    local nItemId = cfg.itemid
	    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end
function MonthCardDlg:RefreshItem()
    local strTable = "fushi.cmonthcardconfig"
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            strTable = "fushi.cmonthcardconfigpay"
        end
    end
	for i, v in pairs( self.m_listCell ) do
		local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(i)
        local itembean = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(cfg.itemid)
        if itembean then
		    v:SetImage(gGetIconManager():GetItemIconByID( itembean.icon))
            SetItemCellBoundColorByQulityItemWithId(v,itembean.id)
            if cfg.itemnum > 1 then
		        v:SetTextUnitText(CEGUI.String("X"..cfg.itemnum))
            else
                v:SetTextUnitText(CEGUI.String(""))
            end
            ShowItemTreasureIfNeed(v,itembean.id)
        end
    end

end
return MonthCardDlg
