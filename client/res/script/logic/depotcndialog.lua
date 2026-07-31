require "logic.dialog"

depotcndialog = {}
setmetatable(depotcndialog, Dialog)
depotcndialog.__index = depotcndialog

local _instance
function depotcndialog.getInstance()
	if not _instance then
		_instance = depotcndialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function depotcndialog.getInstanceAndShow()
	if not _instance then
		_instance = depotcndialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function depotcndialog.getInstanceNotCreate()
	return _instance
end

function depotcndialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function depotcndialog.ToggleOpenClose()
	if not _instance then
		_instance = depotcndialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function depotcndialog.GetLayoutFileName()
	return "depotgaiming_mtg.layout"
end

function depotcndialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, depotcndialog)
	return self
end

function depotcndialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
	self.cc_depot = winMgr:getWindow("depotgaiming_mtg/framewindow/cczy")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_depot)
    self.animationInstance:start()
	
	self.frameWindow = winMgr:getWindow("depotgaiming_mtg/framewindow")
	self.descText = winMgr:getWindow("depotgaiming_mtg/text")
	self.inputBox = CEGUI.toEditbox(winMgr:getWindow("depotgaiming_mtg/shurubg/editbox"))
	self.placeHolder = winMgr:getWindow("depotgaiming_mtg/shurubg/textqing")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("depotgaiming_mtg/btnquxiao"))
	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("depotgaiming_mtg/queren"))
	
    self.inputBox:SetNormalColourRect(0xff50321a);
	
	self.cancelBtn:subscribeEvent("Clicked", depotcndialog.handleCancelClicked, self)
	self.sureBtn:subscribeEvent("Clicked", depotcndialog.handleSureClicked, self)
    self.inputBox:SetShieldSpace(true)		--不允许输入空格
	self.inputBox:SetOnlyNumberMode(false,-1)
    self.inputBox:setMaxTextLength(5)
	self.inputBox:subscribeEvent("TextChanged", self.OnEditNumChange, self)

    self.index = 1
end

function depotcndialog:handleCancelClicked(args)
    depotcndialog.DestroyDialog()
    return true
end

function depotcndialog:handleSureClicked(args)
    if MHSD_UTILS.ShiedText(self.inputBox:getText()) then
	    GetCTipsManager():AddMessageTipById(142260) --名称中含有非法字符，请重新输入。
	    return true
    end
    local p = require "protodef.fire.pb.item.cmodifydepotname".new()
	p.depotindex = self.index
	p.depotname = self.inputBox:getText()
	require "manager.luaprotocolmanager":send(p)
    depotcndialog.DestroyDialog()
    return true
end

function depotcndialog:setIndex(index)
    self.index = index
end

function depotcndialog:OnEditNumChange()
    if string.len(self.inputBox:getText()) > 0 then
	    self.placeHolder:setVisible(false)
	    self.sureBtn:setEnabled(true)
    else
	    self.placeHolder:setVisible(true);
		self.sureBtn:setEnabled(false);
    end
end


return depotcndialog