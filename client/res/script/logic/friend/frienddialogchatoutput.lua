FriendDialogChatOutput = {}

FriendDialogChatOutput.__index = FriendDialogChatOutput

function FriendDialogChatOutput.RefreshChatRecord(selfRef, roleID)
	selfRef.m_ChatRecordList:cleanupNonAutoChildren()

	local maxShowCell = 50

	local cellList = {}

	local roleInf = gGetFriendsManager():GetContactRole(roleID)
	local chatRecordNum = roleInf:GetChatRecordNum()
	local endIndex = (chatRecordNum <= maxShowCell and 1 or chatRecordNum - maxShowCell)
	for i = chatRecordNum, endIndex, -1 do
		local chatUnit = roleInf:GetChatRecordByIndex(i)
		local cellWnd = FriendDialogChatOutput.CreateCell(i)
		local cellTable = FriendDialogChatOutput.GetCellTable(cellWnd, i)
		FriendDialogChatOutput.SetChatCell(cellWnd, cellTable, roleInf, chatUnit, i)
		FriendDialogChatOutput.UpdateChatCellSize(cellWnd, cellTable)
		selfRef.m_ChatRecordList:addChildWindow(cellWnd)
		FriendDialogChatOutput.UpdateHeadPos(cellWnd, cellTable, selfRef.m_ChatRecordList, chatUnit)

		cellList[i + 1 - endIndex] = cellWnd
	end
	FriendDialogChatOutput.UpdateAllCellPos(selfRef, cellList)
end


function FriendDialogChatOutput.CreateCell(index)

	local namePrefix = tostring(index)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local cellWnd = winMgr:loadWindowLayout("friendchatcell.layout", namePrefix)
	return cellWnd
end

function FriendDialogChatOutput.GetCellTable(cellWnd, index)
	local namePrefix = tostring(index)

	local winMgr = CEGUI.WindowManager:getSingleton()

	local headWndName = namePrefix .. "friendchatcell/head"
	local headWnd = CEGUI.toItemCell(winMgr:getWindow(headWndName))

	local textbgWndName = namePrefix .. "friendchatcell/textbg"
	local textbgWnd = winMgr:getWindow(textbgWndName)

	local yuyinWndName = namePrefix .. "friendchatcell/textbg/wenben/yuyin"
	local yuyinWnd = CEGUI.toPushButton(winMgr:getWindow(yuyinWndName))

	local durationWndName = namePrefix .. "friendchatcell/textbg/wenben/yuyin/duration"
	local durationWnd = winMgr:getWindow(durationWndName)

	local textWndName = namePrefix .. "friendchatcell/textbg/text"
	local textWnd = CEGUI.Window.toRichEditbox(winMgr:getWindow(textWndName))
	textWnd:setReadOnly(true)
	textWnd:getVertScrollbar():EnbalePanGuesture(false)

	local timeWndName = namePrefix .. "friendchatcell/time"
	local timeWnd = winMgr:getWindow(timeWndName)

    local leftVoiceImage = namePrefix .. "friendchatcell/textbg/wenben/yuyin/cell1"
    local rightVoiceImage = namePrefix .. "friendchatcell/textbg/wenben/yuyin/cell2"
    local leftVoiceWnd = winMgr:getWindow(leftVoiceImage.."/icon")
    local rightVoiceWnd = winMgr:getWindow(rightVoiceImage.."/icon")
    leftVoiceWnd:setVisible(false)
    rightVoiceWnd:setVisible(false)

	local ret = {
		m_HeadWnd = headWnd,
		m_TextbgWnd = textbgWnd,
		m_YuyinWnd = yuyinWnd,
		m_DurationWnd = durationWnd,
		m_TextWnd = textWnd,
		m_TimeWnd = timeWnd,
        m_leftVoiceWnd = leftVoiceWnd,
        m_rightVoiceWnd = rightVoiceWnd,
	}
	return ret
end

function FriendDialogChatOutput:HandleGetVoice(e)
	-- 这里是不是应该检查一下本地的文件是否存在在发消息？
	local winEvent = CEGUI.toWindowEventArgs(e)

	local voiceButtonWnd = winEvent.window
    local id = voiceButtonWnd:getID()
    if voiceButtonWnd then
        local strUuid = voiceButtonWnd:getUserString("uuid")
        local strTime = voiceButtonWnd:getUserString("time")
        local nTime = tonumber(strTime)
        if strUuid ~= "" and nTime ~= nil and nTime > 0 then
            gGetVoiceManager():tryGetVoice(strUuid, nTime, voiceButtonWnd:getName().."/cell"..id, true)
        end
    end

	return true
end

function FriendDialogChatOutput.SetChatCell(cellWnd, cellTable, roleInf, chatUnit, index)
	local roleid = chatUnit.roleid
	local name = chatUnit.name
	local shape = roleInf.shape
	local time = chatUnit.time
	local text = chatUnit.chatContent
    local voiceUUID = chatUnit.voiceUUID
	local isHaveVoice = 0
	local voiceTime = 0
    if string.len(voiceUUID) > 0 then
        isHaveVoice = 1
        voiceTime = chatUnit.voiceTime
    end

	local selfName = gGetDataManager():GetMainCharacterName()
	local selfShape = gGetDataManager():GetMainCharacterShape()
    local isSelf = false

	if name == selfName then
		shape = selfShape
        isSelf = true
	elseif roleid == -1 then
		shape = 1070101
	end

	local headWnd = cellTable.m_HeadWnd
	local textbgWnd = cellTable.m_TextbgWnd
	local yuyinWnd = cellTable.m_YuyinWnd
	local durationWnd = cellTable.m_DurationWnd
	local textWnd = cellTable.m_TextWnd
	local timeWnd = cellTable.m_TimeWnd
    local leftVoiceWnd = cellTable.m_leftVoiceWnd
    local rightVoiceWnd = cellTable.m_rightVoiceWnd

    if isHaveVoice == 1 then
        yuyinWnd:setUserString("uuid", voiceUUID)
        yuyinWnd:setUserString("time", tostring(voiceTime))
        yuyinWnd:subscribeEvent("Clicked", FriendDialogChatOutput.HandleGetVoice, FriendDialogChatOutput)
        if isSelf then
            leftVoiceWnd:setVisible(false)
            rightVoiceWnd:setVisible(true)
            yuyinWnd:setID(2)
        else
            leftVoiceWnd:setVisible(true)
            rightVoiceWnd:setVisible(false)
            yuyinWnd:setID(1)
        end
    else
        leftVoiceWnd:setVisible(false)
        rightVoiceWnd:setVisible(false)
    end


	if timeWnd then
		timeWnd:setText(time)
	end

	if headWnd then
		local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
       headWnd:SetImage(gGetIconManager():GetImageByID(shapeConf.littleheadID))
	end

	if yuyinWnd and durationWnd then
		if isHaveVoice == 1 then
			local secondText = BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11154).msg
			local timeText = tostring(voiceTime)
			durationWnd:setText(timeText .. secondText)
		else
			yuyinWnd:setVisible(false)
		end
	end

	if textWnd then
		textWnd:AppendParseText(CEGUI.String(text), roleid ~= -1)
		textWnd:Refresh()
	end

end

function FriendDialogChatOutput.UpdateChatCellSize(cellWnd, cellTable)
	local isHaveVoice = 0

	local headWnd = cellTable.m_HeadWnd
	local textbgWnd = cellTable.m_TextbgWnd
	local yuyinWnd = cellTable.m_YuyinWnd
	local durationWnd = cellTable.m_DurationWnd
	local textWnd = cellTable.m_TextWnd
	local timeWnd = cellTable.m_TimeWnd
    local voiceWnd = cellTable.m_leftVoiceWnd

	if yuyinWnd then
		if yuyinWnd:isVisible() == true then
			isHaveVoice = 1
		end
	end

    local size = textWnd:GetExtendSize()
	local w = size.width + 20
	local h = size.height + 15
    local orgTextBgHeight= textbgWnd:getPixelSize().height
    local orgCellSize = cellWnd:getPixelSize()
    local yuyinSize = yuyinWnd:getPixelSize()

	if isHaveVoice ~= 1 then
        textWnd:setYPosition(yuyinWnd:getYPosition())
        textbgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, w), CEGUI.UDim(0.0, h)))
    else
        h = h + yuyinSize.height
        if yuyinSize.width > w then
            textbgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, yuyinSize.width + voiceWnd:getPixelSize().width * 2), CEGUI.UDim(0.0, h)))
        else
            textbgWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, w), CEGUI.UDim(0.0, h)))
            yuyinWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, w - voiceWnd:getPixelSize().width * 2), CEGUI.UDim(0.0, yuyinSize.height)))
        end

    end

    local tempHeight = h + 5 + timeWnd:getPixelSize().height
    if tempHeight > orgCellSize.height then
        cellWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, orgCellSize.width), CEGUI.UDim(0.0, tempHeight)))
    end

    local minus = h - orgTextBgHeight
    if minus > 0 then
        cellWnd:setSize(CEGUI.UVector2(CEGUI.UDim(0.0, orgCellSize.width), CEGUI.UDim(0.0, orgCellSize.height + minus)))
    end

end

function FriendDialogChatOutput.UpdateHeadPos(cellWnd, cellTable, parentWnd, chatUnit)
	local name = chatUnit.name
	local selfName = gGetDataManager():GetMainCharacterName()

	local headWnd = cellTable.m_HeadWnd
	local textbgWnd = cellTable.m_TextbgWnd
	local timeWnd = cellTable.m_TimeWnd
    local yuyinWnd = cellTable.m_YuyinWnd
    local leftVoiceWnd = cellTable.m_leftVoiceWnd
    local rightVoiceWnd = cellTable.m_rightVoiceWnd
    local cellWidth = cellWnd:getPixelSize().width

	local edgeDistance = 10.0
    local winMgr = CEGUI.WindowManager:getSingleton()
    local timePosWnd = winMgr:getWindow("Frienddialog/chatframe")
    local timePosWndWidth = timePosWnd:getPixelSize().width
    local parentWidth = parentWnd:getWidth().offset 
    local timeWndWidth = cellTable.m_TimeWnd:getPixelSize().width
	if name ~= selfName then
        cellWnd:setXPosition(CEGUI.UDim(0.0, edgeDistance))
        if yuyinWnd then
            local pos = yuyinWnd:getPosition()
            local yuyinSize = yuyinWnd:getSize()
            yuyinWnd:setXPosition(CEGUI.UDim(0.0, pos.x.offset + rightVoiceWnd:getPixelSize().width + 5))
            yuyinWnd:setSize(yuyinSize)
        end
	else
        rightVoiceWnd:setXPosition(CEGUI.UDim(0.0, yuyinWnd:getPosition().x.offset + yuyinWnd:getPixelSize().width + 5))

        local headWidth = headWnd:getPixelSize().width
        local headX = cellWidth - headWidth - edgeDistance
        headWnd:setXPosition(CEGUI.UDim(0.0, headX))

        local textWndWidth = textbgWnd:getPixelSize().width
        local textWndX = headX - textWndWidth
        textbgWnd:setXPosition(CEGUI.UDim(0.0, textWndX))
	end

end

function FriendDialogChatOutput.UpdateAllCellPos(selfRef, cellList)
	local yPos = 0

	local count = #cellList
	for i = 1, count do
		local cell = cellList[i]
		cell:setYPosition(CEGUI.UDim(0.0, yPos))
		yPos = yPos + cell:getPixelSize().height
	end

--    local maxHeight = selfRef.m_ChatRecordList:getPixelSize().height
    local docSize = selfRef.m_ChatRecordList:getVertScrollbar():getDocumentSize()

    selfRef.m_ChatRecordList:setVerticalScrollPosition(yPos / docSize)

end

return FriendDialogChatOutput
