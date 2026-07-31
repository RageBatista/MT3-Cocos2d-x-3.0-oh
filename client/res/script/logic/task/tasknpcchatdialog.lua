require "logic.dialog"

Tasknpcchatdialog = {}
setmetatable(Tasknpcchatdialog, Dialog)
Tasknpcchatdialog.__index = Tasknpcchatdialog

local _instance
function Tasknpcchatdialog.getInstance()
	if not _instance then
		_instance = Tasknpcchatdialog:new()
		_instance:OnCreate()
	end
	return _instance
end


function Tasknpcchatdialog.getInstanceAndShow()
	if not _instance then
		_instance = Tasknpcchatdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Tasknpcchatdialog.getInstanceNotCreate()
	return _instance
end

function Tasknpcchatdialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Tasknpcchatdialog.ToggleOpenClose()
	if not _instance then
		_instance = Tasknpcchatdialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Tasknpcchatdialog.GetLayoutFileName()
	return "tasknpcchatdialog.layout"
end

function Tasknpcchatdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Tasknpcchatdialog)
	return self
end

function Tasknpcchatdialog:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function Tasknpcchatdialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	--self.windowroot = winMgr:getWindow("Tasknpcchatdialog/back")
	self.richBoxChat = CEGUI.toRichEditbox(winMgr:getWindow("Tasknpcchatdialog/RichEditBox"))
    self.m_richBoxChatHeight = self.richBoxChat:getPixelSize().height;
	self.labelNpcName = winMgr:getWindow("Tasknpcchatdialog/name")
	self.imageHead = winMgr:getWindow("Tasknpcchatdialog/icon")
	--self.imageBgTop = winMgr:getWindow("NpcDialog/back/bg")

	--self.imageBgTop:setVisible(false)
	self.m_pMainFrame:setAlwaysOnTop(true)
	self.m_pMainFrame:activate()
end

function Tasknpcchatdialog:ShowNpcChat(nNpcId,strChat)
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if not npcCfg then 
		return
	end
	local strNpcName = npcCfg.name
	self.labelNpcName:setText(strNpcName)
	
	local nNpcshapId = npcCfg.modelID
	local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(nNpcshapId)
	local strHeadPath = gGetIconManager():GetImagePathByID(Shape.headID):c_str()
	self.imageHead:setProperty("Image", strHeadPath)
	self.richBoxChat:Clear()
	self.richBoxChat:show()
	local nIndex = string.find(strChat, "<T")
	if nIndex then
		self.richBoxChat:AppendParseText(CEGUI.String(strChat))
	else
		self.richBoxChat:AppendText(CEGUI.String(strChat))
	end
	self.richBoxChat:Refresh()

    local extendSize = self.richBoxChat:GetExtendSize()
	local y = (self.m_richBoxChatHeight - extendSize.height) * 0.5;
	if y<0 then
        y = 0
    end
	self.richBoxChat:setYPosition(CEGUI.UDim(0,y));
	self.richBoxChat:Refresh()
	
end

return Tasknpcchatdialog
