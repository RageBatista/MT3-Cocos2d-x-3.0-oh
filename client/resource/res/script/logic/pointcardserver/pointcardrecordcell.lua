PointCardRecordCell = {}

setmetatable(PointCardRecordCell, Dialog)
PointCardRecordCell.__index = PointCardRecordCell
local prefix = 0

function PointCardRecordCell.CreateNewDlg(parent)
	local newDlg = PointCardRecordCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function PointCardRecordCell.GetLayoutFileName()
	return "cashexchange_record.layout"
end

function PointCardRecordCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PointCardRecordCell)
	return self
end

function PointCardRecordCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.m_txt = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr.."jiaoyijilu/neirong"))
    self.window = CEGUI.Window.toPushButton(winMgr:getWindow(prefixstr.."jiaoyijilu"))
end

function PointCardRecordCell:setData(data)
	local time = StringCover.getTimeStruct(data.tradingtime / 1000)
    --¼ÆËãÐÇÆÚ
    local strmsg = ""
	local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday
    local hour = time.tm_hour
    local min = time.tm_min
    if time.tm_hour < 10 then
        hour = "0"..hour
    end
    if time.tm_min < 10 then
        min = "0"..min
    end

    local strbuilder = StringBuilder:new()
    strbuilder:Set("parameter1", tostring(yearCur))
    strbuilder:Set("parameter2", tostring(monthCur))
    strbuilder:Set("parameter3", tostring(dayCur))
    strbuilder:Set("parameter4", tostring(hour..":"..min))
    strbuilder:Set("parameter5", tostring(data.num))
    strbuilder:Set("parameter6", tostring(MoneyFormat(data.price)))
    local content = strbuilder:GetString(MHSD_UTILS.get_resstring(11509))
    if data.tradingtype == 0 then
        content = strbuilder:GetString(MHSD_UTILS.get_resstring(11510))
    else
        content = strbuilder:GetString(MHSD_UTILS.get_resstring(11509))
    end
    strbuilder:delete()
    self.m_txt:Clear()
    self.m_txt:AppendParseText(CEGUI.String(content))
        
    self.m_txt:Refresh()
end

return PointCardRecordCell