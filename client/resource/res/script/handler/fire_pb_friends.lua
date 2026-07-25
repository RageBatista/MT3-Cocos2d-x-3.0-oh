local m = require "protodef.fire.pb.friends.sjioncamp"
function m:process()
    -- 已废弃
end


local ssearchfriend = require "protodef.fire.pb.friends.ssearchfriend"
function ssearchfriend:process()
	LogInfo("ssearchfriend process")
	require "logic.friendadddialog"
	if FriendAddDialog.getInstanceNotCreate() then
		FriendAddDialog.getInstanceNotCreate():Init(self.friendinfobean)
	end

end

local srecommendfriend = require "protodef.fire.pb.friends.srecommendfriend"
function srecommendfriend:process()
	LogInfo("srecommendfriend process")
	require "logic.friendadddialog"
	if FriendAddDialog.getInstanceNotCreate() then
		FriendAddDialog.getInstanceNotCreate():InitList(self.friendinfobeanlist)
	end
end

local saddfriend = require "protodef.fire.pb.friends.saddfriend"
function saddfriend:process()
	if not gGetFriendsManager() then
        return 
    end
    if not gGetNetConnection() then
        return
    end
    local friendlevel = 1;
    local friendinfobean = self.friendinfobean
	gGetFriendsManager():AddContact(friendinfobean.roleid, friendinfobean.name,
		friendinfobean.rolelevel, friendlevel, friendinfobean.online, friendinfobean.school, friendinfobean.shape,
		friendinfobean.camp, friendinfobean.relation, friendinfobean.factionid, friendinfobean.factionname)

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshSpaceAddFriendBtn)

	-- 添加好友，发 GameCenter 成就得分
	if GameCenter:GetInstance() then
        local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        if manager then
            if manager.m_isPointCardServer then
                GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId_DK.DK_AddFriend, 10);
            else
                GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId.AddFriend, 10);
            end
        end
	end
end

local supdatefriendstate = require "protodef.fire.pb.friends.supdatefriendstate"
function supdatefriendstate:process()
	if not gGetFriendsManager() then
        return 
    end
  	gGetFriendsManager():updateFriendState(self.roleid, self.relation);    
end

local sfriendsonline = require "protodef.fire.pb.friends.sfriendsonline"
function sfriendsonline:process()
	if not gGetFriendsManager() then
        return 
    end
    if not gGetDataManager() then
        return 
    end
    
	gGetFriendsManager():ChangeRoleOnlineState(self.roleid, self.online)
end

local sfriendsinfoinit = require "protodef.fire.pb.friends.sfriendsinfoinit"
function sfriendsinfoinit:process()
	if not gGetFriendsManager() then
        return 
    end

	gGetFriendsManager():Cleanup()
	gGetFriendsManager():SetFriendListSortFunc(nil)

    local strSystemFriendName = require("utils.mhsdutils").get_resstring(2773)
    local strSpriteFriendName = require("utils.mhsdutils").get_resstring(11503)
	gGetFriendsManager():AddContact(-1, strSystemFriendName, 89, 99999999, 1, 0, 0, 0, 0, 0, "")
	gGetFriendsManager():AddLoadChatRecordRole(-1);
    gGetFriendsManager():AddContact(-2, strSpriteFriendName, 89, 99999999, 1, 0, 0, 0, 0, 0, "")
    gGetFriendsManager():AddLoadChatRecordRole(-2);
    for i=1,#self.friends do
        local friends = self.friends
        gGetFriendsManager():AddContact(friends[i].friendinfobean.roleid, friends[i].friendinfobean.name,
			friends[i].friendinfobean.rolelevel, friends[i].friendlevel, friends[i].friendinfobean.online,
			friends[i].friendinfobean.school, friends[i].friendinfobean.shape, friends[i].friendinfobean.camp,
			friends[i].friendinfobean.relation, friends[i].friendinfobean.factionid, friends[i].friendinfobean.factionname)

		gGetFriendsManager():AddFriend(friends[i].friendinfobean.roleid)
		gGetFriendsManager():AddLoadChatRecordRole(friends[i].friendinfobean.roleid)
    end
	gGetFriendsManager():AddLastChat(-1, false)
    gGetFriendsManager():AddLastChat(-2, false)
	gGetFriendsManager():LoadLastContactList()
	gGetFriendsManager():FullLoadChatRecordRole()
	--// 请求所有陌生人的信息
	gGetFriendsManager():SendRequestAllStrangerRoleInfo()
	gGetFriendsManager():SetFriendListSortFunc(FriendManager.compare)
	gGetFriendsManager():SortFriendList()
    gGetFriendsManager():SetMaxFriendNumber(self.friendnumlimit)
    require("logic.chat.cchatoutboxoperateldlg").RefreshNotify()
end

local sfriendmessagetorole = require "protodef.fire.pb.friends.sfriendmessagetorole"
function sfriendmessagetorole:process()
	if not gGetFriendsManager() then
        return 
    end
    if not gGetDataManager() then
        return 
    end
     if not gGetGameUIManager() then
        return 
    end
    local roleid = self.roleid
    local role = self.role
    local rolelevel = self.rolelevel
    local content = self.content
    local nInBan =require("system.banlistmanager").GlobalIsInBanList(roleid)
    local mainRoleId = gGetDataManager():GetMainCharacterID()
    local voiceUuid = require "logic.friend.frienddialog".GetVoiceUuid(content)
    local voiceTime = require "logic.friend.frienddialog".GetVoiceTime(content)
    if GetChatCellManager():HasVoiceContent(self.content) and voiceUuid == "" then
        return
    end
	if roleid > 0 and roleid ~= mainRoleId and 0 == nInBan then
		local role = gGetFriendsManager():GetContactRole(roleid)
		if role.roleID > 0 then
			gGetFriendsManager():PushChatMsg(roleid, role.name, role.isOnline, rolelevel, role.friendLevel,
				role.school, role.shape, role.camp, role.relation, role.factionID, role.factionName, content, "", voiceUuid, voiceTime)
		end
    end
end

local sstrangermessagetorole = require "protodef.fire.pb.friends.sstrangermessagetorole"
function sstrangermessagetorole:process()
    if not gGetFriendsManager() then
        return 
    end
    if not gGetDataManager() then
        return 
    end
     if not gGetGameUIManager() then
        return 
    end
    local strangermessage = self.strangermessage
    local roleID = strangermessage.friendinfobean.roleid;

    local nInBan =require("system.banlistmanager").GlobalIsInBanList(roleID) 
    local mainRoleId = gGetDataManager():GetMainCharacterID()
    local voiceUuid = require "logic.friend.frienddialog".GetVoiceUuid(strangermessage.content)
    local voiceTime = require "logic.friend.frienddialog".GetVoiceTime(strangermessage.content)
    if GetChatCellManager():HasVoiceContent(strangermessage.content) and voiceUuid == "" then
        return
    end

	if roleID > 0 and roleID ~= mainRoleId and 0 == nInBan then
	
		gGetFriendsManager():AddContact(strangermessage.friendinfobean.roleid, strangermessage.friendinfobean.name,
			strangermessage.friendinfobean.rolelevel, 0, strangermessage.friendinfobean.online, strangermessage.friendinfobean.school,
			strangermessage.friendinfobean.shape, strangermessage.friendinfobean.camp, strangermessage.friendinfobean.relation,
			strangermessage.friendinfobean.factionid, strangermessage.friendinfobean.factionname)

		gGetFriendsManager():PushChatMsg(strangermessage.friendinfobean.roleid, strangermessage.friendinfobean.name,
			strangermessage.friendinfobean.online, strangermessage.friendinfobean.rolelevel, 0, strangermessage.friendinfobean.school,
			strangermessage.friendinfobean.shape, strangermessage.friendinfobean.camp, strangermessage.friendinfobean.relation,
			strangermessage.friendinfobean.factionid, strangermessage.friendinfobean.factionname,
			strangermessage.content, "", voiceUuid, voiceTime)

		gGetFriendsManager():RefreshFriendList()
	end
end

local sbreakoffrelation = require "protodef.fire.pb.friends.sbreakoffrelation"
function sbreakoffrelation:process()
     if not gGetFriendsManager() then
        return 
    end
    local roleid  = self.roleid
    gGetFriendsManager():DelFriend(roleid)

    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.refreshSpaceAddFriendBtn)
end

local supdatefriendlevel = require "protodef.fire.pb.friends.supdatefriendlevel"
function supdatefriendlevel:process()
    if not gGetFriendsManager() then
        return 
    end
    gGetFriendsManager():ChangeFriendLevel(self.friendid, self.currentfriendlevel)

end

local srequestupdateroleinfo = require "protodef.fire.pb.friends.srequestupdateroleinfo"
function srequestupdateroleinfo:process()
    if not gGetFriendsManager() then
        return 
    end

    local friendinfobean = self.friendinfobean
    local friendLevel = 0;
    local bMyFriend = gGetFriendsManager():isMyFriend(friendinfobean.roleid)
	if bMyFriend then
		friendLevel = gGetFriendsManager():GetFriendlyDegrees(friendinfobean.roleid)
	end
	gGetFriendsManager():AddContact(friendinfobean.roleid, friendinfobean.name, friendinfobean.rolelevel, friendLevel, friendinfobean.online,
			friendinfobean.school, friendinfobean.shape, friendinfobean.camp, friendinfobean.relation, friendinfobean.factionid, friendinfobean.factionname)

	gGetFriendsManager():CallListenRoleInfoFunc(friendinfobean.roleid)

	require "logic.friend.frienddialog"
	if FriendDialog.getInstanceNotCreate() then
		FriendDialog.getInstance():freshContactsByType(0)
	end
end

local sofflinemsgmessagetorole = require "protodef.fire.pb.friends.sofflinemsgmessagetorole"
function sofflinemsgmessagetorole:process()
    if not gGetFriendsManager() then
        return 
    end
    for k,oneBean in pairs(self.offlinemsglist) do
        local friendLevel = 0;
		local friendinfobean = oneBean.strangermessage.friendinfobean
        local llRoleId = friendinfobean.roleid
		if gGetFriendsManager():isMyFriend(llRoleId) then
			friendLevel = gGetFriendsManager():GetFriendlyDegrees(llRoleId)
		end
        local nInBan = require("system.banlistmanager").GlobalIsInBanList(llRoleId) 

		if 0 == nInBan then
			if not gGetFriendsManager():isMyContactRole(friendinfobean.roleid) then
				gGetFriendsManager():AddContact(friendinfobean.roleid, friendinfobean.name,
					friendinfobean.rolelevel, friendLevel, friendinfobean.online, friendinfobean.school,
					friendinfobean.shape, friendinfobean.camp, friendinfobean.relation,
					friendinfobean.factionid, friendinfobean.factionname)
			end

			local voiceUuid = require "logic.friend.frienddialog".GetVoiceUuid(oneBean.strangermessage.content)
			local voiceTime = require "logic.friend.frienddialog".GetVoiceTime(oneBean.strangermessage.content)
            if not (GetChatCellManager():HasVoiceContent(oneBean.strangermessage.content) and voiceUuid == "") then
			    gGetFriendsManager():PushChatMsg(friendinfobean.roleid, friendinfobean.name,
				    friendinfobean.online, friendinfobean.rolelevel, friendLevel,
				    friendinfobean.school, friendinfobean.shape,
				    friendinfobean.camp, friendinfobean.relation,
				    friendinfobean.factionid, friendinfobean.factionname,
				    oneBean.strangermessage.content, oneBean.time, voiceUuid, voiceTime)
            end
		end
    end
end

local ssendsystemmessagetorole = require "protodef.fire.pb.friends.ssendsystemmessagetorole"
function ssendsystemmessagetorole:process()
    if not gGetFriendsManager() then
        return 
    end
    if self.systemroleid == 0 then
        local record = GameTable.message.GetCMessageTipTableInstance():getRecorder(self.contentid)
        if record.id == -1 then
            return
        end
    	local parastr = {}
	    local total = 0
        if self.contentparam then
		    total = #self.contentparam
	    end
	    for i = 1, total do
		    local str = StringCover.OctectToWString(self.contentparam[i]);
		    table.insert(parastr, str)
	    end
        local sb = StringBuilder.new()
        local strmsg = ""
        if total == 0 then
            strmsg = record.msg
        else
        	for i = 1, total do
		        local str = "parameter" .. i
                sb:Set(str, parastr[i])
	        end
            strmsg = sb:GetString(record.msg)
        end
        if strmsg == nil or strmsg =="" then
            return
        end
        local strTemp = string.sub(strmsg,1,1)
        if strTemp ~= "<" then
            strmsg = string.format("<T t='%s' c='ff261407'/>", strmsg)
        end
        local sysname = MHSD_UTILS.get_resstring(2773)
        gGetFriendsManager():PushChatMsg(-1, sysname, 1, 89, -1, 0, 0, 0, 0, 0, "", strmsg, self.time, "", 0)
        sb:delete()
    end
end

local sgiveinfolist = require "protodef.fire.pb.friends.sgiveinfolist"
function sgiveinfolist:process()
    local dlg = require "logic.friend.sendgiftdialog".getInstanceNotCreate()
    if dlg then
        dlg:refreshGiftData(self.givenummap)
    end
end

local sgiveitem = require "protodef.fire.pb.friends.sgiveitem"
function sgiveitem:process()
    local dlg = require "logic.friend.sendgiftdialog".getInstanceNotCreate()
    if dlg then
        dlg:refreshAfterSendItem(self.roleid, self.itemnum)
    end
end

local sgivegift = require "protodef.fire.pb.friends.sgivegift"
function sgivegift:process()
 local dlg = require "logic.friend.sendgiftdialog".getInstanceNotCreate()
 if dlg then
    if self.result == 1 then --错误双方不是双向好友
        dlg:sendGiftErrTip()
    else
        dlg:refreshToSendGift()
        dlg:clearSendGiftCD()

        local fDialog = require "logic.friend.frienddialog".getInstanceNotCreate() 
        if fDialog then
           fDialog:RefreshRoleRelation(dlg.m_currentSelectedRoleID)
        end
    end
    local Eventmanager = require "logic.space.eventmanager"
    local eventManager = Eventmanager.getInstance()
    eventManager:pushCmd(Eventmanager.eCmd.giveGiftEnd)
 end

end

local ssignlist = require "protodef.fire.pb.friends.ssignlist"
function ssignlist:process()
    if not gGetFriendsManager() then
        return 
    end

    gGetFriendsManager():setFriendRoleSign(self.signcontentmap)
end

local sgetspaceinfo = require "protodef.fire.pb.friends.sgetspaceinfo"
function sgetspaceinfo:process()
    require("logic.space.spaceprotocol").sgetspaceinfo_process(self)
 end


local ssetspacegift = require "protodef.fire.pb.friends.ssetspacegift"
function ssetspacegift:process()
    require("logic.space.spaceprotocol").ssetspacegift_process(self)
end


local sstepspace = require "protodef.fire.pb.friends.sstepspace"
function sstepspace:process()
    require("logic.space.spaceprotocol").sstepspace_process(self)
end


local srequestspaceroleinfo = require "protodef.fire.pb.friends.srequestspaceroleinfo"
function srequestspaceroleinfo:process()
    require("logic.space.spaceprotocol").srequestspaceroleinfo_process(self)
end


local sgetroleslevel = require "protodef.fire.pb.friends.sgetroleslevel"
function sgetroleslevel:process()
    require("logic.space.spaceprotocol").sgetroleslevel_process(self)
end


local sxshspace = require "protodef.fire.pb.friends.sxshspace"
function sxshspace:process()
    require("logic.space.spaceprotocol").sxshspace_process(self)
end

local sxshgivegift = require "protodef.fire.pb.friends.sxshgivegift"
function sxshgivegift:process()
    require("logic.space.spaceprotocol").sxshgivegift_process(self)
end

local sgetxshspaceinfo = require "protodef.fire.pb.friends.sgetxshspaceinfo"
function sgetxshspaceinfo:process()
    require("logic.space.spaceprotocol").sgetxshspaceinfo_process(self)
end

local sgetrecruitaward = require "protodef.fire.pb.friends.sgetrecruitaward"
function sgetrecruitaward:process()
    if self.result == 1 then
        if self.awardtype  == 1 then
            local dlg = require"logic.recruit.recruitdlg".getInstanceNotCreate()
            if dlg then
                dlg:refreshDataForJiangli()
            end
        else
            local dlg = require"logic.recruit.recruitdlg".getInstanceNotCreate()
            if dlg then
                dlg:refreshDataForMine()
            end
        end
    end
end