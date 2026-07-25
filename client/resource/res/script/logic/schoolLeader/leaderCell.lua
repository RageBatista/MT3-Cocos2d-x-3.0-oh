leaderCell = {}

setmetatable(leaderCell, Dialog)
leaderCell.__index = leaderCell
local prefix = 0

function leaderCell.CreateNewDlg(parent)
	local newDlg = leaderCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function leaderCell.GetLayoutFileName()
	return "lingxiucell_mtg.layout"
end

function leaderCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, leaderCell)
	return self
end

function leaderCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.leaderCell = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "lingxiucell_mtg"))
	self.playerName = winMgr:getWindow(prefixstr .. "lingxiucell_mtg/mingzidi/mingzi")
	self.playerModelBg = winMgr:getWindow(prefixstr .. "lingxiucell_mtg/fazhen/moxing")
	self.context = winMgr:getWindow(prefixstr .. "lingxiucell_mtg/rich")
	self.ticketNum = winMgr:getWindow(prefixstr .. "lingxiucell_mtg/shuliang")
	self.btnSelect = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "lingxiucell_mtg/btn"))

    self.btnSelect:subscribeEvent("MouseClick",leaderCell.HandleChooseClicked,self)
end

function leaderCell:setInfo(index)
    local info = require "logic.schoolLeader.leaderManager":getInfoByIndex(index)
    self.playerName:setText(info.rolename)
    self.context:setText(info.words)
    self.ticketNum:setText(info.tickets)
    gGetGameUIManager():AddWindowSprite(self.playerModelBg, info.shape, Nuclear.XPDIR_BOTTOMRIGHT, 0,0, true)
    self.btnSelect:setID(info.roleid)
end

function leaderCell:HandleChooseClicked(args)
    local strMsg =  require "utils.mhsdutils".get_msgtipstring(170032)
    local roleID = CEGUI.toWindowEventArgs(args).window:getID()
    local function ClickYes(args)
        local p = require "protodef.fire.pb.school.cvotecandidate":new()
        p.candidateid = roleID
        p.shouxikey = require "logic.schoolLeader.leaderManager":getShouxikey()
        require "manager.luaprotocolmanager":send(p)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        leaderElectionDlg.DestroyDialog()
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
    return true
end

--function leaderCell:(args)
--    zhiyelingxiu
--end

return leaderCell