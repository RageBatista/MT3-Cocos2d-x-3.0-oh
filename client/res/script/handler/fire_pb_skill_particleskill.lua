local listrequest = require "protodef.fire.pb.skill.particleskill.srequestparticleskilllist"
function listrequest:process()
	LogInfo('in function listrequest:process......')
	local dlg = require "logic.skill.xiulianskilldlg".getInstanceOrNot()
	if dlg then
		dlg.m_curBanggong = self.curcontribution
		dlg.m_skillList = self.skilllist
		dlg:RefreshSkillList()
	else
		LogInfo('function listrequest:process: dlg: '..tostring(dlg))
	end

    local datamanager = require "logic.faction.factiondatamanager"
    datamanager.factionlevel = self.factionlevel
end
local updaterequest = require "protodef.fire.pb.skill.particleskill.supdatelearnparticleskill"
function updaterequest:process()
	LogInfo('in function updaterequest:process......')
	local dlg = require "logic.skill.xiulianskilldlg".getInstanceOrNot()
	if dlg then
		dlg:RefreshSkill(self.skill)
	else
		LogInfo('function updaterequest:process: dlg: '..tostring(dlg))
	end
end
