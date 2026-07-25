
local p = require "protodef.fire.pb.ranklist.srequestranklist"
function p:process()
--    if GetBattleManager():IsInBattle() then
--        return
--    end

    require "protodef.rpcgen.fire.pb.ranklist.ranktype"
	require "logic.rank.rankinglist" 
	require "logic.bingfengwangzuo.bingfengwangzuodlg"
    local typeEnum = RankType:new()
	local proto = self--FireClient.toSRequestRankList(p)
 
	if proto.ranktype == typeEnum.SINGLE_COPY_RANK4 or ((proto.ranktype >= typeEnum.TEAM_COPY_RANK1) and (proto.ranktype <= typeEnum.TEAM_COPY_RANK2)) then
		return true
	end
	
	if proto.ranktype == typeEnum.YZDD_RANK then
--		local YiZhanDaoDiListDlg = require "logic.yizhandaodi.yizhandaodilist"
--		YiZhanDaoDiListDlg.getInstanceAndShow():Refresh(proto.list, proto.myrank)
	elseif proto.ranktype == typeEnum.SINGLE_COPY_RANK1 or proto.ranktype == typeEnum.SINGLE_COPY_RANK2 or proto.ranktype == typeEnum.SINGLE_COPY_RANK3 then -- 冰封王座排行榜
		require "logic.bingfengwangzuo.bingfengwangzuomanager":loadRankData( proto.list )
    elseif proto.ranktype == typeEnum.CLAN_FIGHT_2 or proto.ranktype == typeEnum.CLAN_FIGHT_4 or proto.ranktype == typeEnum.CLAN_FIGHT_WEEK or proto.ranktype == typeEnum.CLAN_FIGHT_HISTROY then
        require ("logic.family.familyfightrank"):RefreshFamilyRankList(proto.ranktype, proto.myrank, proto.list, proto.page, proto.hasmore, proto.extdata,proto.extdata1,proto.extdata2,proto.extdata3)
    elseif proto.ranktype==201 or proto.ranktype==202 or proto.ranktype==203 then
        local dlg =require "logic.rank.zongherank".getInstanceNotCreate()
        if dlg then
            dlg:processList(proto.ranktype, proto.myrank, proto.list, proto.page, proto.hasmore, proto.mytitle, proto.takeawardflag, proto.extdata,proto.extdata1,proto.extdata2,proto.extdata3)
        end
	else
		
		RankingList.getInstanceAndShow(
		function()
			RankingList.processList(proto.ranktype, proto.myrank, proto.list, proto.page, proto.hasmore, proto.mytitle, proto.takeawardflag, proto.extdata,proto.extdata1,proto.extdata2,proto.extdata3)
		end
		);
		
	end
end

-- 查看排行榜
local p = require "protodef.fire.pb.ranklist.getrankinfo.sfactionrankinfo"
function p:process()
    if self.factionkey == 0 then
     return
    end
    local d = require "logic.rank.gonghuixiangqing"
    local parent = RankingList.getInstanceNotCreate()
    if parent then
        local dlg = d.getInstanceAndShow(parent:GetWindow())
        if dlg then
            local DataTable =
            {
                factionid = self.factionkey,
                --- 公会ID
                cengyongming = self.lastname,
                -- 曾用名
                zongzhi = self.title,-- 宗旨
                factionmasterid = self.factionmasterid  --公会会长id
            }
            dlg:RefreshData(DataTable)
        end
    end
end

-- 排行榜查看功能
-- 这里都是从协议中的Table中浅拷贝的数据，请勿执行修改操作
local sranklevelinfo = require "protodef.fire.pb.ranklist.getrankinfo.srankroleinfo2"
require "protodef.rpcgen.fire.pb.ranklist.ranktype"
local typeEnum = RankType:new()  
function sranklevelinfo:process()
    print("____sranklevelinfo:process")

    local rankType = self.ranktype;

    if rankType == typeEnum.PROFESSION_WARRIOR_RANK
        or rankType == typeEnum.PROFESSION_MAGIC_RANK
        or rankType == typeEnum.PROFESSION_PRIEST_RANK
        or rankType == typeEnum.PROFESSION_PALADIN_RANK
        or rankType == typeEnum.PROFESSION_HUNTER_RANK
        or rankType == typeEnum.PROFESSION_DRUID_RANK
        or rankType == typeEnum.ROLE_ZONGHE_RANK 
        or rankType == typeEnum.PROFESSION_ROGUE_RANK 
        or rankType == typeEnum.PROFESSION_SAMAN_RANK
        or rankType == typeEnum.PROFESSION_WARLOCK_RANK 
        or rankType == typeEnum.PVP5_LAST_GRADE1  or
         rankType == typeEnum.PVP5_LAST_GRADE2  or
         rankType == typeEnum.PVP5_LAST_GRADE3  or
         rankType == typeEnum.PVP5_HISTORY_GRADE1  or
         rankType == typeEnum.PVP5_HISTORY_GRADE2  or
         rankType == typeEnum.PVP5_HISTORY_GRADE3 
        then

        local d = require "logic.rank.zonghepingfendlg"
        d.curData = self
        local parent = RankingList.getInstanceNotCreate()
        if parent then
            local parentWnd = parent:GetWindow()
            if parent and parentWnd then
                local dlg = d.getInstanceAndShow(parentWnd)
                if dlg then
                    dlg:RefreshView()
                end
            end
        end



    elseif rankType == typeEnum.ROLE_RANK then

        local d = require "logic.rank.ranklevelviewdlg"
        d.curData = self
        local parent = RankingList.getInstanceNotCreate()
        if parent then
            local parentWnd = parent:GetWindow()
            if parentWnd then
                local dlg = d.getInstanceAndShow(parentWnd)
                if dlg then
                    dlg:RefreshView()
                end
            end
        end
    end
end

local srankzongheinfo = require "protodef.fire.pb.ranklist.getrankinfo.srankroleinfo"
function srankzongheinfo:process()
    print("____srankzongheinfo:process")

     if gGetDataManager() then
        local nMyRoleId = gGetDataManager():GetMainCharacterID()
        if self.roleid ==  nMyRoleId then
            return
        end
    end

    local dlg = ContactRoleDialog.getInstanceAndShow()
    if not dlg then
        return
    end

    local roleHeadID = 0
    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(self.shape)
    if shapeConf then
          roleHeadID = shapeConf.littleheadID
    end

    

    local roleID = self.roleid;
    local roleName = self.rolename;
    local roleLevel = self.level;
    local roleCamp = self.camp;
        -- dlg:SetCharacter(roleID,roleInf.name,roleInf.rolelevel,roleInf.camp,roleHeadID,roleInf.school,roleInf.factionID,roleInf.factionName)		
    dlg:SetCharacter(roleID, roleName, roleLevel, roleCamp, roleHeadID, self.school, 0, self.factionname)

    

end
-- End










