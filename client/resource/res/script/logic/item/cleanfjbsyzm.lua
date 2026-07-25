------------------------------------------------------------------
-- 分解宝石验证码
------------------------------------------------------------------
require "logic.dialog"

Cleanfjbsyzm = {}
setmetatable(Cleanfjbsyzm, Dialog)
Cleanfjbsyzm.__index = Cleanfjbsyzm

local _instance
function Cleanfjbsyzm.getInstance()
	if not _instance then
		_instance = Cleanfjbsyzm:new()
		_instance:OnCreate()
	end
	return _instance
end

function Cleanfjbsyzm.getInstanceAndShow()
	if not _instance then
		_instance = Cleanfjbsyzm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Cleanfjbsyzm.getInstanceNotCreate()
	return _instance
end

function Cleanfjbsyzm.DestroyDialog()
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

function Cleanfjbsyzm.ToggleOpenClose()
	if not _instance then
		_instance = Cleanfjbsyzm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Cleanfjbsyzm.GetLayoutFileName()
	return "cleanfjbsyzm.layout"
end

function Cleanfjbsyzm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Cleanfjbsyzm)
	return self
end

function Cleanfjbsyzm:addButtonAnimation(button, animationName)
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

function Cleanfjbsyzm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("cleanfjbsyzm/framewindow"))
	self.cc_Clean = winMgr:getWindow("cleanfjbsyzm/framewindow/qingbao")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_Clean)
    self.animationInstance:start()
	
    self.c_qbtips = CEGUI.toRichEditbox(winMgr:getWindow("cleanfjbsyzm/framewindow/qingbao/tishi"))
	self.c_qbtips:Clear()
    self.c_qbtips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7552)))
    self.c_qbtips:Refresh()
	
	self.inputNum = winMgr:getWindow("cleanfjbsyzm/bg/shurukuang/inputNum")
	self.numText = winMgr:getWindow("cleanfjbsyzm/bg/bg2/text1")
	self.placeholder = winMgr:getWindow("cleanfjbsyzm/bg/shurukuang/placeholder")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("cleanfjbsyzm/buton1"))
	self:addButtonAnimation(self.cancelBtn, "studyBtnPress")
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("cleanfjbsyzm/buton2"))
	self:addButtonAnimation(self.freeBtn, "studyBtnPress")
	self.freeBtn:subscribeEvent("Clicked", Cleanfjbsyzm.handleFreeClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", Cleanfjbsyzm.DestroyDialog, nil)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", Cleanfjbsyzm.DestroyDialog, nil)
	self.inputNum:subscribeEvent("MouseButtonDown", Cleanfjbsyzm.handleInputNumClicked, self)
	
	self:randomNumber()
end

function Cleanfjbsyzm:randomNumber()
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

function Cleanfjbsyzm:onInputChanged(num)
	self.inputNum:setText(num)
end

function Cleanfjbsyzm:handleInputNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	self.placeholder:setVisible(false)
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.inputNum)
		dlg:setMaxLength(4)
		dlg:setInputChangeCallFunc(Cleanfjbsyzm.onInputChanged, self)
		self.inputNum:setText("")
		
		local p = self.inputNum:GetScreenPos()
		local s = self.inputNum:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end

function Cleanfjbsyzm:handleFreeClicked(args)
    if self.inputNum:getText() ~= self.numText:getText() then
        GetCTipsManager():AddMessageTipById(150075) --验证码不匹配
        return
    end
    --  这里要修改为发送分解宝石的协议
    local p = require("protodef.fire.pb.item.callequipgemfenjie"):new() 
    p.fenjietype = 2 --  设置为 2， 表示分解宝石
    require("manager.luaprotocolmanager"):send(p) 
    Cleanfjbsyzm.DestroyDialog()
end

return Cleanfjbsyzm
