------------------------------------------------------------------
-- 分解装备验证码
------------------------------------------------------------------
require "logic.dialog"

Cleanfjzbyzm = {}
setmetatable(Cleanfjzbyzm, Dialog)
Cleanfjzbyzm.__index = Cleanfjzbyzm

local _instance
function Cleanfjzbyzm.getInstance()
	if not _instance then
		_instance = Cleanfjzbyzm:new()
		_instance:OnCreate()
	end
	return _instance
end

function Cleanfjzbyzm.getInstanceAndShow()
	if not _instance then
		_instance = Cleanfjzbyzm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Cleanfjzbyzm.getInstanceNotCreate()
	return _instance
end

function Cleanfjzbyzm.DestroyDialog()
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

function Cleanfjzbyzm.ToggleOpenClose()
	if not _instance then
		_instance = Cleanfjzbyzm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Cleanfjzbyzm.GetLayoutFileName()
	return "Cleanfjzbyzm.layout"
end

function Cleanfjzbyzm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Cleanfjzbyzm)
	return self
end

function Cleanfjzbyzm:addButtonAnimation(button, animationName)
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

function Cleanfjzbyzm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("cleanfjzbyzm/framewindow"))
	self.cc_Clean = winMgr:getWindow("cleanfjzbyzm/framewindow/qingbao")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_Clean)
    self.animationInstance:start()
	
    self.c_qbtips = CEGUI.toRichEditbox(winMgr:getWindow("cleanfjzbyzm/framewindow/qingbao/tishi"))
	self.c_qbtips:Clear()
    self.c_qbtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7551)))
    self.c_qbtips:Refresh()
	
	self.inputNum = winMgr:getWindow("cleanfjzbyzm/bg/shurukuang/inputNum")
	self.numText = winMgr:getWindow("cleanfjzbyzm/bg/bg2/text1")
	self.placeholder = winMgr:getWindow("cleanfjzbyzm/bg/shurukuang/placeholder")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("cleanfjzbyzm/buton1"))
	self:addButtonAnimation(self.cancelBtn, "studyBtnPress")
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("cleanfjzbyzm/buton2"))
	self:addButtonAnimation(self.freeBtn, "studyBtnPress")
	self.freeBtn:subscribeEvent("Clicked", Cleanfjzbyzm.handleFreeClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", Cleanfjzbyzm.DestroyDialog, nil)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", Cleanfjzbyzm.DestroyDialog, nil)
	self.inputNum:subscribeEvent("MouseButtonDown", Cleanfjzbyzm.handleInputNumClicked, self)
	
	self:randomNumber()
end

function Cleanfjzbyzm:randomNumber()
	local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	local r = {}
	
	--math.randomseed(os.time())
	for i=1, 4 do
		local idx = math.random(1, #t)
		table.insert(r, t[idx])
		table.remove(t, idx)
	end
	
	self.numText:setText(table.concat(r))
end

function Cleanfjzbyzm:onInputChanged(num)
	self.inputNum:setText(num)
end

function Cleanfjzbyzm:handleInputNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	self.placeholder:setVisible(false)
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.inputNum)
		dlg:setMaxLength(4)
		dlg:setInputChangeCallFunc(Cleanfjzbyzm.onInputChanged, self)
		self.inputNum:setText("")
		
		local p = self.inputNum:GetScreenPos()
		local s = self.inputNum:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end

function Cleanfjzbyzm:handleFreeClicked(args)
    if self.inputNum:getText() ~= self.numText:getText() then
        GetCTipsManager():AddMessageTipById(150075) -- 验证码不对，提示
        return
    end
    -- 发送分解装备的协议
    local p = require("protodef.fire.pb.item.callequipgemfenjie"):new() 
    p.fenjietype = 1 -- 设置分解类型，1 表示分解装备
    require("manager.luaprotocolmanager"):send(p) -- 发送协议
    Cleanfjzbyzm.DestroyDialog() 
end

return Cleanfjzbyzm
