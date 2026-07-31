require "logic.dialog"

QQGiftDlg = {}
setmetatable(QQGiftDlg, Dialog)
QQGiftDlg.__index = QQGiftDlg

local _instance
function QQGiftDlg.getInstance()
	if not _instance then
		_instance = QQGiftDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function QQGiftDlg.getInstanceAndShow()
	if not _instance then
		_instance = QQGiftDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function QQGiftDlg.getInstanceNotCreate()
	return _instance
end
function QQGiftDlg.remove()
     _instance = nil
end
function QQGiftDlg.DestroyDialog()
	if _instance then 
	_instance.m_YesBtn.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function QQGiftDlg.ToggleOpenClose()
	if not _instance then
		_instance = QQGiftDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function QQGiftDlg.GetLayoutFileName()
	return "QQlibao.layout"
end

function QQGiftDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, QQGiftDlg)
	return self
end

function QQGiftDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function QQGiftDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_InputBox = CEGUI.toRichEditbox(winMgr:getWindow("QQBG/bg/lingquma/shuru"))
	self.m_InputBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_InputBox:getProperty("NormalTextColour")))
    self.m_YesBtn = CEGUI.toPushButton(winMgr:getWindow("QQBG/LingQuBtn"))
	self:addButtonAnimation(self.m_YesBtn, "studyBtnPress")
    self.m_YesBtn:subscribeEvent("Clicked", QQGiftDlg.OnClickedYesBtn, self)
    self.m_Tips = winMgr:getWindow("QQBG/bg/lingquma/inputtext")
    self.m_Url =winMgr:getWindow("QQBG/bg/tiaozhuan")
    self.m_Url:subscribeEvent("MouseClick", QQGiftDlg.OnClickedUrl, self)
end
function QQGiftDlg:OnClickedUrl(args)
    IOS_MHSD_UTILS.OpenURL(GameTable.common.GetCCommonTableInstance():getRecorder(366).value)
end
function QQGiftDlg:OnClickedYesBtn(args)
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

function QQGiftDlg:update(dt)
local text2 = self.m_InputBox:GetPureText()
   if text2 == "" and self.m_InputBox:hasInputFocus() then
       self.m_Tips:setVisible(true)
    else
        self.m_Tips:setVisible(false)
    end
end 
return QQGiftDlg