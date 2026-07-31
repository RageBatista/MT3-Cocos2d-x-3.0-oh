------------------------------------------------------------------
-- 清包验证码
------------------------------------------------------------------
require "logic.dialog"

CleanBagyzm = {}
setmetatable(CleanBagyzm, Dialog)
CleanBagyzm.__index = CleanBagyzm

local _instance
function CleanBagyzm.getInstance()
	if not _instance then
		_instance = CleanBagyzm:new()
		_instance:OnCreate()
	end
	return _instance
end

function CleanBagyzm.getInstanceAndShow()
	if not _instance then
		_instance = CleanBagyzm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CleanBagyzm.getInstanceNotCreate()
	return _instance
end

function CleanBagyzm.DestroyDialog()
	if _instance then
	_instance.cancelBtn.animation:stop()
	_instance.freeBtn.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CleanBagyzm.ToggleOpenClose()
	if not _instance then
		_instance = CleanBagyzm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CleanBagyzm.GetLayoutFileName()
	return "cleanbagyzm.layout"
end

function CleanBagyzm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CleanBagyzm)
	return self
end

function CleanBagyzm:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function CleanBagyzm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("cleanbagyzm/framewindow"))
	self.cc_Clean = winMgr:getWindow("cleanbagyzm/framewindow/qingbao")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_Clean)
    self.animationInstance:start()
	
    self.c_qbtips = CEGUI.toRichEditbox(winMgr:getWindow("cleanbagyzm/framewindow/qingbao/tishi"))
	self.c_qbtips:Clear()
    self.c_qbtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7553)))
    self.c_qbtips:Refresh()
	
    self.m_CheckText = CEGUI.toEditbox(winMgr:getWindow("cleanbagyzm/bg/shurukuang/box")) 
    self.m_CheckText:SetNormalColourRect(0xFFBA8956);  -- 颜色文本
	
	self.inputNum = winMgr:getWindow("cleanbagyzm/bg/shurukuang/inputNum")
	self.numText = winMgr:getWindow("cleanbagyzm/bg/bg2/text1")
	self.placeholder = winMgr:getWindow("cleanbagyzm/bg/shurukuang/placeholder")
	
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("cleanbagyzm/buton1"))
	self:addButtonAnimation(self.cancelBtn, "studyBtnPress")
	
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("cleanbagyzm/buton2"))
	self:addButtonAnimation(self.freeBtn, "studyBtnPress")
    
	self.freeBtn:subscribeEvent("Clicked", CleanBagyzm.handleFreeClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", CleanBagyzm.DestroyDialog, nil)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", CleanBagyzm.DestroyDialog, nil)
	
	
    local randomId = math.random(820, 824)  
    --  读取随机字符-在通用配置表
    self.checktext = GameTable.common.GetCCommonTableInstance():getRecorder(randomId).value
    self.numText:setText("点击输入：" .. self.checktext) 
	
	self.m_pMainFrame:subscribeEvent("WindowUpdate", CleanBagyzm.HandleWindowUpdate, self)
end

function CleanBagyzm:HandleWindowUpdate()
    local text = self.m_CheckText:getText()
    self.numText:setVisible((text == "" and self.m_CheckText:hasInputFocus()))
end

function CleanBagyzm:handleFreeClicked(args)
    if self.m_CheckText:getText() ~= self.checktext then 
        GetCTipsManager():AddMessageTipById(150075) 
        return
    end
	local p = require("protodef.fire.pb.item.ccleanmainpack").Create()
	LuaProtocolManager.getInstance():send(p);
	CleanBagyzm.DestroyDialog()
	-- GetCTipsManager():AddMessageTipById(191287)
	-- 清包提示在GS已经有编号了，不用做
end

return CleanBagyzm
