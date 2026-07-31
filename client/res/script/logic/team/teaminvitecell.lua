TeamInviteCell = { }

setmetatable(TeamInviteCell, Dialog)
TeamInviteCell.__index = TeamInviteCell
local prefix = 1
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function TeamInviteCell.CreateNewDlg(pParentDlg)
    local newDlg = TeamInviteCell:new()
    newDlg:OnCreate(pParentDlg)

    return newDlg
end


function TeamInviteCell.GetLayoutFileName()
    return "teamapplycell.layout"
end

function TeamInviteCell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, TeamInviteCell)
    return self
end

function TeamInviteCell:OnCreate(pParentDlg)
    prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.name = winMgr:getWindow(prefixstr .. 'teamapply/back/name')
    self.level = winMgr:getWindow(prefixstr .. 'teamapply/back/level')
    self.school = winMgr:getWindow(prefixstr .. 'teamapply/back/school')
    self.acceptBtn = winMgr:getWindow(prefixstr .. 'teamapply/back/btn')
	self.icon = winMgr:getWindow(prefixstr .. 'teamapply/back/dikuang/touxiang')
    self.c_pIcon = winMgr:getWindow(prefixstr .. 'teamapply/back/icon')

    self.acceptBtn:subscribeEvent('Clicked', self.handleAcceptClicked, self)
end

-- stContactRole
function TeamInviteCell:loadData(data)
    self.name:setText(data.name)
    local rolelv = ""..data.rolelevel
    if data.rolelevel>1000 then
        local zscs,t2 = math.modf(data.rolelevel/1000)
        rolelv = zscs..""..(data.rolelevel-zscs*1000)
    end
    self.level:setText(tostring(rolelv))
    self.roleid = data.roleID
    local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(data.school)
    if schoolinfo then
        self.school:setText(schoolinfo.name)
    end

    local strHead = gGetFriendsManager():GetContactRoleIcon(data.roleID)
    self.icon:setProperty("Image", strHead)
	self.c_pIcon:setProperty("Image", schoolinfo.schooliconpath)
end

function TeamInviteCell:loadDataFaction(data)
    self.name:setText(data.rolename)
    local rolelv = ""..data.rolelevel
    if data.rolelevel>1000 then
        local zscs,t2 = math.modf(data.rolelevel/1000)
        rolelv = zscs..""..(data.rolelevel-zscs*1000)
    end
    self.level:setText(tostring(rolelv))
    self.roleid = data.roleid
    local schoolinfo = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(data.school)
    if schoolinfo then
        self.school:setText(schoolinfo.name)
    end
    local conf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shapeid)
    local iconpath = gGetIconManager():GetImagePathByID(conf.littleheadID):c_str()
    self.icon:setProperty("Image", iconpath)
	self.c_pIcon:setProperty("Image", schoolinfo.schooliconpath)

end
function TeamInviteCell:handleAcceptClicked(args)
    self.acceptBtn:setEnabled(false)
    GetTeamManager():RequestInviteToMyTeam(self.roleid)
end

return TeamInviteCell
