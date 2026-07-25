

local srefreshrolescore = require "protodef.fire.pb.attr.srefreshrolescore"
function srefreshrolescore:process()
     if not gGetDataManager()  then
        return
    end
    local data = gGetDataManager():GetMainCharacterData();
    for nType,nValue in pairs(self.datas) do
    if (nType == self.TOTAL_SCORE) then
	
		data.totalScore = nValue;
	
	elseif (nType == self.EQUIP_SCORE) then
	
		data.equipScore = nValue;
	
	elseif (nType == self.MANY_PET_SCORE) then
	
		data.manyPetScore = nValue;
	
	elseif (nType == self.PET_SCORE) then
	
		data.petScore = nValue;
	
	elseif (nType == self.LEVEL_SCORE) then
	
		data.levelScore = nValue;
	
	elseif (nType == self.XIULIAN_SCORE) then
	
		data.xiulianScore = nValue;
	
	elseif (nType == self.ROLE_SCORE) then
	
		data.roleScore = nValue;
	
	elseif (nType == self.SKILL_SCORE) then
	
		data.skillScore = nValue;
	end

    end
    require 'logic.item.mainpackdlg';
    if(CMainPackDlg:getInstanceOrNot())then 
        CMainPackDlg:getInstanceOrNot():UpdateTotalScore();
    end
	
	require 'logic.characterinfo.characterprodlg'
    local dlg = CharacterProDlg.getInstanceNotCreate() 
    if dlg then
        dlg:UpdatePlayerScore()  --  在评分更新后，调用 CharacterProDlg:UpdatePlayerScore() 刷新界面
    end


end

local srefreshrolecurrency = require "protodef.fire.pb.attr.srefreshrolecurrency"
function srefreshrolecurrency:process()
     if not gGetDataManager()  then
        return
    end
    for nKey,nnValue in pairs(self.datas) do
        gGetDataManager():RefreshRoleScore(nKey,nnValue)
    end
    
    require 'logic.characterinfo.characterinfodlg'.UpdateAllScoreInstance()
end

--�����֣���ȡ������
local srequestusednamedata = require "protodef.fire.pb.srequestusednamedata"
function srequestusednamedata:process()
        local dlg = require ("logic.gaimingka").getInstanceAndShow()
	    dlg:updateUserData(self.itemkey,self.usednames)
end

local smodifyrolename = require "protodef.fire.pb.smodifyrolename"
function smodifyrolename:process()
    local name = self.newname
    local roleId = self.roleid
    gCommon.changeRoleId = roleId
    if name then
        local character = gGetScene():FindCharacterByID(roleId)
        if character then
            if gGetDataManager():IsPlayerSelf(roleId)  then
                local data = gGetDataManager():GetMainCharacterData()
                data.strName = name
            else
                character:SetName(name)
            end
            local list = GetTeamManager():GetMemberList()
            for _,v in ipairs(list) do
                if v.id == roleId then
                    v.strName = name
                end
            end

            if (character:IsInBattle()) then
                 GetCTipsManager():AddMessageTipById(170026)
            else
                 character:UpdatNameTexture(true)
            end
            local dlg = require "logic.gaimingka"
            if dlg then
                dlg.DestroyDialog()
            end
       end

       GetTeamManager():UpdateMemberName(roleId,name)
       local Renwulistdialog = require "logic.task.renwulistdialog"
       if Renwulistdialog then
              Renwulistdialog.tryRefreshTeamInfo()
       end

    else
        print ("change name error")
    end

end

local srefreshpetdata = require "protodef.fire.pb.attr.srefreshpetdata"
function srefreshpetdata:process()
	local petData = require("logic.pet.mainpetdatamanager").getInstance():FindMyPetByID(self.petkey, self.columnid)
	if not petData or not gGetDataManager() then
		return
    end
	
	local levelChanged = false

	for first, second in pairs(self.datas) do
		if first == fire.pb.attr.AttrType.EXP then
			petData.curexp = second
		elseif first == fire.pb.attr.AttrType.PET_SCALE then
			petData.scale = second
		elseif first == fire.pb.attr.AttrType.PET_GROW_RATE then
			petData.growrate = second
  		elseif first == fire.pb.attr.AttrType.LEVEL then -- ˢ�³���ȼ�
			levelChanged = true
			local level = second
  			petData.petattribution[fire.pb.attr.AttrType.LEVEL] =  level
			petData.nextexp = BeanConfigManager.getInstance():GetTableByName("pet.cpetnextexp"):getRecorder(level).exp;
		elseif first == fire.pb.attr.AttrType.POINT then
			local point = second
			petData.petattribution[first] = point
			if levelChanged and point > 0 then
				YangChengListDlg.notifyPetPointAdd()
            end
			if point == 0 then
				YangChengListDlg.dealwithPetAddpointStatus()
			end
        elseif first == 1240 then
            petData.petattribution[first] = second
        else
            petData.petattribution[first] = second
	    end
	end

	if gGetDataManager():GetBattlePetID() == self.petkey then
		gGetDataManager().m_EventBattlePetDataChange:Bingo()

		-- ˢ��ս����������
		if GetBattleManager() and GetBattleManager():IsInBattle() then
			gGetDataManager().m_EventMainPetAttributeChange:Bingo()
		end
	end	
end

local srefreshpointtype = require "protodef.fire.pb.attr.srefreshpointtype"
function srefreshpointtype:process()
	if gGetGameApplication() == nil then
        return
    end
	if gGetDataManager() == nil then
        return
    end
	if gGetScene() == nil then
        return
    end
    local data = gGetDataManager():GetMainCharacterData() --stMainCharacterData()
    for k, v in pairs(self.point) do
        data.pointScheme[k] = v
    end
	data.pointSchemeChangeTimes = self.schemechanges
	data.pointSchemeID = self.pointscheme

	local leftPoint = data.pointScheme[self.pointscheme]
	if leftPoint == 0 then
		YangChengListDlg.dealwithRoleAddpointStatus()
	elseif leftPoint > 0 then
		YangChengListDlg.nofityRolePointAdd()
	end
	data.cons = self.bfp.cons			--����
	data.iq = self.bfp.iq				        --ħ��
	data.str = self.bfp.str		            --����
	data.endu = self.bfp.endu			--����
	data.agi = self.bfp.agi			        --����

    data.cons_save = {}
    for k,v in pairs(self.bfp.cons_save) do
        table.insert(data.cons_save, v)
    end

    data.iq_save = {}
    for k,v in pairs(self.bfp.iq_save) do
        table.insert(data.iq_save, v)
    end

    data.str_save = {}
    for k,v in pairs(self.bfp.str_save) do
        table.insert(data.str_save, v)
    end

    data.endu_save = {}
    for k,v in pairs(self.bfp.endu_save) do
        table.insert(data.endu_save, v)
    end

    data.agi_save = {}
    for k,v in pairs(self.bfp.agi_save) do
        table.insert(data.agi_save, v)
    end
	--gGetDataManager():UpdatePointScheme(data)

    CharacterPropertyAddPtrDlg.getInstanceExistAndShow()
	AddPointManager.getInstanceAndUpdate()
end

local p = require "protodef.fire.pb.attr.srefreshroledata"
function p:process()
    if gGetDataManager() then
        gGetDataManager():refreshRoleData(self)
    end
end
