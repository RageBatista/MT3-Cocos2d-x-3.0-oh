require "logic.dialog"
debugrequire "logic.team.teaminvitecell"

TeamInviteDlg = { }
setmetatable(TeamInviteDlg, Dialog)
TeamInviteDlg.__index = TeamInviteDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance
function TeamInviteDlg.getInstance()
    if not _instance then
        _instance = TeamInviteDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function TeamInviteDlg.getInstanceAndShow()
    if not _instance then
        _instance = TeamInviteDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function TeamInviteDlg.getInstanceNotCreate()
    return _instance
end


function TeamInviteDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            for _, v in pairs(_instance.cells) do
                v:OnClose()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function TeamInviteDlg.ToggleOpenClose()
    if not _instance then
        _instance = TeamInviteDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function TeamInviteDlg.GetLayoutFileName()
    return "teamfriend.layout"
end

function TeamInviteDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, TeamInviteDlg)
    return self
end

function TeamInviteDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.cc_yaoqingck = winMgr:getWindow("teamfriend/yaoqing")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_yaoqingck)
    self.animationInstance:start()
    
    self.frame = CEGUI.toFrameWindow(winMgr:getWindow('teamfriend/yaoqing'))
    self.closeBtn = winMgr:getWindow('teamfriend/yaoqing/close')
    self.content = winMgr:getWindow('teamfriend/yaoqing/content')

    self.labelChat = winMgr:getWindow('teamfriend/yaoqing/tupian/tishi/text')

    self.imageBgChat = winMgr:getWindow('teamfriend/yaoqing/tupian')
    self.imageBgChat:setVisible(false)

    self.closeBtn:subscribeEvent('Clicked', self.handleCloseClicked, self)

    self.TYPE = { FRIEND = 1, GONGHUI = 2 }
    self.m_FactionData = require "logic.faction.factiondatamanager"
end

function TeamInviteDlg:refreshChat(t)

    local nTipId = 11391
    if t == self.TYPE.FRIEND then
        nTipId = 11391
    else
        nTipId = 11392
    end
    local strChat = require("utils.mhsdutils").get_resstring(nTipId)
    self.labelChat:setText(strChat)
end

function TeamInviteDlg:setType(t)
    self.cells = { }
    self.type = t
    local cellWidth = 343 
    local cellHeight = 90 
    
    if t == self.TYPE.FRIEND then
        self.frame:setText(MHSD_UTILS.get_resstring(11813))
        local count = gGetFriendsManager():GetCurFriendNum()
        local n = 0 
        for i = 1, count do
            local roleId = gGetFriendsManager():GetFriendRoleIDByIdx(i)
            if roleId > 0 then
                local data = gGetFriendsManager():GetContactRole(roleId)
                if data.isOnline == 1 then
                    local cell = TeamInviteCell.CreateNewDlg(self.content)
                    local row = math.floor(n / 2) 
                    local col = n % 2 
                    local xPos = col * (cellWidth + 5) + 10 
                    local yPos = row * (cellHeight + 5)
                    cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPos), CEGUI.UDim(0, yPos)))
                    cell:loadData(data)
                    n = n + 1
                    self.cells[n] = cell
                end
            end
        end

    elseif t == self.TYPE.GONGHUI then
        self.frame:setText(MHSD_UTILS.get_resstring(11813))
        local n = 0
        local data = gGetDataManager():GetMainCharacterData()
        for _, v in pairs(self.m_FactionData.members) do
            if v.roleid ~= data.roleid then
                if v.lastonlinetime == 0 then
                    local cell = TeamInviteCell.CreateNewDlg(self.content)
                    local row = math.floor(n / 2) 
                    local col = n % 2 
                    local xPos = col * (cellWidth + 5) + 10 
                    local yPos = row * (cellHeight + 5)
                    cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPos), CEGUI.UDim(0, yPos)))
                    cell:loadDataFaction(v)
                    n = n + 1
                    self.cells[n] = cell
                end
            end
        end
    end

    if #self.cells == 0 then
        self.imageBgChat:setVisible(true)
        self:refreshChat(t)
    else
        self.imageBgChat:setVisible(false)
    end
end

function TeamInviteDlg:handleCloseClicked(args)
    self.DestroyDialog()
    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceAndShow()
    end
end

return TeamInviteDlg