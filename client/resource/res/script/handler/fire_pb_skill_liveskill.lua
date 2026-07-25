local listrequest = require "protodef.fire.pb.skill.liveskill.srequestliveskilllist"
function listrequest:process()
	LogInfo('in function listrequest:process......')
	local dlg = require "logic.skill.gonghuiskilldlg".getInstanceOrNot()
	if dlg then
		dlg:SetSkillList(self.skilllist)
	else
		LogInfo('function listrequest:process: dlg: '..tostring(dlg))
	end
end


local learnrequest = require "protodef.fire.pb.skill.liveskill.supdatelearnliveskill"
function learnrequest:process()
	local dlg = require "logic.skill.gonghuiskilldlg".getInstanceOrNot()
	if dlg then
		dlg:SetSkill(self.skill)
    else
        if GonghuiSkillDlg.m_skillList then
            for i,v in pairs(GonghuiSkillDlg.m_skillList) do
                if v.id == self.skill.id then
                    GonghuiSkillDlg.m_skillList[i].level = self.skill.level
                end
            end
        end
	end
end


local stuffRequest = require "protodef.fire.pb.skill.liveskill.sliveskillmakestuff"
function stuffRequest:process()
	local dlg = require "logic.skill.gonghuiskilldlg".getInstanceOrNot()
	if dlg then
		dlg:MakeStuffCallback(self.ret)
	end
end

local foodRequest = require "protodef.fire.pb.skill.liveskill.sliveskillmakefood"
function foodRequest:process()
	local dlg = require "logic.skill.gonghuiskilldlg".getInstanceOrNot()
	if dlg then
		dlg:MakeFoodCallback(self.ret, self.itemid)
	end
end

local drugRequest = require "protodef.fire.pb.skill.liveskill.sliveskillmakedrug"
function drugRequest:process()
	local dlg = require "logic.skill.zuoyaodlg".getInstanceNotCreate()
	if dlg then
		dlg:MakeDrugCallback(self.ret, self.itemid)
	end
end

local dagongRequest = require "protodef.fire.pb.skill.liveskill.sliveskillmakefarm"
function dagongRequest:process()
	local dlg = require "logic.skill.strengthusedlg".getInstanceNotCreate()
	if dlg then
		dlg:DagongCallback(self.addgold)
	end
	
end

local tongxinRequest = require "protodef.fire.pb.skill.liveskill.sliveskillmakefriendgift"
function tongxinRequest:process()
	local dlg = require "logic.skill.strengthusedlg".getInstanceNotCreate()
	if dlg then
		dlg:TongxinCallback(self.itemid)
	end
end

local makeenhancementRequest = require "protodef.fire.pb.skill.liveskill.sliveskillmakeenhancement"
function makeenhancementRequest:process()
	local dlg = require "logic.skill.strengthusedlg".getInstanceNotCreate()
	if dlg then
		dlg:MakeEnhancementCallback()
	end
end


