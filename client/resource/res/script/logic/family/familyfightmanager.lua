
FamilyFightManager = {}
FamilyFightManager.__index = FamilyFightManager
local _instance = nil

function FamilyFightManager.Destroy()
    if _instance then 
		_instance:ClearData()
        _instance = nil
    end
end

function FamilyFightManager.getInstance()
	if not _instance then
		_instance = FamilyFightManager:new()
	end
	return _instance
end

function FamilyFightManager:new()
    local self = {}
    setmetatable(self, FamilyFightManager)
	self:InitData()
    return self
end

FamilyFightManager.Data =
{
    m_myList = {},              --己方公会战成员列表
    m_emeryList = {},       --敌方方公会战成员列表
    m_isInFight = false,     -- 设置是否在公会战，默认false
    m_enterTime = 0,        --公会战进入时间
    m_readyTime = 0,        --公会战准备时间
    m_beginTime = 0,        --公会战开始时间
    m_endTime = 0,           --公会战结束时间
    m_time = 1000,
    m_userList = {},
    m_curType = 0,
    m_serverUserList = {},
    m_isCurXingdongli = 0,
    m_isInitTime = 1000,
   -- m_changeColor = {}
}

FamilyFightManagerFigthType =
{
    InReady = 1,    --准备阶段
    Started = 2,    --已经开始
    Ended = 3       --已经结束
}

FamilyFightManagerCamp =
{
    UnKnown = -1,    --未知错误
    Friendly = 1,    --友放
    Emery = 2       --敌方
}

--公会战清除数据
function FamilyFightManager:ClearData()
    FamilyFightManager.Data.m_myList = {}
    FamilyFightManager.Data.m_emeryList = {}
    FamilyFightManager.Data.m_isInFight = false
    FamilyFightManager.Data.m_enterTime = 0
    FamilyFightManager.Data.m_readyTime = 0
    FamilyFightManager.Data.m_beginTime = 0
    FamilyFightManager.Data.m_endTime = 0
    FamilyFightManager.Data.m_userList = {}
   -- FamilyFightManager.Data.m_changeColor = {}
    FamilyFightManager.Data.m_serverUserList = {}
end

--公会战初始化数据
function FamilyFightManager:InitData()
    local actScheculed = BeanConfigManager.getInstance():GetTableByName("timer.cscheculedactivity"):getRecorder(281001)
    if actScheculed~= nil then
        FamilyFightManager.Data.m_enterTime = actScheculed.startTime
        FamilyFightManager.Data.m_beginTime = actScheculed.startTime2
        FamilyFightManager.Data.m_endTime = actScheculed.endTime
    end
end

function FamilyFightManager:OnMapChanged()
    local familyfightxianshi = require "logic.family.familyfightxianshi"
    local logodlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
    if GetIsInFamilyFight() then
            if familyfightxianshi then
                local dlg  = familyfightxianshi.getInstanceAndShow()
                dlg:UpdateRoleAct(FamilyFightManager.Data.m_isCurXingdongli)
            end
            if logodlg then
                logodlg:IsShowAllBtn(false)
            end
           if not GetTeamManager() then
             return
           end
           if GetTeamManager():IsMyselfLeader() then
                GetMainCharacter():SetTeamNumVisible(true)
                local memberNum = GetTeamManager():GetMemberNum()
                local str = tostring(memberNum) .. "/5"
                GetMainCharacter():SetTeamNum(str)
                GetMainCharacter():SetTeamNumHeight(200,250)
           end
    else
        if familyfightxianshi then
            familyfightxianshi.DestroyDialog()
        end
        if logodlg then
            logodlg:IsShowAllBtn(true)
        end
         GetMainCharacter():SetTeamNumVisible(false)
    end
end

function FamilyFightManager:SetXingDongli(xingdongli)
    FamilyFightManager.Data.m_isCurXingdongli  = xingdongli
    local familyfightxianshi = require "logic.family.familyfightxianshi"
    if familyfightxianshi then
        local dlg  = familyfightxianshi.getInstanceAndShow()
        dlg:UpdateRoleAct(FamilyFightManager.Data.m_isCurXingdongli)
    end
end

function FamilyFightManager:update(delta)
    self:updateFactionFightInfo(delta)
end

-- 处理断线重连
function FamilyFightManager.onInternetReconnected()
    FamilyFightManager.Data.m_userList = {}
   -- FamilyFightManager.Data.m_changeColor = {}
    FamilyFightManager.Data.m_serverUserList = {}
    if not GetIsInFamilyFight() then
        local familyfight = require ("logic.family.familyfightxianshi").getInstanceNotCreate()
        if familyfight then
            familyfight.DestroyDialog()
        end
    end
end

--更新公会战玩家的显示信息
function FamilyFightManager:updateFactionFightInfo(delta)
    --LogInfo("updateFactionFightInfo")
    if not GetIsInFamilyFight() then
        return
    end
    self:SendFightUserId(delta)

    self:UpdateNameColor(delta)
end

function FamilyFightManager:UpdateNameColor(delta)
    FamilyFightManager.Data.m_isInitTime = delta + FamilyFightManager.Data.m_isInitTime
    if  FamilyFightManager.Data.m_isInitTime > 1000 then
        if  FamilyFightManager.Data.m_curType == FamilyFightManagerFigthType.InReady then
            self:UpdateNameColorInFight()
        elseif FamilyFightManager.Data.m_curType == FamilyFightManagerFigthType.Started then
            self:UpdateNameColorStartedFight()
        else
           
        end
        FamilyFightManager.Data.m_isInitTime = 0
    end
end

--[[
准备阶段    1.自己和自己队员为粉色 0xfffa7dff    2.己方为绿色  0xfffc7cb3   3.敌方为黄色
战斗阶段    1.自己和己方都为绿色                 2.敌方为红色
--]]
--更新准备阶段颜色的显示
function FamilyFightManager:UpdateNameColorInFight()
    for k,v in pairs (FamilyFightManager.Data.m_serverUserList) do
		local character = gGetScene():FindCharacterByID(k)
		if character ~= nil then
			local roleid = character:GetID()
			if v==FamilyFightManagerCamp.Friendly then --自己一方
				character:SetNameColour(0xff33ff33) 	--green
				if  GetTeamManager() then
					local list = GetTeamManager():GetMemberList()
					for _,v in ipairs(list) do
						if v.id == roleid then
							character:SetNameColour(0xfffa7dff) 
						end
					end 
				end 
				if gGetDataManager():GetMainCharacterData().roleid  == roleid  then
					character:SetNameColour(0xfffa7dff)
				end
			elseif v==FamilyFightManagerCamp.Emery then --敌对一方
				character:SetNameColour(0xff33ffff) 	-- 敌方为黄色 
			elseif v ==FamilyFightManagerCamp.UnKnown then
				character:SetNameColour(0xff33fff0) 	--
			end
		end
    end
end


--更新开始战斗颜色的显示
function FamilyFightManager:UpdateNameColorStartedFight()
    for k,v in pairs (FamilyFightManager.Data.m_serverUserList) do
        --if FamilyFightManager.Data.m_changeColor[k] == nil then
             local character = gGetScene():FindCharacterByID(k)
             if character ~= nil then
                if v==FamilyFightManagerCamp.Friendly then --自己一方
                       character:SetNameColour(0xff33ff33) 	--green
                elseif v==FamilyFightManagerCamp.Emery then --敌对一方
                       character:SetNameColour(0xff3333ff) 	--red
                elseif v ==FamilyFightManagerCamp.UnKnown then
                      character:SetNameColour(0xff33fff0) 	--
                end
        --        FamilyFightManager.Data.m_changeColor[k] = 1
             end
        --end
    end
end

function FamilyFightManager:SendFightUserId(delta)
    FamilyFightManager.Data.m_time = delta + FamilyFightManager.Data.m_time
    if FamilyFightManager.Data.m_time > 1000 then

        if  self:GetIsReadyForFight()  then
            FamilyFightManager.Data.m_curType = FamilyFightManagerFigthType.InReady
        else
            FamilyFightManager.Data.m_curType = FamilyFightManagerFigthType.Started
        end

        local req = require"protodef.fire.pb.clan.fight.crequestroleisenemy".Create()
        local num = gGetScene():GetSceneCharNum()
		for i = 1, num do
            local character = gGetScene():GetSceneCharacter(i)
            local roleid = character:GetID()
            if FamilyFightManager.Data.m_userList[roleid] == nil then
                FamilyFightManager.Data.m_userList[roleid] = 1
            end
		end
        for k,v in pairs (FamilyFightManager.Data.m_userList) do
            if v == 1 then
                table.insert(req.roleidlist,k)
                FamilyFightManager.Data.m_userList[k] = 2
            end
        end
        if req.roleidlist and #req.roleidlist > 0 then
            LuaProtocolManager.getInstance():send(req)
        end
        FamilyFightManager.Data.m_time = 0
    end
end

 

function FamilyFightManager:UpdateUserList(userlist)
    if userlist ==nil then return end
    for k,v in pairs(userlist) do
        FamilyFightManager.Data.m_serverUserList[k] = v
    end
end

--判断是否敌对
function FamilyFightManager:IsEnemy(roleid)
    local isenmy = FamilyFightManager.Data.m_serverUserList[roleid]
    for k,v in pairs (FamilyFightManager.Data.m_serverUserList) do
        if tonumber(k) == tonumber(roleid) then
            if v == FamilyFightManagerCamp.Emery then
                return true
            end
        end
    end
    return false
end

--获取是否在备战中
function FamilyFightManager:GetIsReadyForFight()
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000) 
    local hour = time.tm_hour
    local min = time.tm_min
    local begintimehour, begintimemin, begintimesec = string.match(FamilyFightManager.Data.m_beginTime, "(%d+):(%d+):(%d+)")
    local leftmin = (hour - begintimehour ) * 60 + (  min - begintimemin)
    if leftmin >= 0 then
        return false
    end
    return true
end


function FamilyFightManager:SystemSetToResetData()
    if GetMainCharacter() then
        GetMainCharacter():SetNameColour(0xff33ff33) 	--green
    end
    FamilyFightManager.Data.m_userList = {}
    --FamilyFightManager.Data.m_changeColor = {}
    FamilyFightManager.Data.m_serverUserList = {}
end

--离开公会战
function FamilyFightManager:ResetData()
    self:SystemSetToResetData()
    local familyfight = require ("logic.family.familyfightxianshi").getInstanceNotCreate()
    if familyfight then
        familyfight.DestroyDialog()
    end
	
	--设置回去同屏数量
	local value = gGetGameConfigManager():GetConfigValue("personshow")
	local beanConfigManager = BeanConfigManager.getInstance()
	local beanTabel = beanConfigManager:GetTableByName("SysConfig.ctongpingsetting")
	local record = beanTabel:getRecorder(1)
	local maxNum = 10
	if not value then
        value = 1
    end

	if value == 1 then
		maxNum = record.morevalue
	else
		maxNum = record.lessvalue
	end
	
    require "mainticker"
    if PlayerCountByFPS < maxNum then
        maxNum = PlayerCountByFPS
    end
	print("FamilyFightManager:ResetData() =========finsh fight============" .. maxNum)
    local setMaxShowNumAction = require ("protodef.fire.pb.csetmaxscreenshownum").Create()
    setMaxShowNumAction.maxscreenshownum = maxNum
    LuaProtocolManager.getInstance():send(setMaxShowNumAction)
end

 
return FamilyFightManager



