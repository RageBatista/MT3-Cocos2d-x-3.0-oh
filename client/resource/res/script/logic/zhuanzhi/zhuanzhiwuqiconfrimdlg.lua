require "logic.dialog"

ZhuanZhiWuQiConfrimDlg = {}
setmetatable(ZhuanZhiWuQiConfrimDlg, Dialog)
ZhuanZhiWuQiConfrimDlg.__index = ZhuanZhiWuQiConfrimDlg

local _instance
function ZhuanZhiWuQiConfrimDlg.getInstance()
	if not _instance then
		_instance = ZhuanZhiWuQiConfrimDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiWuQiConfrimDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiWuQiConfrimDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiWuQiConfrimDlg.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiWuQiConfrimDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiWuQiConfrimDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiWuQiConfrimDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiWuQiConfrimDlg.GetLayoutFileName()
	return "zhuanzhiwuqiqueren.layout"
end

function ZhuanZhiWuQiConfrimDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiWuQiConfrimDlg)
	return self
end

function ZhuanZhiWuQiConfrimDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	local needmoney = GameTable.common.GetCCommonTableInstance():getRecorder(433).value

	self.m_NeedYinBi = winMgr:getWindow("zhuanzhiwuqiqueren/kuang/di/text")
	self.m_NeedYinBi:setText(formatMoneyString(needmoney))

	self.m_OKBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhiwuqiqueren/queren"))
	self.m_OKBtn:subscribeEvent("MouseButtonUp", ZhuanZhiWuQiConfrimDlg.HandlerOkBtn, self)

	self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhiwuqiqueren/quxiao"))
	self.m_CancelBtn:subscribeEvent("MouseButtonUp", ZhuanZhiWuQiConfrimDlg.HandlerCancelBtn, self)

	self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhiwuqiqueren/miaoshu"))

	self.m_key = 0
	self.m_id = 0

end

function ZhuanZhiWuQiConfrimDlg:SetInfoData(text1, text2, key , id)
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174008)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", text1)
	sb:Set("parameter2", text2)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	self.m_key = key
	self.m_id = id

	self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
	self.m_TextInfo:Refresh()
end

function ZhuanZhiWuQiConfrimDlg:HandlerOkBtn(e)
	local cmd = require "protodef.fire.pb.school.change.cchangeweapon".Create()
	cmd.srcweaponkey = self.m_key
	cmd.newweapontypeid = self.m_id
	LuaProtocolManager.getInstance():send(cmd)

	ZhuanZhiWuQiConfrimDlg.DestroyDialog()
end

function ZhuanZhiWuQiConfrimDlg:HandlerCancelBtn(e)
	ZhuanZhiWuQiConfrimDlg.DestroyDialog()
end

return ZhuanZhiWuQiConfrimDlg