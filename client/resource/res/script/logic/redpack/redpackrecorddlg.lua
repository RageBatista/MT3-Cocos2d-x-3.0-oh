require "logic.dialog"
require "logic.redpack.redpackrecordcelldlg"

RedPackRecordDlg = {}
setmetatable(RedPackRecordDlg, Dialog)
RedPackRecordDlg.__index = RedPackRecordDlg

local _instance
function RedPackRecordDlg.getInstance()
	if not _instance then
		_instance = RedPackRecordDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function RedPackRecordDlg.getInstanceAndShow()
	if not _instance then
		_instance = RedPackRecordDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackRecordDlg.getInstanceNotCreate()
	return _instance
end

function RedPackRecordDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RedPackRecordDlg.ToggleOpenClose()
	if not _instance then
		_instance = RedPackRecordDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RedPackRecordDlg.GetLayoutFileName()
	return "hongbaojilu.layout"
end

function RedPackRecordDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackRecordDlg)
	return self
end

function RedPackRecordDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_time = winMgr:getWindow("hongbaojilu/time")
    self.m_dec = CEGUI.Window.toRichEditbox(winMgr:getWindow("hongbaojilu/dec"))
    self.m_num = winMgr:getWindow("hongbaojilu/num")
    self.m_money = winMgr:getWindow("hongbaojilu/fushi")
    self.m_List = winMgr:getWindow("hongbaojilu/list")
    self.m_img = winMgr:getWindow("hongbaojilu/fushitu")

    self.m_celldatas = {}
    self.m_index = 1
    local s = self.m_List:getPixelSize()
	self.m_TableView = TableView.create(self.m_List)
	self.m_TableView:setViewSize(s.width-20, s.height-20)
	self.m_TableView:setPosition(10, 10)
	self.m_TableView:setColumCount(1)
end
function RedPackRecordDlg:setData(data)
    local time = StringCover.getTimeStruct(data.time / 1000)
    local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday
    self.m_time:setText(yearCur.."-"..monthCur.."-"..dayCur)
    self.m_money:setText(MHSD_UTILS.GetMoneyFormatString(data.redpackallmoney))
    self.m_celldatas = data.redpackrolehisinfolist
    self.m_index = data.modeltype

    self.m_img:setProperty("Image", "set:common image:common_jinb")
    self:tableSortData()
    local s = self.m_List:getPixelSize()
	self.m_TableView:setCellCountAndSize(TableUtil.tablelength(self.m_celldatas), 335, 75)
	self.m_TableView:setDataSourceFunc(self, RedPackRecordDlg.tableViewGetCellAtIndex)
	self.m_TableView:reloadData()

    local num = TableUtil.tablelength(self.m_celldatas)

    self.m_num:setText(num.."/"..data.redpackallnum)

    local defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
    self.m_dec:Clear()
	self.m_dec:AppendText(CEGUI.String(data.redpackdes),defaultColor)
    self.m_dec:Refresh()
end

function RedPackRecordDlg:tableSortData()
    if TableUtil.tablelength(self.m_celldatas) > 2 then
        local minid = 0
        local maxid = 0
        local minValue = 0
        local maxValue = 0
        minid = 1
        maxid = 1
        minValue = self.m_celldatas[1].redpackmoney
        maxValue = self.m_celldatas[1].redpackmoney
        for i,v in pairs (self.m_celldatas) do
            if v.redpackmoney<minValue then
                minid = i
                minValue = v.redpackmoney
            end

        end
        local temp = self.m_celldatas[2]
        self.m_celldatas[2] = self.m_celldatas[minid]
        self.m_celldatas[minid] = temp
        for i,v in pairs (self.m_celldatas) do
            if v.redpackmoney>maxValue then
                maxid = i
                maxValue = v.redpackmoney
            end
        end

        temp = self.m_celldatas[1]
        self.m_celldatas[1] = self.m_celldatas[maxid]
        self.m_celldatas[maxid] = temp
    elseif TableUtil.tablelength(self.m_celldatas) == 2 then
        if self.m_celldatas[1].redpackmoney < self.m_celldatas[2].redpackmoney then
            temp = self.m_celldatas[1]
            self.m_celldatas[1] = self.m_celldatas[2]
            self.m_celldatas[2] = temp
        end
    end



end
function RedPackRecordDlg:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = RedPackRecordCellDlg.CreateNewDlg(tableView.container)
	end
    local manager = require"logic.redpack.redpackmanager".getInstance()
	cell:setCellData(self.m_celldatas[idx + 1], self.m_index)
    cell:setCellIdex(idx + 1)
	cell.window:setID(idx)
	return cell
end
return RedPackRecordDlg