--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

FriendManager = {}
FriendManager.__index = FriendManager

local maxRecord = 50

local m_FriendListSortFunc = nil
local m_VecAllContactRole = {}
local m_VecMyFriends = {}
local m_VecChatRecord = {}
local m_ListLoadChatRecordRole = {}
local m_VecLastContactRole = {}
local m_MapLastChatRecord = {}
local m_ListenRoleInfoFunc = nil
local m_WantToChatRoleID = 0
local m_WantToContactRoleID = 0

local m_signMap = {}

stContactRole = class("stContactRole")

function stContactRole:init()
    self.roleID = 0
    self.name = ""
    self.friendLevel = 0
    self.rolelevel = 0
    self.isOnline = 0
    self.school = 0
    self.shape = 0
    self.camp = 0
    self.relation = 0
    self.factionID = 0
    self.factionName = "" 

    self.m_VecChatRecord = {}
end

function stContactRole:GetChatRecordNum()
    return require "utils.tableutil".tablelength(self.m_VecChatRecord)
end

function stContactRole:GetChatRecordByIndex(index)
    if self.m_VecChatRecord[index] then
        return self.m_VecChatRecord[index]
    end
end

function stContactRole:insertRecord(record)
    local isExist = false
    for _, v in pairs(self.m_VecChatRecord) do
        if v == record then
            isExist = true
            break
        end
    end

    if not isExist then
        table.insert(self.m_VecChatRecord, record)
    end
end

function stContactRole:setData(roleID, name, nRoleLevel, friendLevel, isOnline, school, shape, camp, relation, nFactionID, strFactionName)
    self.roleID = roleID
    self.name = name
    self.friendLevel = friendLevel
    self.rolelevel = nRoleLevel
    self.isOnline = isOnline
    self.school = school
    self.shape = shape
    self.camp = camp
    self.relation = relation
    self.factionID = nFactionID
    self.factionName = strFactionName
end


stChatRecordUnit = class("stChatRecordUnit")
function stChatRecordUnit:init()
    self.roleid = 0
    self.name = ""
    self.time = ""
    self.chatContent = ""
    self.isOnline = 0
    self.rolelevel = 0
    self.friendLevel = 0
    self.school = 0
    self.shape = 0
    self.camp = 0
    self.relation = 0
    self.factionID = 0
    self.factionName = ""
    self.voiceUUID = ""
    self.voiceTime = 0
    self.messageID = ""
end

function stChatRecordUnit:setData(cRecord)
    self.roleid = cRecord.roleid
    self.name = cRecord.name
    self.time = cRecord.time
    self.chatContent = cRecord.chatContent
    self.isOnline = cRecord.isOnline
    self.rolelevel = cRecord.rolelevel
    self.friendLevel = cRecord.friendLevel
    self.school = cRecord.school
    self.shape = cRecord.shape
    self.camp = cRecord.camp
    self.relation = cRecord.relation
    self.factionID = cRecord.factionID
    self.factionName = cRecord.factionName
    self.voiceUUID = cRecord.voiceUUID
    self.voiceTime = cRecord.voiceTime
    self.messageID = cRecord.messageID
end

local _instance
function gGetFriendsManager()
    if not _instance then
        FriendManager.getInstance()
    end
    return _instance
end

function FriendManager.getInstance()
    if not _instance then
        _instance = FriendManager:new()
    end
    return _instance
end

function FriendManager:new()
    local self = {}
    setmetatable(self, FriendManager)
    return self
end

function FriendManager.Destroy()
	if _instance then 
		_instance = nil
	end
end

function FriendManager:Cleanup()
    m_ListenRoleInfoFunc = nil
    m_WantToContactRoleID = 0
    m_WantToChatRoleID = 0
    m_ListLoadChatRecordRole = {}
    m_MapLastChatRecord = {}
    m_VecChatRecord = {}
    m_VecMyFriends = {}
    m_VecLastContactRole = {}
    m_VecAllContactRole = {}
    self.NullRole = stContactRole.new()
end

function FriendManager:SetMaxFriendNumber(num)
    self.m_friendNum = num
end

function FriendManager:GetMaxFriendNumber(num)
    return self.m_friendNum
end

function FriendManager:LoadChatRecordByRoleID(roleID)
    if FriendManager.RoleHasNotLoadChatRecord(roleID) then
        local role = self:GetContactRole(roleID)
        if role and roleID == role.roleID and role.roleID ~= 0 then
            local cRecordVector = std.vector_stChatRecordUnit_()
            FriendVisitor:loadChatRecord(gGetDataManager():GetMainCharacterID(), gGetDataManager():GetMainCharacterName(), roleID, cRecordVector)
            for i = 0, cRecordVector:size() -1 do
                local crd = cRecordVector[i]
                local record = stChatRecordUnit.new()
                record:init()
                record:setData(crd)
                role:insertRecord(record)
            end
        end
        self:removeListLoadByID(roleID)
    end
end

function FriendManager:removeListLoadByID(roleID)
    for k, v in pairs(m_ListLoadChatRecordRole) do
        if v == roleID then
            table.remove(m_ListLoadChatRecordRole, k)
        end
    end
end

function FriendManager:GetContactRole(roleID)
    for _, v in pairs(m_VecAllContactRole) do
        if roleID == v.roleID then
            return v
        end
    end
    return self.NullRole
end

function FriendManager.getRoleNameByID(roleID)
    local role = gGetFriendsManager():GetContactRole(roleID)
    if role then
        return role.name
    end
    return ""
end

function FriendManager:RefreshContactRoleInf(roleID, name, nRoleLevel, friendLevel, isOnline, school, shape, camp, relation, nFactionID, strFactionName)
    for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            v.name = name
            v.rolelevel = nRoleLevel
            v.isOnline = isOnline
            v.school = school
            v.friendLevel = friendLevel
            v.shape = shape
            v.camp = camp
            v.relation = relation
            v.factionID = nFactionID
            v.factionName = strFactionName
            return
        end
    end

end


function FriendManager:AddContact(roleID, name, nRoleLevel, friendLevel, isOnline, school, shape, camp, relation, nFactionID, strFactionName)
    local role = self:GetContactRole(roleID)
    if role and role.roleID ~= 0 then
        self:RefreshContactRoleInf(roleID, name, nRoleLevel, friendLevel, isOnline, school, shape, camp, relation, nFactionID, strFactionName)
	else
       local role = stContactRole.new()
       role:setData(roleID, name, nRoleLevel, friendLevel, isOnline, school, shape, camp, relation, nFactionID, strFactionName)
       table.insert(m_VecAllContactRole, role)
    end

	if friendLevel > 0 then
        self:AddFriend(roleID)
	end
end

function FriendManager:DelContact(roleID)
    for k, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            table.remove(m_VecAllContactRole, k)
            return
        end
    end
end

function FriendManager:GetContactRoleByName(strName)
	if strName and string.len(strName) > 0 then
        for _, v in pairs(m_VecAllContactRole) do
            if v.name == strName then
                return v
            end
        end
    end
    return self.NullRole
end


function FriendManager:AddFriend(roleID)
    if self:isMyFriend(roleID) then return end

    table.insert(m_VecMyFriends, roleID)
    self:RefreshFriendList()

    local fdg = require "logic.friend.frienddialog".getInstanceNotCreate()
    if fdg then
        fdg:RefreshRoleRelation(roleID)
    end
end

function FriendManager:isMyContactRole(roleID)
    for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            return true
        end
    end

    return false
end

function FriendManager:updateFriendState(roleID, relation)
    for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            v.relation = relation
            break
        end
    end

    self:RefreshFriendList()
end

function FriendManager:GetFriendlyDegrees(roleID)
    if not self:isMyFriend(roleID) then
        return 0
    else
        local role = self:GetContactRole(roleID)
        if role then
            return role.friendLevel
        end
        return 0
    end
end

function FriendManager:DelFriend(roleID)
    local role = self:GetContactRole(roleID)
    if role.roleID ~= 0 then
        role.friendLevel = 0
    end

    for k, v in pairs(m_VecMyFriends) do
        if v == roleID then
            table.remove(m_VecMyFriends, k)
            break
        end
    end

    self:RefreshFriendList()
    local fdg = require "logic.friend.frienddialog".getInstanceNotCreate()
    if fdg then
        fdg:RefreshRoleRelation(roleID)
    end
end

function FriendManager:RequestAddFriend(roleID)
    if self:isMyFriend(roleID) then
        require "logic.chat.tipsmanager".AddMessageTip_(MHSD_UTILS.get_resstring(922))
        return
    end

    local nInBan =require("system.banlistmanager").GlobalIsInBanList(roleID)

    if (nInBan == 1) then
        require "logic.chat.tipsmanager".AddMessageTipById_(145665)
        return
    end

    local req = require "protodef.fire.pb.friends.crequestaddfriend".Create()
    req.roleid = roleID
    LuaProtocolManager.getInstance():send(req)
end

function FriendManager:RequestDelFriend(roleID)
    local req = require"protodef.fire.pb.friends.cbreakoffrelation":new()
    req.roleid = roleID
    LuaProtocolManager.getInstance():send(req)
end

function FriendManager:AddLastChat(roleID, isSave)
    local vecSize = require "utils.tableutil".tablelength(m_VecLastContactRole)
    if require "utils.tableutil".tablelength(m_VecLastContactRole) > 0 then
		local lastID = m_VecLastContactRole[vecSize]
		if lastID == roleID and lastID == -1 then return end
    end

    if vecSize>= 20 then
        table.remove(m_VecLastContactRole, 1)
    end

    for k, v in pairs(m_VecLastContactRole) do
        if v == roleID then
            table.remove(m_VecLastContactRole, k)
            break
        end
    end

    table.insert(m_VecLastContactRole, 1, roleID)

    self:SortLastContactList()

    if isSave then
        self:SaveLastContactList()
    end

    self:RefreshLastContactList()
end

function FriendManager:ChangeRoleOnlineState(roleID, isOnline, bShowNotify)
    for k, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID and v.isOnline ~= isOnline then
            v.isOnline = isOnline
            self:RefreshFriendList()
            if v.friendLevel > 0 then
                local tipsID = 0
                if isOnline > 0 then
                    tipsID = 140382
                elseif  isOnline == 0 then
                    tipsID = 140383
                end
                
                local tipStr = MHSD_UTILS.get_msgtipstring(tipsID)
                local sb = StringBuilder.new()
                sb:Set("parameter1", v.name)
                GetCTipsManager():AddMessageTip(sb:GetString(tipStr))
                sb:delete()

            end
            break
        end
    end

	if self:isInLastChatList(roleID) then
        self:RefreshLastContactList()
	end
end

function FriendManager:isInLastChatList(roleID)
    for _, v in pairs(m_VecLastContactRole) do
        if v == roleID then
            return true
        end
    end
    return false
end

function FriendManager:RefreshLastContactList()
    require "logic.friend.frienddialog".RefreshChatListForCpp()
 end

 function FriendManager:ChangeFriendLevel(roleID, friendLevel)
    for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            if v.friendLevel ~= friendLevel then
                v.friendLevel = friendLevel
                self:RefreshFriendList()
                if self:isInLastChatList(roleID) then
                    self:RefreshLastContactList()
                end
                local fdg = require "logic.friend.frienddialog".getInstanceNotCreate()
                if fdg then
                    fdg:RefreshRoleRelation(roleID)
                end
            end
            break
        end
    end

    for _, v in pairs(m_VecChatRecord) do
        if v.roleid == roleID then
            if v.friendLevel ~= friendLevel then
                v.friendLevel = friendLevel
                break
            end
        end
    end
end

function FriendManager:GetContactRoleIcon(roleID)
    local  role = self:GetContactRole(roleID)
    if role.roleID ~= 0 then
        local shape = role.shape
        local shapeRecord = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
        if shapeRecord then
            local conPath = gGetIconManager():GetImagePathByID(shapeRecord.littleheadID):c_str()
            return conPath
        end
    end
end

function FriendManager:GetContactRoleIcon(roleID, isOffline)
    local  role = self:GetContactRole(roleID)
    if role.roleID ~= 0 then
        local shape = role.shape
        local shapeRecord = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
        if shapeRecord then
            local headid = shapeRecord.littleheadID
            if isOffline == 0 then
                headid = headid + 10000
            end
            local conPath = gGetIconManager():GetImagePathByID(headid):c_str()
            return conPath
        end
    end
end

function FriendManager:PopChatMsg()
    require "logic.friend.friendmaillabel".Show(1)
end

function FriendManager:PopRoleMsg(roleID)
    local records = {}
    local recordKeys = {}
    for k, v in pairs(m_VecChatRecord) do
        if v.roleid == roleID then
            table.insert(records, v)
            table.insert(recordKeys, k)
        end
    end

    for k = require "utils.tableutil".tablelength(recordKeys),1 ,-1 do
        table.remove(m_VecChatRecord, k)
    end 
    if require "utils.tableutil".tablelength(records) == 0 then
        if self:isMyContactRole(roleID) then
            self:LoadChatRecordByRoleID(roleID)
        end
        return
    end

    local role = self:GetContactRole(roleID)

    local record = records[1]
    if role.roleID ~= 0 then
        self:RefreshContactRoleInf(record.roleid, record.name, record.rolelevel, record.friendLevel, role.isOnline, record.school, record.shape, record.camp, record.relation, record.factionID, record.factionName)

        self:ChangeFriendLevel(record.roleid, record.friendLevel)

        self:LoadChatRecordByRoleID(record.roleid)

        for k, v in pairs(records) do
            role:insertRecord(v)
        end

    else

        self:AddContact(roleID, record.name, record.rolelevel, record.friendLevel, record.isOnline, record.school, record.shape, record.camp, record.relation, record.factionID, record.factionName)
        local NewRole = self:GetContactRole(record.roleid)
        self:LoadChatRecordByRoleID(record.roleid)

        local count = 0
        for k, v in pairs(records) do
            NewRole:insertRecord(v)
            count = count + 1
            if count > 10000 then
                return
            end
        end

    end

    self:RefreshFriendBtnNotify()
end

function FriendManager:RefreshFriendBtnNotify()
    local bShowNotify = false 
    if require "utils.tableutil".tablelength(m_VecChatRecord) > 0 then
        bShowNotify = true
    end

    require "logic.maincontrol".SetFriendBtnFlash(bShowNotify)
end

function FriendManager:ChangeRoleLevel(roleID, roleLevel)
    for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            if v.rolelevel ~= roleLevel then
                v.rolelevel = roleLevel
            end
            break
        end
    end
end

function FriendManager:AddChatRecord(senderID, contactRoleId, senderName, time, content, voiceUUID, voiceTime)
    local record = stChatRecordUnit.new()
    record:init()
	record.roleid = contactRoleId
	if senderID == 0 then
		record.name = gGetDataManager():GetMainCharacterName()
	else
		record.name = senderName
    end

	if string.len(time) == 0 then
        local serverTime = gGetServerTime()	
        local time = StringCover.getTimeStruct(serverTime / 1000)
        local year = time.tm_year + 1900
        local month = time.tm_mon + 1
        local day = time.tm_mday
        local hour = time.tm_hour
        local minute = time.tm_min
        local second = time.tm_sec
        strTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
		record.time = strTime
    else
        record.time = time
	end

	record.chatContent = content

	if string.len(voiceUUID) > 0  and voiceTime ~= 0 then
		record.voiceUUID = voiceUUID
		record.voiceTime = voiceTime
	    record.chatContent = self:GetVoiceText(content)
	end

    for k, v in pairs(m_VecAllContactRole) do
        if v.roleID == record.roleid then
            v:insertRecord(record)
            break
        end
    end

    self:SaveChatRecordByRoleID(record.roleid)

    self:AddLastChat(record.roleid, true)
end

--获取语音的文字.
function FriendManager:GetVoiceText(chatText)
	local text = chatText:match("text=(.*)&")
	return text or ""
end

function FriendManager.AddLastChat__(roleid, saving)
    if _instance then
        _instance:AddLastChat(roleid, saving)
    end
end

function FriendManager:ClearChatRecord(roleID)
    for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            v.m_VecChatRecord = {}
            self:SaveChatRecordByRoleID(roleID)
            break
        end
    end
end

function FriendManager:RequestBreakFriendRelation(roleID)
    if self:isMyFriend(roleID) then
        local role = self:GetContactRole(roleID)
        local message = MHSD_UTILS.get_resstring(925)..role.name..MHSD_UTILS.get_resstring(926)
        gGetMessageManager():AddConfirmBox(eConfirmNormal, message, FriendManager.SendBreakFriendRelationToServer, self, MessageManager.HandleDefaultCancelEvent, MessageManager, roleID)
    end
end

function FriendManager:HasNotShowMsg() 
    return require "utils.tableutil".tablelength(m_VecChatRecord) > 0 
end

function FriendManager.GetRoleNotReadMsgNum(roleID)
	local num = 0
    for k, v in pairs(m_VecChatRecord) do
        if v.roleid == roleID then
            num = num + 1
        end
    end
    return num
end

function FriendManager:GetNotReadMsgNum()
    return require "utils.tableutil".tablelength(m_VecChatRecord)
end

function FriendManager:SetChatRoleID(roleID, name)
    if gGetDataManager():GetMainCharacterID() ~= roleID then
        m_WantToChatRoleID = roleID
        self:AddLastChat(roleID, false)
        require "logic.friend.frienddialog".GlobalSetChatRole()
    else
        GetCTipsManager():AddMessageTipById(141533)
    end
end

function FriendManager:SetChatRoleByID(roleID)
    self:SetChatRoleID(roleID, "")
end

function FriendManager:RequestSetChatRoleID(roleID)
    local bHaveRoleInfo = true
    m_ListenRoleInfoFunc = nil
    self:SendRequestUpdateRoleInfo(roleID)
    bHaveRoleInfo = false

	if bHaveRoleInfo then
        self:SetChatRoleByID(roleID)
	else
		m_ListenRoleInfoFunc = self.SetChatRoleByID
	end
end

function FriendManager:isFriendOnline(roleID)
	local role = self:GetContactRole(roleID)
	if role.roleID ~= 0 then
        if role.isOnline == 1 then
            return true
        else
            return false
        end
    end
	return false
end

function FriendManager:ClearAllLastChatRecord()
    m_MapLastChatRecord = {}
end

function FriendManager:RefreshLastChatRecord(roleID, strRecord)
	if string.len(strRecord) == 0 then
        self:RemoveLastChatRecord(roleID)
    else
        table.insert(m_MapLastChatRecord, roleID, strRecord)
    end
end

function FriendManager:RemoveLastChatRecord(roleID)
    for k, v in pairs(m_MapLastChatRecord) do
        if k == roleID then
            table.remove(m_MapLastChatRecord, k)
        end
    end
end

function FriendManager.GetChatRecordNumByRoleID(roleID)
    if _instance then
        local role = _instance:GetContactRole(roleID)
        if role then
            return role:GetChatRecordNum()
        else 
            return 0
        end
    end
    return 0
end

function FriendManager:GetLastChatRecord(roleID, strRecord)
    for k, v in pairs(m_MapLastChatRecord) do
        if k == roleID then
            return true
        end
    end

    return false
end

function FriendManager.GetRecentChatRoleIDByIdx(idx)
	if idx > 0 and require "utils.tableutil".tablelength(m_VecLastContactRole) >= idx then
		return m_VecLastContactRole[idx]
    end
	return 0
end

function FriendManager:SendRequestUpdateRoleInfo(roleID)
    local req = require"protodef.fire.pb.friends.crequestupdateroleinfo":new()
    req.roleid = roleID
    LuaProtocolManager.getInstance():send(req)
end

function FriendManager:CallListenRoleInfoFunc(roleID)
	if m_ListenRoleInfoFunc then
        m_ListenRoleInfoFunc(self, roleID)
        m_ListenRoleInfoFunc = nil
    end
end

function FriendManager:GetWantToContactRoleID() 
    return m_WantToContactRoleID
end

function FriendManager:ContactRoleDialogOpen(roleID)
    local role = gGetFriendsManager():GetContactRole(roleID)
    if role and role.roleID ~= 0 then
        m_WantToContactRoleID = roleID
        ContactRoleDialog.GlobalSetCharacter()
    end
end

function FriendManager:PopSystemMsg()
    local roleID = -1

	local records = {}

    for k, v in pairs(m_VecChatRecord) do
        if v.roleid == roleID then
            table.insert(records, v)
        end
    end

    if require "utils.tableutil".tablelength(records) == 0 then
        return false
   end

   for _, v in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            for _, t in pairs(records) do
                v:insertRecord(t)
            end
        end
   end

    self:RefreshFriendBtnNotify()

    return true
end

function FriendManager:FullLoadChatRecordRole()
	for k, v in pairs(m_VecLastContactRole) do
        self:AddLoadChatRecordRole(m_VecLastContactRole[k])
    end
end

function FriendManager:LoadLastContactList()
    FriendVisitor:loadRecentRoleList()
    self:SortLastContactList()
end

function FriendManager:SetContactRole(roleID, bOpenContactRoleDlg)
	local bHaveRoleInfo = true
	m_ListenRoleInfoFunc = nil
	m_WantToContactRoleID = roleID

    self:SendRequestUpdateRoleInfo(roleID)
    bHaveRoleInfo = false

	if bOpenContactRoleDlg then
		if bHaveRoleInfo then
            self:ContactRoleDialogOpen(roleID)
		else
			m_ListenRoleInfoFunc = self.ContactRoleDialogOpen
        end
	end
end

function FriendManager:SendRequestAllStrangerRoleInfo()
    for k, v in pairs(m_VecLastContactRole) do
        if not self:isMyContactRole(v) then
            self:SendRequestUpdateRoleInfo(v)
        end
    end
end

function FriendManager.GetRecentChatListNum()
	return require "utils.tableutil".tablelength(m_VecLastContactRole)
end

function FriendManager:GetLastMsgRoleID()
    local tSize = require "utils.tableutil".tablelength(m_VecChatRecord)
    if tSize > 0 then
        return m_VecChatRecord[tSize].roleid
    end
    return 0
end

function FriendManager:GetWantToChatRoleID()
    return m_WantToChatRoleID
end

function FriendManager:SendBreakFriendRelationToServer(e)
    local windowargs = CEGUI.toWindowEventArgs(e)
    local pConfirmBoxInfo = tolua.cast(windowargs.window:getUserData(), "stConfirmBoxInfo")
    if pConfirmBoxInfo then
		local roleID = pConfirmBoxInfo.userID

		if self:isMyFriend(roleID) then
            local req = require"protodef.fire.pb.friends.cbreakoffrelation":new()
            req.roleid = roleID
            LuaProtocolManager.getInstance():send(req)
        end
	end

	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
	return true
end

function FriendManager:SaveLastContactList()
    FriendVisitor:writeRecentRoleList()
end

function FriendManager:SortLastContactList()
    local vecSize = require "utils.tableutil".tablelength(m_VecLastContactRole)

    for k, v in pairs(m_VecLastContactRole) do
        if v == -2 then
            table.remove(m_VecLastContactRole, k)
            break
        end
    end
    table.insert(m_VecLastContactRole, 1, -2)


    for k, v in pairs(m_VecLastContactRole) do
        if v == -1 then
            table.remove(m_VecLastContactRole, k)
            break
        end
    end
    table.insert(m_VecLastContactRole, 1, -1)
end

function FriendManager.isMyFriend__(roleID)
    return gGetFriendsManager():isMyFriend(roleID)
end

function FriendManager:isMyFriend(roleID)
    for _, v in pairs (m_VecMyFriends) do
        if v == roleID then
            return true
        end
    end

    return false
end

function FriendManager:RefreshFriendList()
    self:SortFriendList()
    require "logic.friend.frienddialog".freshFriendsForCpp()
end

function FriendManager:SortFriendList()
    if self:GetCurFriendNum() < 2 then return end 

	if m_FriendListSortFunc then
		table.sort(m_VecMyFriends, m_FriendListSortFunc)
	end
end

function FriendManager:SetFriendListSortFunc(func)
	m_FriendListSortFunc = func
end

function FriendManager.compare(a, b)
		if a == -1 then
			return true
		elseif b == -1 then
			return false
		elseif a == -2 then
			return true
		elseif b == -2 then
			return false
		end

		local aRole = gGetFriendsManager():GetContactRole(a)
		local bRole = gGetFriendsManager():GetContactRole(b)
		local aHasNotReadMsg = gGetFriendsManager():RoleHasNotReadMsg(a)
		local bHasNotReadMsg = gGetFriendsManager():RoleHasNotReadMsg(b)

		local xa = bit.band(aRole.relation, 1)
		if xa == 0 then
			xa = bit.band(aRole.relation, 2)
		end
		if xa == 0 then
			xa = bit.band(aRole.relation, 4)
		end

		local xb = bit.band(bRole.relation, 1)
		if xb == 0 then
			xb = bit.band(bRole.relation, 2)
		end
		if xb == 0 then
			xb = bit.band(bRole.relation, 4)
		end

		if not aHasNotReadMsg and bHasNotReadMsg then
			return false
		elseif aHasNotReadMsg and not bHasNotReadMsg then
			return true
		end

		if aRole.isOnline == 0 and bRole.isOnline > 0 then
			return false
		elseif aRole.isOnline > 0 and bRole.isOnline == 0 then
			return true
		elseif xa > 0 and xb == 0 then
			return true
		elseif xa == 0 and xb > 0 then
			return false
		elseif xa > 0 and xb > 0 and xa ~= xb then
			return xa < xb
		elseif aRole.friendLevel < bRole.friendLevel then
			return false
		elseif aRole.friendLevel ~= bRole.friendLevel then
			return true
        end

		return a < b
end

function FriendManager:RoleHasNotReadMsg(roleID)
    for _, v in pairs(m_VecChatRecord) do
        if v.roleid == roleID then
            return true
        end
    end

    return false
end

function FriendManager:PushChatMsg(roleID, roleName, online, level, friendLevel, school, shape, camp, relation, factionID, factionName, strContent, time, voiceUuid, voiceTime)
	if gGetGameConfigManager():GetConfigValue("friendmessage") == 1 then
		if not self:HasGivenRoleIDFriend(roleID) then
            return
        end
    end

    local record = stChatRecordUnit.new()
    record:init()
    record.roleid = roleID
    record.name = roleName

	local strTime = ""
	if string.len(time) > 0 then
		if string.find(time, "-") then
            strTime = time
		end
	else
        local serverTime = gGetServerTime()	
        local time = StringCover.getTimeStruct(serverTime / 1000)
        local year = time.tm_year + 1900
        local month = time.tm_mon + 1
        local day = time.tm_mday
        local hour = time.tm_hour
        local minute = time.tm_min
        local second = time.tm_sec
        strTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
    end

    record.time = strTime
    record.chatContent = strContent
    record.isOnline = online
    record.rolelevel = level
    record.friendLevel = friendLevel
    record.school = school
    record.shape = shape
    record.camp = camp
    record.relation = relation
    record.factionID = factionID
    record.factionName = factionName
    record.voiceUUID = voiceUuid
    record.voiceTime = voiceTime

	if string.len(voiceUuid) > 0  and voiceTime ~= 0 then
	    record.chatContent = self:GetVoiceText(strContent)
	end

    table.insert(m_VecChatRecord, record)
    self:AddLastChat(roleID, true)
    self:RefreshFriendBtnNotify()
    require "logic.friend.frienddialog".refreshChatContentForCpp()

    self:SaveChatRecordByRoleID(record.roleid)

end

function FriendManager:SaveChatRecordByRoleID(roleID) 
    for _, v  in pairs(m_VecAllContactRole) do
        if v.roleID == roleID then
            if FriendManager.RoleHasNotLoadChatRecord(roleID) then
                self:LoadChatRecordByRoleID(roleID)
            end

            if self:RoleHasNotReadMsg(roleID) then
                for k, t in pairs(m_VecChatRecord) do
                    if t.roleid == roleID then
                       v:insertRecord(t)
                    end
                end
            end
            FriendVisitor:SaveChatRecord(gGetDataManager():GetMainCharacterID(), gGetDataManager():GetMainCharacterName(), v.roleID)
            break
        end
    end
end

function FriendManager.GetRecordNumByRoleID__(roleID)
    local role = gGetFriendsManager():GetContactRole(roleID)
    if role then
        return role:GetChatRecordNum()
    end
    return 0
end

function FriendManager.getRoleRecordTime__(RoleID, index)
    local role = gGetFriendsManager():GetContactRole(RoleID)
    if role then
       record = role:GetChatRecordByIndex(index)
       if record then
            return record.time
       end
    end
end

function FriendManager.getRoleRecordVoiceUuid__(RoleID, index)
    local role = gGetFriendsManager():GetContactRole(RoleID)
    if role then
       record = role:GetChatRecordByIndex(index)
       if record and string.len(record.voiceUUID) > 0 then
            return record.voiceUUID
       end
    end
end

function FriendManager.getRoleRecordVoiceTime__(RoleID, index)
    local role = gGetFriendsManager():GetContactRole(RoleID)
    if role then
       record = role:GetChatRecordByIndex(index)
       if record and string.len(record.voiceUUID) > 0 then
            return record.voiceTime
       end
    end
end

function FriendManager.getRoleRecordContent__(RoleID, index)
    local role = gGetFriendsManager():GetContactRole(RoleID)
    if role then
       record = role:GetChatRecordByIndex(index)
       if record then
            return record.chatContent
       end
    end
end

function FriendManager.getRoleRecordName__(RoleID, index)
    local role = gGetFriendsManager():GetContactRole(RoleID)
    if role then
       record = role:GetChatRecordByIndex(index)
       if record then
            return record.name
       end
    end
end

function FriendManager.getRoleRecordMessageID__(RoleID, index)
    local role = gGetFriendsManager():GetContactRole(RoleID)
    if role then
       record = role:GetChatRecordByIndex(index)
       if record then
            return record.messageID
       end
    end
end


function FriendManager.RoleHasNotLoadChatRecord(roleID)
    for _, v in pairs (m_ListLoadChatRecordRole) do
        if v == roleID then
            return true
        end
    end
    return false
end

function FriendManager:AddLoadChatRecordRole(roleID)
    for _, v in pairs(m_ListLoadChatRecordRole) do
        if v == roleID then
            return
        end
    end
    table.insert(m_ListLoadChatRecordRole, roleID)
end

function FriendManager:HasGivenRoleIDFriend(roleID)
    for _, v in pairs(m_VecMyFriends) do
        if roleID == v then
            return true
        end
    end

	return false
end

function FriendManager:GetCurFriendNum()
    return require "utils.tableutil".tablelength(m_VecMyFriends)
end

function FriendManager:GetFriendRoleIDByIdx(idx)
	if idx > 0 and self:GetCurFriendNum() >= idx then
		return m_VecMyFriends[idx]
    end
	return 0
end

function FriendManager:setFriendRoleSign(signMap)
    m_signMap = signMap
end

function FriendManager:getSignByRoleID(roleID)
    for k, v in pairs(m_signMap) do
        if k == roleID then
            return v
        end
    end
    return ""
end

function FriendManager:updateFriendSign(roleid, signStr)
    for k, v in pairs(m_signMap) do
        if k == roleid then
             m_signMap[k] = signStr
            break
        end
    end
end

--endregion
