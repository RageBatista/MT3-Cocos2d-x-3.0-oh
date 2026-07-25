------------------------------------------------------------------
-- 宠物验证码
------------------------------------------------------------------
require "logic.dialog"

Petyzm = {}
setmetatable(Petyzm, Dialog)
Petyzm.__index = Petyzm

local _instance
function Petyzm.getInstance()
	if not _instance then
		_instance = Petyzm:new()
		_instance:OnCreate()
	end
	return _instance
end

function Petyzm.getInstanceAndShow()
	if not _instance then
		_instance = Petyzm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Petyzm.getInstanceNotCreate()
	return _instance
end

function Petyzm.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Petyzm.ToggleOpenClose()
	if not _instance then
		_instance = Petyzm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Petyzm.GetLayoutFileName()
	return "petyzm.layout"
end

function Petyzm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Petyzm)
	return self
end

function Petyzm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("petyzm/framewindow"))
	self.desText = winMgr:getWindow("petyzm/text")
	self.inputNum = winMgr:getWindow("petyzm/bg/shurukuang/inputNum")
	self.numText = winMgr:getWindow("petyzm/bg/bg2/text1")
	self.placeholder = winMgr:getWindow("petyzm/bg/shurukuang/placeholder")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("petyzm/buton1"))
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("petyzm/buton2"))

	self.freeBtn:subscribeEvent("Clicked", Petyzm.handleFreeClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", Petyzm.DestroyDialog, nil)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", Petyzm.DestroyDialog, nil)
	self.inputNum:subscribeEvent("MouseButtonDown", Petyzm.handleInputNumClicked, self)
	self.petkey=0
	self.resultkey=0
	self:randomNumber()
end

function Petyzm:randomNumber()
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

function Petyzm:setData(petkey,petid)
	self.petkey=petkey
	self.resultkey=petid
	local str ="是否确认幻化当前宠物和造型？"
	self.desText:setText(str)
end

function Petyzm:onInputChanged(num)
	self.inputNum:setText(num)
end

function Petyzm:handleInputNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	self.placeholder:setVisible(false)
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.inputNum)
		dlg:setMaxLength(4)
		dlg:setInputChangeCallFunc(Petyzm.onInputChanged, self)
		self.inputNum:setText("")
		
		local p = self.inputNum:GetScreenPos()
		local s = self.inputNum:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end

function Petyzm:handleFreeClicked(args)
	if self.inputNum:getText() ~= self.numText:getText() then
		GetCTipsManager():AddMessageTipById(150075) --��֤�벻ƥ��
		return
	end
	 local p = require("protodef.fire.pb.pet.cpethuanhua").Create()
	 p.petkey = self.petkey
	 p.resultkey=self.resultkey
	 LuaProtocolManager:send(p)
	Petyzm.DestroyDialog()
	PetHuanHuaDlg.DestroyDialog()
end

return Petyzm
