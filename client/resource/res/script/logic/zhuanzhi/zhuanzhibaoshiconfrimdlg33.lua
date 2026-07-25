require "logic.dialog"

ZhuanZhiBaoShiConfrimDlg33 = {}
setmetatable(ZhuanZhiBaoShiConfrimDlg33, Dialog)
ZhuanZhiBaoShiConfrimDlg33.__index = ZhuanZhiBaoShiConfrimDlg33

local _instance
function ZhuanZhiBaoShiConfrimDlg33.getInstance()
	if not _instance then
		_instance = ZhuanZhiBaoShiConfrimDlg33:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiBaoShiConfrimDlg33.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiBaoShiConfrimDlg33:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiBaoShiConfrimDlg33.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiBaoShiConfrimDlg33.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiBaoShiConfrimDlg33.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiBaoShiConfrimDlg33:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiBaoShiConfrimDlg33.GetLayoutFileName()
	return "zhuanzhibaoshiqueren.layout"
end

function ZhuanZhiBaoShiConfrimDlg33:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiBaoShiConfrimDlg33)
	return self
end

function ZhuanZhiBaoShiConfrimDlg33:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_TextInfo = CEGUI.toRichEditbox(winMgr:getWindow("zhuanzhibaoshiqueren/miaoshu"))

	self.m_OKBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhibaoshiqueren/queren"))
	self.m_OKBtn:subscribeEvent("MouseButtonUp", ZhuanZhiBaoShiConfrimDlg33.HandlerOkBtn, self)

	self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("zhuanzhibaoshiqueren/quxiao"))
	self.m_CancelBtn:subscribeEvent("MouseButtonUp", ZhuanZhiBaoShiConfrimDlg33.HandlerCancelBtn, self)

	self.m_CurID = -1
	self.m_NextID = -1

	self:GetWindow():setAlwaysOnTop(true)
end

function ZhuanZhiBaoShiConfrimDlg33:SetInfoData(text1, text2, curid, nextid)

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(192300)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", text1)
	sb:Set("parameter2", text2)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	self.m_TextInfo:AppendParseText(CEGUI.String(strmsg), false)
	self.m_TextInfo:Refresh()

	self.m_CurID = curid
	self.m_NextID = nextid
end

function ZhuanZhiBaoShiConfrimDlg33:HandlerOkBtn(e)
	local cmd = require "protodef.fire.pb.school.change.cchangegem33".Create()
	cmd.gemkey = self.m_CurID
	cmd.newgemitemid = self.m_NextID
	LuaProtocolManager.getInstance():send(cmd)

	ZhuanZhiBaoShiConfrimDlg33.DestroyDialog()
end

function ZhuanZhiBaoShiConfrimDlg33:HandlerCancelBtn(e)
	ZhuanZhiBaoShiConfrimDlg33.DestroyDialog()
end

return ZhuanZhiBaoShiConfrimDlg33