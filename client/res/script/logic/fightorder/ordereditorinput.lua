require "logic.dialog"

OrderEditorInput = {}
setmetatable(OrderEditorInput, Dialog)
OrderEditorInput.__index = OrderEditorInput

local _instance

function OrderEditorInput.getInstance()
	if not _instance then
		_instance = OrderEditorInput:new()
		_instance:OnCreate()
	end
	return _instance
end

function OrderEditorInput.getInstanceAndShow()
	if not _instance then
		_instance = OrderEditorInput:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function OrderEditorInput.getInstanceNotCreate()
	return _instance
end

function OrderEditorInput.DestroyDialog()
    BattleSkillTip.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function OrderEditorInput.ToggleOpenClose()
	if not _instance then
		_instance = OrderEditorInput:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function OrderEditorInput.GetLayoutFileName()
	return "orderedit2.layout"
end

function OrderEditorInput:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, OrderEditorInput)
	return self
end

function OrderEditorInput:OnCreate()
	Dialog.OnCreate(self)
    self.m_SkillType = 0
	self.m_mode = 0
    
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("orderedit2/guanbi"))
	self.closeBtn:subscribeEvent("Clicked", self.handleCANCELClicked, self)

    
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("orderedit2/queren"))
	self.okBtn:subscribeEvent("Clicked", self.handleOKClicked, self)
    
	self.cancalBtn = CEGUI.toPushButton(winMgr:getWindow("orderedit2/quxiao"))
	self.cancalBtn:subscribeEvent("Clicked", self.handleCANCELClicked, self)
    
	self.c_tishi = winMgr:getWindow("orderedit2/textbg/tishiwenzi")
	
	self.inputText = CEGUI.toEditbox(winMgr:getWindow("orderedit2/textbg/input"))
    self.inputText:setMaxTextLength(4)
	self.inputText:SetNormalColourRect(0xFFBA8956);
	self.inputText:subscribeEvent("TextChangedEvent", self.handleTextChanged, self)
    self.inputText:subscribeEvent("MouseClick", self.handleMouseClick, self)
    self.editact = false
end

function OrderEditorInput:handleTextChanged(args)
    if string.len(self.inputText:getText()) > 0 then
        self.c_tishi:setVisible(false)  -- 隐藏提示文字
    else
        self.c_tishi:setVisible(true)   -- 显示提示文字
    end
end

function OrderEditorInput:OnEditActive(args)
    if self.inputText:isInputFocus() then  
        self.c_tishi:setVisible(false)     -- 隐藏提示文字
    else      
        local stt = self.inputText:getText() 
        local len = string.len(stt)  
        if string.len(self.inputText:getText()) == 0 then 
            self.c_tishi:setVisible(true)      -- 显示提示文字
        end
    end
end 

function OrderEditorInput:handleMouseClick(args)
    self.c_tishi:setVisible(false)      --隐藏提示文字
end

function OrderEditorInput:handleCANCELClicked(args)  
    self.DestroyDialog()
end
function OrderEditorInput:handleOKClicked(args)  
    local txt = self.inputText:getText()
    if MHSD_UTILS.ShiedText(txt) then
	    GetCTipsManager():AddMessageTipById(142260) --名称中含有非法字符，请重新输入。
        return
    end
    local ocmd = GetTeamManager():getOrderCmd(self.side,self.ind)
    
    local send = require "protodef.fire.pb.battle.battleflag.cmodifybattleflag":new()
    send.flag = ""
    if ocmd == nil or ocmd.txt == "" then
        if txt ~= "" then
            send.opttype = 0
            send.flag = txt
        else
            return
        end
        send.index = (self.side-1)*10 + GetTeamManager():getServerOrderCount(self.side)
    else
        if txt == "" then
            send.opttype = 1
        elseif txt ~= ocmd.txt then
            send.opttype = 2
            send.flag = txt
        else
            return
        end
        send.index = (self.side-1)*10 + self.ind - ocmd.serverid - 1
    end
    require "manager.luaprotocolmanager":send(send)

    --GetTeamManager():setOrderCmd(self.side,self.ind,txt)
    local dlg = OrderEditorDlg.getInstanceNotCreate()
    if dlg then
        dlg:refresh()
    end
    self.DestroyDialog()
end

function OrderEditorInput:init(side,ind)
    self.side = side
    self.ind = ind
    
    local cmd = GetTeamManager():getOrderCmd(self.side,self.ind)
    if cmd then
        self.inputText:setText(cmd.txt)
    else
        self.inputText:setText("")
    end
	if string.len(self.inputText:getText()) == 0 then 
        self.c_tishi:setVisible(true)      -- 显示提示文字
    else
        self.c_tishi:setVisible(false)     -- 隐藏提示文字
    end
end
return OrderEditorInput
