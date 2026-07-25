require "logic.dialog"

TeamHanHuaEdit = {}
setmetatable(TeamHanHuaEdit, Dialog)
TeamHanHuaEdit.__index = TeamHanHuaEdit

local _instance
function TeamHanHuaEdit.getInstance()
	if not _instance then
		_instance = TeamHanHuaEdit:new()
		_instance:OnCreate()
	end
	return _instance
end

function TeamHanHuaEdit.getInstanceAndShow()
	if not _instance then
		_instance = TeamHanHuaEdit:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)

		_instance:RefreashContent()
	end
	return _instance
end

function TeamHanHuaEdit.getInstanceNotCreate()
	return _instance
end

function TeamHanHuaEdit.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TeamHanHuaEdit.ToggleOpenClose()
	if not _instance then
		_instance = TeamHanHuaEdit:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:RefreashContent()
		end
	end
end

function TeamHanHuaEdit.GetLayoutFileName()
	return "liaotianbianji.layout"
end

function TeamHanHuaEdit:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TeamHanHuaEdit)
	return self
end

function TeamHanHuaEdit:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	--[[self.cc_liaotian = winMgr:getWindow("liaotianbianjidb")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_liaotian)
    self.animationInstance:start()
	
	self.cc_btnClose = CEGUI.toPushButton(winMgr:getWindow("liaotianbianji/close"))
    self.cc_btnClose:subscribeEvent("Clicked", TeamHanHuaEdit.ccbtnCloseCallBack, self)
	--]]
	
	self.m_SendBtn = CEGUI.toPushButton(winMgr:getWindow("liaotianbianjidb/fasong"))
	self.m_SendBtn:subscribeEvent("Clicked", TeamHanHuaEdit.SendTalkContent, self)

	self.m_CheckBox1 = CEGUI.toCheckbox(winMgr:getWindow("liaotianbianji/duiwubg"))
	self.m_CheckBox1:subscribeEvent("CheckStateChanged", TeamHanHuaEdit.CheckBoxCallBack_1, self)
	self.m_CheckBox1:setSelectedNoEvent(true)

	self.m_CheckBox2 = CEGUI.toCheckbox(winMgr:getWindow("liaotianbianji/shijiebg"))
	self.m_CheckBox2:subscribeEvent("CheckStateChanged", TeamHanHuaEdit.CheckBoxCallBack_2, self)

	self.m_CheckBox3 = CEGUI.toCheckbox(winMgr:getWindow("liaotianbianji/bangpaibg"))
	self.m_CheckBox3:subscribeEvent("CheckStateChanged", TeamHanHuaEdit.CheckBoxCallBack_3, self)

	self.m_CheckBox4 = CEGUI.toCheckbox(winMgr:getWindow("liaotianbianji/dangqianbg"))
	self.m_CheckBox4:subscribeEvent("CheckStateChanged", TeamHanHuaEdit.CheckBoxCallBack_4, self)
	

	self.m_TalkContant = CEGUI.toRichEditbox(winMgr:getWindow("liaotianbianjidb/liaotianbg/wenben"))
	self.m_TalkContant:setMaxTextLength(24)
	self.m_TalkContant:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_TalkContant:getProperty("NormalTextColour")))
	self.m_TalkContant:subscribeEvent("EditboxFullEvent", TeamHanHuaEdit.OnInputBoxFull, self)
	self.m_TalkContant:subscribeEvent("TextAccepted", TeamHanHuaEdit.SendTalkContent, self)
	self.m_TalkContant:subscribeEvent("TextChanged", TeamHanHuaEdit.ContentChanged, self)

	self.m_LeaveText = winMgr:getWindow("liaotianbianjidb/daojishu")
    self.m_LeaveText:setVisible(false)

	self.m_ClearContent = CEGUI.toPushButton(winMgr:getWindow("liaotianbianjidb/xiaochu"))
	self.m_ClearContent:subscribeEvent("Clicked", TeamHanHuaEdit.ClearContent, self)

	self.m_bCloseIsHide = true
	self.m_TargetID = -1

	self:RefreashContent()
	self:ContentChanged()
end

function TeamHanHuaEdit:ClearContent(e)
	self.m_TalkContant:Clear()
	self.m_TalkContant:Refresh()
end

function TeamHanHuaEdit:ContentChanged(e)
		local outText = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11458).msg
		local count = self.m_TalkContant:GetPureText()
		local aaa = 24 - string.len(count)
		local pos = string.find(outText, "d")
		if pos ~= nil then
			pos = pos - 2
			outText = string.sub(outText, 0, pos) .. aaa .. string.sub(outText, pos + 3, string.len(outText))
		end
		self.m_LeaveText:setText(outText)
end

function TeamHanHuaEdit:SendTalkContent(e)
	local channelID = 0

	if self.m_CheckBox1:isSelected() then
		channelID = ChannelType.CHANNEL_TEAM_APPLY
	elseif self.m_CheckBox2:isSelected() then
		channelID = ChannelType.CHANNEL_WORLD
	elseif self.m_CheckBox3:isSelected() then
		channelID = ChannelType.CHANNEL_CLAN
	elseif self.m_CheckBox4:isSelected() then
		channelID = ChannelType.CHANNEL_WORLD
	end

    local setting = GetTeamManager():GetTeamMatchInfo()
    local matchinfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(setting.targetid)
    if not matchinfo then
        --δѡ��Ŀ��
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(150023))
    else
        --����һ������Э��
        local sb = require "utils.stringbuilder":new()
        local msg = MHSD_UTILS.get_resstring(11462)
        sb:Set("parameter1", matchinfo.content)
        sb:Set("parameter2", matchinfo.target)
        sb:SetNum("parameter3", GetTeamManager():GetMemberNum())
        sb:SetNum("parameter4", setting.minlevel)
        sb:SetNum("parameter5", setting.maxlevel)
        sb:Set("parameter6", GetTeamManager():GetTeamID())
        sb:Set("parameter7", self.m_TalkContant:GetPureText())
        sb:Set("parameter8", gGetDataManager():GetMainCharacterID())
        msg = sb:GetString(msg)
        sb:delete()
	    local p = require('protodef.fire.pb.team.conekeyteammatch').Create()
        p.channeltype = channelID
        p.text = msg
	    LuaProtocolManager:send(p)
    end
end

function TeamHanHuaEdit:CheckBoxCallBack_1(e)
    if not self.m_CheckBox1:isSelected() then
        self.m_CheckBox1:setSelectedNoEvent(true)
    end
	self.m_CheckBox2:setSelectedNoEvent(false)
	self.m_CheckBox3:setSelectedNoEvent(false)
	self.m_CheckBox4:setSelectedNoEvent(false)
end

function TeamHanHuaEdit:CheckBoxCallBack_2(e)
    if not self.m_CheckBox2:isSelected() then
        self.m_CheckBox2:setSelectedNoEvent(true)
    end
	self.m_CheckBox1:setSelectedNoEvent(false)
	self.m_CheckBox3:setSelectedNoEvent(false)
	self.m_CheckBox4:setSelectedNoEvent(false)
end

function TeamHanHuaEdit:CheckBoxCallBack_3(e)
    if not self.m_CheckBox3:isSelected() then
        self.m_CheckBox3:setSelectedNoEvent(true)
    end
	self.m_CheckBox1:setSelectedNoEvent(false)
	self.m_CheckBox2:setSelectedNoEvent(false)
	self.m_CheckBox4:setSelectedNoEvent(false)
end

function TeamHanHuaEdit:CheckBoxCallBack_4(e)
    if not self.m_CheckBox4:isSelected() then
        self.m_CheckBox4:setSelectedNoEvent(true)
    end
	self.m_CheckBox1:setSelectedNoEvent(false)
	self.m_CheckBox2:setSelectedNoEvent(false)
	self.m_CheckBox3:setSelectedNoEvent(false)
end

function TeamHanHuaEdit:OnInputBoxFull(e)
	GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1449))
end

function TeamHanHuaEdit:ccbtnCloseCallBack(args)
    TeamHanHuaEdit.DestroyDialog()
end

function TeamHanHuaEdit:RefreashContent()
--    local matchInfo = GetTeamManager():GetTeamMatchInfo()
--	if self.m_TargetID ~= matchInfo.targetid then
--		local dlg2 = require("logic.team.teamdialognew").getInstanceNotCreate()
--		if dlg2 then
--			local str = "<T t=\""
--			str = str ..dlg2.targetNameText:getText()
--			str = str .."\" c=\"FF693F00\"></T>"

--			self.m_TalkContant:Clear()
--			self.m_TalkContant:AppendParseText(CEGUI.String(str), false)
--			self.m_TalkContant:Refresh()

--			self.m_TargetID = matchInfo.targetid
--		end
--	end

	self:ContentChanged()
end

return TeamHanHuaEdit