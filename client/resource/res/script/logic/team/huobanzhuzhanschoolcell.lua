huobanzhuzhanSchoolCell = {}

setmetatable(huobanzhuzhanSchoolCell, Dialog)
huobanzhuzhanSchoolCell.__index = huobanzhuzhanSchoolCell
local prefix = 0

function huobanzhuzhanSchoolCell.CreateNewDlg(parent)
	local newDlg = huobanzhuzhanSchoolCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function huobanzhuzhanSchoolCell.GetLayoutFileName()
	return "leitaishaixuancell_mtg.layout"
end

function huobanzhuzhanSchoolCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, huobanzhuzhanSchoolCell)
	return self
end

function huobanzhuzhanSchoolCell:OnCreate(parent)
	prefix = prefix + 1
    local prefixstr = tostring(prefix).."huoban"
	Dialog.OnCreate(self, parent, prefixstr)

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_Btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "leitaishaixuancell_mtg/btn1"))
    self.m_Bg = winMgr:getWindow(prefixstr .. "leitaishaixuancell_mtg")
    self.m_Btn:SetMouseLeaveReleaseInput(false)
    self.m_Btn:EnableClickAni(false)
    self.m_Text = winMgr:getWindow(prefixstr .. "leitaishaixuancell_mtg/text")
    self.m_Btn:subscribeEvent("Clicked", huobanzhuzhanSchoolCell.HandleSchoolBtn, self)
    self.m_Text:subscribeEvent("Clicked", huobanzhuzhanSchoolCell.HandleSchoolBtn, self)
    self.m_Bg:subscribeEvent("Clicked", huobanzhuzhanSchoolCell.HandleSchoolBtn, self)
    self.m_id = 0

end
function huobanzhuzhanSchoolCell:HandleSchoolBtn(e)
    local dlg = require "logic.team.huobanzhuzhandialog".getInstanceNotCreate()
    if dlg then
        dlg:HandleSchoolFilter(self.m_id)
        dlg:CloseSchoolBtn()
    end

end
function huobanzhuzhanSchoolCell:init(id, bln)
    local schoolrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(id)
    self.m_Btn:setProperty("NormalImage", schoolrecord.normalbtnimage)
    self.m_Btn:setProperty("PushedImage", schoolrecord.pushbtnimage)
    self.m_Text:setText(schoolrecord.name)
    self.m_id = id
end
return huobanzhuzhanSchoolCell
