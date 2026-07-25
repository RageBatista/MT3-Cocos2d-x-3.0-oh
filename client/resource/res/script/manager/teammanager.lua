------------------------------------------------------------------
-- ���������
------------------------------------------------------------------

require "manager.teamcommon"
require "utils.bit"
require "utils.stringbuilder"


TeamManager = {}
TeamManager.__index = TeamManager

TeamManager.chatTimestamp = 0	-- һ��������ʱ���

local _instance
function GetTeamManager()
    return _instance
end

function TeamManager.newInstance()
    if not _instance then
        _instance = {}
        setmetatable(_instance, TeamManager)
        _instance:init()
    end
    return _instance
end

function TeamManager:init()
    self.m_TeamID = 0
    self.m_TeamSMapID = 0
    self.m_TeamFormationID = 0
    self.m_bIsMatching = false
    self.m_listMember = {}  --stTeamMember �±��1��ʼ��Э�����0��ʼ
    self.m_InviterList = {}   --stTeamInviter
    self.m_listApplicant = {}   --stApplyMember
    self.m_TeamMathInfo = stTeamMatchInfo.new()
    TeamManager.chatTimestamp = 0
    
    self.m_TeamOrderID = 0          --ս��ָ��
    self.m_OrderCmd1 = {}          --ս��ָ������ �ѷ�
    self.m_OrderCmd2 = {}          --ս��ָ������ �з�
    --for i=1,10 do
    --    table.insert(self.m_OrderCmd1,"")
     --   table.insert(self.m_OrderCmd2,"")
    --end
    self.m_HasCmd = false          --�Ѿ��ӷ�����ȡ������
    --���ս��������
    self.elapsed = 0
    self.teamGuideStep = 0  --1.�ȴ�˵���Ķ�Ա���ӵ�ս�� 2.��Ա�ӳ�˵�� 3.�ӳ�������Ͳ
    self.teamGuideChatMemberId = 0 --���Ⱥ����Ķ�Ա�����ѡ�ļ�����
    self.teamGuideMsgId = 0 --���˵�Ļ�
end

function TeamManager.purgeData()
	if _instance then
		_instance:DismissTeam()
		_instance:ClearInviterList()
	end
end

function TeamManager.removeInstance()
    if _instance then
        _instance = nil
    end
end

function TeamManager:GetTeamID()
    return self.m_TeamID
end

function TeamManager:GetTeamSMapID()
    return self.m_TeamSMapID
end

function TeamManager:GetTeamMemberNum()
    return #self.m_listMember
end

function TeamManager:GetTeamFormationID()
    return self.m_TeamFormationID
end

function TeamManager:IsTeamFull()
    return #self.m_listMember >= MAX_TEAMMEMBER
end

function TeamManager:GetMemberList()
    return self.m_listMember
end

function TeamManager:GetMemberNum()
    return #self.m_listMember
end

function TeamManager:IsOnTeam()
    return self.m_TeamID ~= 0 and #self.m_listMember > 0
end

function TeamManager:GetApplicantList()
    return self.m_listApplicant
end

function TeamManager:GetApplicationNum()
    return #self.m_listApplicant
end

function TeamManager:GetApplication(num)
    return self.m_listApplicant[num]
end

function TeamManager:IsIndexValid(index)
    return index >= 1 and index <= #self.m_listMember
end

function TeamManager:IsMatching()
    return self.m_bIsMatching
end

function TeamManager:getMyID()
    if gGetDataManager() then
        return gGetDataManager():GetMainCharacterID()
    end
    return 0
end

--��������
function TeamManager:CreateTeam(teamid, state, smapid, formationid)
	self.m_TeamID = teamid
	self.m_TeamSMapID = smapid or 0
	self.m_TeamFormationID = formationid or 0
    self.m_TeamOrderID = 0
    self:PostTeamListChanged()
end

--����˳�����
function TeamManager:SetTeamSequence(list)
	if #self.m_listMember ~= #list then
		return
    end

    for i,id in ipairs(list) do
        local idx = self:GetTeamMemberIndexByID(id)
        if idx ~= -1 and idx ~= i then
            self.m_listMember[idx], self.m_listMember[i] = self.m_listMember[i], self.m_listMember[idx]
        end
    end

    self:PostTeamListChanged()
end

--�ͻ����Լ������������ˣ���������˶��飬���δ��Ӧ�б���ɾ��
function TeamManager:RemoveWhenInviterJoin(roleid)
    for k,v in ipairs(self.m_InviterList) do
        if v.roleid == roleid then
            table.remove(self.m_InviterList, k)
            break
        end
    end
end

--����һ����Ա
--pData: TeamMemberBasic
function TeamManager:AddTeamMember(pData)
	if self:IsTeamFull() then
		return
    end
	if self:GetTeamMemberByID(pData.roleid) then
		--�ö�Ա�Ѵ���
        local member = self:GetTeamMemberByID(pData.roleid)
        member:setData(pData)

	else
		--�ȴ��������list��ɾ�������
		self:RemoveWhenInviterJoin(pData.roleid)

		--���������б���Ҳɾ�������
		self:RemoveApplicant(pData.roleid)

		local pMember = stTeamMember.new()
		pMember:setData(pData)
        table.insert(self.m_listMember, pMember)

		if pMember.id == gGetDataManager():GetMainCharacterID() then
			if not self:IsMyselfLeader() then
				--����Լ�������ĳ�����飬���Ҳ��Ƕӳ�����ɾ���Լ������������Ϣ�б�
				self:ClearInviterList()
			end
		end
	end
end

--ˢ��ĳ����Ա����
function TeamManager:UpdateMemberState(id, state)
	local pMember = self:GetTeamMemberByID(id)
	if pMember then
		if GetChatManager() then
			if state == eTeamMemberNormal then
				if pMember.eMemberState == eTeamMemberAbsent then
					GetChatManager():AddTipsMsg(162023, 0, {pMember.strName}, true) --xxx�ع��˶���
				end
			elseif state == eTeamMemberAbsent then
				GetChatManager():AddTipsMsg(141199, 0, {pMember.strName}, true) --xxx�����˶���
				
			elseif state == eTeamMemberReturn then
				GetChatManager():AddTipsMsg(162023, 0, {pMember.strName}, true) --xxx�ع��˶���
				
			elseif state == eTeamMemberFallline then
				GetChatManager():AddTipsMsg(162024, 0, {pMember.strName}, true) --xxx������
            end
		end

		pMember.eMemberState = state

        NotificationCenter.postNotification(Notifi_TeamMemberStateChange, id)
        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh)

		self:UpdateMemberSpeed()
	end
end

function TeamManager:UpdateMemberLevel(id, level)
	local pMember = self:GetTeamMemberByID(id)
	if pMember then
		pMember.level = level

        NotificationCenter.postNotification(Notifi_TeamMemberLevelChange, id)
        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh)
	end
end

function TeamManager:UpdateMemberName(id, name)
	local pMember = self:GetTeamMemberByID(id)
	if pMember then
		pMember.strName = name

        NotificationCenter.postNotification(Notifi_TeamMemberNameChange, id)
        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh)
	end
end

function TeamManager:UpdateMemberHpMp(id, Hp, Mp)
    local member = self:GetTeamMemberByID(id)
	if member then
		member.HP = Hp
		member.MP = Mp

        NotificationCenter.postNotification(Notifi_TeamMemberHpMpChange, id)
        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh)
	end
end

function TeamManager:UpdateMemberMaxHpMp(id, MaxHp, maxMp)
    local member = self:GetTeamMemberByID(id)
	if member then
		member.MaxHP = MaxHp
		member.MaxMP = maxMp

        NotificationCenter.postNotification(Notifi_TeamMemberHpMpChange, id)
        NotificationCenter.postNotification(Notifi_TeamMemberDataRefresh)
	end
end

--���¶�Ա����
function TeamManager:UpdateMemberPosition(id, loc, sceneid)
	local pTeamMember = self:GetTeamMemberByID(id)
	if pTeamMember then
		pTeamMember.iSceneID = sceneid
		pTeamMember.iMapID = bit.band(sceneid, 0x00000000FFFFFFFF)
		pTeamMember.ptLogicLocation = loc
		--����Ƕӳ�λ�ø����ˣ�ҲҪˢ��������Աλ�ã��������ǲ�����������
		if pTeamMember == self:GetTeamLeader() then
            for _,v in ipairs(self.m_listMember) do
                if v.id ~= id and v.eMemberState == eTeamMemberNormal then
                    v.iSceneID = sceneid
					v.iMapID = bit.band(sceneid, 0x00000000FFFFFFFF)
					v.ptLogicLocation = loc
                end
            end
		end

		--����Ƕӳ�λ�ñ仯�����Լ����Զ����Ѱ·�У������Զ�Ѱ·��ǰ�����Լ�����ս����
		if self:GetTeamLeader().id == id
		 and GetMainCharacter():GetMapWalker():GetMapWalkerType() == eMapWalkerType_ReturnTeam
		 and not GetBattleManager():IsInBattle()
           then
			self:RequestAbsentReturnTeam(false)
		end

		self:UpdateMemberSpeed()
	end
end

function TeamManager:UpdateMemberSpeed()
    for _,v in ipairs(self.m_listMember) do
        local character = gGetScene():FindCharacterByID(v.id)
        if character then
            character:UpdateSpeed()
        end
    end
end

--�޳���Ա
function TeamManager:RemoveTeamMember(id)
	if #self.m_listMember == 0 then
		return
    end
    
    for k,v in ipairs(self.m_listMember) do
        if v.id == id then
            table.remove(self.m_listMember, k)
            self:PostTeamListChanged()
            break
        end
    end

    if self.m_TeamOrderID == id then
        self.m_TeamOrderID = 0
    end

	if #self.m_listMember == 0 then
		self.m_TeamMathInfo:init()
	end

    Renwulistdialog.tryShowTeamPane()
end

--������Ա
function TeamManager:SwapMember(index1, index2)
	if self:IsIndexValid(index1) and self:IsIndexValid(index2) then
        self.m_listMember[index1], self.m_listMember[index2] = self.m_listMember[index2], self.m_listMember[index1]

        self:PostTeamListChanged()
	end
end

--���öӳ�
function TeamManager:SetTeamLeader(leaderid)
	--����Լ��Ƕӳ���ж���ˣ���ɾ���������б���ɾ���Լ����������Ա��Ϣ���Լ����öӳ���Ϣ
	if self:IsMyselfLeader() and leaderid ~= self:getMyID() then
		self:ClearInviterList()

		self:ClearTeamApplicantList()
		--�ӳ����ƶ��н����ӳ�λ�ã���ͣ����
		GetMainCharacter():GetMapWalker():ClearGoTo()
		GetMainCharacter():StopMove()	--����ͣ����	
	end

	--����Լ��������Ƕӳ��������Ƕӳ��ˣ�������messageboxmanager��Ķ���,144806 ��ʾ��Ϣ�����ѳ�Ϊ�ӳ�!
	if not self:IsMyselfLeader() and leaderid == self:getMyID() then
        GetChatManager():AddTipsMsg(144806) --���ѳ�Ϊ�ӳ���
		gGetMessageManager():OnAbsentTeamAndBeTeamLeader()
	end

	--����ڹ��Ѱ·�и����˶ӳ�����ͣ����
	if GetMainCharacter():GetMapWalker():GetMapWalkerType() == eMapWalkerType_ReturnTeam then
		GetMainCharacter():GetMapWalker():ClearGoTo()
		GetMainCharacter():StopMove()	--����ͣ����
	end

    for k,v in ipairs(self.m_listMember) do
        if v.id == leaderid then
            self.m_listMember[k], self.m_listMember[1] = self.m_listMember[1], self.m_listMember[k]
            break
        end
    end

	if self:GetTeamLeader().eMemberState ~= eTeamMemberNormal then
		self:GetTeamLeader().eMemberState = eTeamMemberNormal
    end

    self:PostTeamListChanged()

	self:UpdateMemberSpeed()
end

--��ɢ��������˳�����
function TeamManager:DismissTeam()
    self.m_listApplicant = {}
	self.m_TeamID = 0
	self.m_TeamSMapID = 0
	self.m_bIsMatching = false
	self.m_TeamMathInfo:init()
	self:ClearInviterList()
	self:ClearTeamMemberList()

	if gGetMessageManager() then
		gGetMessageManager():OnAbsentTeamAndBeTeamLeader()
    end
	if gGetMessageManager() then
		gGetMessageManager():CloseMessageBoxByType(eMsgType_TeamSummon)
	end
	--�˳�����ʱ��Ҳ�˳��ع����Ѱ·״̬
	if GetMainCharacter() and GetMainCharacter():GetMapWalker():GetMapWalkerType() == eMapWalkerType_ReturnTeam then
		GetMainCharacter():GetMapWalker():ClearGoTo()
		GetMainCharacter():StopMove()
	end

    if GetIsInFamilyFight() then
        GetMainCharacter():SetTeamNumVisible(false)
    end

	self:UpdateMemberSpeed()
end

--��ն�Ա
function TeamManager:ClearTeamMemberList()
	--��ն����Ա
	self.m_listMember = {}
	self.m_TeamMathInfo:init()

    self:PostTeamListChanged()
end

--��ն���������
function TeamManager:ClearTeamApplicantList()
	if #self.m_listApplicant > 0 then
		self:RequestRemoveTeamApply(0)
	end

    self.m_listApplicant = {}

	NotificationCenter.postNotification(Notifi_TeamApplicantChange)
end

function TeamManager:GetTeamMemberByID(id)
    for _,v in ipairs(self.m_listMember) do
        if v.id == id then
            return v
        end
    end
	return nil
end

function TeamManager:GetTeamMemberIndexByID(id)
    for i,v in ipairs(self.m_listMember) do
        if v.id == id then
            return i
        end
    end
	return -1
end

function TeamManager:GetMemberSelf()
	if not self:IsOnTeam() or not gGetDataManager() then
		return nil
    end

    for _,v in ipairs(self.m_listMember) do
        if v.id == gGetDataManager():GetMainCharacterID() then
            return v
        end
    end

    return nil
end

--�õ��ӳ�
function TeamManager:GetTeamLeader()
	if not self:IsOnTeam() then
		return nil
    end
	
    return self.m_listMember[1]
end

function TeamManager:IsMyselfLeader()
	return self:IsOnTeam() and gGetDataManager():GetMainCharacterID() == self:GetTeamLeader().id
end

--�Ƿ������߶�Ա
function TeamManager:IsHaveOffLineMember()
    for _,v in ipairs(self.m_listMember) do
        if v.eMemberState == eTeamMemberFallline then
            return true
        end
    end
	return false
end

--�Ƿ��������Ա
function TeamManager:IsHaveAbsentMember()
    for _,v in ipairs(self.m_listMember) do
        if v.eMemberState == eTeamMemberAbsent then
            return true
        end
    end
	return false
end

-- �ж������Ƿ�����
function TeamManager:isMyselfAbsent()
    local myself = self:GetMemberSelf()
    return myself and myself.eMemberState == eTeamMemberAbsent
end

function TeamManager:isAbsentByRoleid(roleId)
    for _,v in ipairs(self.m_listMember) do
        if v.id == roleId and v.eMemberState == eTeamMemberAbsent then
            return true
        end
    end
	return false
end

function TeamManager:isOffLineByRoleid(roleId)
    for _,v in ipairs(self.m_listMember) do
        if v.id == roleId and v.eMemberState == eTeamMemberFallline then
            return true
        end
    end
	return false
end

--����һ������������
--pData: stApplyMember
function TeamManager:AddApplicant(pData)
	if #self.m_listApplicant >= MAX_APPLYMEMBER then
		return
    end
    
    for _,v in pairs(self.m_listApplicant) do
        if v.id == pData.roleid then --���������Ѵ���
            return
        end
    end

	local pApplicant = stApplyMember.new()
    pApplicant:setData(pData)
	table.insert(self.m_listApplicant, pApplicant)

    GetChatManager():AddTipsMsg(144817, 0, {pApplicant.strName}) --xx����������Ķ��飬���ڶ���-�����б��в鿴��

	NotificationCenter.postNotification(Notifi_TeamApplicantChange)
end

--�Ƴ�һ������������
function TeamManager:RemoveApplicant(id)
	if #self.m_listApplicant == 0 then
		return
    end

    for k,v in ipairs(self.m_listApplicant) do
        if v.id == id then
            table.remove(self.m_listApplicant, k)
            NotificationCenter.postNotification(Notifi_TeamApplicantChange)
            break
        end
    end
end

--�ͻ�������Լ�������ĵ�λ�б�
function TeamManager:ClearInviterList()
    self.m_InviterList = {}
end

---------------------------------------------------------------------------------
--------------------------------�����������������Ϣ-----------------------------
---------------------------------------------------------------------------------
--����Ӷӣ����Ǽ���Է�����
function TeamManager:RequestJoinOneTeam(roleid)
    --����ӶԷ�����
    local p = require("protodef.fire.pb.team.crequestjointeam"):new()
    p.roleid = roleid
    LuaProtocolManager:send(p)
end

--�Ƿ��Ѿ��������
function TeamManager:IsAlreadyInviteCharacter(roleid)
    for _,v in ipairs(self.m_InviterList) do
        if v.roleid == roleid then
            return true
        end
    end
	return false
end

--������ӣ�����Է������Լ�����
function TeamManager:RequestInviteToMyTeam(roleid)
	if not self:IsOnTeam() then
		self:RequestCreateTeam()
	end

    if self:IsTeamFull() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141197)	--���������������Է��޷����룡
        end

	elseif self:IsAlreadyInviteCharacter(roleid) then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(162124)	--���Ѿ�������������ˣ���������Ϣһ�����
        end

	else
		local p = require("protodef.fire.pb.team.cinvitejointeam"):new()
        p.roleid = roleid
        p.force = 0
        LuaProtocolManager:send(p)
	end
end

function TeamManager:ForceRequestInviteToMyTeam(roleid)
	if self:IsMyselfLeader() or not self:IsOnTeam() then
		if self:IsTeamFull() then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(141197)	--���������������Է��޷����룡
            end

		elseif self:IsAlreadyInviteCharacter(roleid) then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(141204)	--���Ѿ�������������ˣ���������Ϣһ�����
            end

		else
			local p = require("protodef.fire.pb.team.cinvitejointeam"):new()
            p.roleid = roleid
            p.force = 1
            LuaProtocolManager:send(p)
		end
	else
		if GetChatManager() then
			GetChatManager():AddTipsMsg(141206)--�㲻�Ƕӳ����޷�����
        end
	end
end

--�ͻ����Լ���ס���������
function TeamManager:AddAlreadyInviterInfo(id)
	local pInviter = stTeamInviter.new()
	pInviter.roleid = id
    table.insert(self.m_InviterList, pInviter)
end

function TeamManager:CanIMove()
	if self:IsOnTeam() and not self:IsMyselfLeader() then
		local myself = self:GetMemberSelf()
		if myself.eMemberState ~= eTeamMemberAbsent then
			return false
		end
	end
	return true
end

--��������
function TeamManager:RequestCreateTeam()
    local p = require("protodef.fire.pb.team.ccreateteam"):new()
    LuaProtocolManager:send(p)
end

--��ɢ����
function TeamManager:RequestDismissTeam()
    local p = require("protodef.fire.pb.team.cdismissteam"):new()
    LuaProtocolManager:send(p)
end

--������Ա
function TeamManager:RequestSwapMember(index1, index2)
	if GetBattleManager():IsInBattle() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141363)--ս���в��ܽ��д������
        end
		return
	end

	if self:IsIndexValid(index1) and self:IsIndexValid(index2) and  index1 ~= index2 then
		if self.m_listMember[index1].eMemberState == eTeamMemberNormal
		 and self.m_listMember[index2].eMemberState == eTeamMemberNormal then
			if index1 == 0 or index2 == 0 then
                if GetChatManager() then
                    GetChatManager():AddTipsMsg(143165)--�ӳ�λ�ò��ܸ���
                end
			else
                local p = require("protodef.fire.pb.team.cswapmember"):new()
                p.index1 = index1 - 1
                p.index2 = index2 - 1
                LuaProtocolManager:send(p)
			end
		else
            if GetChatManager() then
                GetChatManager():AddTipsMsg(141193)	--�����Ա���ܽ���λ��
            end
		end
	else
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1276)) --�����Ͻ�����Ա����
    end
end

--���öӳ�
function TeamManager:RequestSetLeader(index)
	if not self:IsMyselfLeader() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141206)--�㲻�Ƕӳ������ܽ��д˲���
        end
	
	elseif GetBattleManager():IsInBattle() then
        if GetChatManager() then
			GetChatManager():AddTipsMsg(150031)--��ս�����������
        end

	elseif index == -1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141194)--��ѡ��һ������
        end

	elseif self:IsIndexValid(index) and self.m_listMember[index] then
		if index == 0 then
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1277)) --�������Ѿ��Ƕӳ���
		elseif self.m_listMember[index].eMemberState ~= eTeamMemberNormal then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(143164)--143164���߻�������Ҳ��ܽ��ζӳ�
            end
		else
            local p = require("protodef.fire.pb.team.csetteamleader"):new()
            p.roleid = self.m_listMember[index].id
            LuaProtocolManager:send(p)
		end
	end
end
--申请队长
function TeamManager:RequestGetLeader(index)
	if self:IsMyselfLeader() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141206)--你不是队长，不能进行此操作
        end
	
	elseif GetBattleManager():IsInBattle() then
        if GetChatManager() then
			GetChatManager():AddTipsMsg(150031)--请战斗结束后操作
        end

	elseif index == -1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141194)--请选择一个对象
        end

	elseif self:IsIndexValid(index) and self.m_listMember[index] then
		if index == 0 then
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1277)) --你现在已经是队长了
		-- elseif self.m_listMember[index].eMemberState ~= eTeamMemberNormal then
            -- if GetChatManager() then
                -- GetChatManager():AddTipsMsg(143164)--143164离线或暂离玩家不能接任队长
            -- end
		else
            local p = require("protodef.fire.pb.team.cgetteamleader"):new()
            p.roleid = self:GetTeamLeader().id--队长id
            
            LuaProtocolManager:send(p)
		end
	end
end
TTrole = 0
function TeamManager:AskIfAcceptToMarry(leaderid)
	if gGetGameConfigManager():GetConfigValue("refusefriend") == 1 then
		return
	end
	TTrole = leaderid
	local sb = StringBuilder:new()
	-- sb:Set("parameter1", leadername)
 --    local rolelv = level
 --    sb:Set("parameter2", tostring(rolelv))
    local strTitle = MHSD_UTILS.get_resstring(11800)
    local strMsg = sb:GetString(MHSD_UTILS.get_resstring(2915))
    sb:delete()

	gGetMessageManager():AddMessageBox(strTitle, strMsg,
    TeamManager.HandleAcceptToMarry, self,
    TeamManager.HandleRefuseToMarry, self,
        eMsgType_Team, 5000, 0,
        0,nil,MHSD_UTILS.get_resstring(997),MHSD_UTILS.get_resstring(996)) --修改申请队长时间5000就是5秒
end

function TeamManager:HandleAcceptToMarry(e)--同意队长

    local p = require("protodef.fire.pb.team.canswerforgetleader"):new()
    p.agree = 0
    p.role = TTrole--申请者ID
    LuaProtocolManager:send(p)
	gGetMessageManager():CloseCurrentShowMessageBox()
	return true
end

function TeamManager:HandleRefuseToMarry(e)--拒绝队长
    local p = require("protodef.fire.pb.team.canswerforgetleader"):new()
    p.agree = 1
    p.role = TTrole
    LuaProtocolManager:send(p)
	if e.handled ~= 1 then
		gGetMessageManager():CloseCurrentShowMessageBox()
    end
	return true
end
--�ٻ���Ա
function TeamManager:RequestCallbackMember(memberId)
	if GetBattleManager():IsInBattle() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141363)--ս���в��ܽ��д������
        end
		return
	end

	if self:IsMyselfLeader() then
        local p = require("protodef.fire.pb.team.ccallbackmember"):new()
        p.memberid = memberId
        LuaProtocolManager:send(p)

	else
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141206)--�㲻�Ƕӳ������ܽ��д˲���
        end
    end
end

--�����Ա
function TeamManager:RequestExpelMember(index)
	if not self:IsMyselfLeader() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141206)--�㲻�Ƕӳ������ܽ��д˲���
        end
	elseif GetBattleManager():IsInBattle() then
        if GetChatManager() then
			GetChatManager():AddTipsMsg(150031)--ս���в��ܽ��д������
	    end
	elseif index == -1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141194)--��ѡ��һ������
	    end
	elseif index == 0 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(143167)--�㲻�������Լ�
	    end
	elseif self:IsIndexValid(index) and self.m_listMember[index] then
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.m_listMember[index].strName)

        --��ȷ��Ҫ��$parameter1$����߳�������
		gGetMessageManager():AddConfirmBox(eConfirmNormal, sb:GetString(MHSD_UTILS.get_msgtipstring(150118)),
            TeamManager.ConfirmExpelMember, self,
		    MessageManager.HandleDefaultCancelEvent, MessageManager,
            index)
        sb:delete()
	end
end

function TeamManager:ConfirmExpelMember(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
	local pConfirmBoxInfo = tolua.cast(windowargs.window:getUserData(), "stConfirmBoxInfo")
	if pConfirmBoxInfo then
		local index = pConfirmBoxInfo.userID
		if self:IsIndexValid(index) and self.m_listMember[index] then
            local p = require("protodef.fire.pb.team.cexpelmember"):new()
            p.roleid = self.m_listMember[index].id
            LuaProtocolManager:send(p)
		end
		gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
		return true
	end
	return false
end

--����/�ع����
function TeamManager:RequestAbsentReturnTeam(absent)
	if absent and self:GetMemberSelf() and self:GetMemberSelf().eMemberState ~= eTeamMemberAbsent then
		if self:GetMemberNum() == 1 then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(150029)--û�б��������ӳ��ˣ��޷��������
            end
			return
		end

		local selfID = self:GetMemberSelf().id
		local haveMemberNotAbsent = false
        
        for _,v in ipairs(self.m_listMember) do
            if v.id == selfID and v.eMemberState ~= eTeamMemberAbsent and eMemberState ~= eTeamMemberFallline then
                haveMemberNotAbsent = true
                break
            end
        end

		if not haveMemberNotAbsent then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(150029)--û�б��������ӳ��ˣ��޷��������
            end
			return
		end

		--��������
        local p = require("protodef.fire.pb.team.cabsentreturnteam"):new()
        p.absent = 1
        LuaProtocolManager:send(p)
	
	elseif not absent and self:GetMemberSelf() and self:GetMemberSelf().eMemberState == eTeamMemberAbsent then
		--����ع�
        local p = require("protodef.fire.pb.team.cabsentreturnteam"):new()
        p.absent = 2
        LuaProtocolManager:send(p)
	end
end

function TeamManager:DoAbsentReturnTeam()
	local pLeader = gGetScene():FindCharacterByID(self:GetTeamLeader().id)
	if pLeader then
		if Nuclear.distance(pLeader:GetLogicLocation(), GetMainCharacter():GetLogicLocation()) <= 64 then
			if gGetScene():IsTheSameArea(GetMainCharacter():GetLogicLocation(), pLeader:GetLogicLocation(), GetMainCharacter():IsInHighLevel())
			  and GetMainCharacter():IsInHighLevel() == pLeader:IsInHighLevel() then
                local p = require("protodef.fire.pb.team.cabsentreturnteam"):new()
                p.absent = 0
                LuaProtocolManager:send(p)
			else
				if GetChatManager() then
					if GetBattleManager():IsInBattle() then
                        GetChatManager():AddTipsMsg(162135) --������ս����,�޷��ع����
                    else
                        GetChatManager():AddTipsMsg(143867) --��������ս���У���ս����������Ч��
                    end
                end
			end
		else
			self:SetReturnTeamWalk()
		end
	else
		self:SetReturnTeamWalk()
	end
end

function TeamManager:SetReturnTeamWalk()
	--����Զ�Ѱ·
	local pLeaderMember = self:GetTeamLeader()
	--��ͬһ��ͼ��
	if gGetScene():GetMapSceneID() == pLeaderMember.iSceneID then
		local pLeaderCharacter = gGetScene():FindCharacterByID(pLeaderMember.id)
		if pLeaderCharacter then
			local leaderloc = pLeaderCharacter:GetLogicLocation()
			GetMainCharacter():GetMapWalker():SetTarget(leaderloc.x,leaderloc.y,pLeaderMember.iMapID,0,0,true)
		else
			GetMainCharacter():GetMapWalker():SetTarget(pLeaderMember.ptLogicLocation.x,pLeaderMember.ptLogicLocation.y,pLeaderMember.iMapID,0,0,true)
		end
	
	--��ʾ����ͬһ��ͼ��
	else
        local p = require("protodef.fire.pb.team.cabsentreturnteam"):new()
        p.absent = 0
        LuaProtocolManager:send(p)
	end
end

--�˳�����
function TeamManager:RequestQuitTeam()
	if GetBattleManager():IsInBattle() then
		if GetChatManager() then
			if self:IsMyselfLeader() then
				GetChatManager():AddTipsMsg(150032)--�ӳ�ս�����޷����
			else
                local p = require("protodef.fire.pb.team.cquitteam"):new()
                LuaProtocolManager:send(p)
				
				GetChatManager():AddTipsMsg(150033)--����ӣ�ս����������Ч
			end
		end
	else
		gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(150119), TeamManager.ConfirmQuitTeam, self,
			MessageManager.HandleDefaultCancelEvent, MessageManager)
	end
end

function TeamManager:ConfirmQuitTeam(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
	local pConfirmBoxInfo = tolua.cast(windowargs.window:getUserData(), "stConfirmBoxInfo")
	if pConfirmBoxInfo then
        local p = require("protodef.fire.pb.team.cquitteam"):new()
        LuaProtocolManager:send(p)

		gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
		return true
	end
	return false
end

--����������
function TeamManager:RequestAcceptToMyTeam(roleid)
	if not self:IsMyselfLeader() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141206)--�㲻�Ƕӳ������ܽ��д˲���
        end
	elseif self:IsTeamFull() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(150024)--�����Ѿ���Ա�����������Ӷ�Ա
        end
	else
        local p = require("protodef.fire.pb.team.caccepttoteam"):new()
        p.roleid = roleid
        p.accept = 1
        LuaProtocolManager:send(p)
	end
end

--�ܾ�/��������� roleidΪ0ʱ�����������������
function TeamManager:RequestRemoveTeamApply(roleid)
	if not self:IsMyselfLeader() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141206)--�㲻�Ƕӳ������ܽ��д˲���
	    end
	else
        local p = require("protodef.fire.pb.team.caccepttoteam"):new()
        p.roleid = roleid
        p.accept = 0    --0��ʾ�ܾ�����roleidҲΪ0��ʾ���
        LuaProtocolManager:send(p)
	end
end

--ĳ�������������飬�Ƿ����
function TeamManager:AskIfAcceptJoinTeam(leadername, level, leaderID)
	--hjw  �ܾ����
	if gGetGameConfigManager():GetConfigValue("refusefriend") == 1 then
		return
	end

    leaderID = leaderID or 0

	local sb = StringBuilder:new()
	sb:Set("parameter1", leadername)
    local rolelv = "0转"..level
    if level>1000 then
        local zscs,t2 = math.modf(level/1000)
        rolelv = zscs.."转"..(level-zscs*1000)
    end
    sb:Set("parameter2", tostring(rolelv))
    local strTitle = MHSD_UTILS.get_resstring(1279)
    local strMsg = sb:GetString(MHSD_UTILS.get_resstring(2914))
    sb:delete()

	gGetMessageManager():AddMessageBox(strTitle, strMsg,
		TeamManager.HandleAcceptJoinTeam, self,
		TeamManager.HandleRefuseJoinTeam, self,
        eMsgType_Team, 20000, leaderID,
        0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end

function TeamManager:HandleAcceptJoinTeam(e)
	if self:IsOnTeam() then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(140855)--���Ѿ��ڶ�������
	    end
	else
		local leaderID = gGetMessageManager():GetUserID()
		if leaderID > 0 then
			self:RequestJoinOneTeam(leaderID)
		else
            local p = require("protodef.fire.pb.team.crespondinvite"):new()
            p.agree = 1
            LuaProtocolManager:send(p)
		end
	end
	gGetMessageManager():CloseCurrentShowMessageBox()
	return true
end

function TeamManager:HandleRefuseJoinTeam(e)
    local p = require("protodef.fire.pb.team.crespondinvite"):new()
    p.agree = 0
    LuaProtocolManager:send(p)
	
	if e.handled ~= 1 then
		gGetMessageManager():CloseCurrentShowMessageBox()
    end
	return true
end

--�ӳ��ٻ������Ƿ����
function TeamManager:AskIfAcceptBeCallback(leaderid)
	local pleader = self:GetTeamMemberByID(leaderid)
	if not gGetMessageManager():AlreadyHaveSameTitleMessageBox(MHSD_UTILS.get_resstring(1284)) and pleader then
		local sb = StringBuilder:new()
		sb:Set("parameter1", pleader.strName)
        local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(143163)) --xxҪ�ٻ����ӣ��Ƿ�ͬ�⣿
        sb:delete()

		gGetMessageManager():AddMessageBox(MHSD_UTILS.get_resstring(1285), msg,
			TeamManager.HandleAcceptBeCallback, self,
			TeamManager.HandleRefuseBeCallback, self, eMsgType_Team, 30000,
            0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
	end
end

function TeamManager:HandleRefuseBeCallback(e)
    local p = require("protodef.fire.pb.team.canswerforcallback"):new()
    p.agree = 0
    LuaProtocolManager:send(p)
	
	if e.handled ~= 1 then
		gGetMessageManager():CloseCurrentShowMessageBox()
    end
	return true
end

function TeamManager:HandleAcceptBeCallback(e)
	self:RequestAbsentReturnTeam(false)
	gGetMessageManager():CloseCurrentShowMessageBox()
	return true
end

--������ʾ
function TeamManager:ShowErrorInfo(errortype)
    local msgid = TeamErrorInfoList[errortype + 1]
    if not msgid then
        print("wran: team error not handled " .. errortype)
		return
    end

    if msgid == 0 then
        return
    end

    if errortype == 40 then
        local str = MHSD_UTILS.get_msgtipstring(msgid)
        if TeamManager.chatTimestamp ~= 0 then
            local t = GetTimeStrByNumber(60 -(os.time() - TeamManager.chatTimestamp))
            str = str .. '[' .. t.m .. ':' .. t.s .. ']'
        end
        GetCTipsManager():AddMessageTip(str)

    elseif errortype <= 31 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(msgid))
    else
        GetCTipsManager():AddMessageTipById(msgid)
    end
end

function TeamManager:Run(delta)
    for i=#self.m_InviterList,1,-1 do
        local inviter = self.m_InviterList[i]
        inviter.life = inviter.life - delta
        if inviter.life <= 0 then
            table.remove(self.m_InviterList, i)
            if GetChatManager() then
                GetChatManager():AddTipsMsg(141200)--�Է�û����Ӧ����������ѳ�ʱ��
            end
        end
    end

    --����ս������
    if self.teamGuideStep > 0 then
        local curGuideId = NewRoleGuideManager.getInstance():getCurGuideId()
        if (curGuideId == 0 or curGuideId == NEW_GUIDE_FIRST_TEAM) and GetBattleManager() and GetBattleManager():IsInBattle() then
            if self.teamGuideStep == 1 then
                if GetBattleManager():FindBattlerCharacterByRoleID(self.teamGuideChatMemberId) then
		            self.teamGuideStep = 2
                    self.elapsed = 0
                end
            elseif self.teamGuideStep == 2 then
                self.elapsed = self.elapsed + delta
                if self.elapsed > 800 then
                    self.teamGuideStep = 3
                    self.elapsed = 0
                    local member = self:GetTeamMemberByID(self.teamGuideChatMemberId)
                    if member then
                        if gGetGameConfigManager() and gGetGameConfigManager():isPlayEffect() then
                            local path = string.format("/sound/chat/guide_%d.ogg", self.teamGuideMsgId)
                            path = gGetGameUIManager():GetFullPathFileName(path)
                            SimpleAudioEngine:sharedEngine():playEffect(path)
                        end

                        local text = MHSD_UTILS.get_msgtipstring(self.teamGuideMsgId)
                        local msg = string.format("file=\"guide_%d.ogg\" text=\"%s&\" time=5", self.teamGuideMsgId, text)
                        CChatManager.AddMsg(ChannelType.CHANNEL_TEAM, member.id, member.shapeID, 0, member.campType, member.strName, msg)

                        local color = CChatOutputDialog.getInstance().m_pChatInputBox:getProperty("NormalTextColour")
	                    text = string.gsub(text, color, "FFFFFFFF")
		                local pBattler = GetBattleManager():FindBattlerCharacterByRoleID(self.teamGuideChatMemberId)
		                if pBattler then
			                pBattler = tolua.cast(pBattler, "SceneObject")
			                pBattler:AddTalk(text)
		                end
                    end
                end
            elseif self.teamGuideStep == 3 then
                self.elapsed = self.elapsed + delta
                if self.elapsed > 1200 then
                    NewRoleGuideManager.getInstance():AddToWaitingList(NEW_GUIDE_FIRST_TEAM)

                    self.teamGuideStep = 0
                    self.teamGuideChatMemberId = 0
                    self.teamGuideMsgId = 0
                    self.elapsed = 0
                end
            end
        else
            self.teamGuideStep = 0
            self.teamGuideChatMemberId = 0
            self.teamGuideMsgId = 0
            self.elapsed = 0
        end
    end
end

function TeamManager:GetMember(num)
    return self.m_listMember[num]
end

function TeamManager:SetTeamMatchInfo(targetid, minlevel, maxlevel)
	self.m_TeamMathInfo.targetid = targetid
	self.m_TeamMathInfo.minlevel = minlevel
	self.m_TeamMathInfo.maxlevel = maxlevel
    NotificationCenter.postNotification(Notifi_TeamSettingChange)
end

function TeamManager:GetTeamMatchInfo()
	--after charater upgrade, if the level of target is not suit for character any more, then reset it.
	if not self:IsOnTeam() and self.m_TeamMathInfo.maxlevel < gGetDataManager():GetMainCharacterLevel() then
		self.m_TeamMathInfo:init()
	end
	return self.m_TeamMathInfo
end

function TeamManager:RequestTeamMatch(matchtype, targetId, minlevel, maxlevel)
	if not self:IsTeamFull() then
		self:SetTeamMatchInfo(targetId, minlevel, maxlevel)
        local p = require("protodef.fire.pb.team.crequestteammatch"):new()
        p.typematch = matchtype
        p.targetid = targetId
        p.levelmin = minlevel
        p.levelmax = maxlevel
		LuaProtocolManager:send(p)
	else
		GetCTipsManager():AddMessageTipById(150024) --������������
	end
end

function TeamManager:StartTeamMatch()
	self.m_bIsMatching = true
    NotificationCenter.postNotification(Notifi_TeamAutoMatchChange)
	
	if not self:IsOnTeam() or self:IsMyselfLeader() then
		GetCTipsManager():AddMessageTipById(150038) --��ʼ�Զ�ƥ�䣬���Ժ�
	end
end

function TeamManager:StopTeamMatch()
	self.m_bIsMatching = false
    local p = require("protodef.fire.pb.team.crequeststopteammatch"):new()
    LuaProtocolManager:send(p)
end

function TeamManager:recvStopTeamMatch()
	self.m_bIsMatching = false
	NotificationCenter.postNotification(Notifi_TeamAutoMatchChange)

	if not self:IsOnTeam() or self:IsMyselfLeader() then
		GetCTipsManager():AddMessageTipById(150039) --��ȡ���Զ�ƥ��
	end
end

function TeamManager:PostTeamListChanged()
    NotificationCenter.postNotification(Notifi_TeamListChange)
    if gGetScene() then
        gGetScene():RefreshFollowNpcDistance()
    end
end

------------------------------------------------------------------
--call from c++
function TeamManager.CanIMove_cpp()
	return (_instance and _instance:CanIMove())
end

function TeamManager.IsOnTeam_cpp()
    return (_instance and _instance:IsOnTeam())
end

function TeamManager.GetLeaderId()
    if _instance and #_instance.m_listMember > 0 then
        return _instance.m_listMember[1].id
    end
    return 0
end

function TeamManager.HandleMainCharacterReturnTeam(findpathfailure)
    local mapWalker = GetMainCharacter():GetMapWalker()

	if not mapWalker:IsThroughChefu()
	 and not mapWalker:IsThroughLinanTrans()
	 and not mapWalker:IsThroughFamilyManager()
	 and mapWalker:GetTargetMapID() == gGetScene():GetMapID()
	 and mapWalker:GetMapWalkerType() == eMapWalkerType_ReturnTeam
	then
		local pTeamLeader = nil
		local pLeader = GetTeamManager():GetTeamLeader()
		local targetpos = mapWalker:GetTargetPos()
		local targetmapid = mapWalker:GetTargetMapID()
		if pLeader then
			targetpos = pLeader.ptLogicLocation
			targetmapid = pLeader.iMapID
			pTeamLeader = gGetScene():FindCharacterByID(pLeader.id)
			if pTeamLeader then
				targetpos = pTeamLeader:GetLogicLocation()
			end
		end

		if Nuclear.distance(GetMainCharacter():GetLogicLocation(), targetpos) <= 64 then
			if not gGetScene():IsTheSameArea(targetpos, GetMainCharacter():GetLogicLocation(), GetMainCharacter():IsInHighLevel())
			 or (pTeamLeader and pTeamLeader:IsInHighLevel() ~= GetMainCharacter():IsInHighLevel()) then
                if GetChatManager() then
                    if GetBattleManager():IsInBattle() then
                        GetChatManager():AddTipsMsg(162135) --������ս����,�޷��ع����
                    else
                        GetChatManager():AddTipsMsg(143867) --��������ս���У���ս����������Ч��
                    end
                end
			else
                local p = require("protodef.fire.pb.team.cabsentreturnteam"):new()
                p.absent = 0
                LuaProtocolManager:send(p)
			end
		else
			if findpathfailure then
                if GetChatManager() then
                    if GetBattleManager():IsInBattle() then
                        GetChatManager():AddTipsMsg(162135) --������ս����,�޷��ع����
                    else
                        GetChatManager():AddTipsMsg(143867) --��������ս���У���ս����������Ч��
                    end
                end
			else
				mapWalker:SetTarget(targetpos.x,targetpos.y,targetmapid,0,0,true)
			end
		end
	end
end

function TeamManager_RefreshDistance_cpp(MinFollowDistance, MaxFollowDistance)
    if not GetTeamManager() then
        return MinFollowDistance, MaxFollowDistance
    end

    local m_nMinFollow = MinFollowDistance
    local m_nMaxFollow = MaxFollowDistance

    if GetTeamManager():IsOnTeam() then
		local myself = GetTeamManager():GetMemberSelf()
		if not myself then
			return
		end

		if myself.eMemberState == eTeamMemberAbsent then
			return
		end

		local list = GetTeamManager():GetMemberList()

		local nAllMember = #list
		local nCurMemNumber = 0

        for k,v in ipairs(list) do
			if v.eMemberState ~= eTeamMemberAbsent then
			    if v.id == myself.id then
				    nCurMemNumber = k
                    break
			    end
            end
		end

		local nFollowNumber = nAllMember + 1
		local nSpace = nFollowNumber - nCurMemNumber
		m_nMinFollow = MinFollowDistance * nSpace
		m_nMaxFollow = MaxFollowDistance * nSpace
	end
    return m_nMinFollow, m_nMaxFollow
end

function TeamManager.SendAbsentReturnTeam(absent)
    local p = require("protodef.fire.pb.team.cabsentreturnteam"):new()
    p.absent = absent
    LuaProtocolManager:send(p)
end

function TeamManager.HandleJoinTeamLinkClick(leaderid)
    --���---�жϵ���������������ʱ���Ƿ���������
    require("logic.chat.cchatoutboxoperateldlg").SetOpenChatWnd(false)

    if GetTeamManager() then
		GetTeamManager():RequestJoinOneTeam(leaderid)
	end
end

function TeamManager.HideAllCharExceptTeammate()
    if _instance and _instance:IsOnTeam() then
        for _,v in ipairs(_instance.m_listMember) do
            local obj = gGetScene():FindSceneObjectByTypeID(eSceneObjCharacter, v.id)
            if obj then
                obj:SetVisible(true)
            end
		end
	end
end

--���ս����������
function TeamManager:prepareGuideTeam()
    if not self:IsOnTeam() or GetTeamManager():GetMemberNum() < 3 then
        return
    end

    if NewRoleGuideManager.getInstance():isGuideFinish(NEW_GUIDE_FIRST_TEAM) then
        return
    end

    local myself = GetTeamManager():GetMemberSelf()
    if myself and myself.eMemberState ~= eTeamMemberNormal then
        return
    end

    self.elapsed = 0

    local member = nil
    local msgId = 0

    --first find a girl
    for _,m in pairs(self.m_listMember) do
        if m.shapeID % 2 == 0 and m.id ~= gGetDataManager():GetMainCharacterID() and m.eMemberState == eTeamMemberNormal then
            member = m
            local msgids = {176001, 176002}
            local idx = math.random(1,2)
            msgId = msgids[idx]
            break
        end
    end

    --if no girl, find anyone
    if not member then
        for _,m in pairs(self.m_listMember) do
            if m.id ~= gGetDataManager():GetMainCharacterID() and m.eMemberState == eTeamMemberNormal then
                member = m
                local msgids = {176003, 176004}
                local idx = math.random(1,2)
                msgId = msgids[idx]
                break
            end
        end
    end

    if member and msgId and msgId ~= 0 then
        CChatOutputDialog.ToHide_()

        self.teamGuideStep = 1
        self.teamGuideChatMemberId = member.id
        self.teamGuideMsgId = msgId
    end
end

function TeamManager:isPrepareToGuideTeam()
    return self.teamGuideStep > 0
end

function TeamManager:setTeamOrder(orderid)
    self.m_TeamOrderID = orderid
end
function TeamManager:getTeamOrder()
    return self.m_TeamOrderID
end
function TeamManager:IsMyselfOrder()
    if self:IsOnTeam() then
        if self.m_TeamOrderID == 0 then
            return self:IsMyselfLeader()
        else
	        return gGetDataManager():GetMainCharacterID() == self.m_TeamOrderID
        end
    end
    return false
end
function TeamManager:getOrderCmd(side,id)
    if side == 1 then
        return self.m_OrderCmd1[id]
    else
        return self.m_OrderCmd2[id]
    end
    return nil
end
function TeamManager:getOrderIndexCmd(side,id)
    local cur = 1
    if side == 1 then
        for i=1,10 do
            if self.m_OrderCmd1[i] and self.m_OrderCmd1[i] ~= "" then
                if cur == id then
                    return self.m_OrderCmd1[i]
                end
                cur= cur + 1
            end
        end
    else
        for i=1,10 do
            if self.m_OrderCmd2[i] and self.m_OrderCmd2[i] ~= "" then
                if cur == id then
                    return self.m_OrderCmd2[i]
                end
                cur= cur + 1
            end
        end
    end
    return ""
end
function TeamManager:setOrderCmd(side,id,txt)
    if side == 1 then
        if txt == "" then
            if self.m_OrderCmd1[id] ~= nil then
                table.remove(self.m_OrderCmd1,id)
            end
        else
            if self.m_OrderCmd1[id] == nil then
                self.m_OrderCmd1[id] = {}
                self.m_OrderCmd1[id].edit = true
                self.m_OrderCmd1[id].serverid = self:getDefaultCmdCount(1)
            end
            self.m_OrderCmd1[id].txt = txt
        end
    else
        if txt == "" then
            if self.m_OrderCmd2[id] ~= nil then
                table.remove(self.m_OrderCmd2,id)
            end
        else
            if self.m_OrderCmd2[id] == nil then
                self.m_OrderCmd2[id] = {}
                self.m_OrderCmd2[id].edit = true
                self.m_OrderCmd2[id].serverid = self:getDefaultCmdCount(2)
            end
            self.m_OrderCmd2[id].txt = txt
        end
    end
end
function TeamManager:getOrderCmdCount(side)
    local count = 0
    if side == 1 then
        for i=1,10 do
            if self.m_OrderCmd1[i] and self.m_OrderCmd1[i].txt ~= "" then
                count= count + 1
            end
        end
    else
        for i=1,10 do
            if self.m_OrderCmd2[i] and self.m_OrderCmd2[i] ~= "" then
                count= count + 1
            end
        end
    end
    return count
end
function TeamManager:getServerOrderCount(side)
    local count = 0
    if side == 1 then
        for i=1,10 do
            if self.m_OrderCmd1[i] and self.m_OrderCmd1[i].txt ~= "" and self.m_OrderCmd1[i].edit then
                count= count + 1
            end
        end
    else
        for i=1,10 do
            if self.m_OrderCmd2[i] and self.m_OrderCmd2[i] ~= "" and self.m_OrderCmd2[i].edit then
                count= count + 1
            end
        end
    end
    return count
    
end
function TeamManager:getDefaultCmdCount(side)
    if side == 1 then
        return 4
    else
        return 5
    end
    return 0
end
function TeamManager:initOrdCmd(mylist,otherlist)
    
    self.m_OrderCmd1 = {}
    local dinfo = {}
    dinfo.edit = false
    dinfo.txt = MHSD_UTILS.get_resstring(11646)
    dinfo.serverid = 0
    table.insert(self.m_OrderCmd1,dinfo)
    local dinfo2 = {}
    dinfo2.edit = false
    dinfo2.txt = MHSD_UTILS.get_resstring(11647)
    dinfo2.serverid = 0
    table.insert(self.m_OrderCmd1,dinfo2)
    local dinfo3 = {}
    dinfo3.edit = false
    dinfo3.txt = MHSD_UTILS.get_resstring(11648)
    dinfo3.serverid = 0
    table.insert(self.m_OrderCmd1,dinfo3)
    local dinfo4 = {}
    dinfo4.edit = false
    dinfo4.txt = MHSD_UTILS.get_resstring(11649)
    dinfo4.serverid = 0
    table.insert(self.m_OrderCmd1,dinfo4)
    local dcount = self:getDefaultCmdCount(1)
    for k,v in pairs(mylist) do      
        local info = {}
        info.edit = true
        info.txt = v or ""
        info.serverid = dcount
        table.insert(self.m_OrderCmd1,info)
    end

    self.m_OrderCmd2 = {}
    
    local einfo = {}
    einfo.edit = false
    einfo.txt = MHSD_UTILS.get_resstring(11641)
    einfo.serverid = 0
    table.insert(self.m_OrderCmd2,einfo)
    local einfo2 = {}
    einfo2.edit = false
    einfo2.txt = MHSD_UTILS.get_resstring(11642)
    einfo2.serverid = 0
    table.insert(self.m_OrderCmd2,einfo2)
    local einfo3 = {}
    einfo3.edit = false
    einfo3.txt = MHSD_UTILS.get_resstring(11643)
    einfo3.serverid = 0
    table.insert(self.m_OrderCmd2,einfo3)
    local einfo4 = {}
    einfo4.edit = false
    einfo4.txt = MHSD_UTILS.get_resstring(11644)
    einfo4.serverid = 0
    table.insert(self.m_OrderCmd2,einfo4)
    local einfo5 = {}
    einfo5.edit = false
    einfo5.txt = MHSD_UTILS.get_resstring(11645)
    einfo5.serverid = 0
    table.insert(self.m_OrderCmd2,einfo5)
    local ecount = self:getDefaultCmdCount(2)
    for k,v in pairs(otherlist) do      
        local info = {}
        info.edit = true
        info.txt = v or ""
        info.serverid = ecount
        table.insert(self.m_OrderCmd2,info)
    end
    self.m_HasCmd = true
end
function TeamManager:getMySelfCommand()
    if self.m_HasCmd == false then
        local send = require "protodef.fire.pb.battle.battleflag.creqbattleflag":new()
        require "manager.luaprotocolmanager":send(send)
    end
end

local p = require "protodef.fire.pb.battle.battleflag.ssendbattleflag"
function p:process()
    GetTeamManager():initOrdCmd(self.friendflags,self.enemyflags)
    local dlg = OrderEditorDlg.getInstanceNotCreate()
    if dlg then
        dlg:refresh()
    end
    local dlg2 = OrderSetDlg.getInstanceNotCreate()
    if dlg2 then
        dlg2:refresh()
    end    
end
return TeamManager
