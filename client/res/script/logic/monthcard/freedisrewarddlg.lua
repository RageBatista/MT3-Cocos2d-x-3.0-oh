require "logic.dialog"
require "logic.monthcard.freedisrewardcell"

FreeDisRewardDlg = {}
setmetatable(FreeDisRewardDlg, Dialog)
FreeDisRewardDlg.__index = FreeDisRewardDlg

local _instance
function FreeDisRewardDlg.getInstance()
	if not _instance then
		_instance = FreeDisRewardDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function FreeDisRewardDlg.getInstanceAndShow()
	if not _instance then
		_instance = FreeDisRewardDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FreeDisRewardDlg.getInstanceNotCreate()
	return _instance
end

function FreeDisRewardDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FreeDisRewardDlg.ToggleOpenClose()
	if not _instance then
		_instance = FreeDisRewardDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FreeDisRewardDlg.GetLayoutFileName()
	return "ziyoufenpeilibao.layout"
end

function FreeDisRewardDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FreeDisRewardDlg)
	return self
end

function FreeDisRewardDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_id = 0
    self.m_Num = winMgr:getWindow("ziyoufenpeilibao/text3")
    self.m_btnCancel = CEGUI.toPushButton(winMgr:getWindow("ziyoufenpeilibao/cancel"))
    self.m_btnCancel:subscribeEvent("MouseClick", FreeDisRewardDlg.HandleCancelClicked, self)
    self.m_btnOk = CEGUI.toPushButton(winMgr:getWindow("ziyoufenpeilibao/cancel1"))
    self.m_btnOk:subscribeEvent("MouseClick", FreeDisRewardDlg.HandleOkClicked, self)
    self.m_btnOk:setEnabled(false)
    self.m_List = winMgr:getWindow("ziyoufenpeilibao/bg")
    self.m_ItemS = {}
    self.m_ItemNums = {}
    self.m_unNum = 0
    self.m_MaxNum = 0
    local s = self.m_List:getPixelSize()
	self.m_TableView = TableView.create(self.m_List)
	self.m_TableView:setViewSize(s.width-20, s.height-20)
	self.m_TableView:setPosition(10, 10)    
	self.m_TableView:setColumCount(2)
    self.m_TableView:setDataSourceFunc(self, FreeDisRewardDlg.tableViewGetCellAtIndex)
end
function FreeDisRewardDlg:HandleCancelClicked(e)
    FreeDisRewardDlg.DestroyDialog()
end
function FreeDisRewardDlg:HandleOkClicked(e)
    local p = require("protodef.fire.pb.fushi.monthcard.cgrabmonthcardreward"):new()
    p.itemid = self.m_id
    local itemsAndNum = {}
    for i = 1, #self.m_ItemNums do
        itemsAndNum[self.m_ItemS[i]] = self.m_ItemNums[i]
    end
    p.rewarddistribution = itemsAndNum
	LuaProtocolManager:send(p)
    FreeDisRewardDlg.DestroyDialog()
end
function FreeDisRewardDlg:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = FreedisRewardCell.CreateNewDlg(tableView.container)
        cell.m_item:subscribeEvent("MouseClick", FreeDisRewardDlg.HandleItemClicked, self)
	end
	cell.window:setID(idx)
    cell.m_item:setID(idx)
    cell:refreshUI(idx)
	return cell
end
function FreeDisRewardDlg:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position	
	local nPosX = touchPos.x
	local nPosY = touchPos.y
	
	local ewindow = CEGUI.toWindowEventArgs(args)
	local index = ewindow.window:getID()
    local id = self.m_ItemS[index + 1]
    if id then
    	local Commontipdlg = require "logic.tips.commontipdlg"
	    local commontipdlg = Commontipdlg.getInstanceAndShow()
	    local nType = Commontipdlg.eType.eNormal
	    local nItemId = id
	    commontipdlg:RefreshItem(nType,nItemId,nPosX,nPosY)
    end
end
function FreeDisRewardDlg:setId(id)
    self.m_id = id
    self:RefreshUI()
end
function FreeDisRewardDlg:RefreshUI()
    local strTable = "fushi.cfreedisrewardconfig"
	local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_isPointCardServer then
            strTable = "fushi.cfreedisrewardconfigpay"
        end
    end
    local cfg = BeanConfigManager.getInstance():GetTableByName(strTable):getRecorder(self.m_id)
    if cfg then
        self.m_unNum = cfg.num 
        self.m_MaxNum = cfg.num 
        self.m_Num:setText(cfg.num)
    end


    for i = 0, TableUtil.tablelength(cfg.itemids)-1 do 
        if cfg.itemids[i] ~= 0 then
            table.insert(self.m_ItemS, cfg.itemids[i])
        end
    end
    for i = 1, TableUtil.tablelength(self.m_ItemS) do 
        table.insert(self.m_ItemNums, 0)
    end
    self.m_TableView:setCellCountAndSize(TableUtil.tablelength(self.m_ItemNums), 280, 100)
	self.m_TableView:reloadData()
end
function FreeDisRewardDlg:ChangeNum(index, num)
    self.m_ItemNums[index + 1] = self.m_ItemNums[index + 1] - num
    self.m_unNum = self.m_unNum + num
    self.m_Num:setText(self.m_unNum)
    if self.m_unNum == 0 then
        --self.m_Num:setProperty("TextColours", "FF005B0F")
        self.m_btnOk:setEnabled(true)
    else
        --self.m_Num:setProperty("TextColours", "FFFF0000")
        self.m_btnOk:setEnabled(false)
    end
end
return FreeDisRewardDlg