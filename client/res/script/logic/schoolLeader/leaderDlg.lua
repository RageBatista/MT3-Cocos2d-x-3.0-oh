require "logic.dialog"
require "logic.schoolLeader.leaderCell"

leaderDlg = {}
setmetatable(leaderDlg, Dialog)
leaderDlg.__index = leaderDlg

local _instance
function leaderDlg.getInstance()
	if not _instance then
		_instance = leaderDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function leaderDlg.getInstanceAndShow()
	if not _instance then
		_instance = leaderDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function leaderDlg.getInstanceNotCreate()
	return _instance
end

function leaderDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            if _instance.m_tableview then
                _instance.m_tableview:destroyCells()
            end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function leaderDlg.ToggleOpenClose()
	if not _instance then
		_instance = leaderDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function leaderDlg.GetLayoutFileName()
	return "lingxiu_mtg.layout"
end

function leaderDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, leaderDlg)
	return self
end

function leaderDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.list = CEGUI.toScrollablePane(winMgr:getWindow("lingxiu_mtg/list"))
    self.background = winMgr:getWindow("lingxiu_mtg/diban2")
    self.background:setVisible(false)
    local info = require "logic.schoolLeader.leaderManager":getDataInfo()
    if #info == 0 then
        self.background:setVisible(true)
    end
    self:initData()
end

function leaderDlg:initData()
    if not self.m_tableview then
        local s = self.list:getPixelSize()
        self.m_tableview = TableView.create(self.list, TableView.HORIZONTAL)
        self.m_tableview:setViewSize(s.width, s.height)
        self.m_tableview:setPosition(5, 10)
        self.m_tableview:setDataSourceFunc(self, leaderDlg.tableViewGetCellAtIndex)
    end
    local info = require "logic.schoolLeader.leaderManager":getDataInfo()
    self.m_tableview:setCellCountAndSize(#info, 256, 525)
    self.m_tableview:setContentOffset(0)
    self.m_tableview:reloadData()
end

function leaderDlg:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        cell = leaderCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
    end
    cell:setInfo(idx+1)
    return cell
end

function leaderDlg:refreshTickets(roleId, tickets)
    for k,v in pairs(self.m_tableview.visibleCells) do
        if v.btnSelect:getID() == roleId then
            v.ticketNum:setText(tostring(tickets))
        end
    end
end

return leaderDlg