require "logic.dialog"

InputDialog = {}
setmetatable(InputDialog, Dialog)
InputDialog.__index = InputDialog

local cellHeight = 30   --cell高度
local offset = 2        --字符间隔
local textHeight = 25   --字符高度
local maxCount = 8  --最多显示数量
local _instance
function InputDialog.getInstance()
	if not _instance then
		_instance = InputDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function InputDialog.getInstanceAndShow()
	if not _instance then
		_instance = InputDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function InputDialog.getInstanceNotCreate()
	return _instance
end

function InputDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function InputDialog.ToggleOpenClose()
	if not _instance then
		_instance = InputDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function InputDialog.GetLayoutFileName()
	return "gaimingka.layout"
end

function InputDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, InputDialog)
	return self
end

function InputDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("gaimingka_mtg/framewindow"))
	self.inputBox = CEGUI.toEditbox(winMgr:getWindow("gaimingka_mtg/shurubg/editbox"))
    self.inputBox:subscribeEvent("KeyboardTargetWndChanged", InputDialog.HandleKeyboardTargetWndChanged, self)
	self.inputBox:SetNormalColourRect(0xff8c5e2a);
    self.inputBox:setMaxTextLength(14)
	
	self.placeHolder = winMgr:getWindow("gaimingka_mtg/shurubg/textqing")
	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("xiugaianniu_mtg/queren"))
	self.zengyongmin = winMgr:getWindow("zengyongming_mtg/text6")
	self.idxian = winMgr:getWindow("id_mtg/text5")
	self.xinnichengwen = winMgr:getWindow("xinnicheng_mtg/text4")
	self.zishuxianzhiwenzi = winMgr:getWindow("zishuxianzhi_mtg/text3")
    self.cymtxt = winMgr:getWindow("gaimingka_mtg/shurubg1/text")
    self.cymtxtBg = winMgr:getWindow("gaimingka_mtg/shurubg1")
    self.colseBtn = CEGUI.toPushButton(winMgr:getWindow("petgaiming_back/guanbi"))
    
	
	
    self.cymtxt:subscribeEvent("MouseButtonDown", InputDialog.cymtxtClicked, self)
	self.sureBtn:subscribeEvent("Clicked", InputDialog.handleSureClicked, self)
    self.colseBtn:subscribeEvent("Clicked", InputDialog.handleCloseClicked, self)

    -- 是否update
    self.m_IsUpdate = true
    self.m_itemKey = 0
    self.m_usedNames = {}
    self.m_isTipsVisible = false

    local nMyRoleId = gGetDataManager():GetMainCharacterID()
    self.idxian:setText(tostring(nMyRoleId))

end

function InputDialog:handleSureClicked(args)
    local newName = self.inputBox:getText()
    local cNum, eNum = GetCharCount(newName)
    local res = true
    if cNum and eNum then
        local total = ( cNum * 2 ) + eNum
        if total == 0 then
            GetCTipsManager():AddMessageTipById(170028)
            return
        end
        if total < 4 or total > 8 then
            res = false
        end
    elseif cNum then
        if  cNum < 2 or cNum > 5 then
            res = false
        end
    elseif eNum then
        if  eNum < 4 or eNum > 8 then
            res = false
        end
    end
    if not res then
        GetCTipsManager():AddMessageTipById(140403)
    else
        local send = require "protodef.fire.pb.cmodifyrolename":new()
        send.newname = newName
        send.itemkey = self.m_itemKey
        LuaProtocolManager.getInstance():send(send)
    end
end

function InputDialog:cymtxtClicked(args)

	    local winMgr = CEGUI.WindowManager:getSingleton()
        local pos = self.cymtxtBg:getPosition()
        local size = self.cymtxtBg:getPixelSize()
        if not self.tipUsednames then
    	    self.tipUsednames = winMgr:createWindow("TaharezLook/common_goodstips")
		    self.tipUsednames:setPosition(CEGUI.UVector2(CEGUI.UDim(0,pos.x.offset),CEGUI.UDim(0,pos.y.offset + size.height)))
		    self.tipUsednames:setAlwaysOnTop(true)
		    self.frameWindow:addChildWindow(self.tipUsednames)
            self.tipUsednames:setVisible(false)
        end

        if self.m_isTipsVisible then
               self.tipUsednames:setVisible(false)
               self.m_isTipsVisible = false
        else
            local i,j = 1,1
            if #self.m_usedNames > maxCount then
                j = #self.m_usedNames - maxCount + 1
            end
            
            if #self.m_usedNames > 0 then
                for m = #self.m_usedNames,j,-1 do
                    self.tipUsednames:setSize(CEGUI.UVector2(CEGUI.UDim(0, size.width), CEGUI.UDim(0, (i) * cellHeight ) ))
                    local t = winMgr:createWindow("TaharezLook/StaticText")
		            t:setSize(CEGUI.UVector2(CEGUI.UDim(0, size.width), CEGUI.UDim(0, textHeight)))
                    t:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0,(i-1)*textHeight+offset) ))
		            t:setProperty("BackgroundEnabled", "False")
		            t:setProperty("FrameEnabled", "False")
		            t:setProperty("HorzFormatting", "HorzCentred")
		            t:setProperty("VertFormatting", "VertCentred")
		            t:setProperty("MousePassThroughEnabled", "True")
		            t:setProperty("AlwaysOnTop", "True")
		            t:setProperty("TextColours", "ff8c5e2a")
		            t:setProperty("Font", "simhei-12")
		            t:setText(tostring(self.m_usedNames[m]))
		            self.tipUsednames:addChildWindow(t) 
                    i = i + 1
                end
                self.tipUsednames:setVisible(true)
                self.m_isTipsVisible = true
            end
        end
end

function InputDialog:updateUserData(itemkey,usednames)
    self.m_itemKey = itemkey
    self.m_usedNames = usednames
    local selfName = gGetDataManager():GetMainCharacterName()
    self.cymtxt:setText(selfName)
end

function InputDialog:update(dt)
    if not self.m_IsUpdate then
        return
    end
--    if self.inputBox then
--        local text1 = self.inputBox:getText()
--        self.placeHolder:setVisible((text1 == "" and self.inputBox:hasInputFocus()))
--    end
end
function InputDialog:HandleKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.inputBox then
        self.placeHolder:setVisible(false)
    else
        if self.inputBox:getText() == "" then
            self.placeHolder:setVisible(true)
        end
    end
end
function InputDialog:handleCloseClicked(args)
    self:DestroyDialog()
end

return InputDialog