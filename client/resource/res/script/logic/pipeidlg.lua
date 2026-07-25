require "logic.dialog"

PiPeiDlg = {}
setmetatable(PiPeiDlg, Dialog)
PiPeiDlg.__index = PiPeiDlg

local _instance
function PiPeiDlg.getInstance()
	if not _instance then
		_instance = PiPeiDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PiPeiDlg.getInstanceAndShow()
	if not _instance then
		_instance = PiPeiDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PiPeiDlg.getInstanceNotCreate()
	return _instance
end

function PiPeiDlg.DestroyDialog()
	if _instance then
        if _instance.aniDlg then
            _instance.aniDlg:DestroyDialog()
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PiPeiDlg.ToggleOpenClose()
	if not _instance then
		_instance = PiPeiDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PiPeiDlg.GetLayoutFileName()
	return "pipeiguaiwu.layout"
end

function PiPeiDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PiPeiDlg)
	return self
end

function PiPeiDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
		
	self.m_pFrameWindow = CEGUI.toFrameWindow(winMgr:getWindow("pipeiguaiwu"))
	--self.m_pFrameWindow:getCloseButton():subscribeEvent("Clicked", PiPeiDlg.DestroyDialog, nil)

    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", PiPeiDlg.HandleCancelBtnClicked, self)
    
    self.m_head = CEGUI.Window.toItemCell(winMgr:getWindow("pipeiguaiwu/item")) 
    
    self.imageWait =  winMgr:getWindow("pipeiguaiwu/pi") 
    self.imageWait:setVisible(false)
    local nSpaceX = 20
    local strTextColor = "FF693F00" 
    self.aniDlg = require("logic.jingji.jingjipipeianidialog").create(self.imageWait,nSpaceX,strTextColor)   

    self.timeBar = CEGUI.toProgressBar(winMgr:getWindow("pipeiguaiwu/time"))
    self.m_timeremaining = 0
    
    self.text = winMgr:getWindow("pipeiguaiwu/text1")

	self.m_pMainFrame:removeEvent("WindowUpdate")
	self.m_pMainFrame:subscribeEvent("WindowUpdate", PiPeiDlg.HandleWindowUpdate, self)

    if GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader() then
        self:GetCloseBtn():setVisible(true)
        self.text:setVisible(true)
    else
        self:GetCloseBtn():setVisible(false)
        self.text:setVisible(false)
    end
end

function PiPeiDlg:HandleCancelBtnClicked(args)
	local p = require "protodef.fire.pb.npc.cabandonmacth":new()
    p.npckey = self.m_npckey
    require "manager.luaprotocolmanager".getInstance():send(p)

	self.DestroyDialog()
	return true
end

function PiPeiDlg:HandleWindowUpdate(args)
	local updateArgs = CEGUI.toUpdateEventArgs(args)
    self.m_timeremaining = self.m_timeremaining - updateArgs.d_timeSinceLastFrame*1000
    self.timeBar:setProgress(self.m_timeremaining / self.maxtm)
    if self.m_timeremaining <= 0 then        
	    self:DestroyDialog()
    end
end

function PiPeiDlg:SetTimeRemaining(tm,maxtm)
    self.m_timeremaining = tm
    self.maxtm = maxtm
    self.imageWait:setVisible(true)
end
function PiPeiDlg:SetNpc(npcid,npckey)
    self.m_npckey = npckey
    self.m_npcid = npcid
    
    local NpcBase= BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(self.m_npcid)
    if NpcBase then
        local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(NpcBase.modelID)
	    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	    self.m_head:SetImage(image)
    end
end

function PiPeiDlg.CloseAndSendExit()
    local dlg = PiPeiDlg.getInstanceAndShow()
    if dlg == nil then
        return
    end
    if GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader() then
	    local p = require "protodef.fire.pb.npc.cabandonmacth":new()
        p.npckey = dlg.m_npckey
        require "manager.luaprotocolmanager".getInstance():send(p)
    end
	dlg:DestroyDialog()
	return true
end

local p = require "protodef.fire.pb.npc.snpcbattletime"
function p:process()
    local dlg = PiPeiDlg.getInstanceAndShow()
    dlg:SetTimeRemaining(self.lasttime,self.usetime)
    dlg:SetNpc(self.npcid,self.npckey)
end
local m = require "protodef.fire.pb.npc.smacthresult"
function m:process()
    local dlg = PiPeiDlg.getInstanceNotCreate()
    if dlg then
        dlg:DestroyDialog()
    end
end
return PiPeiDlg
