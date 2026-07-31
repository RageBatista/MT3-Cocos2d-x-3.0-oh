

m = require "protodef.fire.pb.talk.stranschatmessage2client"
function m:process()
	if not GetChatManager() or not gGetDataManager() then
		return
	end

	if 0 == require("system.banlistmanager").GlobalIsInBanList(self.roleid) then
		local msg = { self.messagetype, self.roleid, self.shapeid, self.titleid, 0, self.rolename, self.message }
		table.insert(CChatManager.m_vecChatMsg, msg)
	end

	if self.roleid == gGetDataManager():GetMainCharacterID() and ADD_CHAT_TO_HISTORY == -1 then

		local PureString = CChatOutputDialog.getInstance().m_pChatInputBox:GetPureText()
		local ChatText = CChatOutputDialog.getInstance().m_pChatInputBox:GenerateParseText(false)

		if GetChatCellManager():HasVoiceContent(self.message) then
			-- ������ٱ�������Ϣ��ƽ̨
--			if b_RoleAccusation then
--				local ccMgr = GetChatCellManager()
--				local strUuid = ccMgr:GetVoiceUUID(self.message)
--				local strUrl = gGetGameApplication():GetVoiceServerAddress() .. "iat/" .. strUuid
--				gGetVoiceManager():SendChatToPlatform(1, CEGUI.String(strUrl))
--			end

			--��ʼ����cd��ʱ
			local tmp = CChatOutBoxOperatelDlg.getInstanceNotCreate()
			if tmp then
				GetChatManager():startSendChatCdTime(self.messagetype)
				tmp:SetCdTimeForChannel(self.messagetype, GetChatManager():getSendChatInCdTime(self.messagetype))
			end
		else
			-- ������ٱ�������Ϣ��ƽ̨
			if b_RoleAccusation then
				local roleInf = gGetFriendsManager():GetContactRole(roleID)

				gGetVoiceManager():SendChatToPlatform(0, CEGUI.String(PureString), roleInf.rolelevel, gGetDataManager():GetTotalRechargeYuanBaoNumber())
			end
			CChatOutputDialog.getInstance():AddChatHistory(ChatText)
			CChatOutputDialog.getInstance().m_pChatInputBox:Clear()
			CChatOutputDialog.getInstance().m_pChatInputBox:Refresh()
			CChatOutputDialog.getInstance().m_pChatInputBox:activate()
			CChatOutputDialog.getInstance():SetCanTalk(true)

			GetChatManager():ClearChatLinks()
		end
	end

	if ADD_CHAT_TO_HISTORY == self.roleid then
		ADD_CHAT_TO_HISTORY = -1
		CChatOutputDialog.getInstance():SetCanTalk(true)
	end

	-- 公会聊天，发 GameCenter 成就得分
	if self.messagetype == ChannelType.CHANNEL_CLAN then
		if GameCenter:GetInstance() then
              local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
              if manager then
                  if manager.m_isPointCardServer then
                       GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId_DK.DK_ChatInGuildChannel, 10);
                  else
                      GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId.ChatInGuildChannel, 10);
                  end
              end
		end
	end
end

m = require "protodef.fire.pb.talk.schatitemtips"
function m:process()
	if not GetChatManager() then
		return
	end

	GetChatManager():AddObjTips(self.displayinfo.roleid, self.displayinfo.displaytype, self.displayinfo.uniqid, self.displayinfo.shopid, self.displayinfo.counterid, self.tips)
	GetChatManager():ShowLinkTips(self.displayinfo.roleid, self.displayinfo.displaytype, self.displayinfo.uniqid, self.displayinfo.shopid, self.displayinfo.counterid, self.tips)
	
	--网络请求物品信息后，checktipswnd会先执行，且并没有执行commontipdlg的else语句，
	--把tips的willCheckTipsWnd赋值false，导致会点击两次空白地方来关闭tips
	--这里网络协议请求后，在checktipswnd执行之后，手动设置willCheckTipsWnd为true，
	--就可以点击一次其他地方来关闭tips了
	local commontipdlg = require('logic.tips.commontipdlg').getInstanceNotCreate()
    if commontipdlg then
	    commontipdlg.willCheckTipsWnd = true
    end
end

m = require "protodef.fire.pb.talk.stranschatmessagenotify2client"
function m:process()
	local parastr = {}
	local total = 0
	if self.parameters then
		total = #self.parameters
	end
	for i = 1, total do
		local str = StringCover.OctectToWString(self.parameters[i]);
		table.insert(parastr, str)
	end

	if GetChatManager() then
		GetChatManager():AddTipsMsg(self.messageid, self.npcbaseid, parastr, false)
	end
end

m = require "protodef.fire.pb.talk.sexpmessagetips"
function m:process()
    
    local strAllMsg = require("utils.mhsdutils").get_msgtipstring(self.messageid)

     local sb = StringBuilder.new()
     local strParam = "parameter1"
     sb:Set(strParam,tostring(self.expvalue))
     strAllMsg = sb:GetString(strAllMsg)
     sb:delete()

    for nMsgId,nValue in  pairs(self.messageinfo) do 
       local strOneMsg =  require("utils.mhsdutils").get_msgtipstring(nMsgId)
       if nValue >0 then
            local sb = StringBuilder.new()
            local strParam = "parameter1"
            sb:Set(strParam,tostring(nValue))
            strOneMsg = sb:GetString(strOneMsg)
            sb:delete()
       end
       strAllMsg = strAllMsg..strOneMsg
    end
    GetCTipsManager():AddMessageTip(strAllMsg)
    GetChatManager():AddMsg_SysChannel(strAllMsg)

end


m = require "protodef.fire.pb.talk.schathelpresult"
function m:process()
    local dlg = require("logic.anye.anyemaxituandialog").getInstanceNotCreate()
    if not dlg then
        return
    end
    dlg:callHelpSuccess()
end

--[[
    千里传音（喇叭）协议处理
]]

-- 喇叭发送结果处理
m = require "protodef.fire.pb.talk.shornres"
function m:process()
    if not GetChatManager() then
        return
    end

    local hornDlg = require("logic.chat.horndialog").getInstanceNotCreate()
    if self:isSuccess() then
        -- 发送成功，刷新发送状态与资源显示
        if hornDlg then
            if hornDlg.OnHornSendResult then
                hornDlg:OnHornSendResult(true, self)
            end
        end
        GetCTipsManager():AddMessageTipById(162025)
    else
        -- 发送失败，显示错误提示
        if hornDlg and hornDlg.OnHornSendResult then
            hornDlg:OnHornSendResult(false, self)
        end
        local errorDesc = self:getErrorDesc()
        if errorDesc and errorDesc ~= "" then
            GetChatManager():AddMsg_SysChannel(errorDesc, true, false)
            GetCTipsManager():AddMessageTip(errorDesc)
        end
    end
end

-- 喇叭广播通知处理（其他玩家发送的喇叭）
m = require "protodef.fire.pb.talk.shornex"
function m:process()
    if not GetChatManager() then
        return
    end

    local senderName = self:getDisplayName() or ""
    local content = self.content or ""
    local hornText = "【传音】" .. senderName .. "：" .. content

    local hornDialog = require("logic.chat.horndialog")
    if hornDialog and hornDialog.AddHistoryRecord then
        hornDialog.AddHistoryRecord(senderName, content, self.broadcastType)
    end

    -- 兼容当前客户端聊天实现：喇叭消息写入系统频道，避免未知频道导致队列异常
    GetChatManager():AddMsg_SysChannel(hornText, true, false)

    -- 喇叭飘屏（跑马灯）展示：所有收到广播的客户端都会显示
    local busyTextDlg = require("logic.busytext.busytextdlg").getInstanceAndShow()
    if busyTextDlg then
        busyTextDlg:addMsg(hornText)
        busyTextDlg:SetVisible(true)
    end
end

-- 系统广播通知处理
m = require "protodef.fire.pb.talk.systembroadcastnotify"
function m:process()
    if not GetChatManager() then
        return
    end
    
    -- 获取格式化后的消息内容
    local content = self:getFormattedMessage()
    if not content or content == "" then
        return
    end
    
    -- 根据消息类型选择显示方式
    if self:isNotice() then
        -- 公告类型：顶部弹出显示
        ShowSystemTips(content, 0)
    elseif self:isHighPriority() then
        -- 高优先级：系统频道显示
        GetChatManager():AddMsg_SysChannel(content)
    else
        -- 普通类型：系统频道显示
        GetChatManager():AddMsg_SysChannel(content)
    end
end
