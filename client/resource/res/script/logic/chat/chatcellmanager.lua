
CChatCellManager={}
CChatCellManager.__index = CChatCellManager

local _instance = nil

function GetChatCellManager()
	if not _instance then
		_instance = CChatCellManager:new()
	end
	return _instance
end

function CChatCellManager:new()
	local self = {}
	setmetatable(self, CChatCellManager)
	return self
end

--判断是否包含语音内容.
function CChatCellManager:HasVoiceContent(chatText)
	if string.sub(chatText, 1, 1) ~= "<" then
		return true
	end
	return false
end

--是否有链接的道具.
function CChatCellManager:HasLinkItem(chatText)
	if string.find(chatText, "<P") ~= nil 
	or string.find(chatText, "<R") ~= nil
	or string.find(chatText, "<A") ~= nil
	or string.find(chatText, "<C") ~= nil then
		return true
	end
	return false
end

--获取语音的时间.
function CChatCellManager:GetVoiceTime(chatText)
    local t = string.match(chatText, "time=([%d%.]+)")
    if t then
        local n = tonumber(t)
        if n then
            return math.min(math.floor(n + 0.5), 30)
        end
    end
    return 1
end

--获取语音的文本.
function CChatCellManager:GetVoiceUUID(chatText)
    local text = chatText:match("link=\"([^\"]+)\"")
	return text or ""
end

--获取语音的文件.
function CChatCellManager:GetVoiceFile(chatText)
    local file = string.match(chatText, "file=\"([^\"]+)\"")
    return file or ""
end

--获取语音的文字.
function CChatCellManager:GetVoiceText(chatText)
    local text = chatText:match("text=(.*)&")
	return text or ""
end

function CChatCellManager:Release()

end

---------------------------------------C++用--begin--------------------------------------------
function CChatCellManager.Release_()
	--DEPRECATED
end

function CChatCellManager.Initialize_()
    GetChatCellManager():initPool()
end

---------------------------------------C++用--end----------------------------------------------


-----------------------------------------------------------------------------------------------
--new

function CChatCellManager:initPool()
    if self.tmpCell then
        return
    end

    --用于计算消息高度，不用于显示消息
    self.tmpCell = {}
    self.tmpCell[CELL_STYLE_LEFT] = self:createChatCell(CELL_STYLE_LEFT)
    self.tmpCell[CELL_STYLE_RIGHT] = self:createChatCell(CELL_STYLE_RIGHT)
    self.tmpCell[CELL_STYLE_SYS] = self:createChatCell(CELL_STYLE_SYS)

    self.tmpCell[CELL_STYLE_LEFT].textBox:setHeight(CEGUI.UDim(0, 1000))
    self.tmpCell[CELL_STYLE_RIGHT].textBox:setHeight(CEGUI.UDim(0, 1000))
    self.tmpCell[CELL_STYLE_SYS].textBox:setHeight(CEGUI.UDim(0, 1000))


    self.chatCellPool = {{}, {}, {}}

    for i=1, 10 do
        local cell = self:createChatCell(CELL_STYLE_LEFT)
        table.insert(self.chatCellPool[CELL_STYLE_LEFT], cell)

        cell = self:createChatCell(CELL_STYLE_RIGHT)
        table.insert(self.chatCellPool[CELL_STYLE_RIGHT], cell)
    end

    for i=1, 20 do
        local cell = self:createChatCell(CELL_STYLE_SYS)
        table.insert(self.chatCellPool[CELL_STYLE_SYS], cell)
    end
end

function CChatCellManager:createChatCell(style)
    local cell = stChatCell.new()
    cell:initWithStyle(style)
    return cell
end

--从缓存池中取cell，没有则创建
--@return stChatCell
function CChatCellManager:getChatCellFromPool(style)
    local n = #self.chatCellPool[style]
    if n > 0 then
        local ret = self.chatCellPool[style][n]
        table.remove(self.chatCellPool[style])
        return ret
    end
    return self:createChatCell(style)
end

--@cell stChatCell
function CChatCellManager:pushChatCellToPool(cell)
    cell.window:setVisible(false)
	cell.window:setYPosition(CEGUI.UDim(0, -1))--这个是为了防止切换频道控件坐标没有更新，导致纹理不知道飞哪去了的问题，暂时解决的办法，还得查CEGUI到底哪的问题
    table.insert(self.chatCellPool[cell.style], cell)
end

--隐藏的cell仍然在聊天窗口上，聊天界面销毁时调一下回收
function CChatCellManager:recoverHidedCells()
    for _, styleCells in ipairs(self.chatCellPool) do
        for _, cell in ipairs(styleCells) do
            if cell.window:getParent() then
                cell.window:cleanupAllEvent() --清除调用EnableChildDrag时添加的事件
                cell:initEvent() --重新初始化事件
                cell.window:getParent():removeChildWindow(cell.window)
            end
        end
    end
end

--@record stChatRecord
function CChatCellManager:calculateSize(style, record)
    local textBox = self.tmpCell[style].textBox
    textBox:Clear()
    textBox:AppendParseText(CEGUI.String(record.chatContent), false)
	textBox:Refresh()

    local textSize = textBox:GetExtendSize()
    if record.hasVoice then
        textSize.width = math.max(textSize.width, 150)
        textSize.height = math.max(textSize.height, 24)
    else
        textSize.width = math.max(textSize.width, 30)
        textSize.height = math.max(textSize.height, 24)
    end

    local deltaW = 0
    local deltaH = 0

    --根据文本区的尺寸得出控件的尺寸
    if style == CELL_STYLE_SYS then
        deltaW = 55
        deltaH = 10
    elseif style == CELL_STYLE_LEFT or style == CELL_STYLE_RIGHT then
        local hasVoice = self:HasVoiceContent(record.chatContent)
        deltaH = (hasVoice and 97 or 57)
        deltaW = 140
    end

    return math.ceil(textSize.width), math.ceil(textSize.height), math.ceil(textSize.width) + deltaW, math.ceil(textSize.height) + deltaH
end


return CChatManager
