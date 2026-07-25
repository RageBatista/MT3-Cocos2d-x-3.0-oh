require "logic.dialog"

Libaoduihuanha = {}
setmetatable(Libaoduihuanha, Dialog)
Libaoduihuanha.__index = Libaoduihuanha

local _instance
function Libaoduihuanha.getInstance()
	if not _instance then
		_instance = Libaoduihuanha:new()
		_instance:OnCreate()
	end
	return _instance
end

function Libaoduihuanha.getInstanceAndShow()
	if not _instance then
		_instance = Libaoduihuanha:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Libaoduihuanha.getInstanceNotCreate()
	return _instance
end

function Libaoduihuanha.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Libaoduihuanha.ToggleOpenClose()
	if not _instance then
		_instance = Libaoduihuanha:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Libaoduihuanha.GetLayoutFileName()
	return "Libaoduihuanha_mtg.layout"
end

function Libaoduihuanha:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Libaoduihuanha)
	return self
end

function Libaoduihuanha:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    --输入框
	self.m_InputBox = CEGUI.toRichEditbox(winMgr:getWindow("libaoduihuanha_mtg/textbg/wenzidi/input"))
	
	self.m_InputBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_InputBox:getProperty("NormalTextColour")))
    --输入提示
	self.m_Tips = winMgr:getWindow("libaoduihuanha_mtg/textbg/wenzidi/qingshuru")
    --取消按钮
	self.m_NoBtn = CEGUI.toPushButton(winMgr:getWindow("libaoduihuanha_mtg/btn11"))
    --确定按钮
	self.m_YesBtn = CEGUI.toPushButton(winMgr:getWindow("libaoduihuanha_mtg/btn2"))
    --关闭按钮
	self.m_CloseBtn = CEGUI.toPushButton(winMgr:getWindow("libaoduihuanha_mtg/close"))

	self.m_NoBtn:subscribeEvent("Clicked", Libaoduihuanha.OnClickedNoBtn, self)
	self.m_YesBtn:subscribeEvent("Clicked", Libaoduihuanha.OnClickedYesBtn, self)
	self.m_CloseBtn:subscribeEvent("Clicked", Libaoduihuanha.OnClickedCloseBtn, self)

end

function Libaoduihuanha:OnClickedNoBtn(args)
            self:DestroyDialog()
end
--点击发送
function Libaoduihuanha:OnClickedYesBtn(args)
	local inputText = self.m_InputBox:GetPureText()
	local allid = BeanConfigManager.getInstance():GetTableByName("game.cbenefitcode"):getAllID()
	local ishave = false
	for key, value in pairs(allid) do
	 local code = BeanConfigManager.getInstance():GetTableByName("game.cbenefitcode"):getRecorder(value).code
		if inputText == code then
			ishave = true
		end
	end
	if not ishave then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(160326))
        return
	end
	local p = require"protodef.fire.pb.game.cbenefitcodeexchange":new()
	p.code=self.m_InputBox:GetPureText()
	require "manager.luaprotocolmanager":send(p)
end

function Libaoduihuanha:OnClickedCloseBtn(args)
        self:DestroyDialog()
end

function Libaoduihuanha:update(dt)
local text2 = self.m_InputBox:GetPureText()
   if text2 == "" and self.m_InputBox:hasInputFocus() then
       self.m_Tips:setVisible(true)
    else
        self.m_Tips:setVisible(false)
    end
end 

return Libaoduihuanha
