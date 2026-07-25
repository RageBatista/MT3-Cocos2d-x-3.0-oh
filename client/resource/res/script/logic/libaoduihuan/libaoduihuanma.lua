require "logic.dialog"

Libaoduihuanma = {}
setmetatable(Libaoduihuanma, Dialog)
Libaoduihuanma.__index = Libaoduihuanma

local _instance
function Libaoduihuanma.getInstance()
	if not _instance then
		_instance = Libaoduihuanma:new()
		_instance:OnCreate()
	end
	return _instance
end

function Libaoduihuanma.getInstanceAndShow()
	if not _instance then
		_instance = Libaoduihuanma:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Libaoduihuanma.getInstanceNotCreate()
	return _instance
end

function Libaoduihuanma.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Libaoduihuanma.ToggleOpenClose()
	if not _instance then
		_instance = Libaoduihuanma:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Libaoduihuanma.GetLayoutFileName()
	return "libaoduihuanma_mtg.layout"
end

function Libaoduihuanma:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Libaoduihuanma)
	return self
end

function Libaoduihuanma:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    --输入框
	self.m_InputBox = CEGUI.toRichEditbox(winMgr:getWindow("libaoduihuanma_mtg/textbg/wenzidi/input"))
    self.m_InputBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_InputBox:getProperty("NormalTextColour")))
    --输入提示
	self.m_Tips = winMgr:getWindow("libaoduihuanma_mtg/textbg/wenzidi/qingshuru")
    --取消按钮
	self.m_NoBtn = CEGUI.toPushButton(winMgr:getWindow("libaoduihuanma_mtg/btn11"))
    --确定按钮
	self.m_YesBtn = CEGUI.toPushButton(winMgr:getWindow("libaoduihuanma_mtg/btn2"))
    --关闭按钮
	self.m_CloseBtn = CEGUI.toPushButton(winMgr:getWindow("libaoduihuanma_mtg/close"))

	self.m_NoBtn:subscribeEvent("Clicked", Libaoduihuanma.OnClickedNoBtn, self)
	self.m_YesBtn:subscribeEvent("Clicked", Libaoduihuanma.OnClickedYesBtn, self)
	self.m_CloseBtn:subscribeEvent("Clicked", Libaoduihuanma.OnClickedCloseBtn, self)

end

function Libaoduihuanma:OnClickedNoBtn(args)
            self:DestroyDialog()
end
--点击发送
function Libaoduihuanma:OnClickedYesBtn(args)
local len = self.m_InputBox:GetCharCount()
if len<8 then
    GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160326))
    return
    
elseif len>8 then
 GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160325))
    return
end
    --发送兑换码
	local send = require "protodef.fire.pb.activity.exchangecode.cexchangecode":new()
	send.exchangecode = self.m_InputBox:GetPureText()
	send.npckey = 1
	require "manager.luaprotocolmanager":send(send)
    self:DestroyDialog()
end

function Libaoduihuanma:OnClickedCloseBtn(args)
        self:DestroyDialog()
end

function Libaoduihuanma:update(dt)
        local text2 = self.m_InputBox:GetPureText()
        self.m_Tips:setVisible((text2 == "" and self.m_InputBox:hasInputFocus()))
end

return Libaoduihuanma
