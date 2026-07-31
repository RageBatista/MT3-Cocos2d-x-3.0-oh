require "logic.dialog"

ZhuanZhiConfrimDlg = {}
setmetatable(ZhuanZhiConfrimDlg, Dialog)
ZhuanZhiConfrimDlg.__index = ZhuanZhiConfrimDlg

local _instance
function ZhuanZhiConfrimDlg.getInstance()
	if not _instance then
		_instance = ZhuanZhiConfrimDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ZhuanZhiConfrimDlg.getInstanceAndShow()
	if not _instance then
		_instance = ZhuanZhiConfrimDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ZhuanZhiConfrimDlg.getInstanceNotCreate()
	return _instance
end

function ZhuanZhiConfrimDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ZhuanZhiConfrimDlg.ToggleOpenClose()
	if not _instance then
		_instance = ZhuanZhiConfrimDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ZhuanZhiConfrimDlg.GetLayoutFileName()
	return "zhuanzhiqueren.layout"
end

function ZhuanZhiConfrimDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiConfrimDlg)
	return self
end

function ZhuanZhiConfrimDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_CheckText = CEGUI.toEditbox(winMgr:getWindow("FrameWindow3/di/wenzidi/box"))
	self.m_CheckText:SetNormalColourRect(0xff50321a);
	self.NamePlaceHolder = winMgr:getWindow("FrameWindow3/di/wenzidi/text")

	self.m_ConfrimBtn = CEGUI.toPushButton(winMgr:getWindow("FrameWindow3/queren"))
	self.m_ConfrimBtn:subscribeEvent("MouseButtonUp", ZhuanZhiConfrimDlg.HandleConfrimCallBack, self)

	self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("FrameWindow3/quxiao"))
	self.m_CancelBtn:subscribeEvent("MouseButtonUp", ZhuanZhiConfrimDlg.HandleCancelCallBack, self)

	self.m_CurHeadIcon = CEGUI.toItemCell(winMgr:getWindow("FrameWindow3/zhuanzhiqian/xingxiang"))
	self.m_NextHeadIcon = CEGUI.toItemCell(winMgr:getWindow("FrameWindow3/zhuanzhihou/xingxiang2"))

	self.m_CurSchoolText = winMgr:getWindow("FrameWindow3/zhuanzhiqian/text1")
	self.m_CurClassText = winMgr:getWindow("FrameWindow3/zhuanzhiqian/text2")

	self.m_NextSchoolText = winMgr:getWindow("FrameWindow3/zhuanzhihou/text1")
	self.m_NextClassText = winMgr:getWindow("FrameWindow3/zhuanzhihou/text2")

	self.m_NeedMoneyText = winMgr:getWindow("FrameWindow3/jinbidi/zhi")

	self.m_TransTips = CEGUI.toRichEditbox(winMgr:getWindow("FrameWindow3/di/box"))

	self.m_pMainFrame:subscribeEvent("WindowUpdate", ZhuanZhiConfrimDlg.HandleWindowUpdate, self)

end

function ZhuanZhiConfrimDlg:RefreshData(sharpid, classid, money)
	self.m_SharpID = sharpid
	self.m_ClassID = classid
	self.m_NeedMoney = money

	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape())
	local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID())

	local NextShape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(SchoolID[1][self.m_SharpID])
	local NextSchool = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(ZhiYeStrID[1][self.m_SharpID][self.m_ClassID])

	self.m_CurHeadIcon:SetImage(gGetIconManager():GetImageByID(Shape.littleheadID))
	self.m_NextHeadIcon:SetImage(gGetIconManager():GetImageByID(NextShape.littleheadID))

	self.m_CurSchoolText:setText(Shape.name)
	self.m_CurClassText:setText(school.name)

	self.m_NextSchoolText:setText(NextShape.name)
	self.m_NextClassText:setText(NextSchool.name)

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(174008)

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", Shape.name..school.name)
	sb:Set("parameter2", NextShape.name..NextSchool.name)
	local strmsg = sb:GetString(tip.msg)
	sb:delete()

	self.m_TransTips:AppendParseText(CEGUI.String(strmsg), false)
	self.m_TransTips:Refresh()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local numStr1 = formatMoneyString(money)

	self.m_NeedMoneyText:setText(numStr1)
end

function ZhuanZhiConfrimDlg:HandleConfrimCallBack(e)
	local text = self.m_CheckText:getText()
	local checktext = GameTable.common.GetCCommonTableInstance():getRecorder(429).value
	if text ~= checktext then
		GetCTipsManager():AddMessageTipById(174005)
		return
	end

	local tmpmoney = CurrencyManager.getOwnCurrencyMount(fire.pb.game.MoneyType.MoneyType_HearthStone)
	if tonumber(self.m_NeedMoney) > tmpmoney then
		GetCTipsManager():AddMessageTipById(150506)
		return
	end
	local cmd = require "protodef.fire.pb.school.change.cchangeschool".Create()
	cmd.newshape = TableID[1][self.m_SharpID] --���id��Ӧ��ɫ�������е�id
	cmd.newschool = ZhiYeStrID[1][self.m_SharpID][self.m_ClassID]
	LuaProtocolManager.getInstance():send(cmd)
end

function ZhuanZhiConfrimDlg:HandleCancelCallBack(e)

	ZhuanZhiConfrimDlg.DestroyDialog()
end

function ZhuanZhiConfrimDlg:HandleWindowUpdate()
    local text = self.m_CheckText:getText()
    self.NamePlaceHolder:setVisible((text == "" and self.m_CheckText:hasInputFocus()))
end

return ZhuanZhiConfrimDlg