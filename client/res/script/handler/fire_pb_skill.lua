local p = require "protodef.fire.pb.skill.ssendassistskillmaxlevels"
function p:process()
end

local supdateinborn = require "protodef.fire.pb.skill.supdateinborn"
function supdateinborn:process()
    for acuPointID, acuPointLevel in pairs(self.inborns) do
        RoleSkillManager.getInstance():UpdateAcupointLevel(acuPointID, acuPointLevel)
    end
	local CharacterSkillUpdateDlg = require "logic.skill.characterskillupdatedlg".getInstanceOrNot()
	if CharacterSkillUpdateDlg then
		CharacterSkillUpdateDlg:updateSkillLevel(self.inborns)
	end

    YangChengListDlg.dealwithSkillPoint()
end

local ssendinborns = require "protodef.fire.pb.skill.ssendinborns"
function ssendinborns:process()
    for nKey,nValue in pairs(self.inborns) do 
       RoleSkillManager.getInstance():InsertAcupointInfo(nKey,nValue)
    end
    RoleSkillManager.getInstance():UpdateRoleSkillAndAcupoint()
	
end


local supdateextskill = require "protodef.fire.pb.skill.supdateextskill"
function supdateextskill:process()
    RoleSkillManager.getInstance():ClearExtSkill()
    for nKey,nValue in pairs(self.extskilllists) do
        RoleSkillManager.getInstance():InsertExtSkill(nKey,nValue)
    end
    local nSkillNum = require "utils.tableutil".tablelength(self.extskilllists)
    if GetBattleManager() and nSkillNum==0 then
        GetBattleManager():SetFirstShowQuickButton(false)
    end
end

local ssendspecialskills = require "protodef.fire.pb.skill.ssendspecialskills"
function ssendspecialskills:process()
    RoleSkillManager.getInstance():ClearEquipSkillMap()
    RoleSkillManager.getInstance():InsertEquipSkillMap(self.skills,self.effects)
end

--奇经八脉1
local jingmais = require "logic.workshop.jingmai.sjingmaimain"
function jingmais:process()
    if self.idx==1 then
        local dlg = require "logic.workshop.jingmai.jingmaizhu".getInstanceAndShow()
        dlg:showMain(self)
        local dlg2 = require "logic.workshop.jingmai.jingmaiqianyuandan".getInstanceNotCreate()
        if dlg2 then
            dlg2:setMain(self)
        end
        local dlg3 = require "logic.workshop.jingmai.jingmaiqiankundan".getInstanceNotCreate()
        if dlg3 then
            dlg3:setMain(self)
        end
        local dlg4 = require "logic.workshop.jingmai.jingmaijihuo1".getInstanceNotCreate()
        if dlg4 then
            dlg4.DestroyDialog()
        end
        local dlg5 = require "logic.workshop.jingmai.jingmaijihuo2".getInstanceNotCreate()
        if dlg5 then
            dlg5.DestroyDialog()
        end
    end
    if self.idx==10 then
        local dlg2 = require "logic.workshop.jingmai.jingmaiqianyuandan".getInstanceNotCreate()
        if dlg2 then
            dlg2:setMain(self)
        end
        local dlg3 = require "logic.workshop.jingmai.jingmaiqiankundan".getInstanceNotCreate()
        if dlg3 then
            dlg3:setMain(self)
        end
    end

end