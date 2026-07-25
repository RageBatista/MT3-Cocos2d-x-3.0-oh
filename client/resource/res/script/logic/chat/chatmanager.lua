--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "utils.bit"

CChatManager={m_vecChatMsg = {}}
CChatManager.__index = CChatManager

local m_RequestChatItemTipsItemBaseID = 0
local m_RequestChatItemTipsRoleID = 0
local m_RequestChatItemTipsItemKey = 0
local m_RequestChatItemTipsXPos = 0.0
local m_RequestChatItemTipsYPos = 0.0

local _instance
local m_ChatRecordID = 100000
local m_vecObjTips = {}
local m_vecShiedTexts = {}

local m_mapSendChatCdTime = {}
local m_mapSendChatCdTimeDt = {}
local m_mapChanelSpeakNeedTime = {}
local m_mapChanelLastSpeakTime = {}

local m_TipsLinkVec = {}

function GetChatManager()
	if not _instance then
		_instance = CChatManager:new()
	end
	return _instance
end

function CChatManager:new()
	local self = {}
	setmetatable(self, CChatManager)

	m_mapChanelSpeakNeedTime[ChannelType.CHANNEL_CURRENT] = 1000
	m_mapChanelSpeakNeedTime[ChannelType.CHANNEL_TEAM] = 0
	m_mapChanelSpeakNeedTime[ChannelType.CHANNEL_CLAN] = 3000
	m_mapChanelSpeakNeedTime[ChannelType.CHANNEL_PROFESSION] = 3000
	m_mapChanelSpeakNeedTime[ChannelType.CHANNEL_WORLD] = 120000

	local mapChatCdIdAndChatId = { }
	mapChatCdIdAndChatId[200] = ChannelType.CHANNEL_WORLD
	mapChatCdIdAndChatId[201] = ChannelType.CHANNEL_PROFESSION
	mapChatCdIdAndChatId[202] = ChannelType.CHANNEL_CLAN
	mapChatCdIdAndChatId[203] = ChannelType.CHANNEL_TEAM

	for k,v in pairs(mapChatCdIdAndChatId) do
		local fCdTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(k).value)
		m_mapSendChatCdTime[v] = fCdTime
		m_mapSendChatCdTimeDt[v] = 0
	end

	self:InitShiedTexts()

	return self
end

function CChatManager:ResetRequestChatItemTipsInf()
	m_RequestChatItemTipsRoleID = 0
	m_RequestChatItemTipsItemKey = 0
	m_RequestChatItemTipsXPos = 0.0
	m_RequestChatItemTipsYPos = 0.0
end


function CChatManager.GenerateUniqueChatRecordID()
	m_ChatRecordID = m_ChatRecordID + 1
	return m_ChatRecordID
end

--anye task
--key=anye pos
--baseid = 3 --anyetype
--shopid =
--counter = 1==taskinfo 2=helper other
--bind=

function CChatManager:HandleTipsLinkClick(name, roleID, ctype, skey, baseid, shopID, counterID, nameColor, bind, loseeffecttime)
	-- 杨斌---判断点击聊天框打开聊天界面时，是否点击了连接
	CChatOutBoxOperatelDlg.bOpenChatWnd = false

	m_RequestChatItemTipsItemBaseID = baseid

	local pTipsOctes = nil

	local DI = DisplayInfo:new()
    key = tonumber(skey)

	if ctype ==DI.DISPLAY_TASK then
		pTipsOctes = GetChatManager():GetTipsOctes(roleID, ctype, key, shopID, counterID)
        if baseid==3 and counterID == 2 then --3=anyetask  -- 1=taskinfo 2=helperother
            local nCurLevel = GetMainCharacter():GetLevel()
            if nCurLevel < tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(336).value) then
                GetCTipsManager():AddMessageTipById(166090)
                return 
            end
            --[[
            local nnNowTime = gGetServerTime() /1000
            local nnSendTime = tonumber(loseeffecttime)
            local bInSameWeek =  require("logic.task.taskmanager").getInstance():isInSameWeek(nnSendTime,nnNowTime) 
            if bInSameWeek == false then
                GetCTipsManager():AddMessageTipById(166097)
                return
            end
            --]]

        end
    elseif ctype == DI.DISPLAY_SACE_ROLE then
        getSpaceManager():reqRoleInfo(roleID)
        return 
    elseif ctype ==DI.DISPLAY_PET then
        pTipsOctes = GetChatManager():GetTipsOctes(roleID, ctype, key, baseid, counterID)
	elseif ctype ==DI.DISPLAY_LIVEDIE then
        local p = require("protodef.fire.pb.battle.livedie.clivediebattlewatchfight"):new()
        p.battleid = key
	    LuaProtocolManager:send(p)
        return
	elseif ctype ==DI.DISPLAY_BATTLE then
        local req = require"protodef.fire.pb.battle.livedie.clivediebattlewatchvideo".Create()
        req.vedioid = skey
        LuaProtocolManager.getInstance():send(req)
        return
	elseif ctype ==DI.DISPLAY_ROLL_ITEM then
		-- roll点过程中 点击聊天屏道需要展示的tips
        local firsttype = 0
		local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
        if attr then
		    firsttype = bit.band(attr.itemtypeid, 15)
        end

		if firsttype == eItemType_EQUIP then
			pTipsOctes = GetChatManager():GetTipsOctes(0, 0, baseid, shopID, 0)
		else
			-- 如果是基础物品直接展现物品tips
			local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
			local posX = mousePos.x - 77
			local posY = mousePos.y;
			require ("logic.tips.commontipdlg").LuaShowItemTipWithBaseId(baseid, posX, posY)
			DI = nil
			return
		end
	else
		pTipsOctes = GetChatManager():GetTipsOctes(roleID, ctype, key, shopID, counterID)
	end

	if pTipsOctes ~= nil then
		self:ShowLinkTips(roleID, ctype, key, baseid, bind, pTipsOctes)
	else
		if ctype == DI.DISPLAY_ITEM then
			local tipsdlg = require ("logic.tips.commontipdlg").getInstanceNotCreate()
			if tipsdlg then
				tipsdlg.bRequestTipsProtocol = true
			end
		end

		local reqItemTips = require "protodef.fire.pb.talk.cchatitemtips".Create()
		reqItemTips.displayinfo.roleid = roleID
		reqItemTips.displayinfo.displaytype = ctype
		reqItemTips.displayinfo.uniqid = key

        if ctype == DI.DISPLAY_TASK  then
            reqItemTips.displayinfo.shopid = baseid
            if baseid==3 then --3 --anyetype
                reqItemTips.displayinfo.teamid = bind --bind=anye cur circle
            end
		elseif ctype == DI.DISPLAY_PET  then
			reqItemTips.displayinfo.shopid = baseid
		else
			reqItemTips.displayinfo.shopid = shopID
		end
		reqItemTips.displayinfo.counterid = counterID

		LuaProtocolManager.getInstance():send(reqItemTips)

		-- 	 	m_RequestChatItemTipsRoleID = roleID;
		-- 	 	m_RequestChatItemTipsItemKey = key;
		 	 	
		-- 	 	m_RequestChatItemTipsItemFlag = bind;
		-- 	 	CEGUI::Point mousePos = CEGUI::MouseCursor::getSingleton().getPosition();
		-- 	 	m_RequestChatItemTipsXPos = mousePos.d_x - 77.0f;
		-- 	 	m_RequestChatItemTipsYPos = mousePos.d_y;
	end

	DI = nil
end

--anye task
--key=anye pos
--baseid = 3 --anyetype
--shopid =
--counter = 1==taskinfo 2=helper other
--bind=
--[[
function DisplayInfo:new()
	local self = {}
	setmetatable(self, DisplayInfo)
		self.DISPLAY_ITEM = 1
		self.DISPLAY_PET = 2
		self.DISPLAY_TASK = 8
		self.DISPLAY_TEAM_APPLY = 9
		self.DISPLAY_ROLL_ITEM = 11
		self.DISPLAY_ACTIVITY_ANSWER = 12
		self.DISPLAY_LIVEDIE = 13
		self.DISPLAY_BATTLE = 14

	self.displaytype = 0
	self.roleid = 0
	self.shopid = 0 ==baseid
	self.counterid = 0 ==counter
	self.uniqid = 0   =key
	self.teamid = 0
--]]

function CChatManager.AddMsg(ctype, roleid, roleShape, roleTitle, roleCamp, strName, strMsg)
	if not gGetScene() then
		return
	end
    
	local allid = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getAllID()
	local MsgParseString = strMsg
	for i = 1, #allid do
		local colorConfig = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getRecorder(allid[i])

		local color = colorConfig.color
		local toReplace = colorConfig.chatlist[ctype - 1]
		if string.len(toReplace) > 1 then
			local outputstrings = { }
			local isDoubleColors = false
			if string.find(toReplace, ",") then
				local delimiters = ","
				outputstrings = StringBuilder.Split(toReplace, delimiters)
				isDoubleColors = true
			end
			local pos = string.find(MsgParseString, "c=\""..color) 

            if pos == nil then
                pos = string.find(MsgParseString, "c=\'"..color) 
            end

            if pos == nil then
                pos = string.find(MsgParseString, "TextColor=\""..color)
            end

            if pos ~= nil then
                if isDoubleColors then
                    if string.len(outputstrings[1]) == 8 then
                        MsgParseString = string.gsub(MsgParseString, "(c=['\"])"..color.."['\"]", "%1"..outputstrings[1].."\" ob=\""..color.."\"")
                        MsgParseString = string.gsub(MsgParseString, "(TextColor=['\"])"..color.."['\"]", "%1"..outputstrings[1].."\" ob=\""..color.."\"")
                    end
                else
                        MsgParseString = string.gsub(MsgParseString, "(c=['\"])"..color.."['\"]", "%1"..toReplace.."\" ob=\""..color.."\"")
                        MsgParseString = string.gsub(MsgParseString, "(TextColor=['\"])"..color.."['\"]", "%1"..toReplace.."\" ob=\""..color.."\"")
                end
            end

        end
    end

    --屏蔽字客户端处理
	local res,strMsgNew =  MHSD_UTILS.ShiedText(MsgParseString)


	if ctype == ChannelType.CHANNEL_CURRENT then
		GetChatManager():AddMsg_CurChannel(roleid, roleShape, roleTitle, roleCamp, strName, strMsgNew)
	elseif ctype == ChannelType.CHANNEL_TEAM then
		GetChatManager():AddMsg_Team(roleid, roleShape, roleTitle, roleCamp, strName, strMsgNew, true)
	elseif ctype == ChannelType.CHANNEL_CLAN then
		GetChatManager():AddMsg_Faction(roleid, roleShape, roleTitle, roleCamp, strName, strMsgNew, true)
	elseif ctype == ChannelType.CHANNEL_PROFESSION then
		GetChatManager():AddMsg_ProChannel(roleid, roleShape, roleTitle, roleCamp, strName, strMsgNew, true)
	elseif ctype == ChannelType.CHANNEL_WORLD then
		GetChatManager():AddMsg_World(roleid, roleShape, roleTitle, roleCamp, strName, strMsgNew)
	elseif ctype == ChannelType.CHANNEL_SYSTEM then
		if string.find(strMsgNew, "<") == nil then
			GetChatManager():AddMsg_SysChannel(strMsgNew, true, false)
		else
			GetChatManager():AddMsg_SysChannel(strMsgNew, true, true)
		end
	elseif ctype == ChannelType.CHANNEL_MESSAGE then
		GetChatManager():AddMsg_Message(strMsgNew)
	elseif ctype == ChannelType.CHANNEL_BUBBLE then
		GetChatManager():AddMsg_PoP(strMsgNew)
	elseif ctype == ChannelType.CHANNEL_SLIDE then
		GetChatManager():AddMsg_Roll(strMsgNew)
	elseif ctype == ChannelType.CHANNEL_TEAM_APPLY then
		GetChatManager():AddMsg_TeamApply(roleid, roleShape, roleTitle, roleCamp, strName, strMsgNew)
	end
end

function CChatManager:AddTipsMsg(msgid, npcbaseid, parameters, bCheckSame)
    if msgid == 0 then
        return
    end
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(msgid)
	if tip.id <=0 then
        LogWar("table CMessageTip can't find ID:" .. msgid)
		print("[WARNNING] table CMessageTip can't find ID:" .. msgid)
		return
	end

	local strmsg = ""

    local channels = StringBuilder.Split(tip.type, ",")

    local gameState = (gGetStateManager() and gGetStateManager():getGameState() or eGameStateNull)
	for i = 1, #channels do
        if tonumber(channels[i]) ~= fire.pb.talk.TipsMsgType.TIPS_POPMSG
          and (gameState == eGameStateLogin or gameState == eGameStateNull) then
            return
        end

		if parameters == nil or #parameters == 0 then
			strmsg = tip.msg
		else
			local total = #parameters

			local sb = require "utils.stringbuilder":new()

			for j = 1, total do
				-- 世界频道cd提示，因为有可能出现：还剩0秒才可发言 这种提示，所以提示的参数加1
				if tip.id == 140500 then
					sb:Set("parameter" .. j, parameters[j] + 1)
				else
					sb:Set("parameter" .. j, parameters[j])
				end

			end
			strmsg = sb:GetString(tip.msg)
            sb:delete()
		end

		local allid = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getAllID()

		local channelid = tonumber(channels[i])

		if tonumber(channels[i]) < 0 then
			channelid = -channelid
		end

		for j = 1, #allid do
			local colorConfig = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getRecorder(allid[j])

			local color = colorConfig.color
			local toReplace = colorConfig.notifylist[channelid - 1]
			if string.len(toReplace) > 1 then
				local outputstrings = { }
				local isDoubleColors = false
				if string.find(toReplace, ",") then
					local delimiters = ","
					outputstrings = StringBuilder.Split(toReplace, delimiters)
					isDoubleColors = true
				end

                local pos = string.find(strmsg, "c=\""..color) 

                    if pos == nil then
                        pos = string.find(strmsg, "c=\'"..color) 
                    end

                    if pos == nil then
                        pos = string.find(strmsg, "TextColor=\""..color)
                    end

                    if pos ~= nil then
                        if isDoubleColors then
                            if string.len(outputstrings[1]) == 8 then
                                strmsg = string.gsub(strmsg, "(c=['\"])"..color.."['\"]", "c=\""..outputstrings[1].."\" ob=\""..color.."\"")
                                strmsg = string.gsub(strmsg, "(TextColor=['\"])"..color.."['\"]", "TextColor=\""..outputstrings[1].."\" ob=\""..color.."\"")
                            end
                        else
                                strmsg = string.gsub(strmsg, "(c=['\"])"..color.."['\"]", "c=\""..toReplace.."\" ob=\""..color.."\"")
                                strmsg = string.gsub(strmsg, "(TextColor=['\"])"..color.."['\"]", "TextColor=\""..toReplace.."\" ob=\""..color.."\"")
                        end
                    end


            end
        end

		local strMsgNew = strmsg

		if channelid == fire.pb.talk.TipsMsgType.TIPS_POPMSG then
			GetCTipsManager():AddMessageTip(strMsgNew, true, true, bCheckSame)
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_NPCTALK then
			NpcDialog.getInstance().AddTipsMessageForCpp(0, npcbaseid, strMsgNew)
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_MSG_CHANNEL then
			if string.find(strMsgNew, "<T") == nil then
				GetChatManager():AddMsg_Message(strMsgNew, false)
			else
				GetChatManager():AddMsg_Message(strMsgNew, true)
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_SYSBOARD then
			require("logic.shijiebobaodlg").getInstanceAndShow()
			require("logic.shijiebobaodlg").addMsg(strMsgNew)
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_CLAN then
			if string.find(strMsgNew, "<T") == nil then
				local strFormatMsg = "<T t=\"" .. strMsgNew .. "\"></T>"
				GetChatManager():AddMsg_Faction(0, 0, 0, 0, "", strFormatMsg, tonumber(channels[i]) > 0);
			else
				GetChatManager():AddMsg_Faction(0, 0, 0, 0, "", strMsgNew, tonumber(channels[i]) > 0);
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_TEAM_CHANNEL then
			if string.find(strMsgNew, "<T") == nil then
				local strFormatMsg = "<T t=\"" .. strMsgNew .. "\"></T>"
				GetChatManager():AddMsg_Team(0, 0, 0, 0, "", strFormatMsg, tonumber(channels[i]) > 0);
			else
				GetChatManager():AddMsg_Team(0, 0, 0, 0, "", strMsgNew, tonumber(channels[i]) > 0);
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_PRO_CHANNEL then
			if string.find(strMsgNew, "<T") == nil then
				local strFormatMsg = "<T t=\"" .. strMsgNew .. "\"></T>"
				GetChatManager():AddMsg_ProChannel(0, 0, 0, 0, "", strFormatMsg, tonumber(channels[i]) > 0);
			else
				GetChatManager():AddMsg_ProChannel(0, 0, 0, 0, "", strMsgNew, tonumber(channels[i]) > 0);
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_WORLD then
			if string.find(strMsgNew, "<T") == nil then
				local strFormatMsg = "<T t=\"" .. strMsgNew .. "\"></T>"
				GetChatManager():AddMsg_WorldChannel(0, 0, 0, 0, "", strFormatMsg);
			else
				GetChatManager():AddMsg_WorldChannel(0, 0, 0, 0, "", strMsgNew);
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_CUR_CHANNEL then
			if string.find(strMsgNew, "<T") == nil then
				local strFormatMsg = "<T t=\"" .. strMsgNew .. "\"></T>"
				GetChatManager():AddMsg_CurChannel(0, 0, 0, 0, "", strFormatMsg);
			else
				GetChatManager():AddMsg_CurChannel(0, 0, 0, 0, "", strMsgNew);
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_SYS_CHANNEL then
			if string.find(strMsgNew, "<T") == nil then
				GetChatManager():AddMsg_SysChannel(strMsgNew, tonumber(channels[i]) > 0, false)
			else
				GetChatManager():AddMsg_SysChannel(strMsgNew, tonumber(channels[i]) > 0, true)
			end
		elseif channelid == fire.pb.talk.TipsMsgType.TIPS_CONFIRM then
			if msgid > 0 and string.len(strMsgNew) > 0 then
				gGetMessageManager():AddConfirmBox(eConfirmOK, strMsgNew,
				MessageManager.HandleDefaultCancelEvent, MessageManager,
				MessageManager.HandleDefaultCancelEvent, MessageManager)
			end
        elseif channelid == fire.pb.talk.TipsMsgType.TIPS_ROLE_CHANNEL then
            local dlg = require("logic.busytext.busytextdlg").getInstanceAndShow()
            if dlg then
                local numPao = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(295).value)
                for mm = 1, numPao do
                    dlg:addMsg(strMsgNew)
                end
                
                dlg:SetVisible(true)
            end
		end
	end
end

-- 新加，添加组队频道聊天内容----杨斌
function CChatManager:AddMsg_TeamApply(roleid, shapeid, roleTitle, roleCamp, strName, strMsg)

	local bCheckShied = true
	if roleid == 0 and roleTitle == 0 then
		bCheckShied = false
	end

	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_TEAM_APPLY
	record.roleid = roleid
	record.roleShapeId = shapeid
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true

	CChatOutputDialog.getInstance():AddChatRecord(record)

	local MsgParseString = strMsg

	local color = CChatOutputDialog.getInstance().m_pChatInputBox:getProperty("NormalTextColour")

	MsgParseString = string.gsub(MsgParseString, color, "FFFFFFFF")

	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local pBattler = GetBattleManager():FindBattlerCharacterByRoleID(roleid)
		if pBattler then
			pBattler = tolua.cast(pBattler, "SceneObject")
			pBattler:AddTalk(MsgParseString)
		end
	else
		local pObj = gGetScene():FindCharacterByID(roleid)
		if pObj then
			pObj:AddTalk(MsgParseString)
		end
	end
end

function CChatManager:AddMsg_CurChannel(roleid, shapeid, roleTitle, roleCamp, strName, strMsg)
	local bCheckShied = true
	if roleid == 0 and roleTitle == 0 then
		bCheckShied = false
	end

	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_CURRENT
	record.roleid = roleid
	record.roleShapeId = shapeid
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true

	CChatOutputDialog.getInstance():AddChatRecord(record)

	local MsgParseString = strMsg

	local color = CChatOutputDialog.getInstance().m_pChatInputBox:getProperty("NormalTextColour")

	MsgParseString = string.gsub(MsgParseString, color, "FFFFFFFF")

	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local pBattler = GetBattleManager():FindBattlerCharacterByRoleID(roleid)
		if pBattler then
			pBattler = tolua.cast(pBattler, "SceneObject")
			pBattler:AddTalk(MsgParseString)
		end
	else
		local pObj = gGetScene():FindCharacterByID(roleid)
		if pObj then
			pObj:AddTalk(MsgParseString)
		end
	end
end

function CChatManager:AddMsg_Team(roleid, roleShape, roleTitle, roleCamp, strName, strMsg, showInZhongHe)

	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_TEAM
	if not showInZhongHe then
		record.channel = -record.channel
	end
	record.roleid = roleid
	record.roleShapeId = roleShape
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true

	CChatOutputDialog.getInstance():AddChatRecord(record)

	if #(record.chatContent) > 0 and record.chatContent:sub(1,1) ~= "<" then
		return
	end

	local MsgParseString = strMsg

	local color = CChatOutputDialog.getInstance().m_pChatInputBox:getProperty("NormalTextColour")

	MsgParseString = string.gsub(MsgParseString, color, "FFFFFFFF")

	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local pBattler = GetBattleManager():FindBattlerCharacterByRoleID(roleid)
		if pBattler then
			pBattler = tolua.cast(pBattler, "SceneObject")
			pBattler:AddTalk(MsgParseString)
		end
	else
		local pObj = gGetScene():FindCharacterByID(roleid)
		if pObj then
			pObj:AddTalk(MsgParseString)
		end
	end
end

function CChatManager:AddMsg_WorldChannel(roleid, roleShape, roleTitle, roleCamp, strName, strMsg)
	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_WORLD
	record.roleid = roleid
	record.roleShapeId = roleShape
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true
	CChatOutputDialog.getInstance():AddChatRecord(record)
end

function CChatManager:AddMsg_ProChannel(roleid, roleShape, roleTitle, roleCamp, strName, strMsg, showInZhongHe)
	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_PROFESSION
	if not showInZhongHe then
		record.channel = -record.channel
	end
	record.roleid = roleid
	record.roleShapeId = roleShape
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true
	CChatOutputDialog.getInstance():AddChatRecord(record)
end

function CChatManager:AddMsg_Faction(roleid, roleShape, roleTitle, roleCamp, strName, strMsg, showInZhongHe)
	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_CLAN
	if not showInZhongHe then
		record.channel = -record.channel
	end
	record.roleid = roleid
	record.roleShapeId = roleShape
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true
	CChatOutputDialog.getInstance():AddChatRecord(record)
end

function CChatManager:AddMsg_World(roleid, roleShape, roleTitle, roleCamp, strName, strMsg)
	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_WORLD
	record.roleid = roleid
	record.roleShapeId = roleShape
	record.roleTitle = roleTitle
	record.roleCamp = roleCamp
	record.strName = strName
	record.chatContent = strMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = true
	CChatOutputDialog.getInstance():AddChatRecord(record)
end

function CChatManager:AddMsg_SysChannel(strMsg, showInZongHe, bIsUserDefine)
	local strFormatMsg = strMsg
	if bIsUserDefine == 0 or bIsUserDefine == false then
		strFormatMsg = "<T t=\""..strMsg.."\" c=\"FF693F00\"></T>"
	end
	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_SYSTEM
	if not showInZongHe then
		record.channel = -record.channel
	end
	record.roleid = 0
	record.roleShapeId = 0
	record.roleTitle = 0
	record.roleCamp = 0
	record.strName = ""
	record.chatContent = strFormatMsg
	record.recordID = CChatManager:GenerateUniqueChatRecordID()
	record.forceCheckShied = false
	CChatOutputDialog.getInstance():AddChatRecord(record)
end

function CChatManager:AddMsg_Message(strMsg, bIsUserDefine)
	if gGetStateManager():isGameState(eGameStateRunning) then
		if not gGetStateManager():isGameState(eGameStateBattleDemo) and
			not gGetStateManager():isGameState(eGameStateEditBattleAni) then

			local strFormatMsg = strMsg

			if bIsUserDefine == 0 or bIsUserDefine == false then
				strFormatMsg = "<T t=\"" .. strMsg .. "\" c=\"ffffffff\"></T>"
			end

			local record = stChatRecord.new()
			record.channel = ChannelType.CHANNEL_MESSAGE
			record.roleid = 0
			record.roleShapeId = 0
			record.roleTitle = 0
			record.roleCamp = 0
			record.strName = ""
			record.chatContent = strFormatMsg
			record.recordID = 0
			record.forceCheckShied = false
			CChatOutputDialog.getInstance():AddChatRecord(record)
		end
	end
end

function CChatManager.ReplaceColor(strmsg)
    local allid = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getAllID()

    for j = 1, #allid do
        local colorConfig = BeanConfigManager.getInstance():GetTableByName("chat.cchatcolorconfig"):getRecorder(allid[j])

			local color = colorConfig.color
			local toReplace = colorConfig.notifylist[0]
			if string.len(toReplace) > 1 then
				local outputstrings = { }
				local isDoubleColors = false
				if string.find(toReplace, ",") then
					local delimiters = ","
					outputstrings = StringBuilder.Split(toReplace, delimiters)
					isDoubleColors = true
				end

				if isDoubleColors then
					local pos = string.find(strmsg, color)

					if pos ~= nil and string.len(outputstrings[1]) == 8 then
						strmsg = string.gsub(strmsg, color, outputstrings[1])
					end

                else
                    strmsg = string.gsub(strmsg, color, toReplace)
                end

			end
		end
    return strmsg
end

function CChatManager:AddMsg_PoP(strMsg)
	GetCTipsManager():AddMessageTip(strMsg)
end

function CChatManager:AddMsg_Roll(strMsg)
	gGetGameUIManager():AddSystemBoard(strMsg)
end

function CChatManager:AddFamilyMsg(roleid, roleShape, roleTitle, roleCamp, strName, strMsg)
	local record = stChatRecord.new()
	record.channel = ChannelType.CHANNEL_FAMILY
	record.roleid = 0
	record.roleShapeId = 0
	record.roleTitle = 0
	record.roleCamp = 0
	record.strName = ""
	record.chatContent = strFormatMsg
	record.recordID = 0
	record.forceCheckShied = true
	CChatOutputDialog.getInstance():AddChatRecord(record)
end

function CChatManager:AddObjTips(roleID, ctype, key, shopID, counterID, tipsMsg)
	local Tips = { }

	Tips.roleID = roleID
	Tips.ctype = ctype
	Tips.key = key
	Tips.shopID = shopID
	Tips.counterID = counterID
	Tips.tipsMsg = tipsMsg

	if #m_vecObjTips > 20 then
		table.remove(m_vecObjTips, 1)
	end

	local add = true

	for i = 1, #m_vecObjTips do
		if m_vecObjTips[i].roleID == roleID and
			m_vecObjTips[i].ctype == ctype and
			m_vecObjTips[i].key == key and
			m_vecObjTips[i].shopID == shopID and
			m_vecObjTips[i].counterID == counterID then
			add = false
		end
	end

	if add then
		table.insert(m_vecObjTips, Tips)
	end

end

function CChatManager:GetTipsOctes(roleID, ctype, key, shopID, counterID)
	for i = 1, #m_vecObjTips do
		if m_vecObjTips[i].roleID == roleID and 
			m_vecObjTips[i].ctype == ctype and 
			m_vecObjTips[i].key == key and
			m_vecObjTips[i].shopID == shopID and
			m_vecObjTips[i].counterID == counterID then
			return m_vecObjTips[i].tipsMsg
		end
	end
	return nil
end

function CChatManager:ShowLinkTips(roleID, stype, key, baseID, bind, pTipsOctes)
	if pTipsOctes == nil then
		return
	end
	local DI = DisplayInfo:new()

	local _os_ = FireNet.Marshal.OctetsStream(pTipsOctes)

	if stype ==DI.DISPLAY_ITEM or stype ==DI.DISPLAY_ROLL_ITEM then
		if CChatOutputDialog.getInstanceNotCreate() then
            local firsttype = 0
            local secondtype = 0
			local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(m_RequestChatItemTipsItemBaseID)
            if attr then
			    firsttype = bit.band(attr.itemtypeid, 127)
			    secondtype = bit.band(bit.brshift(attr.itemtypeid, 4), 127)
            end

			local pItem = RoleItem:new()
			local itemData = require("protodef.rpcgen.fire.pb.item"):new()
			itemData.id = m_RequestChatItemTipsItemBaseID
			itemData.key = key
			itemData.number = 0
			itemData.flags = bind
			local bSucceed = pItem:SetItemData(fire.pb.item.BagTypes.BAG, itemData)
            if bSucceed then
			    if pTipsOctes:size() > 0 and pItem:GetObject() ~= nil then
				    pItem:GetObject():MakeTips(_os_)
			    end

			    require("logic.tips.commontipdlg").LuaShowItemTipFromChat(pItem, pItem:GetLocation().tableType, pItem:GetThisID())
            end
		end
	elseif stype ==DI.DISPLAY_TASK then
		if baseID == 2 then
			local quest = stSpecialQuest:new()

			quest.questid = _os_:unmarshal_int32()
			quest.questtype = _os_:unmarshal_int32()
			quest.queststate = _os_:unmarshal_int32()
			quest.round = _os_:unmarshal_int32()
			quest.sumnum = _os_:unmarshal_int32()
			quest.dstmapid = _os_:unmarshal_int32()
			quest.dstnpckey = _os_:unmarshal_int64()
			quest.dstnpcid = _os_:unmarshal_int32()
			quest.dstitemid = _os_:unmarshal_int32()
			quest.dstx = _os_:unmarshal_int32()
			quest.dsty = _os_:unmarshal_int32()
			quest.dstitemnum = _os_:unmarshal_int32()
			quest.dstitemid2 = _os_:unmarshal_int32()
			quest.dstitemidnum2 = _os_:unmarshal_int32()
			quest.validtime = _os_:unmarshal_int64()
			quest.islogin = _os_:unmarshal_int32()

            local nRoleLevel = _os_:unmarshal_int32()
            local nJobId = _os_:unmarshal_int32()

			quest.name = GetNewSpecialQuestName(quest.questtype)

			require("logic.task.showtaskdetail").ShowTask(quest, key, baseID,nRoleLevel,nJobId)
		elseif baseID == 1 then
            local nRoleLevel=0
            local nJobId =0

			require("logic.task.showtaskdetail").ShowTask(0, key, baseID,nRoleLevel,nJobId,roleID)
        elseif baseID == 3 then --anyemaxituan
            require("logic.task.taskmanager").getInstance():showAnyeInfoForClickChat(roleID, stype, key, baseID, bind, pTipsOctes)
		end
	elseif stype ==DI.DISPLAY_PET then
		require("logic.pet.petdetaildlg").getInstanceAndShow()
		require("logic.pet.petdetaildlg").ShowPetDlg(baseID, key, roleID)

		local PetInfo = require "protodef.fire.pb.pet.cgetpetinfo".Create()
		PetInfo.roleid = roleID
		PetInfo.petkey = key
		LuaProtocolManager.getInstance():send(PetInfo)
	end

	DI = nil
end

function CChatManager:ShowRollItemTips(baseID, melonID)
	local pTipsOctes = nil

    local firsttype = 0
    local secondtype = 0
	local attr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(m_RequestChatItemTipsItemBaseID)
    if attr then
	    firsttype = bit.band(attr.itemtypeid, 127)
	    secondtype = bit.band(bit.brshift(attr.itemtypeid, 4), 127)
    end

	if firsttype == eItemType_EQUIP then
		for i = 1, #m_vecObjTips do
			if m_vecObjTips[i].shopID == melonID then
				pTipsOctes = m_vecObjTips[i].tipsMsg
			end
		end
	else
		-- 如果是基础物品直接展现物品tips
		local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
		local posX = mousePos.x - 77
		local posY = mousePos.y;
		require "logic.tips.commontipdlg".LuaShowItemTipWithBaseId(baseID, posX, posY)
		return
	end

	if not pTipsOctes then
		return
	end

	local data = FireNet.Marshal.OctetsStream(pTipsOctes)

	local pItem = RoleItem:new()
    local itemData = require("protodef.rpcgen.fire.pb.item"):new()
	itemData.id = baseID
	itemData.key = 0
	itemData.number = 0
	itemData.flags = 0
	itemData.loseeffecttime = 0
    local bSucceed = pItem:SetItemData(fire.pb.item.BagTypes.BAG, itemData)
    if bSucceed then
	    -- 杨斌，从聊天栏点击装备，设置装备的背包类型为bag
	    if pTipsOctes:size() > 0 and pItem:GetObject() ~= nil then
		    pItem:GetObject():MakeTips(data)
	    end

	    require("logic.tips.commontipdlg").LuaShowItemTipFromChat(pItem, pItem:GetLocation().tableType, pItem:GetThisID())
    end
end

function CChatManager:AddToChatHistory(strMsg)
	if string.len(strMsg) > 0 and CChatOutputDialog.getInstanceNotCreate() then
		CChatOutputDialog.getInstanceNotCreate():AddChatHistory(strMsg)
	end
end

function CChatManager:startSendChatCdTime(nChatId)
	local fCdTime = self:getChannelCdTime(nChatId)

	for k,v in pairs(m_mapSendChatCdTimeDt) do
		if k == nChatId then
			m_mapSendChatCdTimeDt[k] = fCdTime
			break
		end
	end
end

function CChatManager:getSendChatInCdTime(nChatId)
	for k,v in pairs(m_mapSendChatCdTimeDt) do
		if k == nChatId then
			return m_mapSendChatCdTimeDt[k]
		end
	end
	return 0
end

function CChatManager:getChannelCdTime(nChatId)
	for k,v in pairs(m_mapSendChatCdTime) do
		if k == nChatId then
			return m_mapSendChatCdTime[k]
		end
	end
	return 0
end

function CChatManager:update(deltaTime)
	for k,v in pairs(m_mapSendChatCdTimeDt) do
		m_mapSendChatCdTimeDt[k] = m_mapSendChatCdTimeDt[k] - deltaTime/1000

		if m_mapSendChatCdTimeDt[k] < 0 then
			m_mapSendChatCdTimeDt[k] = 0
		end
	end

	GetChatManager():PopMsg()
end

function CChatManager:PopMsg()
	if #CChatManager.m_vecChatMsg == 0 then
		return
	end

	local num = #CChatManager.m_vecChatMsg
	for i = 1, #CChatManager.m_vecChatMsg do

		CChatManager.AddMsg(
		CChatManager.m_vecChatMsg[i][1], 
		CChatManager.m_vecChatMsg[i][2], 
		CChatManager.m_vecChatMsg[i][3], 
		CChatManager.m_vecChatMsg[i][4], 
		CChatManager.m_vecChatMsg[i][5], 
		CChatManager.m_vecChatMsg[i][6], 
		CChatManager.m_vecChatMsg[i][7])
	end

	for i = 1, num do
		table.remove(CChatManager.m_vecChatMsg, 1)
	end
end

function CChatManager:showPaoPaoForVoice(ctype, roleid, strVoice)

	if ctype == ChannelType.CHANNEL_PROFESSION or
		ctype == ChannelType.CHANNEL_CLAN or
		ctype == ChannelType.CHANNEL_TEAM then

        local MsgParseString = strVoice
        local nIndex = string.find(strVoice, "<T")
        if nIndex ~= 1 then
		    local parseText = "<T t=\""..strVoice.."\" c=\"FFFFFFFF\"></T>"
		    MsgParseString = parseText
        end

		if GetBattleManager() and GetBattleManager():IsInBattle() then
			local pBattler = GetBattleManager():FindBattlerCharacterByRoleID(roleid)
			if pBattler then
				pBattler = tolua.cast(pBattler, "SceneObject")
				pBattler:AddTalk(MsgParseString)
			end
		else
			local pObj = gGetScene():FindCharacterByID(roleid)
			if pObj then
				pObj:AddTalk(MsgParseString)
			end
		end
	end
end

function CChatManager:showPaoPaoForVoiceUuid(uuid, text)
	local ccMgr = GetChatCellManager()
	local record, channel = ccMgr:GetChatInfoFormUuid(uuid)
    if record then
        print("call show pao pao for voice!\n")
        self:showPaoPaoForVoice(channel,record.m_iRoleId,text)
    else
        print("get record failed!\n")
    end
end

-- 是否允许自动播放玩家语音
local bAllowAutoPlay = true
function CChatManager.SetAllowAutoPlay(b)
    bAllowAutoPlay = b
end

function CChatManager:isCouldPlayVoice(chanelID)
	local cPlay = false
	if chanelID == ChannelType.CHANNEL_CLAN then
		-- 公会
		cPlay = CChatOutputDialog.getInstanceNotCreate().m_AutoVoicePlayFilter[1]

	elseif chanelID == ChannelType.CHANNEL_WORLD then
		-- 世界
		cPlay = CChatOutputDialog.getInstanceNotCreate().m_AutoVoicePlayFilter[2]

	elseif chanelID == ChannelType.CHANNEL_TEAM then
		-- 队伍
		cPlay = CChatOutputDialog.getInstanceNotCreate().m_AutoVoicePlayFilter[3]

	elseif chanelID == ChannelType.CHANNEL_PROFESSION then
		-- 职业
		cPlay = CChatOutputDialog.getInstanceNotCreate().m_AutoVoicePlayFilter[4]

	end
	return cPlay and bAllowAutoPlay
end

function CChatManager:GetTipsLinkTargetBox()
	local pBox = self:GetEmotionTargetBox()
	if pBox == nil then
		return CChatOutputDialog.getInstanceNotCreate().m_pChatInputBox
	end
	return pBox;
end

function CChatManager:GetEmotionTargetBox()
	local pTarget = CEGUI.System:getSingleton():getKeyboardTargetWindow()
	if pTarget then
		if pTarget:getType() == "TaharezLook/RichEditbox" then
			local pRich = CEGUI.toRichEditbox(pTarget)
			if pRich:isSupportEmotion() then
				return pRich
			end
		end
	else
        if require "logic.friend.frienddialog".getInstanceNotCreate() then
            return require "logic.friend.frienddialog".getInstanceNotCreate().m_InputBox
        else
		    return CChatOutputDialog.getInstanceNotCreate().m_pChatInputBox
        end
	end

	return nil
end

function CChatManager:AddObjectTipsLinkToCurInputBox(name, roleid, ctype, key, baseid, shopID, counterID, isMyObject, bind, loseeffecttime, nameColor,richEditBox)
	local pRichBox = richEditBox --GetChatManager():GetEmotionTargetBox()

	if pRichBox then
		--防止字符过长崩溃的问题-----杨斌
		if pRichBox:GetCharCount() + string.len(name) > pRichBox:getMaxTextLength() then
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449))
			return false
		end

		local curCurTipsLinkCount = pRichBox:GetTipsLinkCount()
		if curCurTipsLinkCount + 1 > TIPS_LINK_COUNT_MAX then
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1528))
			return false
		end

		local strName = "[" .. name .. "]"

		local tmp = pRichBox:InsertTipsLinkInCarat(CEGUI.String(strName), CEGUI.String(""), roleid, ctype, CEGUI.String(tostring(key)), baseid, shopID, counterID, bind, loseeffecttime, nameColor)
		tmp:setTextHorizontalCenter(false)

		pRichBox:activate()
	end

	return true
end

function CChatManager:InitShiedTexts()
	m_vecShiedTexts = { }

	local idVector = BeanConfigManager.getInstance():GetTableByName("chat.cbanwords"):getAllID()

	for i = 1, #idVector do
		local oneText = BeanConfigManager.getInstance():GetTableByName("chat.cbanwords"):getRecorder(idVector[i]).BanWords
		--self:EraseSpaceOfString(oneText)

		table.insert(m_vecShiedTexts, oneText)
	end
end

function CChatManager:ShiedText(inText)

	if string.len(inText) > 0 then
		for i = 1, #m_vecShiedTexts do
			local shiedUnit = m_vecShiedTexts[i]

			if string.len(shiedUnit) > 0 then
				local pos = string.find(inText, shiedUnit)
				if pos ~= nil then
					local tab = { }
					for uchar in string.gfind(shiedUnit, "[%z\1-\127\194-\244][\128-\191]*") do
						tab[#tab + 1] = uchar
					end

					local star = ""
					for i = 1, #tab do
						star = star .. "*"
					end

					inText = string.gsub(inText, shiedUnit, star)

					return inText
				end
			end
		end
	end

	return ""
end

function CChatManager.ShiedText_(inText)
	local ret = GetChatManager():ShiedText(inText)
	return ret
end

function CChatManager:EraseSpaceOfString(strText)
	string.gsub(strText, tabIdx, "	", "")
	string.gsub(strText, tabIdx, " ", "")
--	local tabIdx = string.find(strText, "	")

--	while tabIdx ~= nil do
--		string.gsub(strText, tabIdx, "	", "")
--		tabIdx = strText.find_first_of(L"	");
--	end

--	size_t idxFirst = strText.find_first_not_of(L" ");
--	if (idxFirst != std::wstring::npos)
--	{
--		strText = strText.substr(idxFirst, std::wstring::npos);
--	}


--	size_t idxEnd = strText.find_last_not_of(L" ");
--	if (idxEnd != std::wstring::npos)
--	{
--		strText = strText.substr(0, idxEnd + 1);
--	}
end


function CChatManager:inputCallBack_emotion(insertDlg, nType, nKey, richEditBox)
	local richText = richEditBox
--	if richText then
--		local id = nKey

--		if richText:GetEmotionNum() >= EMOTION_NUM_MAX and id ~= -1 then
--			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449))
--		else
--			richText:InserEmotionInCarat(100 + id)
--		end
--	end

	 if richText then
	 	local id = nKey
	 	-- wndArg.window:getID()
	 	-- 重新着色
	 	local text = "<T t=\"#" ..(100 + id) .. "\"" .. " c=\"" .. CEGUI.PropertyHelper:colourToString(richText:GetColourRect().top_left) .. "\"></T>"

	 	-- 防止字符过长崩溃的问题-----杨斌
	 	local lb = richText:GetCharCount() + richText:GetEmotionNum()
	 	if lb > richText:getMaxTextLength() then
	 		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449).c_str());
	 	else
	 		richText:AppendParseText(CEGUI.String(text))
	 		richText:Refresh()
	 		richText:SetCaratEnd()
	 	end
	 end
end

function CChatManager:inputCallBack_normalChat(insertDlg,nType,nKey,richEditBox)
    
		local key = nKey 
		local winMgr = CEGUI.WindowManager:getSingleton()
		local richButton = CEGUI.toRichEditbox(winMgr:getWindow(key .. "insetchatcell/main"))
		local parseText = richButton:GetPureText()
		local richText = richEditBox --GetChatManager():GetEmotionTargetBox()
		if richText then
			-- 重新着色
			local text = "<T t=\"" .. parseText .. "\"" .. " c=\"" .. CEGUI.PropertyHelper:colourToString(richText:GetColourRect().top_left) .. "\"></T>"

			-- 防止字符过长崩溃的问题-----杨斌
			local la = richButton:GetCharCount() + richButton:GetEmotionNum()
			local lb = richText:GetCharCount() + richText:GetEmotionNum()
			if la + lb > richText:getMaxTextLength() then
				GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449).c_str());
			else
				richText:AppendParseText(CEGUI.String(text))
				richText:Refresh()
				richText:SetCaratEnd()
			end

			insertDlg:HandleDialogXiaLa(e)
		end
	
end
function CChatManager:inputCallBack_sell(insertDlg,nType,nKey,richEditBox)
    --每次点击一个物品发送时，都把存储的物品链接表清空，为了防止同名物品导致的发送物品属性错误
	--（因为在processchatlinks方法里，只判断名字，不判断物品key），暂时这么写。
	--啥时候需要发送多个物品的时候在把这个删除。
	m_TipsLinkVec = {}

    local idx = nKey 
    local goods = insertDlg.stallGoods[idx]
    if not goods then
        return
    end

    if not GetChatManager() then
        return
    end

    local richBox = richEditBox --GetChatManager():GetEmotionTargetBox()
    -- 防止字符过长崩溃的问题-----杨斌
	if richBox:GetCharCount() + string.len(goods.name) > richBox:getMaxTextLength() then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449)) --你输入的字数太多
		return false
	end

    local str = richBox:GenerateParseText()
    local goodsConf = ShopManager:getGoodsConfByItemID(goods.itemid)
    local itemtype = (goodsConf and goodsConf.itemtype or 1)
    local arg = "t=1,id=" .. goods.id .. ",type=" .. itemtype
    local text = "<C t=\"[" .. goods.name .. "]\" arg=\"" .. arg .. "\" c=\"" .. goods.namecolour .. "\"/>"
--    local n = 0
--    str, n = string.gsub(str, "<C[^<>]+arg=\"t=1[^<>]+/>", text)
--    if n == 0 then
--        str = str .. text
--    end

	local showName = goods.name
	local add2Vec = true
	for k, v in ipairs(m_TipsLinkVec) do
		if v.name == showName and v.key == idx then
			add2Vec = false
			break
		end
	end

	if add2Vec then
		local s_Links = { }
		s_Links.name = showName
		s_Links.link = text
		s_Links.key = idx

		table.insert(m_TipsLinkVec, s_Links)
	end

	local tmp = "<T t=\"[" .. showName .. "]\"" .. " c=\"" .. richBox:getProperty("NormalTextColour") .. "\"></T>"
	richBox:Clear()
	richBox:AppendParseText(CEGUI.String(tmp))
	richBox:Refresh()

    insertDlg:HandleDialogXiaLa(e)
end
function CChatManager:inputCallBack_history(insertDlg, nType, nKey, richEditBox)

	local key = nKey
	local winMgr = CEGUI.WindowManager:getSingleton();
	local pBox = CEGUI.toRichEditbox(winMgr:getWindow(key .. "insetchatcell/main"))
	local parseText = pBox:GenerateParseText()

	if pBox:isUserStringDefined("name") and pBox:isUserStringDefined("link") and pBox:isUserStringDefined("key") then
		local name = pBox:getUserString("name")
		local link = pBox:getUserString("link")
		local key = pBox:getUserString("key")
		if name and link then
			local linkdata = { }
			linkdata.name = name
			linkdata.link = link
			linkdata.key = key
			table.insert(m_TipsLinkVec, linkdata)
		end
	end

	local richText = richEditBox
	-- GetChatManager():GetEmotionTargetBox()
	if richText then
		-- 防止字符过长崩溃的问题-----杨斌
		local la = pBox:GetCharCount() + pBox:GetEmotionNum()
		local lb = richText:GetCharCount() + richText:GetEmotionNum()
		if la + lb > CHAT_INPUT_CHAR_COUNT_MAX then
			GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449));
		else
			richText:AppendParseText(CEGUI.String(parseText))
			richText:Refresh()
			richText:SetCaratEnd()
		end

		insertDlg:HandleDialogXiaLa(e)
	end
end

function CChatManager:inputCallBack_item(insertDlg, nType, nKey, richEditBox)
    --每次点击一个物品发送时，都把存储的物品链接表清空，为了防止同名物品导致的发送物品属性错误
	--（因为在processchatlinks方法里，只判断名字，不判断物品key），暂时这么写。
	--啥时候需要发送多个物品的时候在把这个删除。
	m_TipsLinkVec = {}

	local key = nKey
	-- wndArg.window:getID()
	if key <= 0 then
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:GetBagItem(key)
	if not pItem then
		return
	end

	local strName = pItem:GetName()
	local roleID = gGetDataManager():GetMainCharacterID()
	local baseID = pItem:GetBaseObject().id
	if not GetChatManager() then
		return
	end

	local tipsdlg = require("logic.tips.commontipdlg").getInstanceNotCreate()
	if tipsdlg then
		tipsdlg:GetWindow():moveToFront()
	end
	-- 请求物品tips
	GetChatManager():HandleTipsLinkClick(strName, roleID, 1, key, baseID, 0, 1, CEGUI.PropertyHelper:stringToColour(color), 0, 0)

	local richText = richEditBox

	local color = pItem:GetNameColour()
	if pItem:GetBaseObject().nquality == 1 then
		color = "ff50321a"
	end

	local str = richText:GenerateParseText()

	if richText:GetCharCount() + string.len(strName) / 3 + 2 >= CHAT_INPUT_CHAR_COUNT_MAX then
		local tips = MHSD_UTILS.get_resstring(1449)
		GetCTipsManager():AddMessageTip(tips)
		return
	end

	local text =
	"<P t=\"[" .. strName ..
	"]\" roleid=\"" .. roleID ..
	"\" type=\"" .. tonumber(1) ..
	"\" key=\"" .. key ..
	"\" baseid=\"" .. baseID ..
	"\" shopid=\"" .. tonumber(0) ..
	"\" counter=\"" .. tonumber(1) ..
	"\" bind=\"" .. tonumber(0) ..
	"\" loseefftime=\"" .. tonumber(0) ..
	"\" TextColor=\"" .. color .. "\"></P>"

	local showName = strName
	local add2Vec = true
	for k, v in ipairs(m_TipsLinkVec) do
		if v.name == showName and v.key == key then
			add2Vec = false
			break
		end
	end

	if add2Vec then
		local s_Links = { }
		s_Links.name = showName
		s_Links.key = key
		s_Links.link = text

		table.insert(m_TipsLinkVec, s_Links)
	end

	local tmp = "<T t=\"[" .. showName .. "]\"" .. " c=\"" .. richText:getProperty("NormalTextColour") .. "\"></T>"
	richText:Clear()
	richText:AppendParseText(CEGUI.String(tmp))
	richText:Refresh()
end

function CChatManager:inputCallBack_pet(insertDlg, nType, nKey, richEditBox)

    --每次点击一个物品发送时，都把存储的物品链接表清空，为了防止同名物品导致的发送物品属性错误
	--（因为在processchatlinks方法里，只判断名字，不判断物品key），暂时这么写。
	--啥时候需要发送多个物品的时候在把这个删除。
	m_TipsLinkVec = {}

	local DI = DisplayInfo:new()
	local id = nKey
	-- wndArg.window:getID()
	if id <= 0 then
		return
	end
	local petData = MainPetDataManager.getInstance():FindMyPetByID(id)
	if petData then
		local tbl = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
		if tbl then
			local roleID = gGetDataManager():GetMainCharacterID()
			-- local nameColour = CEGUI.PropertyHelper:stringToColour(tbl.colour)
			if GetChatManager() then
				local richText = richEditBox
				-- GetChatManager():GetEmotionTargetBox()
				if richText:GetCharCount() + string.len(tbl.name) / 3 + 2 >= CHAT_INPUT_CHAR_COUNT_MAX then
					local tips = MHSD_UTILS.get_resstring(1449)
					GetCTipsManager():AddMessageTip(tips)
					return
				end
				local str = richText:GenerateParseText()
				local text =
				"<P t=\"[" .. tbl.name ..
				"]\" roleid=\"" .. roleID ..
				"\" type=\"" .. DI.DISPLAY_PET ..
				"\" key=\"" .. id ..
				"\" baseid=\"" .. petData.baseid ..
				"\" shopid=\"" .. 0 ..
				"\" counter=\"" .. 1 ..
				"\" bind=\"" .. 0 ..
				"\" loseefftime=\"" .. 0 ..
				"\" TextColor=\"" .. tbl.colour .. "\"></P>"

				local showName = tbl.name
				local add2Vec = true
				for k, v in ipairs(m_TipsLinkVec) do
					if v.name == showName and v.key == id then
						add2Vec = false
						break
					end
				end

				if add2Vec then
					local s_Links = { }
					s_Links.name = showName
					s_Links.link = text
					s_Links.key = id

					table.insert(m_TipsLinkVec, s_Links)
				end
				local tmp = "<T t=\"[" .. showName .. "]\"" .. " c=\"" .. richText:getProperty("NormalTextColour") .. "\"></T>"
				richText:Clear()
				richText:AppendParseText(CEGUI.String(tmp))
				richText:Refresh()

			end
		end
	end

	insertDlg:HandleDialogXiaLa(e)
	DI = nil
end

function CChatManager:inputCallBack_task(insertDlg,nType,nKey,richEditBox)

	local DI = DisplayInfo:new()
	local key = nKey 
	if key <= 0 then
        return
    end
	local quest = GetTaskManager():GetSpecialQuest(key)
	local roleID = gGetDataManager():GetMainCharacterID()
	local baseID = 1
	local strName = nil
	if quest then
			strName = quest.name
			baseID = 2
	else
			local missionInfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(key)
			strName = missionInfo.MissionName
	end

    local ChatContent = ""
    if richEditBox == CChatOutputDialog.getInstanceNotCreate().m_pChatInputBox then
			ChatContent = richEditBox:GenerateParseText(false)
			richEditBox:Clear()
    end

	local result = false
	if GetChatManager() and strName then
			local tmp = 1
			if baseID == 2 then
				tmp = quest.questtype
			end
			result = GetChatManager():AddObjectTipsLinkToCurInputBox(strName, roleID, DI.DISPLAY_TASK, key, baseID, 0, tmp, true, 0, 0, CEGUI.PropertyHelper:stringToColour("ff50321a"),richEditBox)
	end

    -- 直接发送链接------杨斌
	if richEditBox == CChatOutputDialog.getInstanceNotCreate().m_pChatInputBox and result then
        local richText = CChatOutputDialog.getInstanceNotCreate().m_pChatInputBox
		if richText then
					local showinfos = { }
					local ChatText = richText:GenerateParseText(false)
					local PureString = richText:GetPureText()

					ADD_CHAT_TO_HISTORY = roleID

					CChatOutputDialog.getInstanceNotCreate():SendChatMsgToServer(ChatText, showinfos, PureString, 0)

					richText:Clear()
					richText:AppendParseText(CEGUI.String(ChatContent))
					richText:Refresh()
		end
	end
	insertDlg:HandleDialogXiaLa(e)
	DI = nil
end

function CChatManager:inputCallBack_task_space(insertDlg, nType, nKey, richEditBox)

	--每次点击一个物品发送时，都把存储的物品链接表清空，为了防止同名物品导致的发送物品属性错误
	--（因为在processchatlinks方法里，只判断名字，不判断物品key），暂时这么写。
	--啥时候需要发送多个物品的时候在把这个删除。
	m_TipsLinkVec = {}

	local DI = DisplayInfo:new()
	local key = nKey
	if key <= 0 then
		return
	end
	local quest = GetTaskManager():GetSpecialQuest(key)
	local roleID = gGetDataManager():GetMainCharacterID()
	local baseID = 1
	local strName = nil
	if quest then
		strName = quest.name
		baseID = 2
	else
		local missionInfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(key)
		strName = missionInfo.MissionName
	end
	local tmp = 1
	if GetChatManager() and strName then
		if baseID == 2 then
			tmp = quest.questtype
		end
	end

	local str = richEditBox:GenerateParseText(false)

	local roleid = roleID
	local ntype = DI.DISPLAY_TASK
	-- local key =
	local baseid = baseID
	local shopid = 0
	local counter = tmp
	local bind = 0
	local loseeffecttime = 0

	local strTaskContent = "[" .. strName .. "]"
	strTaskContent = "<P t=\"" .. strTaskContent .. "\" "
	strTaskContent = strTaskContent .. "roleid=\"" .. tostring(roleid) .. "\" "
	strTaskContent = strTaskContent .. "type=\"" .. tostring(ntype) .. "\" "
	strTaskContent = strTaskContent .. "key=\"" .. tostring(key) .. "\" "
	strTaskContent = strTaskContent .. "baseid=\"" .. tostring(baseid) .. "\" "

	strTaskContent = strTaskContent .. "shopid=\"" .. tostring(shopid) .. "\" "
	strTaskContent = strTaskContent .. "counter=\"" .. tostring(counter) .. "\" "
	strTaskContent = strTaskContent .. "bind=\"" .. tostring(bind) .. "\" "
	-- bind = nCurAnyeTimes
	strTaskContent = strTaskContent .. "loseefftime=\"" .. tostring(loseeffecttime) .. "\" "
	-- strTaskContent = strTaskContent.."TaskType=\"".."anye".."\" "
	strTaskContent = strTaskContent .. "TextColor=\"" .. "ff50321a" .. "\" "
	-- ff00ff00
	strTaskContent = strTaskContent .. "/>"

	--[[
    local n = 0
    str, n = string.gsub(str, "<P[^<>]+></P>", strTaskContent)
    if n == 0 then
		str = str .. strTaskContent
    end
    --]]

	-- local strTemp = "["..strName.."]"

	local strTemp = str .. "<T t=\"[" .. strName .. "]\"" .. " c=\"" .. richEditBox:getProperty("NormalTextColour") .. "\"></T>"


	richEditBox:Clear()
	richEditBox:AppendParseText(CEGUI.String(strTemp))
	richEditBox:Refresh()


	local showName = strName
	local add2Vec = true
	for k, v in ipairs(m_TipsLinkVec) do
		if v.name == showName then
			add2Vec = false
			break
		end
	end

	if add2Vec then
		local s_Links = { }
		s_Links.name = showName
		s_Links.link = strTaskContent
		s_Links.key = -1
		table.insert(m_TipsLinkVec, s_Links)
	end


	insertDlg:HandleDialogXiaLa(e)
	DI = nil
end

function CChatManager:getTempData()
    return m_TipsLinkVec
end

function CChatManager:clearTempData()
     m_TipsLinkVec = {}
end


function CChatManager:inputCallBack(insertDlg,nType,nKey)
    local richEditBox = GetChatManager():GetEmotionTargetBox()
    local InsertDlg = require("logic.chat.insertdlg")
    if InsertDlg.eFunType.emotion == nType then
        self:inputCallBack_emotion(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.normalChat == nType then
        self:inputCallBack_normalChat(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.sell == nType then
        self:inputCallBack_sell(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.history == nType then
        self:inputCallBack_history(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.item == nType then
        self:inputCallBack_item(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.pet == nType then
        self:inputCallBack_pet(insertDlg,nType,nKey,richEditBox)
    elseif InsertDlg.eFunType.task == nType then
        self:inputCallBack_task(insertDlg,nType,nKey,richEditBox)
    end
end

function CChatManager:ProcessChatLinks(pureText, inputbox)
	local Text = pureText:gsub("\"", "&quot;")
	local strCorrectText = string.gsub(Text,"-","_")

	--local key = ChatText:match('lk="(%d+)"')

	local ret = ""
	local tmpVec = { }
	local pos = nil
	local color = CEGUI.PropertyHelper:colourToString(inputbox:GetColourRect().top_left)
	local link = ""

	for k, v in ipairs(m_TipsLinkVec) do
		local strName = v.name
        strName = string.gsub(strName,"-","_")
		pos = strCorrectText:find("%[" .. strName .. "%]")

		if pos then
			local len1 = string.len("%[" .. v.name .. "%]")
			local len2 = string.len(Text)

			tmpVec[1] = string.sub(Text, 1, pos - 1)
			tmpVec[2] = string.sub(Text, pos - 2 + len1, len2)

			link = v.link

			CChatOutputDialog.getInstance():SetLinkForHistory(v.name, v.link, v.key)
			break
		end
	end

	--m_TipsLinkVec = { }

	if not pos then
		tmpVec[1] = Text
	end

	for k, v in ipairs(tmpVec) do
		local tmpText = v
		if k == 2 then
			ret = ret .. link
		end

		local subPos1 = tmpText:find("#%d%d%d")

		if not subPos1 then
			ret = ret .. "<T t=\"" .. tmpText .. "\" c=\"" .. color .. "\"></T>"
		else
			while subPos1 do
				local sub1 = tmpText:sub(1, subPos1 - 1)
				local sub2 = tmpText:sub(subPos1 + 1, subPos1 + 3)

				if sub1 ~= "" then
					ret = ret .. "<T t=\"" .. sub1 .. "\" c=\"" .. color .. "\"></T>" .. "<E e=\"" .. sub2 .. "\"></E>"
				else
					ret = ret .. "<E e=\"" .. sub2 .. "\"></E>"
				end

				tmpText = tmpText:sub(subPos1 + 4, tmpText:len())

				subPos1 = tmpText:find("#%d%d%d")
				if not subPos1 then
					ret = ret .. "<T t=\"" .. tmpText .. "\" c=\"" .. color .. "\"></T>"
				end
			end
		end

	end

	return ret
end

function CChatManager:ClearChatLinks()
	m_TipsLinkVec = { }
end

---------------------------------------C++用--begin--------------------------------------------
function CChatManager.AddMsg_Message_(strMsg)
	if string.find(strMsg, "<T") == nil then
		GetChatManager():AddMsg_Message(strMsg, false)
	else
		GetChatManager():AddMsg_Message(strMsg, true)
	end
end

function CChatManager.AddMsg_SysChannel_(strMsg)
	if string.find(strMsg, "<T") == nil then
		GetChatManager():AddMsg_SysChannel(strMsg, true, false)
	else
		GetChatManager():AddMsg_SysChannel(strMsg, true, true)
	end
end

function CChatManager.HandleTipsLinkClick_(name, roleID, ctype, key, baseid, shopID, counterID, nameColor, bind, loseeffecttime)
	GetChatManager():HandleTipsLinkClick(name, roleID, ctype, key, baseid, shopID, counterID, nameColor, bind, loseeffecttime)
end

function CChatManager.AddTipsMsg_(msgid, npcbaseid, parameters, bCheckSame)
	if bCheckSame == 0 then
		GetChatManager():AddTipsMsg(msgid, npcbaseid, parameters, false)
	else
		GetChatManager():AddTipsMsg(msgid, npcbaseid, parameters, true)
	end
end

function CChatManager.showPaoPaoForVoice_(ctype, roleid, strVoice)
	GetChatManager():showPaoPaoForVoice(ctype, roleid, strVoice)
end

function CChatManager.showPaoPaoForVoiceUuid_(uuid, text)
    print("call CChatManager.showPaoPaoVoiceUuid_\n")
    GetChatManager():showPaoPaoForVoiceUuid(uuid, text)
end

function CChatManager.AddMsg_PoP_(roleid, shapeid, roleTitle, roleCamp, strName, strMsg)
	GetChatManager():AddMsg_PoP(roleid, shapeid, roleTitle, roleCamp, strName, strMsg)
end

function CChatManager.AddMsg_CurChannel_(roleid, shapeid, roleTitle, roleCamp, strName, strMsg)
	GetChatManager():AddMsg_CurChannel(roleid, shapeid, roleTitle, roleCamp, strName, strMsg)
end
---------------------------------------C++用--end--------------------------------------------
return CChatManager
--endregion
