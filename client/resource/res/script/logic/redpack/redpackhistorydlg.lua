require "logic.dialog"
require "logic.redpack.redpackhistorycelldlg"
RedPackHistoryDlg = {}
setmetatable(RedPackHistoryDlg, Dialog)
RedPackHistoryDlg.__index = RedPackHistoryDlg

local _instance
function RedPackHistoryDlg.getInstance()
	if not _instance then
		_instance = RedPackHistoryDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RedPackHistoryDlg.getInstanceAndShow()
	if not _instance then
		_instance = RedPackHistoryDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackHistoryDlg.getInstanceNotCreate()
	return _instance
end

function RedPackHistoryDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RedPackHistoryDlg.ToggleOpenClose()
	if not _instance then
		_instance = RedPackHistoryDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RedPackHistoryDlg.GetLayoutFileName()
	return "hongbaogerenjilu.layout"
end

function RedPackHistoryDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackHistoryDlg)
	return self
end

function RedPackHistoryDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", RedPackHistoryLabel.hide, nil)
    self.m_SendNum = winMgr:getWindow("hongbaogerenjilu/shuliang1")
    self.m_MoneyNum = winMgr:getWindow("hongbaogerenjilu/ziti")
    
    self.m_List = winMgr:getWindow("hongbaogerenjilu/List")
    self.m_Cover = winMgr:getWindow("hongbaogerenjilu/cover")
    self.m_SendTxt = winMgr:getWindow("hongbaogerenjilu/sendtxt")
    self.m_GetTxt = winMgr:getWindow("hongbaogerenjilu/gettxt")
    self.m_jinbi1 = winMgr:getWindow("hongbaogerenjilu/all1")
    self.m_jinbi2 = winMgr:getWindow("hongbaogerenjilu/jinbi")
    self.m_jinbi3 = winMgr:getWindow("hongbaogerenjilu/diban")
    
    self.m_fushi1 = winMgr:getWindow("hongbaogerenjilu/jinbi1")
    self.m_fushi2 = winMgr:getWindow("hongbaogerenjilu/diban1")
    self.m_fushi3 = winMgr:getWindow("hongbaogerenjilu/ziti2")
    self.m_Money1Num = winMgr:getWindow("hongbaogerenjilu/shuliang3")

    self.m_Cover:setVisible(false)
    local s = self.m_List:getPixelSize()
	self.m_TableView = TableView.create(self.m_List)
	self.m_TableView:setViewSize(s.width-20, s.height-20)
	self.m_TableView:setPosition(10, 10)
	self.m_TableView:setColumCount(2)
	self.m_TableView:setDataSourceFunc(self, RedPackHistoryDlg.tableViewGetCellAtIndex)
    self.m_index = 0
end
function RedPackHistoryDlg:setData(data)
    local manager = require"logic.redpack.redpackmanager".getInstance()
    if data.firstpageflag == 0 then
        manager.m_HistoryRedPack = {}
    end
    if data.redpackrolerecord ~= nil then
        for i,v in pairs (data.redpackrolerecord) do
            table.insert(manager.m_HistoryRedPack, v)
        end
    end
	self.m_TableView:setCellCountAndSize(TableUtil.tablelength(manager.m_HistoryRedPack), 300, 125)
	self.m_TableView:reloadData()
    self.m_SendNum:setText(tostring(data.redpackallnum))
    self.m_MoneyNum:setText(MHSD_UTILS.GetMoneyFormatString(data.redpackallmoney))
    self.m_Money1Num:setText(MHSD_UTILS.GetMoneyFormatString(data.redpackallfushi))
    self.m_Cover:setVisible(false)
end
function RedPackHistoryDlg:InitData(index)
    
    self.m_index = index
    if self.m_index  == 2 then
        self.m_SendTxt:setVisible(true)
        self.m_GetTxt:setVisible(false)
	    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                self.m_jinbi1:setVisible(true)
                self.m_jinbi2:setVisible(true)
                self.m_MoneyNum:setVisible(true)
                self.m_jinbi3:setVisible(true)
                self.m_fushi1:setVisible(false)
                self.m_fushi2:setVisible(false)
                self.m_fushi3:setVisible(false)
                self.m_Money1Num:setVisible(false)
            else    
                self.m_jinbi1:setVisible(false)
                self.m_jinbi2:setVisible(false)
                self.m_MoneyNum:setVisible(false)
                self.m_jinbi3:setVisible(false)   
                self.m_fushi1:setVisible(true)
                self.m_fushi2:setVisible(true)
                self.m_fushi3:setVisible(true)
                self.m_Money1Num:setVisible(true)
            end
        end
    else  
        self.m_SendTxt:setVisible(false)
        self.m_GetTxt:setVisible(true)
        self.m_jinbi1:setVisible(true)
        self.m_jinbi2:setVisible(true)
        self.m_MoneyNum:setVisible(true)
        self.m_jinbi3:setVisible(true)
        self.m_fushi1:setVisible(false)
        self.m_fushi2:setVisible(false)
        self.m_fushi3:setVisible(false)
        self.m_Money1Num:setVisible(false)
    end
    
end
function RedPackHistoryDlg:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = RedPackHistoryCellDlg.CreateNewDlg(tableView.container)
        cell.window:subscribeEvent("MouseClick", RedPackHistoryDlg.HandleCellClicked, self)
	end
    local manager = require"logic.redpack.redpackmanager".getInstance()
	cell:setCellData(manager.m_HistoryRedPack[idx + 1], self.m_index)
	cell.window:setID(idx)
	return cell
end
function RedPackHistoryDlg:HandleCellClicked(e)
    local eventargs = CEGUI.toWindowEventArgs(e)
    local id = eventargs.window:getID()
    local manager = require"logic.redpack.redpackmanager".getInstance()

    local p = require("protodef.fire.pb.fushi.redpack.csendredpackhisview"):new()
    p.modeltype = manager.m_HistoryRedPack[id + 1].modeltype
    p.redpackid = manager.m_HistoryRedPack[id + 1].redpackid
    LuaProtocolManager:send(p)
end
function RedPackHistoryDlg:Update(delta)
    local s = self.m_List:getPixelSize()
    local manager = require"logic.redpack.redpackmanager".getInstance()
    if TableUtil.tablelength(manager.m_HistoryRedPack) == 0 then
        return
    end
    local num = TableUtil.tablelength(manager.m_HistoryRedPack) % 2
    if num == 0 then
        num = math.floor(TableUtil.tablelength(manager.m_HistoryRedPack) / 2)
    else
        num = math.floor(TableUtil.tablelength(manager.m_HistoryRedPack) / 2) + 1
    end
    local height = math.floor(num * 120 - (s.height-20))

    if not self.m_Cover:isVisible() and num >= 25 then
        if self.m_TableView:getContentOffset() - height > 50 then
            self.m_Cover:setVisible(true)
            local p = require("protodef.fire.pb.fushi.redpack.csendredpackrolerecordview"):new()
            p.modeltype = self.m_index - 1
            p.redpackid = manager.m_HistoryRedPack[#manager.m_HistoryRedPack].redpackid
            LuaProtocolManager:send(p)
        end
    end
end
function RedPackHistoryDlg:Clear()
    self.m_TableView:setCellCount(0)
    self.m_TableView:reloadData()
    self.m_SendNum:setText("0")
    self.m_MoneyNum:setText("0")
    self.m_Money1Num:setText("0")
end
return RedPackHistoryDlg