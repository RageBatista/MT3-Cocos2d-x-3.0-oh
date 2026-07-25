
local m2 = require "protodef.fire.pb.hook.srefreshrolehookbattledata"
function m2:process()
	print("enter srefreshrolehookbattledata process")
	require "logic.mapchose.mapchosedlg"
	require "logic.mapchose.hookmanger"

	if self.rolehookbattledata.isautobattle == 0 then
        if GetBattleManager() then
            GetBattleManager():EndAutoOperate()
        end
	else
        if GetBattleManager() then
		    GetBattleManager():BeginAutoOperate()
        end
    end
	
	--…Ë÷√
    if GetBattleManager() then
         if gCommon.RoleOperateType  ~= -1 and gCommon.RoleSelecttedSkill ~= -1 then
            GetBattleManager():SetAutoCommandOperateType(0, gCommon.RoleOperateType)
	        GetBattleManager():SetAutoCommandOperateID(0, gCommon.RoleSelecttedSkill)
        else
            GetBattleManager():SetAutoCommandOperateType(0,self.rolehookbattledata.charoptype)
	        GetBattleManager():SetAutoCommandOperateID(0,self.rolehookbattledata.charopid)	
        end

        if gCommon.PetOperateType  ~= -1 and gCommon.PetSelecttedSkill ~= -1 then
            GetBattleManager():SetAutoCommandOperateType(1, gCommon.PetOperateType)
	        GetBattleManager():SetAutoCommandOperateID(1, gCommon.PetSelecttedSkill)
        else
            GetBattleManager():SetAutoCommandOperateType(1,self.rolehookbattledata.petoptype)
	        GetBattleManager():SetAutoCommandOperateID(1,self.rolehookbattledata.petopid)	
        end
    end
	
	local processarray = {self.rolehookbattledata.isautobattle, self.rolehookbattledata.charoptype, self.rolehookbattledata.charopid,
	 self.rolehookbattledata.petoptype, self.rolehookbattledata.petopid }	
	
	HookManager.getInstance():SetSkillDataSrv(processarray)
	
	local dlg = MapChoseDlg.getInstanceNotCreate()--getInstanceAndShow()
	if dlg then
		dlg:SetSrvData()
		dlg:RefreshSkillBox()
		dlg:RefreshBtn()
		dlg:RefreshCellColor()
	end
end


local m3 = require "protodef.fire.pb.hook.srefreshrolehookexpdata"
function m3:process()
	print("enter srefreshrolehookexpdata process")
	require "logic.mapchose.mapchosedlg"
	require "logic.mapchose.hookmanger"

		
	local processarray = {self.rolehookexpdata.cangetdpoint, 	self.rolehookexpdata.getdpoint,	self.rolehookexpdata.offlineexp }
	
	
	HookManager.getInstance():SetHookDataSrv(processarray)
	
	local dlg = MapChoseDlg.getInstanceNotCreate()--getInstanceAndShow()
	if dlg then
		dlg:SetSrvData()
		dlg:RefreshSkillBox()
		dlg:RefreshBtn()
		dlg:RefreshCellColor()
	end
	
	local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:RefreshAllBtn()
	end

    local hdDlg = getHuodongDlg().getInstanceNotCreate()
    if hdDlg then
		hdDlg:SetSrvData()
		hdDlg:RefreshBtn()
	end

end



