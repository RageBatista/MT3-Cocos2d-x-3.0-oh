------------------------------------------------------------------
-- 队伍匹配界面cell
------------------------------------------------------------------
require "logic.dialog"
require "utils.commonutil"

TeamMatchCell = { }

setmetatable(TeamMatchCell, Dialog)
TeamMatchCell.__index = TeamMatchCell
local prefix = 1

function TeamMatchCell.CreateNewDlg(pParentDlg)
    local newDlg = TeamMatchCell:new()
    newDlg:OnCreate(pParentDlg)
    return newDlg
end

function TeamMatchCell.GetLayoutFileName()
    return "teamshenqingcell.layout"
end

function TeamMatchCell:OnCreate(pParentDlg)
    prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()

    local prefixstr = tostring(prefix)
    self.name = winMgr:getWindow(prefixstr .. 'teamshenqing/text')
    self.level = winMgr:getWindow(prefixstr .. 'teamshenqing/LV')
    self.applyBtn = winMgr:getWindow(prefixstr .. 'teamshenqing/btn')
    self.icon = winMgr:getWindow(prefixstr .. 'teamshenqing/image')
    self.actName = winMgr:getWindow(prefixstr .. 'teamshenqing/zhuagui')

    self.membersCells = {}
    for i=1,5 do
        self.membersCells[i] = {}
        self.membersCells[i].itemcell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "teamshenqing/hero" .. i))
        self.membersCells[i].schoolIcon = winMgr:getWindow(prefixstr .. "teamshenqing/schoolicon" .. i)

        self.membersCells[i].itemcell:subscribeEvent("TableClick", TeamMatchCell.handleMemberCellClicked, self)
    end

    self.applyBtn:subscribeEvent('Clicked', self.handleApplyClicked, self)
end

------------------- public: -----------------------------------

function TeamMatchCell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, TeamMatchCell)
    return self
end

-- TeamInfoBasicWithMembers
function TeamMatchCell:loadData(teaminfo)
    self.teaminfo = teaminfo
    self.name:setText(teaminfo.teaminfobasic.leadername)
    self.level:setText('' .. teaminfo.teaminfobasic.leaderlevel)

    local matchinfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(teaminfo.teaminfobasic.targetid)
    if matchinfo and matchinfo.id ~= -1 then
        self.actName:setText(matchinfo.content)
    else
        self.actName:setText(MHSD_UTILS.get_resstring(3148)) -- 无
    end

    for i=1,5 do
        local cell = self.membersCells[i]
        local data = teaminfo.memberlist[i]
        if data then
            local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(data.shape)
            local img = gGetIconManager():GetImageByID(config.littleheadID)
            cell.itemcell:setID(i)
            cell.itemcell:setID2(config.littleheadID)
            cell.itemcell:SetImage(img)
            cell.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)

            local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(data.school)
	        cell.schoolIcon:setProperty("Image", schoolconf.schooliconpath)
        else
            --cell.itemcell:setVisible(false)
            cell.schoolIcon:setVisible(false)
        end
    end

    if teaminfo.status == 1 then
        self.applyBtn:setText(MHSD_UTILS.get_resstring(11113)) -- 已申请
        self.applyBtn:setEnabled(false)
    end
end

function TeamMatchCell:handleMemberCellClicked(args)
    local cell = CEGUI.toWindowEventArgs(args).window
    local idx = cell:getID()
    if idx == 0 then
        return
    end

    local data = self.teaminfo.memberlist[idx]
    local headId = cell:getID2()

    local dlg = ContactRoleDialog.getInstanceAndShow()
    dlg:SetCharacter(data.roleid, data.rolename, data.level, 0, headId, data.school, 0)
end

function TeamMatchCell:handleApplyClicked(args)
    GetTeamManager():RequestJoinOneTeam(self.teaminfo.teaminfobasic.leaderid)
    self.applyBtn:setText(MHSD_UTILS.get_resstring(11113)) -- 已申请
    self.applyBtn:setEnabled(false)
end

return TeamMatchCell
