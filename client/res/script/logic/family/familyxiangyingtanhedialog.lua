require "logic.dialog"

FamilyXiangYingTanHeDialog = {}
setmetatable(FamilyXiangYingTanHeDialog, Dialog)
FamilyXiangYingTanHeDialog.__index = FamilyXiangYingTanHeDialog

local _instance
function FamilyXiangYingTanHeDialog.getInstance()
	if not _instance then
		_instance = FamilyXiangYingTanHeDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyXiangYingTanHeDialog.getInstanceAndShow()
	if not _instance then
		_instance = FamilyXiangYingTanHeDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyXiangYingTanHeDialog.getInstanceNotCreate()
	return _instance
end

function FamilyXiangYingTanHeDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyXiangYingTanHeDialog.ToggleOpenClose()
	if not _instance then
		_instance = FamilyXiangYingTanHeDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyXiangYingTanHeDialog.GetLayoutFileName()
	return "familytanhexiangying.layout"
end

function FamilyXiangYingTanHeDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyXiangYingTanHeDialog)
	return self
end

function FamilyXiangYingTanHeDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pFrameWindow = CEGUI.toFrameWindow(winMgr:getWindow("tanhexiangying/ditu"))
	self.m_pFrameWindow:getCloseButton():subscribeEvent("Clicked", FamilyXiangYingTanHeDialog.DestroyDialog, nil)

	--self.m_TouXiang = winMgr:getWindow("tanhexiangying/ditu/textbg/touxiang")
	self.m_Desc = CEGUI.toRichEditbox(winMgr:getWindow("tanhexiangying/ditu/textbg/richanbox"))
	self.m_Text = CEGUI.toRichEditbox(winMgr:getWindow("tanhexiangying/ditu/textbg/text"))
	self.m_RespNum = winMgr:getWindow("tanhexiangying/ditu/textbg/di/")
	self.m_RemainTime = winMgr:getWindow("tanhexiangying/ditu/textbg/di/1")

	self.m_XiangYingTanHeBtn = CEGUI.toPushButton(winMgr:getWindow("tanhexiangying/ditu/btn"))
    self.m_XiangYingTanHeBtn:subscribeEvent("Clicked", FamilyXiangYingTanHeDialog.OnXiangYingTanHe, self)

    self:refreshUI()
end

-- 定时器
function FamilyXiangYingTanHeDialog:update(delta)
    self:refreshTime()
end

-- 刷新界面
function FamilyXiangYingTanHeDialog:refreshUI()
    local datamanager = require "logic.faction.factiondatamanager"

    local sb = require "utils.stringbuilder":new()
    sb:SetNum("parameter1", datamanager.m_impeach.maxnum)
    local strDesc = MHSD_UTILS.get_resstring(11608)
    strDesc = sb:GetString(strDesc)
    sb:delete()
    self.m_Desc:Clear()
    self.m_Desc:AppendParseText(CEGUI.String(strDesc))
    self.m_Desc:Refresh()

    sb = require "utils.stringbuilder":new()
    sb:Set("parameter1", datamanager.m_impeach.name)
    local strText = MHSD_UTILS.get_resstring(11610)
    strText = sb:GetString(strText)
    sb:delete()
    self.m_Text:Clear()
    self.m_Text:AppendParseText(CEGUI.String(strText))
    self.m_Text:Refresh()

    local strRespNum = datamanager.m_impeach.curnum .. "/" .. datamanager.m_impeach.maxnum
    self.m_RespNum:setText(strRespNum)

    self:refreshTime()
end

-- 刷新倒计时
function FamilyXiangYingTanHeDialog:refreshTime()
    local datamanager = require "logic.faction.factiondatamanager"
    local t = GetTimeStrByNumber(60 * 60 -(gGetServerTime() - datamanager.m_impeach.time) / 1000)
    self.m_RemainTime:setText(t.m .. ':' .. t.s)
end

function FamilyXiangYingTanHeDialog:OnXiangYingTanHe()
    local function onConfirm(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local datamanager = require "logic.faction.factiondatamanager"
        datamanager.RequestImpeach(2)
    end

    local function onCancel(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
    end

    if gGetMessageManager() then
        gGetMessageManager():AddMessageBox(
            "", MHSD_UTILS.get_msgtipstring(172050),
            onConfirm, self, onCancel, self,
            eMsgType_Normal, 30000, 0, 0, nil,
            MHSD_UTILS.get_resstring(2037),
            MHSD_UTILS.get_resstring(2038))
    end
end

return FamilyXiangYingTanHeDialog