------------------------------------------------------------------
-- 宠物放生输入验证码
------------------------------------------------------------------
require "logic.dialog"

PetFreeConfirm = {}
setmetatable(PetFreeConfirm, Dialog)
PetFreeConfirm.__index = PetFreeConfirm

local _instance
function PetFreeConfirm.getInstance()
	if not _instance then
		_instance = PetFreeConfirm:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetFreeConfirm.getInstanceAndShow()
	if not _instance then
		_instance = PetFreeConfirm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetFreeConfirm.getInstanceNotCreate()
	return _instance
end

function PetFreeConfirm.DestroyDialog()
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

function PetFreeConfirm.ToggleOpenClose()
	if not _instance then
		_instance = PetFreeConfirm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetFreeConfirm.GetLayoutFileName()
	return "petfangsheng.layout"
end

function PetFreeConfirm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetFreeConfirm)
	return self
end

function PetFreeConfirm:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        -- 保存动画实例
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function PetFreeConfirm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("petfangsheng/framewindow"))
	self.desText = winMgr:getWindow("petfangsheng/text")
	self.inputNum = winMgr:getWindow("petfangsheng/bg/shurukuang/inputNum")
	self.numText = winMgr:getWindow("petfangsheng/bg/bg2/text1")
	self.placeholder = winMgr:getWindow("petfangsheng/bg/shurukuang/placeholder")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("petfangsheng/buton1"))
	self:addButtonAnimation(self.cancelBtn, "studyBtnPress")
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("petfangsheng/buton2"))
	self:addButtonAnimation(self.freeBtn, "studyBtnPress")

	self.freeBtn:subscribeEvent("Clicked", PetFreeConfirm.handleFreeClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", PetFreeConfirm.DestroyDialog, nil)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", PetFreeConfirm.DestroyDialog, nil)
	self.inputNum:subscribeEvent("MouseButtonDown", PetFreeConfirm.handleInputNumClicked, self)

	self:randomNumber()
end

function PetFreeConfirm:randomNumber()
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

function PetFreeConfirm:setPetData(petData)
	self.petData = petData
	local str = self.desText:getText()
	str = string.gsub(str, "name", petData.name)
	str = string.gsub(str, "level", petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	self.desText:setText(str)
end

function PetFreeConfirm:onInputChanged(num)
	self.inputNum:setText(num)
end

function PetFreeConfirm:handleInputNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	self.placeholder:setVisible(false)
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.inputNum)
		dlg:setMaxLength(4)
		dlg:setInputChangeCallFunc(PetFreeConfirm.onInputChanged, self)
		self.inputNum:setText("")
		
		local p = self.inputNum:GetScreenPos()
		local s = self.inputNum:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end

function PetFreeConfirm:handleFreeClicked(args)
	if self.inputNum:getText() ~= self.numText:getText() then
		GetCTipsManager():AddMessageTipById(150075) --验证码不匹配
		return
	end
	local p = require("protodef.fire.pb.pet.cfreepet1"):new()
	p.petkeys = { self.petData.key }
	LuaProtocolManager.getInstance():send(p)
	PetFreeConfirm.DestroyDialog()
end

return PetFreeConfirm
