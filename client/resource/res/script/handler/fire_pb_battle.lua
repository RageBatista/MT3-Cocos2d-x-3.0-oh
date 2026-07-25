
local sguaji = require "logic.guaji.sguaji"
function sguaji:process()
    LogInfo("sguaji:process()")
    require("logic.guaji.guaji").gaibian(self)
end

local spvp1myinfo = require "protodef.fire.pb.battle.pvp1.spvp1myinfo"
function spvp1myinfo:process()
    LogInfo("spvp1myinfo:process()")
    require("logic.jingji.jingjiprotocol").spvp1myinfo_process(self)
end

local spvp1rankinglist = require "protodef.fire.pb.battle.pvp1.spvp1rankinglist"
function spvp1rankinglist:process()
    
    require("logic.jingji.jingjiprotocol").spvp1rankinglist_process(self)
end

local spvp1readyfight = require "protodef.fire.pb.battle.pvp1.spvp1readyfight"
function spvp1readyfight:process()
    
    require("logic.jingji.jingjiprotocol").spvp1readyfight_process(self)
end

local spvp1openboxstate = require "protodef.fire.pb.battle.pvp1.spvp1openboxstate"
function spvp1openboxstate:process()
    
    require("logic.jingji.jingjiprotocol").spvp1openboxstate_process(self)
end

local spvp1battleinfo = require "protodef.fire.pb.battle.pvp1.spvp1battleinfo"
function spvp1battleinfo:process()
   
    require("logic.jingji.jingjiprotocol").spvp1battleinfo_process(self)
end

local spvp1matchresult = require "protodef.fire.pb.battle.pvp1.spvp1matchresult"
function spvp1matchresult:process()
    
    require("logic.jingji.jingjiprotocol").spvp1matchresult_process(self)
end
-- 3v3
local spvp3myinfo = require "protodef.fire.pb.battle.pvp3.spvp3myinfo"
function spvp3myinfo:process()
    LogInfo("spvp3myinfo:process()")
    require("logic.jingji.jingjiprotocol").spvp3myinfo_process(self)
end

local spvp3rankinglist = require "protodef.fire.pb.battle.pvp3.spvp3rankinglist"
function spvp3rankinglist:process()
    LogInfo("spvp3rankinglist:process()")
    require("logic.jingji.jingjiprotocol").spvp3rankinglist_process(self)
end

local spvp3readyfight = require "protodef.fire.pb.battle.pvp3.spvp3readyfight"
function spvp3readyfight:process()
    LogInfo("spvp3readyfight:process()")
    require("logic.jingji.jingjiprotocol").spvp3readyfight_process(self)
end

local spvp3matchresult = require "protodef.fire.pb.battle.pvp3.spvp3matchresult"
function spvp3matchresult:process()
    LogInfo("spvp3matchresult:process()")
    require("logic.jingji.jingjiprotocol").spvp3matchresult_process(self)
end

local spvp3battleinfo = require "protodef.fire.pb.battle.pvp3.spvp3battleinfo"
function spvp3battleinfo:process()
    LogInfo("spvp3battleinfo:process()")
    require("logic.jingji.jingjiprotocol").spvp3battleinfo_process(self)
end

local spvp3openboxstate = require "protodef.fire.pb.battle.pvp3.spvp3openboxstate"
function spvp3openboxstate:process()
    LogInfo("spvp3openboxstate:process()")
    require("logic.jingji.jingjiprotocol").spvp3openboxstate_process(self)
end

-- 55
local spvp5myinfo = require "protodef.fire.pb.battle.pvp5.spvp5myinfo"
function spvp5myinfo:process()
    require("logic.jingji.jingjiprotocol").spvp5myinfo_process(self)
end

local spvp5rankinglist = require "protodef.fire.pb.battle.pvp5.spvp5rankinglist"
function spvp5rankinglist:process()
    LogInfo("spvp5rankinglist:process()")
    require("logic.jingji.jingjiprotocol").spvp5rankinglist_process(self)
end

local spvp5readyfight = require "protodef.fire.pb.battle.pvp5.spvp5readyfight"
function spvp5readyfight:process()
    require("logic.jingji.jingjiprotocol").spvp5readyfight_process(self)
end


local spvp5matchresult = require "protodef.fire.pb.battle.pvp5.spvp5matchresult"
function spvp5matchresult:process()
    LogInfo("spvp5matchresult:process()")
    require("logic.jingji.jingjiprotocol").spvp5matchresult_process(self)
end

local spvp5battleinfo = require "protodef.fire.pb.battle.pvp5.spvp5battleinfo"
function spvp5battleinfo:process()
    LogInfo("spvp5battleinfo:process()")
    require("logic.jingji.jingjiprotocol").spvp5battleinfo_process(self)
end

local spvp5openboxstate = require "protodef.fire.pb.battle.pvp5.spvp5openboxstate"
function spvp5openboxstate:process()
    require("logic.jingji.jingjiprotocol").spvp5openboxstate_process(self)
end


-- PK相关
local p = require "protodef.fire.pb.battle.splaypkfightview"
function p:process()
    local datamanager = require "logic.leitai.leitaidatamanager"
    -- 获得模块号
    datamanager.ModularType = self.modeltype
    local dlg = LeiTaiDialog.getInstanceNotCreate()
    -- 单人对手界面
    if datamanager.ModularType == 1 then
        if dlg then
            -- 返回PK验证验证
            datamanager.m_FilterMode = self.school
            datamanager.m_LevelArea = self.levelindex
            datamanager.m_EntryList = self.rolelist
            dlg:RefreshTab1()
        end
    elseif datamanager.ModularType == 2 then
        if dlg then
            -- 返回PK验证验证
            datamanager.m_FilterMode = self.school
            datamanager.m_LevelArea = self.levelindex
            datamanager.m_EntryList = self.rolelist
            dlg:RefreshTab2()
        end
    elseif datamanager.ModularType == 3 then
        if dlg then
            -- 返回PK验证验证
            datamanager.m_FilterMode = self.school
            datamanager.m_LevelArea = self.levelindex
            datamanager.m_EntryList = self.rolelist
            datamanager.m_EntryList2 = self.rolewatchlist
            dlg:RefreshTab3()
        end
    end
    local dlg1 = LeiTaiUnder.getInstanceNotCreate()
    local dlg2 = LeiTaiUnder1.getInstanceNotCreate()
    if dlg1 then
        dlg1:RefreshSelect()
    end
    if dlg2 then
        dlg2:RefreshSelect()
    end
end
local sourceID = 0
local p = require "protodef.fire.pb.battle.sinvitationplaypk"
function p:process()
    sourceID = self.sourceid
    local text = ""
    -- 单人模式
    if self.teamnum == 0 then
        text = MHSD_UTILS.get_msgtipstring(160422)
        text = string.gsub(text, "%$parameter1%$", tostring(self.rolename))
        text = string.gsub(text, "%$parameter2%$", tostring(self.rolelevel))
        -- 多人模式
    else
        text = MHSD_UTILS.get_msgtipstring(160423)
        text = string.gsub(text, "%$parameter1%$", tostring(self.rolename))
        text = string.gsub(text, "%$parameter2%$", tostring(self.rolelevel))
        text = string.gsub(text, "%$parameter3%$", tostring(self.teamnum))
    end

    local function nofactioninvitation(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
        local send = require "protodef.fire.pb.battle.cinvitationplaypkresult":new()
        send.sourceid = sourceID
        send.acceptresult = 0
        require "manager.luaprotocolmanager":send(send)
        sourceID = nil
         require "logic.leitai.leitaidatamanager".m_IsTick = false
         require "logic.leitai.leitaidatamanager".m_Time =0
    end

    local function acceptfactioninvitation(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local send = require "protodef.fire.pb.battle.cinvitationplaypkresult":new()
        send.sourceid = sourceID
        send.acceptresult = 1
        require "manager.luaprotocolmanager":send(send)
        sourceID = nil
         require "logic.leitai.leitaidatamanager".m_IsTick = false
         require "logic.leitai.leitaidatamanager".m_Time =0
    end
    gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal+1000)
    gGetMessageManager():AddMessageBox("", text, acceptfactioninvitation, self, nofactioninvitation, self, eMsgType_Normal+1000, 30000, 0, 0, nil, MHSD_UTILS.get_msgtipstring(160144), MHSD_UTILS.get_msgtipstring(160145))
end

local p = require "protodef.fire.pb.battle.sinvitationplaypkresult"
function p:process()
       require "logic.leitai.leitaidatamanager".m_IsTick = false
       require "logic.leitai.leitaidatamanager".m_Time =0
end

local p = require "protodef.fire.pb.battle.sdeadless20"
function p:process()
    if self.eventtype == 0 then
 		if gGetDataManager():GetMainCharacterLevel() < 10 then
 			GetCTipsManager():AddMessageTipById(160010);
 		else
 			deathNoteDlg.getInstanceAndShow()
        end
 	end
 	if GetMainCharacter():GetMoveState() == eMove_Pacing then
 		GetMainCharacter():StopPacingMove();
 	end
end

local ssendroundplayend = require "protodef.fire.pb.battle.ssendroundplayend"
function ssendroundplayend:process()
    if not GetBattleManager() then
		return;
	end
	self.fighterid = GetBattleManager():SCBattleIDChange(self.fighterid);
	local pBatter = GetBattleManager():FindBattlerByID(self.fighterid);
	if pBatter then
		pBatter:SetDemoShowEnd(true);

        local pPet = GetBattleManager():FindBattlerByID(self.fighterid+5);
        if pPet then
		    pPet:SetDemoShowEnd(true);
        end
        if GetBattleManager():GetMainBattleCharID() == self.fighterid then
            GetBattleManager():SetDelayDemoShow(1000)
        end
	    GetBattleManager():RefreshBattlerDemo();
	end
end

local ssendwatchbattlestart = require "protodef.fire.pb.battle.ssendwatchbattlestart"
function ssendwatchbattlestart:process()
    if not GetBattleManager() then
		return;
	end
    GetBattleManager():SetBattleType(self.battletype);
    GetBattleManager():SetBattleKey(self.battlekey);
	if self.enemyside == 0 then
		GetBattleManager():SetBattleIDChange(false);
		GetBattleManager():SetFriendFormation(self.friendsformation);
		GetBattleManager():SetEnemyFormation(self.enemyformation);
        GetBattleManager():SetFriendFormationLvl(self.friendsformationlevel);
        GetBattleManager():SetEnemyFormationLvl(self.enemyformationlevel);
	else
		GetBattleManager():SetBattleIDChange(true);
		GetBattleManager():SetFriendFormation(self.enemyformation);
		GetBattleManager():SetEnemyFormation(self.friendsformation);
        GetBattleManager():SetFriendFormationLvl(self.enemyformationlevel);
        GetBattleManager():SetEnemyFormationLvl(self.friendsformationlevel);
	end
    bingfengwangzuoTips.DestroyDialog()
    bingfengwangzuoDlg.DestroyDialog()
	GetBattleManager():BeginWatchScene(self.leftcount,self.battletype,self.roundnum,self.background,self.backmusic, self.battlekey);
    
end



local ssendbattleroperatestate = require "protodef.fire.pb.battle.ssendbattleroperatestate"
function ssendbattleroperatestate:process()
    if not GetBattleManager() then
		return;
	end
	local battleID = self.battleid;
	battleID = GetBattleManager():SCBattleIDChange(battleID);
	local pBattler = GetBattleManager():FindBattlerByID(battleID);
	if pBattler then
		pBattler:SetOperateState(self.state);
	end
	
	if self.state == 2 and GetBattleManager():GetMainBattleCharID() == battleID 
	and GetBattleManager():GetBattleState() == eBattleStateOperateChar then
		GetBattleManager():FinishBattleOperate(eMainBattlerChar);
	end
	if self.state == 2 and GetBattleManager():GetMainBattlePetID() == battleID
	 and GetBattleManager():GetBattleState() == eBattleStateOperatePet then
		GetBattleManager():FinishBattleOperate(eMainBattlerPet);
	end
end

local ssendalreadyuseitem = require "protodef.fire.pb.battle.ssendalreadyuseitem"
function ssendalreadyuseitem:process()
     if not GetBattleManager() then
		return;
	end
    GetBattleManager():ClearAlreadyUseItemList()

    for nKey,nValue in pairs(self.itemlist) do 
        GetBattleManager():InsertAlreadyUseItemList(nKey,nValue)
    end
    GetBattleManager():RefreshTwoItem()
end

local ssynchrobosshp = require "protodef.fire.pb.battle.ssynchrobosshp"
function ssynchrobosshp:process()
    if not GetBattleManager() then
		return;
	end

    local dlg = familybossBloodBar.getInstanceAndShow() 
    if dlg then
        dlg:initInfo(self.bossmonsterid, self.hp, self.maxhp, self.rolename, self.changehp)
    end
end

local ssendroleinitattrs = require "protodef.fire.pb.battle.ssendroleinitattrs"
function ssendroleinitattrs:process()
	local m = std.map_int_int_()
	for k,v in pairs(self.roleinitattrs) do
		if k == fire.pb.attr.AttrType.EXP or k == fire.pb.attr.AttrType.LEVEL or k == fire.pb.attr.AttrType.NEXP then
		
		else
			m[k] = tonumber(v)
		end
	end
	if gGetDataManager() ~= nil then
		gGetDataManager():SetMainBattlerTempAttribute(m)
	end
end
local ssetcommander = require "protodef.fire.pb.battle.battleflag.ssetcommander"
function ssetcommander:process()
    GetTeamManager():setTeamOrder(self.roleid)
    local dlg = TeamDialogNew.getInstanceNotCreate()
    if dlg then
        dlg:refreshContainer(dlg.showType)
    end
end
local ssetbattleflag = require "protodef.fire.pb.battle.battleflag.ssetbattleflag"
function ssetbattleflag:process()
    if self.opttype == 3 then
        GetBattleManager():ClearAllFlag()
    else
        local pBatter = GetBattleManager():FindBattlerByID(self.index);
	    if pBatter then
            pBatter:SetFlag(self.flag)
        end
    end
end