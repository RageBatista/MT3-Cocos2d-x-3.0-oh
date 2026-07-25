require "logic.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "protodef.fire.pb.ranklist.crequestranklist"
require "protodef.rpcgen.fire.pb.ranklist.ranktype"
require "protodef.rpcgen.fire.pb.ranklist.levelrankdata"
require "protodef.rpcgen.fire.pb.ranklist.petgraderankdata"
require "protodef.rpcgen.fire.pb.ranklist.factionrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.rolezongherankrecord"
require "protodef.rpcgen.fire.pb.ranklist.rolerankrecord"
require "protodef.rpcgen.fire.pb.ranklist.factionraidrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.factionrankrecordex"

--local FIRST_COLOR = "[colrect='tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751']"
local FIRST_COLOR = "[colrect='tl:fffcc865 tr:fffcc865 bl:fffcc865 br:fffcc865']"
local maxNum = 6    --最大列数
RankingList = { }
setmetatable(RankingList, Dialog)
RankingList.__index = RankingList

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local typeEnum = RankType:new()
function RankingList.getInstance()
    LogInfo("enter RankingList getInstance")
    if not _instance then
        _instance = RankingList:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankingList.hide()
    if _instance then
        _instance:SetVisible(false)
    end
end

local getInstanceAndShowCallback = nil;

function RankingList_AsyncLoadCallback(pWindow)
    if _instance then
        _instance.m_pMainFrame = pWindow;

        local bCloseIsHide = _instance.m_bCloseIsHide;
        _instance.m_bCloseIsHide = false;
        _instance:OnCreate();
        _instance.m_bCloseIsHide = bCloseIsHide;

        if getInstanceAndShowCallback then
            getInstanceAndShowCallback();
        end
    end
end

function RankingList.getInstanceAndShow(cb)
    LogInfo("enter instance show")
    if not _instance then
        _instance = RankingList:new()

        getInstanceAndShowCallback = cb;

        local fileName = _instance.GetLayoutFileName();
        gGetGameUIManager():asyncLoadWindowLayout(fileName, "", "RankingList_AsyncLoadCallback");

    elseif _instance.m_pMainFrame then
        LogInfo("set visible")
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)

        if cb then
            cb();
        end
    end

    return _instance
end

function RankingList.getInstanceNotCreate()
    return _instance
end

function RankingList:OnClose()
    Dialog.OnClose(self)
    _instance = nil
end

function RankingList.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function RankingList.ToggleOpenClose()
    if not _instance then
        _instance = RankingList:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function RankingList.processList(ranktype, myrank, list, page, hasmore, mytitle, takeAwardFlag, extdata, extdata1,extdata2,extdata3)
    if _instance and _instance.m_rankType~=ranktype then		
        _instance.m_pMain:getVertScrollbar():Stop()
        _instance.m_pMain:getVertScrollbar():setScrollPosition(0)
    end
    LogInfo("RankingList processList")
    if _instance then
        _instance.m_rankType = ranktype
        if myrank == 0 then
            -- 我在榜外 by changhao
            if ranktype == typeEnum.ROLE_ZONGHE_RANK then
                -- 综合 by changhao
                local strbuilder = StringBuilder:new()
                strbuilder:Set("parameter1", mytitle)
                _instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2913)))
                strbuilder:delete()
            elseif ranktype == typeEnum.PROFESSION_WARRIOR_RANK or
                    ranktype == typeEnum.PROFESSION_MAGIC_RANK or
                    ranktype == typeEnum.PROFESSION_PRIEST_RANK or
                    ranktype == typeEnum.PROFESSION_PALADIN_RANK or
                    ranktype == typeEnum.PROFESSION_HUNTER_RANK or
                    ranktype == typeEnum.PROFESSION_DRUID_RANK or
                    ranktype == typeEnum.ROLE_RANK or
                    ranktype == 60 or
                    ranktype == 61 or
                    ranktype == 62 or
                    ranktype == 63 or
                    ranktype == 64 or
                ranktype == 65 or
                ranktype == 66 or
                ranktype == 67
            then

                local strbuilder = StringBuilder:new()
                strbuilder:Set("parameter1", mytitle)
                _instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2913)))
                strbuilder:delete()

            else
                _instance.m_pText:setText(MHSD_UTILS.get_resstring(2898))
            end
        else
            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", myrank)
            if ranktype == typeEnum.FACTION_RANK then
                _instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2911)))
            elseif ranktype == typeEnum.ROLE_ZONGHE_RANK then
                strbuilder:Set("parameter1", myrank)
                strbuilder:Set("parameter2", mytitle)
                _instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2912)))
            elseif ranktype == typeEnum.PROFESSION_WARRIOR_RANK or
                    ranktype == typeEnum.PROFESSION_MAGIC_RANK or
                    ranktype == typeEnum.PROFESSION_PRIEST_RANK or
                    ranktype == typeEnum.PROFESSION_PALADIN_RANK or
                    ranktype == typeEnum.PROFESSION_HUNTER_RANK or
                    ranktype == typeEnum.PROFESSION_DRUID_RANK or
                    ranktype == 60 or
                    ranktype == 61 or
                    ranktype == 62 or
                    ranktype == 63 or
                ranktype == 64 or
                ranktype == 65 or
                ranktype == 66 or
                ranktype == 67 then
                strbuilder:Set("parameter1", myrank)
                strbuilder:Set("parameter2", mytitle)
                _instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2912)))

            else
                _instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2899)))
            end
            strbuilder:delete()
        end
        _instance.m_iCurPage = page
        _instance.m_bHasMore = hasmore

        local record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(ranktype)
        if record.lingjiang == 0 then
            _instance.m_pRewardBtn:setVisible(false)
        else
            _instance.m_pRewardBtn:setVisible(true)
        end
        if takeAwardFlag == 1 then
            _instance.m_pRewardBtn:setEnabled(true)
        else
            _instance.m_pRewardBtn:setEnabled(false)
        end

        if ranktype == typeEnum.LEVEL_RANK then
            -- 等级排名 by changhao
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = LevelRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                -- local level = "0转"..row.level
                -- if row.level>1000 then
                --     local zscs,t2 = math.modf(row.level/1000)
                --     level = zscs.."转"..(row.level-zscs*1000)
                -- end

                
                local level = row.level
                if row.level>1000 then
                    local zscs,t2 = math.modf(row.level/1000)
                    level = (row.level-zscs*1000)
                end

                _instance:AddRow(2,row.Shape,row.color1,row.color2,row.components,row.rank - 1, row.roleid, tostring(row.rank), row.nickname, BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school).name, tostring(level))
            end

            local myschool = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID()).name
            local myname = gGetDataManager():GetMainCharacterName()
            local mylevel = gGetDataManager():GetMainCharacterLevel()
            -- local level = "0转"..mylevel
            -- if mylevel>1000 then
            --     local zscs,t2 = math.modf(mylevel/1000)
            --     level = zscs.."转"..(mylevel-zscs*1000)
            -- end

            
            local level = mylevel
            if mylevel>1000 then
                local zscs,t2 = math.modf(mylevel/1000)
                level = (mylevel-zscs*1000)
            end
            _instance:UpdateMyRank(tostring(myrank), myname, myschool, tostring(level));
            -- 更新自己的信息 by changhao

        elseif ranktype == typeEnum.PET_GRADE_RANK then
            -- 宠物 by changhao
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = PetGradeRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                _instance:AddRow(1,row.Shape,row.colour,0,0,row.rank - 1, row.uniquepetid, tostring(row.rank), row.petname, row.nickname, tostring(row.petgrade))
            end

            local myschool = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID()).name
            local myname = gGetDataManager():GetMainCharacterName()
            local mylevel = gGetDataManager():GetMainCharacterLevel()

            _instance:UpdateMyRank(tostring(myrank), mytitle, myname, tostring(extdata));
            -- 更新自己的信息 by changhao			

        elseif (ranktype == typeEnum.CAMP_TRIBE_RANK) or(ranktype == typeEnum.CAMP_LEAGUE_RANK) then
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = CampRecordBean:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                _instance:AddRow(0,0,0,0,0,row.index - 1, row.roleid, tostring(row.index), row.rolename, BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school).name, tostring(row.score), row.title)
            end

        elseif ranktype == typeEnum.FACTION_RANK then
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = FactionRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                _instance:AddRow(0,0,0,0,0,row.rank - 1, row.factionkey, tostring(row.rank), row.factionname, tostring(row.level), row.mastername)
            end
        elseif ranktype == typeEnum.ROLE_ZONGHE_RANK then
            -- 综合排名 by changhao
			
			local roleItemManager = require("logic.item.roleitemmanager").getInstance()
				local fb = roleItemManager:getfenbang()

				if fb == 0 or fb == 1 then 
				self._min = 1
				self._max = 200
				elseif fb == 2 then
				self._min = 90
				self._max = 115
				elseif fb == 3 then
				self._min = 70
				self._max = 89
				elseif fb == 4 then
				self._min = 1
				self._max = 69
				end
				
			local num = page *300
            local sizeof_recordlist = #list
			
            for k = 1, sizeof_recordlist do
                local row = RoleZongheRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
               
                row:unmarshal(_os_)
                _os_:delete()
                -- local level = "0转"..row.rolelevel
                -- if row.rolelevel>1000 then
                --     local zscs,t2 = math.modf(row.rolelevel/1000)
                --     level = zscs.."转"..(row.rolelevel-zscs*1000)
                -- end

                
                local level = row.rolelevel
                if row.rolelevel>1000 then
                    local zscs,t2 = math.modf(row.rolelevel/1000)
                    level = (row.rolelevel-zscs*1000)
                end
				
				if row.rolelevel <= self._max and  row.rolelevel >= self._min then
              --  _instance:AddRow(2,row.Shape,row.color1,row.color2,row.components,row.rank - 1, row.roleid, tostring(row.rank), row.rolename, BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school).name,level,tostring(row.score))
				_instance:AddRow(2,row.Shape,row.color1,row.color2,row.components,num, row.roleid, tostring(num+1), row.rolename, BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school).name,level,tostring(row.score))
					num = num +1
					if num == 100 then 
					break
					end
				end
		   end
			

            local myschool = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID()).name
            local myname = gGetDataManager():GetMainCharacterName()
            local mylevel = gGetDataManager():GetMainCharacterLevel()
            local mylevel = gGetDataManager():GetMainCharacterLevel()
            -- local level = "0转"..mylevel
            -- if mylevel>1000 then
            --     local zscs,t2 = math.modf(mylevel/1000)
            --     level = zscs.."转"..(mylevel-zscs*1000)
            -- end

            
            local level = mylevel
            if mylevel>1000 then
                local zscs,t2 = math.modf(mylevel/1000)
                level = (mylevel-zscs*1000)
            end

            _instance:UpdateMyRank(tostring(myrank), myname, myschool,level, tostring(extdata));
            -- 更新自己的信息 by changhao			

        elseif ranktype == typeEnum.PROFESSION_WARRIOR_RANK or
                ranktype == typeEnum.PROFESSION_MAGIC_RANK or
                ranktype == typeEnum.PROFESSION_PRIEST_RANK or
                ranktype == typeEnum.PROFESSION_PALADIN_RANK or
                ranktype == typeEnum.PROFESSION_HUNTER_RANK or
                ranktype == typeEnum.PROFESSION_DRUID_RANK or
                ranktype == 60 or
                ranktype == 61 or
                ranktype == 62 or
                ranktype == 63 or
                ranktype == 64 or
            ranktype == 65 or
            ranktype == 66 or
            ranktype == 67 then
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = RoleProfessionRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                -- local level = "0转"..row.rolelevel
                -- if row.rolelevel>1000 then
                --     local zscs,t2 = math.modf(row.rolelevel/1000)
                --     level = zscs.."转"..(row.rolelevel-zscs*1000)
                -- end

                local level = row.rolelevel
                if row.rolelevel>1000 then
                    local zscs,t2 = math.modf(row.rolelevel/1000)
                    level = (row.rolelevel-zscs*1000)
                end


                _instance:AddRow(2,row.Shape,row.color1,row.color2,row.components,row.rank - 1, row.roleid, tostring(row.rank), row.rolename, tostring(level),tostring(row.score))
            end

            local myschool = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID()).name
            local myname = gGetDataManager():GetMainCharacterName()
            local mylevel = gGetDataManager():GetMainCharacterLevel()
            -- local level = "0转"..mylevel
            -- if mylevel>1000 then
            --     local zscs,t2 = math.modf(mylevel/1000)
            --     level = zscs.."转"..(mylevel-zscs*1000)
            -- end

            
            local level = mylevel
            if mylevel>1000 then
                local zscs,t2 = math.modf(mylevel/1000)
                level = (mylevel-zscs*1000)
            end

            _instance:UpdateMyRank(tostring(myrank), myname, tostring(level), tostring(extdata));
            -- 更新自己的信息 by changhao

        elseif ranktype == typeEnum.ROLE_RANK then
            -- 人物榜 by changhao
            -- ✅ 修复：使用RoleRankRecord（与服务器端RoleRankRecord Bean字段顺序完全匹配）

            print("========== 人物榜调试开始 ==========")
            print("rankType: " .. ranktype)
            print("myrank: " .. myrank)

            local sizeof_recordlist = #list
            print("记录数量: " .. sizeof_recordlist)

            for k = 1, sizeof_recordlist do
                print(">>> 第 " .. k .. " 条记录")

                -- ✅ 使用RoleRankRecord（服务器端RoleRankRecord Bean）
                local row = RoleRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])

                row:unmarshal(_os_)
                _os_:delete()

                print("  解析结果:")
                print("    rank = " .. row.rank)
                print("    roleid = " .. row.roleid)
                print("    rolename = " .. (row.rolename or "nil"))
                print("    school = " .. row.school)
                print("    level = " .. row.level)
                print("    score = " .. row.score)
                print("    shape = " .. row.shape)
                print("    triggertime = " .. row.triggertime)
                print("    color1 = " .. row.color1)
                print("    color2 = " .. row.color2)

                -- 🔍 调试：打印 components 内容
                print("    components 数据:")
                if row.components then
                    local count = 0
                    for k,v in pairs(row.components) do
                        print("      ["..k.."] = "..v)
                        count = count + 1
                    end
                    print("    components 总数: " .. count)
                else
                    print("    components = nil 或不存在！")
                end

                local level = row.level
                if row.level > 1000 then
                    local zscs = math.modf(row.level/1000)
                    level = (row.level - zscs*1000)
                end

                print("  准备添加到UI...")
                _instance:AddRow(2, row.shape, row.color1, row.color2, row.components,
                                row.rank - 1, row.roleid,
                                tostring(row.rank), row.rolename,
                                BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school).name,
                                level, tostring(row.score))
                print("  添加完成")
            end

            local myschool = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(gGetDataManager():GetMainCharacterSchoolID()).name
            local myname = gGetDataManager():GetMainCharacterName()
            local mylevel = gGetDataManager():GetMainCharacterLevel()

            local level = mylevel
            if mylevel > 1000 then
                local zscs = math.modf(mylevel/1000)
                level = (mylevel - zscs*1000)
            end

            print(">>> 更新我的排名: " .. myrank .. ", " .. myname .. ", " .. myschool .. ", " .. level .. ", " .. extdata)
            _instance:UpdateMyRank(tostring(myrank), myname, myschool, level, tostring(extdata))
            print("========== 人物榜调试结束 ==========\n")
            -- 更新自己的信息 by changhao

            -- 公会竞速榜--熔火之心 -- 纳克萨玛斯
        elseif ranktype == typeEnum.FACTION_MC or
                ranktype == typeEnum.FACTION_NAXX then
            local record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(ranktype)
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = FactionRaidRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                _instance:AddRow(0,0,0,0,0,row.rank - 1, row.factionid, tostring(row.rank), row.factionname, _instance:FormatTime(row.progressstime), tostring(row.progresss) .. "/" .. tostring(10))
            end
            local datamanager = require "logic.faction.factiondatamanager"
            if datamanager then
                if datamanager:IsHasFaction() then
                    _instance:UpdateMyRank(tostring(myrank), datamanager.factionname, _instance:FormatTime(extdata1), tostring(extdata) .. "/" .. tostring(10));
                else
                    _instance:NoRank()
                end
            else
                _instance:NoRank()
            end
        elseif ranktype == typeEnum.FACTION_COPY then
            --公会副本进度
            local record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(ranktype)
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = FactionRaidRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                _instance:AddRow(0,0,0,0,0,row.rank - 1, row.factionid, tostring(row.rank), row.factionname, row.factioncopyname, tostring(row.progresss) .. "/" .. tostring(10), tostring(100 - math.floor(row.bosshp*100)).. "%", _instance:FormatTime(row.progressstime))
            end
            local datamanager = require "logic.faction.factiondatamanager"
            if datamanager then
                if datamanager:IsHasFaction() then
                    _instance:UpdateMyRank(tostring(myrank), datamanager.factionname,  tostring(extdata3), tostring(extdata) .. "/" .. tostring(10), tostring(100 - math.floor(extdata2*100)).. "%", _instance:FormatTime(extdata1))
                else
                    _instance:NoRank()
                end
            else
                _instance:NoRank()
            end
        elseif  ranktype == typeEnum.PVP5_LAST_GRADE1  or
                ranktype == typeEnum.PVP5_LAST_GRADE2  or
                ranktype == typeEnum.PVP5_LAST_GRADE3  or
                ranktype == typeEnum.PVP5_HISTORY_GRADE1  or
                ranktype == typeEnum.PVP5_HISTORY_GRADE2  or
                ranktype == typeEnum.PVP5_HISTORY_GRADE3
        then
            local PvP5RankData = require("protodef.rpcgen.fire.pb.ranklist.pvp5rankdata")
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = PvP5RankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()

                local strJobName = ""
                local jobTable =  BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school)
                if jobTable then
                    strJobName = jobTable.name
                end
                _instance:AddRow(0,0,0,0,0,row.rank - 1, row.roleid, tostring(row.rank), row.rolename, strJobName,tostring(row.score))
            end
            local nMyJobId = gGetDataManager():GetMainCharacterSchoolID()
            local jobTable = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(nMyJobId)
            local myschool = ""
            if jobTable then
                myschool = jobTable.name
            end

            local myname = gGetDataManager():GetMainCharacterName()
            local mylevel = gGetDataManager():GetMainCharacterLevel()

            _instance:UpdateMyRank(tostring(myrank), myname, myschool, tostring(extdata));

            -- 公会榜 -- 公会等级 公会综合实力
        elseif ranktype == typeEnum.FACTION_RANK_LEVEL or
                ranktype == typeEnum.FACTION_ZONGHE then
            local isUpdateSelfFaction = false
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = FactionRankRecordEx:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                if ranktype == typeEnum.FACTION_RANK_LEVEL then
                    local temp = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(row.hotellevel)
                    local text = tostring(row.externdata) .. "/" .. tostring(temp.peoplemax)
                    _instance:AddRow(0,0,0,0,0,row.rank - 1, row.factionid, tostring(row.rank), row.factionname, tostring(row.factionlevel), text)

                else
                    _instance:AddRow(0,0,0,0,0,row.rank - 1, row.factionid, tostring(row.rank), row.factionname, tostring(row.factionlevel), tostring(row.externdata))
                end
            end
            local datamanager = require "logic.faction.factiondatamanager"
            if datamanager then
                if datamanager:IsHasFaction() and datamanager.factionname then
                    local mytext = tostring(datamanager.GetPersonNumber()) .. "/" .. tostring(datamanager.GetMaxPersonNumber())
                    _instance:UpdateMyRank(tostring(myrank), datamanager.factionname, tostring(datamanager.factionlevel), mytext)
                else
                    _instance:NoRank()
                end
            else
                _instance:NoRank()
            end
        elseif ranktype == typeEnum.RED_PACK_1 or ranktype == typeEnum.RED_PACK_2 then
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = RedPackRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                local strJobName = ""
                local jobTable =  BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school)
                if jobTable then
                    strJobName = jobTable.name
                end
                _instance:AddRow(2,row.Shape,row.color1,row.color2,row.components,row.rank - 1, row.roleid, tostring(row.rank), row.rolename, strJobName, tostring(row.num))
            end
            local myname = gGetDataManager():GetMainCharacterName()
            local myschool = gGetDataManager():GetMainCharacterSchoolName()
            _instance:UpdateMyRank(tostring(myrank), myname, myschool, tostring(extdata))
        elseif ranktype == typeEnum.FLOWER_RECEIVE or ranktype == typeEnum.FLOWER_GIVE then
            local sizeof_recordlist = #list
            for k = 1, sizeof_recordlist do
                local row = RoleZongheRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
                local strJobName = ""
                local jobTable =  BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(row.school)
                if jobTable then
                    strJobName = jobTable.name
                end
                _instance:AddRow(0,0,0,0,0,row.rank - 1, row.roleid, tostring(row.rank), row.rolename, strJobName, tostring(row.num))
            end
            local myname = gGetDataManager():GetMainCharacterName()
            local myschool = gGetDataManager():GetMainCharacterSchoolName()
            _instance:UpdateMyRank(tostring(myrank), myname, myschool, tostring(extdata))
        end
    end
end
-- 格式化时间
function RankingList:FormatTime(time)
    if not time then
        return ""
    end
    local text = MHSD_UTILS.get_resstring(1239)
    if time == 0 then
        return  string.format(text, 0, 0)
    end
    if time < 1000 then
        return ""
    end
    local min = math.floor(time / 1000 / 60)
    local sec = time / 1000 - min * 60
    text = string.format(text, min, sec)
    return text
end
-- 没有公会
function RankingList:NoRank()
    self.m_myRank[0]:setText("");
    self.m_myRank[1]:setText("");
    self.m_myRank[2]:setText("");
    self.m_myRank[3]:setText("");
    self.m_myRank[4]:setText("");
    self.m_myRank[5]:setText("");
end
-- 更新我的排名信息 by changhao
function RankingList:UpdateMyRank(col0, col1, col2, col3, col4, col5)

    self.m_myRank[0]:setText(col0);
    self.m_myRank[1]:setText(col1);
    self.m_myRank[2]:setText(col2);
    self.m_myRank[3]:setText(col3);
    self.m_myRank[4]:setText(col4);
    self.m_myRank[5]:setText(col5);

    if col0 == "0" then
        -- 榜外 by changhao
        self.m_myRank[0]:setText(MHSD_UTILS.get_resstring(11204));
    end

    if col4 then
        self:ResetRankPos(maxNum - 1)
        if col5 then
            self:ResetRankPos(maxNum)
        end
    else
        self:ResetRankPos(maxNum - 2)
    end

end

function RankingList.TakeAwardSuccess(ranktype)
    LogInfo("RankingList take award success")
    if _instance then
        if _instance.m_rankType == ranktype then
            _instance.m_pRewardBtn:setEnabled(false)
        end
    end
end

----/////////////////////////////////////////------

function RankingList.GetLayoutFileName()
    return "rankinglist.layout"
end

function RankingList:OnCreate()
print("布局加载完成1")
	
    LogInfo("enter RankingList oncreate")
	print("布局加载完成2")
	
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
	print("布局加载完成3")
	
    self.m_FontText = "simhei-12"
	print("布局加载完成4")
	
    local winMgr = CEGUI.WindowManager:getSingleton()
	print("布局加载完成5")
	
    -- get windows
    self.m_pTree = CEGUI.toGroupBtnTree(winMgr:getWindow("RankingList/tree"))
	print("布局加载完成6")
	
    self.m_pMain = CEGUI.Window.toMultiColumnList(winMgr:getWindow("RankingList/PersonalInfo/list"))
	print("布局加载完成7")
	
	self.m_pMain_high = self.m_pMain:getYPosition().offset
    self.m_CloseBtnEx = CEGUI.Window.toPushButton(winMgr:getWindow("RankingList/close"))
    self.m_pRewardBtn = CEGUI.Window.toPushButton(winMgr:getWindow("RankingList/get"))
    self.m_pText = winMgr:getWindow("RankingList/personalrank")
	print("布局加载完成8")
    self.m_pMain:setUserSortControlEnabled(false)
	print("布局加载完成8222")
    self:InitTree()
	print("布局加载完成83333")
    self.top1 = winMgr:getWindow("RankingList/top1/mode")
	print("布局加载完成84444")
    self.top1name = winMgr:getWindow("RankingList/top1/name")
	
	print("布局加载完成9")
    self.top2 = winMgr:getWindow("RankingList/top2/mode")
    self.top2name = winMgr:getWindow("RankingList/top2/name")
	print("布局加载完成10")
    self.top3 = winMgr:getWindow("RankingList/top3/mode")
    self.top3name = winMgr:getWindow("RankingList/top3/name")
	
	print("布局加载完成11")
	self.m_fenbang1 = CEGUI.toPushButton(winMgr:getWindow("RankingList/get/list1"))
	self.m_fenbang2 = CEGUI.toPushButton(winMgr:getWindow("RankingList/get/list2"))
	self.m_fenbang3 = CEGUI.toPushButton(winMgr:getWindow("RankingList/get/list3"))
	self.m_fenbang4 = CEGUI.toPushButton(winMgr:getWindow("RankingList/get/list4"))
	
	self.m_fenbang1:subscribeEvent("Clicked", RankingList.HandlefenbangClick1, self)
	self.m_fenbang2:subscribeEvent("Clicked", RankingList.HandlefenbangClick2, self)
	self.m_fenbang3:subscribeEvent("Clicked", RankingList.HandlefenbangClick3, self)
	self.m_fenbang4:subscribeEvent("Clicked", RankingList.HandlefenbangClick4, self)
	
	self.m_fenbang1:setVisible(false)
	self.m_fenbang2:setVisible(false)
	self.m_fenbang3:setVisible(false)
	self.m_fenbang4:setVisible(false)
	
	print("布局加载完成888")
    -- 自己的排名 by changhao
    self.m_myRank = { };

    self.m_myRank[0] = winMgr:getWindow("RankingList/bangwaixinxi/paiming")
    self.m_myRank[1] = winMgr:getWindow("RankingList/bangwaixinxi/canshu1")
    self.m_myRank[2] = winMgr:getWindow("RankingList/bangwaixinxi/canshu2")
    self.m_myRank[3] = winMgr:getWindow("RankingList/bangwaixinxi/canshu3")
    self.m_myRank[4] = winMgr:getWindow("RankingList/bangwaixinxi/canshu4")
    self.m_myRank[5] = winMgr:getWindow("RankingList/bangwaixinxi/canshu5")

    self.m_myRank[6] = CEGUI.Window.toPushButton(winMgr:getWindow("RankingList/bangwaixinxi/xiangyinganniu"));

    self.m_myRank[6]:subscribeEvent("Clicked", RankingList.HandleMySelfClick, self)

    self.m_myRankWidth = self.m_myRank[6]:getWidth().offset

    self.m_myRankTextXpos = {}
    -- subscribe event
    self.m_CloseBtnEx:subscribeEvent("Clicked", RankingList.OnCloseBtnEx, self)
    self.m_pTree:subscribeEvent("ItemSelectionChanged", RankingList.HandleSelectRank, self)
    -- 响应树控改变by changhao
    self.m_pMain:subscribeEvent("NextPage", RankingList.HandleNextPage, self)
    self.m_pMain:subscribeEvent("SelectionChanged", RankingList.HandleListMemberSelected, self)
    self.m_pTree:SetLastOpenItem(self.m_PersonalItem)
    self.m_pTree:SetLastSelectItem(self.m_zongheItem)
    self.m_pTree:invalidate()

    local p = require "protodef.fire.pb.clan.copenclan":new()
    require "manager.luaprotocolmanager".getInstance():send(p)

    LogInfo("exit RankingList OnCreate")
	print("布局加载完成")
	
end

------------------- private: -----------------------------------

function RankingList:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, RankingList)

    return self
end

function RankingList:HandleSelectRank(args)
    -- 选择一个新的排名 by changhao
    LogInfo("RankingList handle select rank")
    local item = self.m_pTree:getSelectedItem()
    if item == nil then
        return true
    end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local fb = roleItemManager:getfenbang()
	if fb ~= 0 then
	self.m_fenbang1:setVisible(false)
	self.m_fenbang2:setVisible(false)
	self.m_fenbang3:setVisible(false)
	self.m_fenbang4:setVisible(false)
	end
    local id = item:getID()
    local req = CRequestRankList.Create()
    req.ranktype = id
    self.m_iRankType = id
    req.page = 0
    self.m_iCurPage = 0
    LuaProtocolManager.getInstance():send(req)
    gGetGameUIManager():AddWindowSprite(self.top1,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top2,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    gGetGameUIManager():AddWindowSprite(self.top3,  0, Nuclear.XPDIR_BOTTOMRIGHT, 0, 0, true)
    self.top1name:setText("")
    self.top2name:setText("")
    self.top3name:setText("")
	
	
	if  id == 32 then
	local heitht = self.m_pMain:getYPosition().offset
	self.m_pMain:setYPosition(CEGUI.UDim(0, heitht +40));
	self.m_fenbang1:setVisible(true)
	self.m_fenbang2:setVisible(true)
	self.m_fenbang3:setVisible(true)
	self.m_fenbang4:setVisible(true)
	else
		if fb == 0 then
		self.m_fenbang1:setVisible(false)
		self.m_fenbang2:setVisible(false)
		self.m_fenbang3:setVisible(false)
		self.m_fenbang4:setVisible(false)
		end
		
	self.m_pMain:setYPosition(CEGUI.UDim(0, self.m_pMain_high));
	end
    self.m_pMain:resetList()
    local record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(id)
    -- 重新设置列表头长度 by changhao
    self.m_myRankTextXpos = {}
    self.m_myRankTextXpos[1] = record.kuandu1
    self.m_myRankTextXpos[2] = record.kuandu2
    self.m_myRankTextXpos[3] = record.kuandu3
    self.m_myRankTextXpos[4] = record.kuandu4
    self.m_myRankTextXpos[5] = record.kuandu5
    self.m_myRankTextXpos[6] = record.kuandu6
    self.m_pMain:getListHeader():getSegmentFromColumn(0):setText(record.name1)
    self.m_pMain:setColumnHeaderWidth(0, CEGUI.UDim(record.kuandu1, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(1):setText(record.name2)
    self.m_pMain:setColumnHeaderWidth(1, CEGUI.UDim(record.kuandu2, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(2):setText(record.name3)
    self.m_pMain:setColumnHeaderWidth(2, CEGUI.UDim(record.kuandu3, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(3):setText(record.name4)
    self.m_pMain:setColumnHeaderWidth(3, CEGUI.UDim(record.kuandu4, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(4):setText(record.name5)
    self.m_pMain:setColumnHeaderWidth(4, CEGUI.UDim(record.kuandu5, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(5):setText(record.name6)
    self.m_pMain:setColumnHeaderWidth(5, CEGUI.UDim(record.kuandu6, 0))

    self:ResetRankPos(maxNum)

end

function RankingList:ResetRankPos(num)
    local offset = 4
    for i = 0, (num-1) do
        local scale = self.m_myRankTextXpos[i + 1]
        local myRank = self.m_myRank[i]
        offset = offset + (scale * self.m_myRankWidth) / 2
        myRank:setXPosition(CEGUI.UDim(0, offset - myRank:getWidth().offset / 2))
        offset = offset + (scale * self.m_myRankWidth) / 2
    end
end

function RankingList:HandleMySelfClick(args)

    local rankItem = self.m_pTree:getSelectedItem()
    if rankItem == nil then
        return;
    end

    local rankType = rankItem:getID();

    local req = require "protodef.fire.pb.ranklist.getrankinfo.crankgetinfo".Create()

    if rankType == typeEnum.PET_GRADE_RANK then
        req.ranktype = typeEnum.PET_GRADE_RANK;
        req.rank = -2;

    elseif rankType == typeEnum.ROLE_ZONGHE_RANK then
        req.ranktype = typeEnum.ROLE_ZONGHE_RANK;
        req.rank = -1;
    elseif rankType == typeEnum.ROLE_RANK then
        req.ranktype = typeEnum.ROLE_RANK
        req.rank = -1;
    elseif rankType == typeEnum.LEVEL_RANK then
        req.ranktype = typeEnum.LEVEL_RANK;
        req.rank = -1;
    elseif rankType == typeEnum.FACTION_RANK_LEVEL or
            rankType == typeEnum.FACTION_ZONGHE or
            rankType == typeEnum.FACTION_MC or
            rankType == typeEnum.FACTION_NAXX then
        req.ranktype = rankType
        req.rank = -1;
    elseif  rankType == typeEnum.FACTION_COPY then
        req.ranktype = rankType
        req.rank = -1;
    elseif rankType == typeEnum.RED_PACK_1 or rankType == typeEnum.RED_PACK_2 or rankType == typeEnum.FLOWER_GIVE or rankType == typeEnum.FLOWER_RECEIVE then
        req.rank = -1;
    else
        req.ranktype = typeEnum.ROLE_ZONGHE_RANK;
        req.rank = -1;
    end

    require "manager.luaprotocolmanager".getInstance():send(req)

end

function RankingList:HandlefenbangClick1(args)
	self:sety(1)
	self.m_pMain:resetList()
		
end

function RankingList:HandlefenbangClick2(args)
	self:sety(2)
	self.m_pMain:resetList()
end
function RankingList:HandlefenbangClick3(args)
	self:sety(3)
	self.m_pMain:resetList()
end
function RankingList:HandlefenbangClick4(args)
	self:sety(4)
	self.m_pMain:resetList()
end

function RankingList:sety(m)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.fenbang = m
	roleItemManager:setfenbang(self.fenbang)
	local req = CRequestRankList.Create()
    req.ranktype = 32
    req.page = 0

    LuaProtocolManager.getInstance():send(req)


end


function RankingList:HandleListMemberSelected(args)
    local rowItem = self.m_pMain:getFirstSelectedItem()
    local rankItem = self.m_pTree:getSelectedItem()
    if rankItem == nil or rowItem == nil then
        return true
    end
    local rowId = rowItem:getID()
    local rankType = rankItem:getID()
    local id = rowItem:GetUserID()
    if rankType == typeEnum.ROLE_ZONGHE_RANK or rankType == typeEnum.LEVEL_RANK or rankType == typeEnum.PET_GRADE_RANK or rankType == typeEnum.XIAKE_RANK
            or rankType == typeEnum.PROFESSION_WARRIOR_RANK
            or rankType == typeEnum.PROFESSION_MAGIC_RANK
            or rankType == typeEnum.PROFESSION_PRIEST_RANK
            or rankType == typeEnum.PROFESSION_PALADIN_RANK
            or rankType == typeEnum.PROFESSION_HUNTER_RANK
            or rankType == typeEnum.PROFESSION_DRUID_RANK
            or rankType == typeEnum.ROLE_RANK
            or rankType == 60
            or rankType == 61
            or rankType == 62
            or rankType == 63
            or rankType == 64
        or rankType == 65
        or rankType == 66 or
        rankType == 67 or
         rankType == 113 or
          rankType == 114 or
           rankType == 115 or
            rankType == typeEnum.PVP5_LAST_GRADE1  or
            rankType == typeEnum.PVP5_LAST_GRADE2  or
            rankType == typeEnum.PVP5_LAST_GRADE3  or
            rankType == typeEnum.PVP5_HISTORY_GRADE1  or
            rankType == typeEnum.PVP5_HISTORY_GRADE2  or
            rankType == typeEnum.PVP5_HISTORY_GRADE3  or
            rankType == typeEnum.RED_PACK_1  or
            rankType == typeEnum.RED_PACK_2  or
            rankType == typeEnum.FLOWER_GIVE  or
            rankType == typeEnum.FLOWER_RECEIVE
    then

        local req = require "protodef.fire.pb.ranklist.getrankinfo.crankgetinfo".Create()
        req.ranktype = rankType
        req.rank = rowId
        req.id = id
        require "manager.luaprotocolmanager".getInstance():send(req)

    elseif rankType == typeEnum.PET_GRADE_RANK then

        local req = require "protodef.fire.pb.ranklist.getrankinfo.crankgetinfo".Create()
        req.ranktype = rankType
        req.rank = rowId
        require "manager.luaprotocolmanager".getInstance():send(req)
    elseif rankType == typeEnum.FACTION_RANK_LEVEL or
            rankType == typeEnum.FACTION_ZONGHE or
            rankType == typeEnum.FACTION_MC or
            rankType == typeEnum.FACTION_NAXX or
            rankType == typeEnum.FACTION_COPY then
        local req = require "protodef.fire.pb.ranklist.getrankinfo.crankgetinfo".Create()
        req.ranktype = rankType
        req.rank = rowId
        req.id = id
        require "manager.luaprotocolmanager".getInstance():send(req)
    end

end

function RankingList:HandleNextPage(args)
    LogInfo("RankingList handle next page")
    if self.m_bHasMore then
        self.m_iCurPage = self.m_iCurPage + 1
        local BarPos = self.m_pMain:getVertScrollbar():getScrollPosition()
        self.m_pMain:getVertScrollbar():Stop()
        self.m_pMain:getVertScrollbar():setScrollPosition(BarPos)

        local req = CRequestRankList.Create()
        req.ranktype = self.m_iRankType
        req.page = self.m_iCurPage
        LuaProtocolManager.getInstance():send(req)

    end
    return true
end


function RankingList:InitTree()
    LogInfo("RankingList init tree")

    local strTitle1 = MHSD_UTILS.get_resstring(2900)
	print("9999999999")
	local first = self.m_pTree:addItem(CEGUI.String("[font='simhei-12'][colour='fffcc865']" .. strTitle1)) 
    --local first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR ..strTitle1))
    -- 个人信息榜 by changhao
    print("9999999999111111")
    local record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(typeEnum.ROLE_ZONGHE_RANK)
	
	print("9999999999222222")
    -- 综合            p排行榜配置表.xlsx by changhao
	local second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), typeEnum.ROLE_ZONGHE_RANK)
	
	print("99999999999999")
    --local second = first:addItem(CEGUI.String(record.leixing), typeEnum.ROLE_ZONGHE_RANK)

    SetGroupBtnTreeSecondIcon1(second)
     print("999999999933333")
    self.m_PersonalItem = first
	print("999999999944444")
    self.m_zongheItem = second
print("99999999995555")
    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(typeEnum.LEVEL_RANK)
	print("999999999966666")
    -- 等级 by changhao
  --  second = first:addItem(CEGUI.String(record.leixing), typeEnum.LEVEL_RANK)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), typeEnum.LEVEL_RANK)
    SetGroupBtnTreeFirstIcon1(first)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(38)
    -- 人物 by changhao
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 38)
   -- second = first:addItem(CEGUI.String(record.leixing), 38)
	
    SetGroupBtnTreeSecondIcon1(second)
    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(typeEnum.PET_GRADE_RANK)
    -- 宠物 by changhao
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), typeEnum.PET_GRADE_RANK)
   -- second = first:addItem(CEGUI.String(record.leixing), typeEnum.PET_GRADE_RANK)
    SetGroupBtnTreeSecondIcon1(second)
    first:toggleIsOpen()

    -------------------------------------------
	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. "[font='simhei-12'][colour='fffcc865']" .. MHSD_UTILS.get_resstring(11195))) 
   -- first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(11195)))
    -- 职业榜 by changhao
    SetGroupBtnTreeFirstIcon1(first)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(43)
    --  战士 by changhao
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 43)
    --second = first:addItem(CEGUI.String(record.leixing), 43)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(44)
    --  法师 by changhao
    --second = first:addItem(CEGUI.String(record.leixing), 44)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 44)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(45)
   --  牧师 by changhao
   -- second = first:addItem(CEGUI.String(record.leixing), 45)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 45)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(46)
    --  圣骑士 by changhao
    --second = first:addItem(CEGUI.String(record.leixing), 46)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 46)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(47)
   --  猎人 by changhao
    --second = first:addItem(CEGUI.String(record.leixing), 47)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 47)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(48)
    --  德鲁伊 by changhao
    --second = first:addItem(CEGUI.String(record.leixing), 48)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 48)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(60)
    --  盗贼 by changhao
   -- second = first:addItem(CEGUI.String(record.leixing), 60)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 60)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(61)
    --  萨满 by changhao
    --second = first:addItem(CEGUI.String(record.leixing), 61)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 61)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(62)
    --  术士 by changhao
    --second = first:addItem(CEGUI.String(record.leixing), 62)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 62)
    SetGroupBtnTreeSecondIcon1(second)
	---新门派
	record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(63)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 63)
    SetGroupBtnTreeSecondIcon1(second)
    ---新门派
	record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(64)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 64)
    SetGroupBtnTreeSecondIcon1(second)
    ---新门派
    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(65)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 65)
    SetGroupBtnTreeSecondIcon1(second)
    ---新门派
    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(66)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 66)
    SetGroupBtnTreeSecondIcon1(second)
    -- ==============================================
    -------------------------------------------------
    --first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(11331)))
	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. "[font='simhei-12'][colour='fffcc865']" .. MHSD_UTILS.get_resstring(11331))) 
    -- 公会榜 by changhao
    SetGroupBtnTreeFirstIcon1(first)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(49)
    --  公会等级 by sunwen
    --second = first:addItem(CEGUI.String(record.leixing), 49)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 49)
    SetGroupBtnTreeSecondIcon1(second)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(50)
    --  公会综合实力 by sunwen
    --second = first:addItem(CEGUI.String(record.leixing), 50)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 50)
    SetGroupBtnTreeSecondIcon1(second)

    -- ==============================================
    -------------------------------------------------
    --first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(11332)))
	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. "[font='simhei-12'][colour='fffcc865']" .. MHSD_UTILS.get_resstring(11332))) 
    -- 公会竞速榜 by changhao
    SetGroupBtnTreeFirstIcon1(first)

    record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(70)
    --  熔火之心 by sunwen
    --second = first:addItem(CEGUI.String(record.leixing), 70)
	second = first:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), 70)
    SetGroupBtnTreeSecondIcon1(second)

    --record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(52)
    --  纳克萨马斯 by sunwen
    --second = first:addItem(CEGUI.String(record.leixing), 52)
    --SetGroupBtnTreeSecondIcon1(second)
    -- ==============================================
    local str5v5Title = MHSD_UTILS.get_resstring(11475)
    first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. "[font='simhei-12'][colour='fffcc865']" .. str5v5Title))	
    --first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR ..str5v5Title))
    SetGroupBtnTreeFirstIcon1(first)

    self:addSecondRank(first,81)
    self:addSecondRank(first,82)
    self:addSecondRank(first,83)
    self:addSecondRank(first,84)
    self:addSecondRank(first,85)
    self:addSecondRank(first,86)

    local strRedPackTitle = MHSD_UTILS.get_resstring(11571) 
    --first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR ..strRedPackTitle))
	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. "[font='simhei-12'][colour='fffcc865']" ..strRedPackTitle))
    SetGroupBtnTreeFirstIcon1(first)
    if IsPointCardServer() then
        self:addSecondRank(first,102)
    else
        self:addSecondRank(first,101)
    end
    
    

    local strRedPackTitle = MHSD_UTILS.get_resstring(11572)
    first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. "[font='simhei-12'][colour='fffcc865']" ..strRedPackTitle))	
   -- first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR ..strRedPackTitle))
    SetGroupBtnTreeFirstIcon1(first)
    self:addSecondRank(first,111)
    self:addSecondRank(first,112)
end

function RankingList:addSecondRank(firstItem, nRankId)
    local record = BeanConfigManager.getInstance():GetTableByName("game.cpaihangbang"):getRecorder(nRankId)
    if not record then
        return
    end
    --local second = firstItem:addItem(CEGUI.String(record.leixing), nRankId)
	local second = firstItem:addItem(CEGUI.String("[font='simhei-11'][colour='fffcc865']" .. record.leixing), nRankId)
    SetGroupBtnTreeSecondIcon1(second)

end

-- 添加一个数据行
function RankingList:AddRow(leixing,Shape,color1,color2,components,rownum, id, col0, col1, col2, col3, col4, col5)

    if rownum==0 and leixing==2 then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top1:getPixelSize()
        self.top1xx = gGetGameUIManager():AddWindowSprite(self.top1, shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top1name:setProperty("TextColours", textColor)
        self.top1name:setText(col1)
        -- ✅ 安全检查：components 可能为空
        if components and components[1] then
            self.top1xx:SetSpriteComponent(eSprite_Weapon, components[1])
        end
        if components and components[6] then
            self.top1xx:SetSpriteComponent(eSprite_Horse,components[6])
        end
        self.top1xx:SetDyePartIndex(0, color1)
        self.top1xx:SetDyePartIndex(1, color2)
    end
    if rownum==1 and leixing==2 then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top2:getPixelSize()
        self.top2xx = gGetGameUIManager():AddWindowSprite(self.top2, shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top2name:setProperty("TextColours", textColor)
        self.top2name:setText(col1)
        -- ✅ 安全检查：components 可能为空
        if components and components[1] then
            self.top2xx:SetSpriteComponent(eSprite_Weapon, components[1])
        end
        if components and components[6] then
            self.top2xx:SetSpriteComponent(eSprite_Horse,components[6])
        end
        self.top2xx:SetDyePartIndex(0, color1)
        self.top2xx:SetDyePartIndex(1, color2)
    end
    if rownum==2 and leixing==2 then
        local shapex=Shape
        if Shape<100 then
            shapex=shapex+1010100+1000
        end
        local s1 = self.top1:getPixelSize()
        self.top3xx = gGetGameUIManager():AddWindowSprite(self.top3,  shapex, Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top3name:setProperty("TextColours", textColor)
        self.top3name:setText(col1)
        -- ✅ 安全检查：components 可能为空
        if components and components[1] then
            self.top3xx:SetSpriteComponent(eSprite_Weapon, components[1])
        end
        if components and components[6] then
            self.top3xx:SetSpriteComponent(eSprite_Horse,components[6])
        end
        self.top3xx:SetDyePartIndex(0, color1)
        self.top3xx:SetDyePartIndex(1, color2)
    end
    if rownum==0 and leixing==1 then
        local s1 = self.top1:getPixelSize()
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(Shape)
        self.top1xx = gGetGameUIManager():AddWindowSprite(self.top1,  tonumber(petAttr.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top1name:setProperty("TextColours", textColor)
        self.top1name:setText(col1)
    end
    if rownum==1 and leixing==1 then
        local s1 = self.top2:getPixelSize()
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(Shape)
        self.top2xx = gGetGameUIManager():AddWindowSprite(self.top2,  tonumber(petAttr.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top2name:setProperty("TextColours", textColor)
        self.top2name:setText(col1)
    end
    if rownum==2 and leixing==1 then
        local s1 = self.top1:getPixelSize()
        local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(Shape)
        self.top3xx = gGetGameUIManager():AddWindowSprite(self.top3,  tonumber(petAttr.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
        local huoliColor = self:GetRowColor(rownum)
        local textColor = "tl:"..huoliColor.." tr:"..huoliColor.." bl:"..huoliColor.." br:"..huoliColor
        self.top3name:setProperty("TextColours", textColor)
        self.top3name:setText(col1)
    end
    LogInfo("RankingList add row")
    self.m_pMain:addRow(rownum)
    -- 获得字体颜色
    local color = self:GetRowColor(rownum)

    local pItem0 = self:CreateColumnItem(col0, color, rownum, id, 0)
    if pItem0 then
        if rownum == 0 then
            -- 前3名只显示图标不显示名次 by changhao
            pItem0:setStaticImage("set:cc25412 image:no1");
            pItem0:setText("");
        elseif rownum == 1 then
            pItem0:setStaticImage("set:cc25412 image:no2");
            pItem0:setText("");
        elseif rownum == 2 then
            pItem0:setStaticImage("set:cc25412 image:no3");
            pItem0:setText("");
        end
        pItem0:setStaticImageWidthAndHeight(40.0, 40.0)
    end

    local pItem1 = self:CreateColumnItem(col1, color, rownum, id, 1)
    local pItem2 = self:CreateColumnItem(col2, color, rownum, id, 2)
    local pItem3 = self:CreateColumnItem(col3, color, rownum, id, 3)
    local pItem4 = self:CreateColumnItem(col4, color, rownum, id, 4)
    local pItem4 = self:CreateColumnItem(col5, color, rownum, id, 5)
end

function RankingList:OnCloseBtnEx()
    self:DestroyDialog()
end
-- 创建一个列
function RankingList:CreateColumnItem(text, color, rownum, id, col)
    if not text then
        return nil
    end
    local pItem = CEGUI.createListboxTextItem(text)
    if not pItem then
        return nil
    end
    pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
    pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
    pItem:setID(rownum)
    pItem:SetUserID(id)
    pItem:setFont(self.m_FontText)
    if self.m_pMain then
        self.m_pMain:setItem(pItem, col, rownum)
    end
    return pItem
end
-- 行颜色
function RankingList:GetRowColor(rownum)
    local color = "ff8c5e2a"
    if rownum == 0 then
        -- 排名第一 by changhao
        color = "ff8c5e2a"
    elseif rownum == 1 then
        color = "ff8c5e2a"
    elseif rownum == 2 then
        color = "ff8c5e2a"
    end
    return color
end

function RankingList:shape1(row,components,list)
    local s = self.m_CurSpriteBack1:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack1, row.shape1, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
    for i, v in pairs(components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            self.m_CurSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            self.m_CurSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            self.m_CurSprite:UpdateWeaponColorParticle(v)      
        end
    end
            local sizeof_recordlist = #list
            for k = 1, 1 do
                local row = RoleZongheRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName1:setText(row.rolename)
            end
end
function RankingList:shape2(row,components,list)
    local s = self.m_CurSpriteBack2:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack2, row.shape2, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
    for i, v in pairs(components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            self.m_CurSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            self.m_CurSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            self.m_CurSprite:UpdateWeaponColorParticle(v)      
        end
    end
            local sizeof_recordlist = #list
            for k = 2, 2 do
                local row = RoleZongheRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName2:setText(row.rolename)
            end
end
function RankingList:shape3(row,components,list)
    local s = self.m_CurSpriteBack3:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack3, row.shape3, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
    for i, v in pairs(components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            self.m_CurSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            self.m_CurSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            self.m_CurSprite:UpdateWeaponColorParticle(v)      
        end
    end
            local sizeof_recordlist = #list
            for k = 3, 3 do
                local row = RoleZongheRankRecord:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName3:setText(row.rolename)
            end
end
function RankingList:shape4(row,list)
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(row.shape1)
    local s = self.m_CurSpriteBack1:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack1, petAttr.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
	local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
	local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
	local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
	self.m_CurSprite:SetSpriteComponent(eSprite_Weapon, weapon)
	self.m_CurSprite:SetDyePartIndex(0, pA)
    self.m_CurSprite:SetDyePartIndex(1, pB)
	
            local sizeof_recordlist = #list
            for k = 1, 1 do
                local row = PetGradeRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName1:setText(row.petname)
            end
end
function RankingList:shape5(row,list)
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(row.shape2)
    local s = self.m_CurSpriteBack2:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack2, petAttr.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
	local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
	local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
	local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
	self.m_CurSprite:SetSpriteComponent(eSprite_Weapon, weapon)
	self.m_CurSprite:SetDyePartIndex(0, pA)
    self.m_CurSprite:SetDyePartIndex(1, pB)
            local sizeof_recordlist = #list
            for k = 2, 2 do
                local row = PetGradeRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName2:setText(row.petname)
            end
end
function RankingList:shape6(row,list)
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(row.shape3)
    local s = self.m_CurSpriteBack3:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack3, petAttr.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
	local weapon = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
	local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
	local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
	self.m_CurSprite:SetSpriteComponent(eSprite_Weapon, weapon)
	self.m_CurSprite:SetDyePartIndex(0, pA)
    self.m_CurSprite:SetDyePartIndex(1, pB)
            local sizeof_recordlist = #list
            for k = 3, 3 do
                local row = PetGradeRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName3:setText(row.petname)
            end
end


function RankingList:shape7(row,components,list)
    local s = self.m_CurSpriteBack1:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack1, row.shape1, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
    for i, v in pairs(components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            self.m_CurSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            self.m_CurSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            self.m_CurSprite:UpdateWeaponColorParticle(v)      
        end
    end
            local sizeof_recordlist = #list
            for k = 1, 1 do
                local row = LevelRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName1:setText(row.nickname)
            end
end
function RankingList:shape8(row,components,list)
    local s = self.m_CurSpriteBack2:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack2, row.shape2, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
    for i, v in pairs(components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            self.m_CurSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            self.m_CurSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            self.m_CurSprite:UpdateWeaponColorParticle(v)      
        end
    end
            local sizeof_recordlist = #list
            for k = 2, 2 do
                local row = LevelRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName2:setText(row.nickname)
            end
end
function RankingList:shape9(row,components,list)
    local s = self.m_CurSpriteBack3:getPixelSize()
    self.m_CurSprite = gGetGameUIManager():AddWindowSprite(self.m_CurSpriteBack3, row.shape3, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 50, true)
    for i, v in pairs(components) do
        if i ~= eSprite_WeaponColor and i ~= eSprite_Fashion
			and i ~= eSprite_DyePartA and i ~= eSprite_DyePartB then
            self.m_CurSprite:SetSpriteComponent(i, v)
        elseif 50 <= i and i <= 59 then
            self.m_CurSprite:SetDyePartIndex(i-50,v)
        elseif i == eSprite_Weapon then
            self.m_CurSprite:UpdateWeaponColorParticle(v)      
        end
    end
            local sizeof_recordlist = #list
            for k = 3, 3 do
                local row = LevelRankData:new()
                local _os_ = FireNet.Marshal.OctetsStream:new(list[k])
                row:unmarshal(_os_)
                _os_:delete()
    _instance.m_txtPlayerName3:setText(row.nickname)
            end
end
return RankingList