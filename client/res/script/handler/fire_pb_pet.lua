

--����ϴ��
local p = require "protodef.fire.pb.pet.spetwash"
function p:process()
	if PetLianYaoDlg.getInstanceNotCreate() then
		PetLianYaoDlg.getInstanceNotCreate():recvWashSuccess()
	end
end

--����ϳ�
p = require "protodef.fire.pb.pet.spetsynthesize"
function p:process()
	if PetLianYaoDlg.getInstanceNotCreate() then
		PetLianYaoDlg.getInstanceNotCreate():recvCombineSuccess(self.petkey)
	end
end

--���＼����֤
p = require "protodef.fire.pb.pet.spetskillcertification"
function p:process()
	if PetLianYaoDlg.getInstanceNotCreate() then
		PetLianYaoDlg.getInstanceNotCreate():recvSkillIdentifySuccess(self.petkey, self.skillid, self.isconfirm)
	end
end

--��������
p = require "protodef.fire.pb.pet.spetaptitudecultivate"
function p:process()
	if PetFeedDlg.getInstanceNotCreate() then
		PetFeedDlg.getInstanceNotCreate():recvZiZhiCultivateSuccess(self.petkey, self.aptid, self.aptvalue)
	end
	if PetChooseZiZhi and PetChooseZiZhi.getInstanceNotCreate() then
		PetChooseZiZhi.getInstanceNotCreate():refreshData()
	end
end

p = require "protodef.fire.pb.pet.spetaptitudecultivatee"
function p:process()
	if PetFeedDlg.getInstanceNotCreate() then
		PetFeedDlg.getInstanceNotCreate():recvZiZhiCultivateSuccess(self.petkey, self.aptid, self.aptvalue)
	end
	print("987*************刷新宠物")
	if PetChooseZiZhiNew and PetChooseZiZhiNew.getInstanceNotCreate() then
		PetChooseZiZhiNew.getInstanceNotCreate():refreshData()
	end
end

local spetsetautoaddpoint  = require "protodef.fire.pb.pet.spetsetautoaddpoint"
function spetsetautoaddpoint:process()
    if not gGetDataManager() then
        return
    end
	local petData = MainPetDataManager.getInstance():FindMyPetByID(self.petkey);
    if not petData then
        return
    end
	petData.autoBfp.cons = self.cons;
	petData.autoBfp.iq = self.iq;
	petData.autoBfp.str = self.str;
	petData.autoBfp.endu = self.endu;
	petData.autoBfp.agi = self.agi;
end

local srefreshpetcolumncapacity  = require "protodef.fire.pb.pet.srefreshpetcolumncapacity"
function srefreshpetcolumncapacity:process()
    if not gGetDataManager() then
		return;
	end
    local columnid = self.columnid
    local capacity = self.capacity
	if columnid == fire.pb.item.BagTypes.BAG then
		require("logic.pet.mainpetdatamanager").getInstance():SetMaxPetNum(capacity);
        --unction("PetPropertyDlg.UpdataPetCapacity");
	elseif columnid == fire.pb.item.BagTypes.DEPOT then
		require("logic.pet.mainpetdatamanager").getInstance():SetDeportCapacity(capacity);
		require("logic.pet.petstoragedlg").updateStorageCapacity(capacity)
	end
end


require "protodef.rpcgen.fire.pb.pet.peterror"
local speterror = require "protodef.fire.pb.pet.speterror"
function speterror:process()
    if not gGetGameUIManager() then
        return
    end
    local nTipId = 0
  
    local bTip = false
    if self.peterror == PetError.UnkownError then
        nTipId = 1071
    elseif self.peterror == PetError.KeyNotFound then
        nTipId = 1072
    elseif self.peterror == PetError.PetcolumnFull then
        nTipId = 144906
        bTip = true
    elseif self.peterror == PetError.WrongDstCol then
        nTipId = 1073
    elseif self.peterror == PetError.ShowPetCantMoveErr then
        nTipId = 140387
        bTip = true
    elseif self.peterror == PetError.FightPetCantMoveErr then
        nTipId = 140386
        bTip = true
    elseif self.peterror == PetError.PetNameOverLen then
        nTipId = 142995
         bTip = true
    elseif self.peterror == PetError.PetNameShotLen then
        nTipId = 1074
    elseif self.peterror == PetError.PetNameInvalid then
        nTipId = 1075
    elseif self.peterror == PetError.ShowPetCantFree then
        nTipId = 1076
    elseif self.peterror == PetError.FightPetCantFree then
        nTipId = 1077
    elseif self.peterror == PetError.WrongFreeCode then
        nTipId = 1078
    end
    local strTip = ""
    if bTip then
        strTip = require("utils.mhsdutils").get_msgtipstring(nTipId)
    else
        strTip = require("utils.mhsdutils").get_resstring(nTipId)
    end
    GetCTipsManager():AddMessageTip(strTip);
end

local sremovepetfromcol  = require "protodef.fire.pb.pet.sremovepetfromcol"
function sremovepetfromcol:process()
    require("logic.pet.mainpetdatamanager").getInstance():RemovePetByID(self.petkey,self.columnid);
	LuaRemovePetFromCol(self.petkey, self.columnid)

end

local srefreshpetscore  = require "protodef.fire.pb.pet.srefreshpetscore"
function srefreshpetscore:process()
    require("logic.pet.mainpetdatamanager").getInstance():RefreshPetScore(self.petkey, self.petscore, self.petbasescore);
end

local smodpetname  = require "protodef.fire.pb.pet.smodpetname"
function smodpetname:process()
   	require("logic.pet.mainpetdatamanager").getInstance():UpdatePetName(self.roleid,self.petkey,self.petname);
end

local ssetfightpetrest  = require "protodef.fire.pb.pet.ssetfightpetrest"
function ssetfightpetrest:process()
    if not gGetDataManager() then
		return;
	end
     if not GetBattleManager() then
		return;
	end
    if self.isinbattle == 1 then
		GetBattleManager():SetRecallDemoPet(true);
	else
		require("logic.pet.mainpetdatamanager").getInstance():ClearBattlePet();
    end
	
end

local ssetfightpet  = require "protodef.fire.pb.pet.ssetfightpet"
function ssetfightpet:process()
    if not gGetDataManager() then
		return;
	end
     if not GetBattleManager() then
		return;
	end
    
    gCommon.PetOperateType = -1
    gCommon.PetSelecttedSkill = -1

    if self.isinbattle == 1 then
		GetBattleManager():SetSummonDemoPetKey(self.petkey);
	else
		gGetDataManager():SetBattlePet(self.petkey);
    end
	
end

local srefreshpetexp  = require "protodef.fire.pb.pet.srefreshpetexp"
function srefreshpetexp:process()
    require("logic.pet.mainpetdatamanager").getInstance():RefreshPetExp(self.petkey,self.curexp);
end


local sshowpetaround  = require "protodef.fire.pb.pet.sshowpetaround"
function sshowpetaround:process()
    if not gGetDataManager() then
		return;
	end   
    if not gGetScene() then
		return;
	end 
    if self.roleid == gGetDataManager():GetMainCharacterID() then
		require("logic.pet.mainpetdatamanager").getInstance():UpdateShowPet(self.showpetkey);
	end
	if self.showpetkey  == 0 then
		gGetScene():RemovePetByMasterID(self.roleid);
	else
		gGetScene():AddScenePetData(self.roleid, self.showpetid, self.showpetname, self.colour, self.size, self.showeffect);
	end

end

-- ֪ͨ�ͻ������ӳ���
local saddpettocolumn  = require "protodef.fire.pb.pet.saddpettocolumn"
function saddpettocolumn:process()
    require("logic.pet.mainpetdatamanager").getInstance():AddPetToColumn(self.columnid, self.petdata)
end

-- ˢ�³��＼��
local srefreshpetskill  = require "protodef.fire.pb.pet.srefreshpetskill"
function srefreshpetskill:process()
    require("logic.pet.mainpetdatamanager").getInstance():RefreshPetSkills(self.petkey, self.skills, self.expiredtimes)
end

local srefreshpetinternal  = require "protodef.fire.pb.pet.srefreshpetinternal"
function srefreshpetinternal:process()
    require("logic.pet.mainpetdatamanager").getInstance():RefreshPetInternals(self.petkey, self.skills, {})
	local dlg=require("logic.pet.petaddneidanbook").getInstanceNotCreate()
	if dlg then
		dlg:onNeidanSuccess()
	end
	local dlg1=require("logic.pet.petpropertydlgnew").getInstanceNotCreate()
	if dlg1 then
		local petData = MainPetDataManager.getInstance():FindMyPetByID(self.petkey)
		dlg1:refreshSkillView(petData)
	end
end

local srefreshpetinfo = require "protodef.fire.pb.pet.srefreshpetinfo"
function srefreshpetinfo:process()
	local petData = require("logic.pet.mainpetdatamanager").getInstance():FindMyPetByID(self.petinfo.key)
	if not petData or not gGetDataManager() then
		return
    end

	local petPointChange = false
	petData.baseid = self.petinfo.id -- ����ID
	petData.key = self.petinfo.key -- key
	petData.name = self.petinfo.name -- ����
	petData.colour = self.petinfo.colour
	petData.petattribution[1240]=self.petinfo.qianye
	petData.petattribution[fire.pb.attr.AttrType.LEVEL] = self.petinfo.level		-- �ȼ�
	petData.petattribution[fire.pb.attr.AttrType.PET_FIGHT_LEVEL] = self.petinfo.uselevel -- ��ս�ȼ�
	petData.petattribution[fire.pb.attr.AttrType.HP] = self.petinfo.hp -- ��ǰ����
	petData.petattribution[fire.pb.attr.AttrType.MAX_HP] = self.petinfo.maxhp		-- �������
	petData.petattribution[fire.pb.attr.AttrType.MP] = self.petinfo.mp				-- ��ǰ����
	petData.petattribution[fire.pb.attr.AttrType.MAX_MP] = self.petinfo.maxmp		-- �����
	petData.petattribution[fire.pb.attr.AttrType.ATTACK] = self.petinfo.attack		-- ����
	petData.petattribution[fire.pb.attr.AttrType.DEFEND] = self.petinfo.defend		-- ����
	petData.petattribution[fire.pb.attr.AttrType.SPEED] = self.petinfo.speed		-- �ٶ�
	petData.petattribution[fire.pb.attr.AttrType.MAGIC_ATTACK] = self.petinfo.magicattack -- ��������
	petData.petattribution[fire.pb.attr.AttrType.MAGIC_DEF] = self.petinfo.magicdef-- ��������

	petData.petattribution[fire.pb.attr.AttrType.CONS] = self.petinfo.bfp.cons		-- ����
	petData.petattribution[fire.pb.attr.AttrType.IQ] = self.petinfo.bfp.iq			-- ����
	petData.petattribution[fire.pb.attr.AttrType.STR] = self.petinfo.bfp.str		-- ����
	petData.petattribution[fire.pb.attr.AttrType.ENDU] = self.petinfo.bfp.endu		-- ����
	petData.petattribution[fire.pb.attr.AttrType.AGI] = self.petinfo.bfp.agi		-- ����
	if petData.petattribution[fire.pb.attr.AttrType.POINT] < self.petinfo.point then
		YangChengListDlg.notifyPetPointAdd()
	end
	petData.petattribution[fire.pb.attr.AttrType.POINT] = self.petinfo.point			-- Ǳ�ܡ�δ�������
	petData.curexp = self.petinfo.exp			-- ��ǰ����
	petData.nextexp = self.petinfo.nexp			-- ������Ҫ����
	petData.petattribution[fire.pb.attr.AttrType.PET_ATTACK_APT] = self.petinfo.attackapt		-- ��������
	petData.petattribution[fire.pb.attr.AttrType.PET_DEFEND_APT] = self.petinfo.defendapt		-- ��������
	petData.petattribution[fire.pb.attr.AttrType.PET_PHYFORCE_APT] = self.petinfo.phyforceapt	-- ��������
	petData.petattribution[fire.pb.attr.AttrType.PET_MAGIC_APT] = self.petinfo.magicapt		-- ��������
	petData.petattribution[fire.pb.attr.AttrType.PET_SPEED_APT] = self.petinfo.speedapt		-- �ٶ�����
	petData.petattribution[fire.pb.attr.AttrType.PET_DODGE_APT] = self.petinfo.dodgeapt		-- ��������
	petData.growrate = self.petinfo.growrate / 1000.0 -- �ɳ���
	petData.petattribution[fire.pb.attr.AttrType.PET_LIFE] = self.petinfo.life -- ����
	petData.kind = self.petinfo.kind
	petData.starId = self.petinfo.starid
    petData.practiseTimes = self.petinfo.practisetimes
    petData.zizhi = self.petinfo.zizhi
    petData.genguadd = self.petinfo.changegengu
    
	petData.petskilllist = self.petinfo.skills
	petData.petskillexpires = self.petinfo.skillexpires

	petData.initbfp.cons = self.petinfo.initbfp.cons
	petData.initbfp.iq = self.petinfo.initbfp.iq
	petData.initbfp.str = self.petinfo.initbfp.str
	petData.initbfp.endu = self.petinfo.initbfp.endu
	petData.initbfp.agi = self.petinfo.initbfp.agi

	petData.autoBfp.cons = self.petinfo.autoaddcons
	petData.autoBfp.iq = self.petinfo.autoaddiq
	petData.autoBfp.str = self.petinfo.autoaddstr
	petData.autoBfp.endu = self.petinfo.autoaddendu
	petData.autoBfp.agi = self.petinfo.autoaddagi

	petData.pointresetcount = self.petinfo.pointresetcount
	petData.aptaddcount = self.petinfo.aptaddcount
	petData.growrateaddcount = self.petinfo.growrateaddcount
	petData.score = self.petinfo.petscore
	petData.basescore = self.petinfo.petbasescore
	petData.petdye1 = self.petinfo.petdye1
	petData.petdye2 = self.petinfo.petdye2
	petData.washcount = self.petinfo.washcount
	petData.shenshouinccount = self.petinfo.shenshouinccount
	petData.marketfreezeexpire = self.petinfo.marketfreezeexpire
	petData:RefreshShape()

	MainPetDataManager.getInstance():SetLastRefreshPetID(self.petinfo.key)
	gGetDataManager():FirePetDataChange(self.petinfo.key)
end

-- �õ�������Ϣ
local sgetpetinfo = require "protodef.fire.pb.pet.sgetpetinfo"
function sgetpetinfo:process()
	local petData = require("logic.pet.mainpetdata"):new()
    petData:initWithLua(self.petinfo)
	LuaRecvPetTipsData(petData, 3)
end

-- ��ʼ�����ǳ����б�
local sgetpetcolumninfo = require "protodef.fire.pb.pet.sgetpetcolumninfo"
function sgetpetcolumninfo:process()
	require("logic.pet.mainpetdatamanager").getInstance():AddMyPetList(self.pets, self.columnid)
	
	if self.columnid == 2 then
		MainPetDataManager.getInstance():SetDeportCapacity(self.colunmsize)
		petstoragedlg.getInstanceAndShow(self.colunmsize)
	end
end
local ssetpetequiplist = require "protodef.fire.pb.pet.ssetpetequiplist"
function ssetpetequiplist:process()
	local p = require("logic.pet.petpropertydlgnew").getInstance()
	LogInfo("xiangquanid"..self.xiangquanid)
	LogInfo("xiangquanid"..self.hujiaid)
	LogInfo("xiangquanid"..self.hufuid)
	p:SetTou(self.xiangquanid)
	p:SetYi(self.hujiaid)
	p:SetHu(self.hufuid)
end

local ssetpetequipinfo = require "protodef.fire.pb.pet.ssetpetequipinfo"
function ssetpetequipinfo:process()
if self.itemid ~= 0 then
	local p = debugrequire("logic.tips.petequiptips").getInstanceAndShow(self.petkey,self.itemid,self.petequipinfo)
	p:makepetequiptips(self.itemid,self.petequipinfo,self.effect)
end

end

local sspetfashion = require "protodef.fire.pb.pet.sspetfashion"
function sspetfashion:process()
if self.result ~= 0 then
	local p = require("logic.pet.petshizhuangdlg").getInstance()
	p:refui()
	
end
end