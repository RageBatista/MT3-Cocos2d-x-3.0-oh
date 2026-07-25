require "logic.dialog"

EquipSwitchExConfrimDlg = {}
setmetatable(EquipSwitchExConfrimDlg, Dialog)
EquipSwitchExConfrimDlg.__index = EquipSwitchExConfrimDlg

local _instance
function EquipSwitchExConfrimDlg.getInstance()
	if not _instance then
		_instance = EquipSwitchExConfrimDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function EquipSwitchExConfrimDlg.getInstanceAndShow()
	if not _instance then
		_instance = EquipSwitchExConfrimDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function EquipSwitchExConfrimDlg.getInstanceNotCreate()
	return _instance
end

function EquipSwitchExConfrimDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function EquipSwitchExConfrimDlg.ToggleOpenClose()
	if not _instance then
		_instance = EquipSwitchExConfrimDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function EquipSwitchExConfrimDlg.GetLayoutFileName()
	return "equipswitchconfrimdlg.layout"
end

function EquipSwitchExConfrimDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, EquipSwitchExConfrimDlg)
	return self
end

function EquipSwitchExConfrimDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()


	self.m_NeedYinBi = winMgr:getWindow("equipswitchconfrimdlg/kuang/di/text")
	self.m_NeedMatImg = CEGUI.toItemCell(winMgr:getWindow("equipswitchconfrimdlg/kuang/di/image"))

	self.m_OKBtn = CEGUI.toPushButton(winMgr:getWindow("equipswitchconfrimdlg/queren"))
	self.m_OKBtn:subscribeEvent("MouseButtonUp", EquipSwitchExConfrimDlg.HandlerOkBtn, self)

	self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("equipswitchconfrimdlg/quxiao"))
	self.m_CancelBtn:subscribeEvent("MouseButtonUp", EquipSwitchExConfrimDlg.HandlerCancelBtn, self)

	self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("equipswitchconfrimdlg/miaoshu"))

	self.m_key = 0
	self.m_id = 0

end

function EquipSwitchExConfrimDlg:SetInfoData(text1, text2, key , id, needmoney)
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(193449)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", text1)
	sb:Set("parameter2", text2)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	self.m_key = key
	self.m_id = id

	self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
	self.m_TextInfo:Refresh()

	self.m_NeedYinBi:setText(formatMoneyString(needmoney))

	--local itemNeedAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(needid)
	--if not itemNeedAttrCfg then
	--	return
	--end

	local costitemimage = gGetIconManager():GetImageByID(1186)
	self.m_NeedMatImg:SetImage(costitemimage)
end

function EquipSwitchExConfrimDlg:HandlerOkBtn(e)
	local cmd = require "protodef.fire.pb.school.change.cchangeequipex".Create()
	cmd.srcweaponkey = self.m_key
	cmd.tonewitem = self.m_id
	LuaProtocolManager.getInstance():send(cmd)
	
	EquipSwitchExConfrimDlg.DestroyDialog()
end

function EquipSwitchExConfrimDlg:HandlerCancelBtn(e)
	EquipSwitchExConfrimDlg.DestroyDialog()
end

return EquipSwitchExConfrimDlg