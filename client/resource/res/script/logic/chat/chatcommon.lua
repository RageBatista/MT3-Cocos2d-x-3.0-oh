require "protodef.rpcgen.fire.pb.talk.channeltype"
require "utils.class"


TIPS_LINK_COUNT_MAX = 5         -- 一次聊天内容中最大的物品或技能tips链接个数

CHAT_INPUT_CHAR_COUNT_MAX = 50  --聊天输入框最大输入字符数字

EMOTION_NUM_MAX = 20            --最多表情输入数

CHANNEL_BTN_COUNT = 7           --频道按钮数量

HISTORY_MAX_COUNT = 27          --最大保存历史数

CHAT_CACHE_COUNT_MAX = 100      --频道最大保存聊天数量

VOICE_BTN_CLICK_INTERVAL = 1500 --语音按钮点击时间间隔

ADD_CHAT_TO_HISTORY = -1

b_RoleAccusation = false        --角色监控


ChannelGroups = {
	ChannelType.CHANNEL_SYSTEM,
	ChannelType.CHANNEL_WORLD,
	ChannelType.CHANNEL_CURRENT,
	ChannelType.CHANNEL_PROFESSION,
	ChannelType.CHANNEL_CLAN,
	ChannelType.CHANNEL_TEAM,
	ChannelType.CHANNEL_TEAM_APPLY
}

local ChannelColor = {
	0xffffffff,
	0xffffffff,
	0xff12d7e9,
	0xfffff100,
	0xff03d65c,
	0xfffd0303,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0xffffffff,
	0xffffffff
}

ChanelNameStrID = {
	1436,   --当前
	1437,   --队伍
	1438,   --职业
	1439,   --公会
	1440,   --世界
	1441,   --系统
	0,
	0,
	0,
	1442,   --组队
	1443,   --喇叭
	0,
	2803,   --阵营
	1442,   --组队
	0
}



------------------------------------------------------------------
--聊天消息结构

stChatRecord = class("stChatRecord")

function stChatRecord:init()
    self.channel = 0
	self.roleid = 0
	self.roleShapeId = 0
	self.roleTitle = 0
	self.roleCamp = 0
	self.strName = ""
	self.chatContent = ""
	self.recordID = 0
	self.forceCheckShied = true
    self.hasVoice = false
    self.voiceUUid = ""
    self.voiceFile = ""
    self.voiceTime = 0
    self.requestKey = ""--求助类消息的key
end


------------------------------------------------------------------
--聊天消息控件

--cell样式
CELL_STYLE_LEFT     = 1
CELL_STYLE_RIGHT    = 2
CELL_STYLE_SYS      = 3

local chatCellName = {"chatdiacell", "chatdiacell2", "chatdiacell3"}
local chatCellUniName = {0, 0, 0}

stChatCell = class("stChatCell")

local function bindChatCellEvent(wnd, eventName, obj, handler)
    if wnd and obj and handler then
        wnd:subscribeEvent(eventName, function(args)
            return handler(obj, args)
        end)
    end
end


function stChatCell:clickChatCellBg_joinTeam(e)

    --local pCom =  self.textBox:GetFirstLinkTextCpn()
    --if not pCom then
    --    return
    --end

    local mouseArgs = CEGUI.toMouseEventArgs(e)
	local pos = mouseArgs.position
	local clickWin = mouseArgs.window

    local component =  self.textBox:GetComponentByPos(pos);
	if component then
        local nComType = component:GetType()
        if nComType==CEGUI.RichEditboxComponentType_JoinTeam then
            return 
        end
	end
       local strChatText = self.textBox:GenerateParseText(false) --<T t="1">
         --loseefftime
    local posLeader =  string.find(strChatText,"loseefftime")
    if not posLeader then
        return
    end
    local nLenKey = string.len("loseefftime=")+1
    local nAllLen = string.len(strChatText)
    local strLeaderId = string.sub(strChatText,posLeader+nLenKey,nAllLen)
    local nYinhaoPos = string.find(strLeaderId,"\"")

    strLeaderId = string.sub(strLeaderId,1,nYinhaoPos-1)

    local nLeaderId = tonumber(strLeaderId)

    if GetTeamManager() then
		GetTeamManager():RequestJoinOneTeam(nLeaderId)
	end

    --[[
    local strChatText = self.textBox:GenerateParseText(false) --<T t="1">
    local posAnyeJoinTeam = string.find(strChatText,"<R")
    local nLen = string.len(strChatText)
    local strJoin = string.sub(strChatText,posAnyeJoinTeam,nLen)

    local vProperty = StringBuilder.Split( strJoin, " ")
    local mapObj = {}
     for k,strOnePro in pairs(vProperty) do
           local nPos = string.find( strOnePro,"=")
           local nLen = string.len(strOnePro)
           if nPos then
              local strKey = string.sub(strOnePro,1,nPos-1)
              local strValue = string.sub(strOnePro,nPos+2,nLen-1)
              mapObj[strKey] = strValue
           end
     end
     local nLeaderId = tonumber(mapObj.leaderid)
     --]]

end


function stChatCell:clickChatCellBg(e)
     if not self or not self.textBox then
        return true
     end
     local strChatText = self.textBox:GenerateParseText(false) --<T t="1">
     local posTaskType = string.find(strChatText,"type=".."\"8\"") --anye 8=task type
     if not posTaskType then
        return
     end

     local posAnyeType = string.find(strChatText,"baseid=".."\"3\"") --anye
     if not posAnyeType then
        return
     end
     --local posAnyeInfo = string.find(strOne,"counter=".."\"1\"") --helper other=2 1=show taskinfo
     local posAnyeJoinTeam = string.find(strChatText,"<L") --cegui bug correct is <R
     if posAnyeType and posAnyeJoinTeam then
        self:clickChatCellBg_joinTeam(e)
        return
     end
    
    local mouseArgs = CEGUI.toMouseEventArgs(e)
	local pos = mouseArgs.position
	local clickWin = mouseArgs.window

    local component =  self.textBox:GetComponentByPos(pos);
	if component then
        local nComType = component:GetType()
        if nComType==CEGUI.RichEditboxComponentType_Tips then
            return 
        end
	end

     local vPart = StringBuilder.Split( strChatText, "><")
     for k,strOne in pairs(vPart) do
           local nPosPBegin = string.find( strOne,"P")
           local posAnye = string.find(strOne,"baseid=".."\"3\"") --anye
           local posHelper = string.find(strOne,"counter=".."\"2\"") --helper other
           if nPosPBegin and posAnye and posHelper then
                strChatText = strOne
           end
     end

    --strAnyeText = "<P t="[暗" roleid="102401" type="8" key="0" baseid="3" shopid="0" counter="1" bind="105" loseefftime="0" TextColor="FF00CC11"></P>"
    local strAnyeText = strChatText --string.sub(strChatText,nPosPBegin,nPosPEnd-4)
    local vProperty = StringBuilder.Split( strAnyeText, " ")
    local mapObj = {}
     for k,strOnePro in pairs(vProperty) do
           local nPos = string.find( strOnePro,"=")
           local nLen = string.len(strOnePro)
           if nPos then
              local strKey = string.sub(strOnePro,1,nPos-1)
              local strValue = string.sub(strOnePro,nPos+2,nLen-1)
              mapObj[strKey] = strValue
           end
     end

     local name = ""
     local roleID = tonumber(mapObj.roleid)
     local ctype = tonumber(mapObj.type)
     local skey = tonumber(mapObj.key)
     local baseid = tonumber(mapObj.baseid)
     local shopID = tonumber(mapObj.shopid)
     local counterID = tonumber(mapObj.counter)
     local nameColor = ""
     local bind = tonumber(mapObj.bind)
     local loseeffecttime = tonumber(mapObj.loseefftime)
     GetChatManager():HandleTipsLinkClick(name, roleID, ctype, skey, baseid, shopID, counterID, nameColor, bind, loseeffecttime)

    
end

function stChatCell:initWithStyle(style)
    self.style = style

    chatCellUniName[style] = chatCellUniName[style] + 1
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.window = winMgr:loadWindowLayout(chatCellName[style] .. ".layout", chatCellUniName[style])


    local name = chatCellUniName[style] .. chatCellName[style]

    self.channelText = winMgr:getWindow(name .. "/pindao")
    self.textBox = CEGUI.toRichEditbox(winMgr:getWindow(name .. "/textbg/wenben"))
    self.textBox:getVertScrollbar():EnbalePanGuesture(false)

    bindChatCellEvent(self.textBox, "MouseClick", self, stChatCell.clickChatCellBg)


    if style == CELL_STYLE_LEFT or style == CELL_STYLE_RIGHT then
        self.nameText = winMgr:getWindow(name .. "/name")
		--self.levelText = winMgr:getWindow(name .. "/level")
        self.voiceIcon = winMgr:getWindow(name .. "/textbg/wenben/yuyin/icon")
        self.voiceBar = CEGUI.toPushButton(winMgr:getWindow(name .. "/textbg/wenben/yuyin"))
        self.headIcon = CEGUI.toPushButton(winMgr:getWindow(name .. "/btnimage"))
        self.bgWnd = winMgr:getWindow(name .. "/textbg")

        self.voiceIconWidth = self.voiceIcon:getPixelSize().width
        self.voiceBarX = self.voiceBar:getXPosition():asAbsolute(self.bgWnd:getPixelSize().width)

        self:initEvent()

    end
	

    self.voiceUUid = ""
    self.voiceFile = ""
end




--record: stChatRecord
function stChatCell:setData(record, textWidth, textHeight, width, height)
    if not record then
        return
    end

    self.channelText:setText(MHSD_UTILS.get_resstring(ChanelNameStrID[record.channel]))
    self.channelText:SetTextColor(ChannelColor[record.channel])

    if self.style == CELL_STYLE_LEFT or self.style == CELL_STYLE_RIGHT then
        local shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(record.roleShapeId)
        if shape then
            local headIconPath = gGetIconManager():GetImagePathByID(shape.littleheadID)
            if headIconPath then
                self.headIcon:setProperty("NormalImage", headIconPath:c_str())
			    self.headIcon:setProperty("PushedImage", headIconPath:c_str())
                self.headIcon:setID(record.roleid)
            end
        end

        self.nameText:setText(record.strName)
		--self.levelText:setText(tostring(record.nLevel))
        self.textBox:setMousePassThroughEnabled(not self:hasLinkItem(record.chatContent))

        if record.hasVoice then
            self.voiceIcon:setVisible(true)
            self.voiceBar:setVisible(true)

            self.voiceBar:setText(record.voiceTime .. MHSD_UTILS.get_resstring(11154)) --秒
            self.voiceUUid = record.voiceUUid
            self.voiceTime = record.voiceTime
            self.voiceFile = record.voiceFile

            self.bgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, textWidth+30), CEGUI.UDim(0, textHeight+22)))  --55:上45+下10
            self.textBox:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 11), CEGUI.UDim(0, 11)))

            self.voiceBar:setWidth(CEGUI.UDim(0, textWidth-self.voiceIconWidth))
            if self.style == CELL_STYLE_RIGHT then
                self.voiceBar:setXPosition(CEGUI.UDim(0, self.voiceBarX))
            end

         else
            self.voiceIcon:setVisible(false)
            self.voiceBar:setVisible(false)
            self.bgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, textWidth+30), CEGUI.UDim(0, textHeight+22))) 
            
            
            if self.style == CELL_STYLE_LEFT then  ---左
                self.textBox:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 15), CEGUI.UDim(0, 11))) 
            elseif self.style == CELL_STYLE_RIGHT then---右
                self.textBox:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 7), CEGUI.UDim(0, 11)))  
            end 
        end
    else
        self.voiceUUid = ""
        self.voiceTime = 0
        self.voiceFile = ""
    end

    --奇怪的误差，直接设置成textWidth只会显示最后一个字
    self.textBox:setSize(CEGUI.UVector2(CEGUI.UDim(0, textWidth+10), CEGUI.UDim(0, textHeight+10)))
    self.textBox:Clear()
	self.textBox:AppendParseText(CEGUI.String(record.chatContent), false)
	self.textBox:Refresh()
    self.window:setHeight(CEGUI.UDim(0, height))
end

function stChatCell:initEvent()
    if self.style ~= CELL_STYLE_SYS then
        bindChatCellEvent(self.headIcon, "Clicked", self, stChatCell.handleHeadIconClicked)
        bindChatCellEvent(self.voiceBar, "Clicked", self, stChatCell.HandleVoiceBarClicked)
    end
end

function stChatCell:handleHeadIconClicked(args)
    local wnd
    if args then
        local eventArgs = CEGUI.toWindowEventArgs(args)
        if eventArgs then
            wnd = eventArgs.window
        end
    end

    if not wnd then
        wnd = self.headIcon
    end

    local id = wnd and wnd:getID() or 0
	if id ~= 0 and id ~= gGetDataManager():GetMainCharacterID() then
        gGetFriendsManager():SetContactRole(id, true)
	end
	return true
end

function stChatCell:HandleVoiceBarClicked(args)
    if self.voiceUUid ~= "" and self.voiceTime > 0 then
        gGetVoiceManager():tryGetVoice(self.voiceUUid, self.voiceTime, self.voiceBar:getName(), true)
    elseif self.voiceFile ~= "" then
        GetBattleManager():PlayAISpeak(self.voiceFile, nil)
    end

	return true
end

function stChatCell:hasLinkItem(text)
    if text:find("<P") or text:find("<R") or text:find("<A") or text:find("<C") then
        return true
    end
    return false
end

------------------------------------------------------------------
--聊天消息数据，包括在频道内显示的消息序号和控件高度

stChatMsg = class("stChatMsg")

function stChatMsg:init()
    self.textWidth = 0  --文本的宽度
    self.textHeight = 0 --文本的高度
    self.width = 0      --cell的宽度
    self.height = 0     --cell的高度
    self.disToTop = 0--到container底边的距离
    self.record = nil   --消息的数据结构 stChatRecord
    self.style = 0      --1.sys 2.left 3.right
    self.cell = nil     --消息控件 stChatCell, 超出显示区时为nil
end

function stChatMsg:calculateSize()
    if self.record then
        self.textWidth, self.textHeight, self.width, self.height = GetChatCellManager():calculateSize(self.style, self.record)
    end
end

function stChatMsg:isShowing()
    return self.cell ~= nil
end

function stChatMsg:show(parent, scroll)
    if style ~= 0 and not self.cell and self.record then
        self.cell = GetChatCellManager():getChatCellFromPool(self.style)
        if self.cell then
            self.cell:setData(self.record, self.textWidth, self.textHeight, self.width, self.height)

            if not self.cell.window:getParent() and parent then
                parent:addChildWindow(self.cell.window)
                scroll:EnableChildDrag(self.cell.window)
            end
            self.cell.window:setVisible(true)
            self.cell.window:setYPosition(CEGUI.UDim(0, self.disToTop))
        end
    end
end

--切换频道或滚动时只隐藏，不从面板上移除
function stChatMsg:hide()
    if self.cell then
        GetChatCellManager():pushChatCellToPool(self.cell)
        self.cell = nil
    end
end

--退出登录时回收
function stChatMsg:recover()
    if self.cell then
        if self.cell.window:getParent() then
            self.cell.window:cleanupAllEvent() --清除调用EnableChildDrag时添加的事件
            self.cell:initEvent() --重新初始化事件
            self.cell.window:getParent():removeChildWindow(self.cell.window)
        end
        GetChatCellManager():pushChatCellToPool(self.cell)
        self.cell = nil
    end
end
