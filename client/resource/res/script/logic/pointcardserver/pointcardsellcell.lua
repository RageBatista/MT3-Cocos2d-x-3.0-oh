PointCardSellCell = {}

setmetatable(PointCardSellCell, Dialog)
PointCardSellCell.__index = PointCardSellCell
local prefix = 0

function PointCardSellCell.CreateNewDlg(parent)
	local newDlg = PointCardSellCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function PointCardSellCell.GetLayoutFileName()
	return "cashexchange_sellcell.layout"
end

function PointCardSellCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PointCardSellCell)
	return self
end

function PointCardSellCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.m_txtNum = winMgr:getWindow(prefixstr.."jimaicell/shuliang")
    self.m_txtUnit = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr.."jimaicell/danjia"))
    self.m_btnDelete = winMgr:getWindow(prefixstr.."jimaicell/delete")
    self.m_txtUnit:setTextLineVertCenter(true)
    self.window = CEGUI.Window.toPushButton(winMgr:getWindow(prefixstr.."jimaicell"))
    self.m_index = winMgr:getWindow(prefixstr.."jimaicell/zhonglei")
end
function PointCardSellCell:setDataForSpot(data, index, count)
    self.m_txtNum:setText(data.num)

    local strbuilder = StringBuilder.new()
    strbuilder:Set("parameter1", tostring(MoneyFormat(data.price)))
    local str = strbuilder:GetString(MHSD_UTILS.get_resstring(11557))
    strbuilder:delete()
    
    self.m_txtUnit:Clear()
    self.m_txtUnit:AppendParseText(CEGUI.String(str))    
    self.m_txtUnit:Refresh() 

    self.m_btnDelete:setVisible(false)
    self.window:setMousePassThroughEnabled(false)
    self.m_index:setText(MHSD_UTILS.get_resstring(11579)..(count - index + 1))
end
function PointCardSellCell:setDataForRole(data, index, count)
    self.m_txtNum:setText(data.num)

    local strbuilder = StringBuilder.new()
    strbuilder:Set("parameter1", tostring(MoneyFormat(data.price)))
    local str = strbuilder:GetString(MHSD_UTILS.get_resstring(11557))
    strbuilder:delete()
    
    self.m_txtUnit:Clear()
    self.m_txtUnit:AppendParseText(CEGUI.String(str))    
    self.m_txtUnit:Refresh() 

    self.m_btnDelete:setVisible(true)
    self.window:setMousePassThroughEnabled(true)
    self.m_index:setText(MHSD_UTILS.get_resstring(11579)..(count - index + 1))
end
return PointCardSellCell