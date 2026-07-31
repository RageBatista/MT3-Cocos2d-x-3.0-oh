RedPackRecordCellDlg = {}

setmetatable(RedPackRecordCellDlg, Dialog)
RedPackRecordCellDlg.__index = RedPackRecordCellDlg
local prefix = 0

function RedPackRecordCellDlg.CreateNewDlg(parent)
	local newDlg = RedPackRecordCellDlg:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function RedPackRecordCellDlg.GetLayoutFileName()
	return "hongbaolishijilu.layout"
end

function RedPackRecordCellDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, RedPackRecordCellDlg)
	return self
end

function RedPackRecordCellDlg:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.window = winMgr:getWindow(prefixstr.."hongbaojilucell")
    self.m_name = winMgr:getWindow(prefixstr.."hongbaojilucell/renming")
    self.img2 = winMgr:getWindow(prefixstr.."hongbaojilucell/tupian")
    self.img1 = winMgr:getWindow(prefixstr.."hongbaojilucell/tupian/pupian1")
    self.m_num = winMgr:getWindow(prefixstr.."hongbaojilucell/shuliang")
    self.m_img = winMgr:getWindow(prefixstr.."hongbaojilucell/jinbi")
end
function RedPackRecordCellDlg:setCellData(data, index)
    self.m_name:setText(data.rolename)
    self.m_num:setText(MHSD_UTILS.GetMoneyFormatString(data.redpackmoney))
    self.m_img:setProperty("Image", "set:common image:common_jinb")
end
function RedPackRecordCellDlg:setCellIdex(index)
    if index == 1 then
        local huoliColor = "FFFF00F0"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_num:setProperty("TextColours", textColor)
        self.img1:setVisible(true)
        self.img2:setVisible(false)
    elseif index == 2 then
        local huoliColor = "FFFFF2DF"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_num:setProperty("TextColours", textColor)
        self.img1:setVisible(false)
        self.img2:setVisible(true)
    else 
        local huoliColor = "FF00FF00"
	    local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
	    self.m_num:setProperty("TextColours", textColor)
        self.img1:setVisible(false)
        self.img2:setVisible(false)
    end

end
return RedPackRecordCellDlg