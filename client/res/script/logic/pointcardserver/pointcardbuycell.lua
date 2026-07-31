PointCardBuyCell = {}

setmetatable(PointCardBuyCell, Dialog)
PointCardBuyCell.__index = PointCardBuyCell
local prefix = 0

function PointCardBuyCell.CreateNewDlg(parent)
	local newDlg = PointCardBuyCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function PointCardBuyCell.GetLayoutFileName()
	return "cashexchange_buycell.layout"
end

function PointCardBuyCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PointCardBuyCell)
	return self
end

function PointCardBuyCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.m_txtNum = winMgr:getWindow(prefixstr.."qiugoucell/shuliang")
    self.m_txtUnit = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr.."qiugoucell/danjia"))
    self.m_btnDelete = winMgr:getWindow(prefixstr.."qiugoucell/delete")
    self.m_txtUnit:setTextLineVertCenter(true)
    self.window = CEGUI.Window.toPushButton(winMgr:getWindow(prefixstr.."qiugoucell"))
    self.m_index = winMgr:getWindow(prefixstr.."qiugoucell/zhonglei")
end
function PointCardBuyCell:setDataForSpot(data, index)

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
    self.m_index:setText(MHSD_UTILS.get_resstring(11578)..index)
end
function PointCardBuyCell:setDataForRole(data, index)
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
    self.m_index:setText(MHSD_UTILS.get_resstring(11578)..index)
end
return PointCardBuyCell