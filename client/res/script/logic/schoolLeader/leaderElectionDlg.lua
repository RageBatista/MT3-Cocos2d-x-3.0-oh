require "logic.dialog"

leaderElectionDlg = {}
setmetatable(leaderElectionDlg, Dialog)
leaderElectionDlg.__index = leaderElectionDlg

local _instance
function leaderElectionDlg.getInstance()
	if not _instance then
		_instance = leaderElectionDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function leaderElectionDlg.getInstanceAndShow()
	if not _instance then
		_instance = leaderElectionDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function leaderElectionDlg.getInstanceNotCreate()
	return _instance
end

function leaderElectionDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function leaderElectionDlg.ToggleOpenClose()
	if not _instance then
		_instance = leaderElectionDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function leaderElectionDlg.GetLayoutFileName()
	return "lingxiuxuanyan_mtg.layout"
end

function leaderElectionDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, leaderElectionDlg)
	return self
end

function leaderElectionDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.playerName = winMgr:getWindow("lingxiuxuanyan_mtg/title/name")
	self.context = CEGUI.toRichEditbox(winMgr:getWindow("lingxiuxuanyan_mtg/di/rich"))
	self.noteText = winMgr:getWindow("lingxiuxuanyan_mtg/di/dianji")
	self.cancel = CEGUI.toPushButton(winMgr:getWindow("lingxiuxuanyan_mtg/btn1"))
	self.sure = CEGUI.toPushButton(winMgr:getWindow("lingxiuxuanyan_mtg/btn2"))

    self.cancel:subscribeEvent("MouseClick",leaderElectionDlg.HandleCancleClicked,self)
    self.sure:subscribeEvent("MouseClick",leaderElectionDlg.HandleSureClicked,self)
    local data = gGetDataManager():GetMainCharacterData()
    self.playerName:setText(data.strName)
end

function leaderElectionDlg:setContentText(context)
    self.context:AppendText(CEGUI.String(context))
    self.context:Refresh()
end

function leaderElectionDlg:HandleCancleClicked(args)
    leaderElectionDlg.DestroyDialog()
    return true
end

function leaderElectionDlg:HandleSureClicked(args)
    local p = require "protodef.fire.pb.school.csendelectorwords":new()
    p.electorwords = self.context:GetPureText()
    require "manager.luaprotocolmanager":send(p)
    leaderElectionDlg.DestroyDialog()
    return true
end

function leaderElectionDlg:run(dt)
    local text = self.context:GetPureText()
    self.noteText:setVisible((text == "" and self.context:hasInputFocus())) 
end

return leaderElectionDlg