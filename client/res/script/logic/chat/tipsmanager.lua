--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
CTipsManager={}
CTipsManager.__index = CTipsManager

local TIPSDISHEIGHT = 4
local _instance

function GetCTipsManager()
	if not _instance then
		_instance = CTipsManager:new()
	end
	return _instance
end

function CTipsManager:new()
	local self = {}
	setmetatable(self, CTipsManager)

	self.m_vecMessageTips = {}
	self.tipsStartYPos = 0
	self.m_fTipDisplayTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(178).value)
	self.m_fHeightFactor = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(179).value)

    --mainticker只有在进入游戏后才起作用，所以这里用uisheet的windowupdate
    CEGUI.System:getSingleton():getGUISheet():subscribeEvent("WindowUpdate", CTipsManager.updateMessageTips, self)

	return self
end

function CTipsManager:AddMessageTipById(id)
	local tips = GameTable.message.GetCMessageTipTableInstance():getRecorder(id).msg
	self:AddMessageTip(tips)
end
function CTipsManager:AddMessageTipByMsg(msg)
	if type(self) == "string" and msg == nil then
		msg = self
		self = GetCTipsManager()
	end
	self:AddMessageTip(msg)
end

function CTipsManager.AddMessageTipById_(id)
	GetCTipsManager():AddMessageTipById(id)
end

function CTipsManager:AddMessageTip(messageTip, bAddToChat, bEnalbe, bCheckSame)
	if string.len(messageTip) == 0 then
		return
	end

	if #self.m_vecMessageTips ~= 0 and bCheckSame and self:IsHaveSameMessageTip(messageTip) then
		return
	end

	local MsgParseString = string.gsub(messageTip, "FF693F00", "FFFFF2DF")

	self:makeMessageTipWnd(MsgParseString, bAddToChat, bEnalbe);
end

function CTipsManager.AddMessageTip_(messageTip, bAddToChat, bEnalbe, bCheckSame)
	GetCTipsManager():AddMessageTip(messageTip, bAddToChat, bEnalbe, bCheckSame)
end

function CTipsManager:IsHaveSameMessageTip(messageTip)
	local winArgs = CEGUI.WindowManager:getSingleton()
	for i = 1, #self.m_vecMessageTips do
		if winArgs:isWindowPresent(self.m_vecMessageTips[i]) then
			local messagetip = CEGUI.toMessageTips(winArgs:getWindow(self.m_vecMessageTips[i]))
			local strEditbox = messagetip:getRichEditbox():GetPureText()

			if messageTip == strEditbox then
				return true
			end
		end
	end

	return false
end

function CTipsManager:makeMessageTipWnd(messageTip, bAddToChat, bEnable)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local mes = CEGUI.toMessageTips(winMgr:createWindow("TaharezLook/MessageTip"))

	self:InitMessageTip(mes, messageTip, bAddToChat)

	if mes:getRichEditbox() then
		mes:getRichEditbox():SetHoriAutoCenter(true)
	end

	mes:setEnabled(true)
	mes:setAlwaysOnTop(true)
	mes:moveToFront()
	mes:setTopMost(true)
	mes:setMousePassThroughEnabled(true)

	local ParentHeight = mes:getParentPixelHeight()
	local xPos =(mes:getParentPixelWidth() - mes:getWidth().offset) / 2
	mes:SetStartYPos(0.48)
	local yPos = mes:GetStartYPos()
	self.tipsStartYPos = mes:GetStartYPos()

	mes:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPos), CEGUI.UDim(yPos, 0)))

	table.insert(self.m_vecMessageTips, mes:getName())

	if #self.m_vecMessageTips > 1 then
		mes:setVisible(false)
	end

	-- 上升一个tips的高度
	mes:SetDestYPos(yPos -(mes:getHeight().offset + TIPSDISHEIGHT) / ParentHeight)
	mes:SetDisplayTime(self.m_fTipDisplayTime)
end

function CTipsManager:InitMessageTip(tip, message, bAddToChat)
	local newMessage = CChatManager.ReplaceColor(message)

	tip:SetTipsType(CEGUI.eMsgTip)

	gGetGameUIManager():AddWndToRootWindow(tip)

	if string.find(newMessage, "<T") then
		tip:setText(newMessage)
		tip:SetTextColor(0xFFFFF2DF);
	else
		newMessage = "<T t=\"" .. newMessage .. "\" c=\"FFFFF2DF\"></T>"
		tip:setText(newMessage)
	end

	local nLineCount = tip:getRichEditbox():GetLineCount()
	if nLineCount == 1 then
		tip:getRichEditbox():setTextLineVertCenter(true)
	else
		tip:getRichEditbox():setTextLineVertCenter(false)
	end
end

function CTipsManager:clearMessages()
	if not CEGUI.WindowManager:getSingleton() then return end

	local winMgr = CEGUI.WindowManager:getSingleton()

	for i = 1, #self.m_vecMessageTips do
		if  winMgr:isWindowPresent(self.m_vecMessageTips[i]) then
		    local msgTip = CEGUI.toMessageTips(winMgr:getWindow(self.m_vecMessageTips[i]))
			winMgr:destroyWindow(msgTip)
		end
	end

	self.m_vecMessageTips = {}
end
function CTipsManager.ParamToString(param)
	local newparam = nil
    for k,v in pairs(param) do
		if newparam == nil then
			newparam = k..'='..v
		else
			newparam = newparam.. '&' .. k..'='..v
		end
    end
	return newparam
end
function CTipsManager:ServerPost(action,param,actionname)

	require "logic.http.HttpManager"
	require "logic.http.LuaJson"
	local actionid = nil

	if actionname == 'getPayItem' then
		actionid = 1
	elseif actionname == 'getPayUrl' then
		actionid = 2
	elseif actionname == 'getChargeItemDay' then
		actionid = 4
	elseif actionname == 'ReceiveDayCharge' then
		actionid = 5
	elseif actionname == 'getChargeItemRole' then
		actionid = 6
	elseif actionname == 'ReceiveRoleCharge' then
		actionid = 7
	elseif actionname=='modifyPass' then
		actionid=8
	end
	

	local newparam = CTipsManager.ParamToString(param)
 
	HttpManager.getInstance():SendData(action,newparam,actionid,
 
		function(retvalue)
			
			local jsonStr=JSON.toJSON(retvalue)
			if actionname == 'getPayItem' then
				ChargeDialog:getInstanceNotCreate()
				ChargeDialog:CreateCell(jsonStr)
			elseif actionname == 'getPayUrl' then
				if jsonStr.code == 0 then
					GetCTipsManager():AddMessageTipByMsg(jsonStr.msg)
				else
					CTipsManager.openChargeUrl(base64decode(jsonStr.url))
				end
			elseif actionname == 'getChargeItemDay' then
				DayChargeDialog:getInstanceNotCreate()
				DayChargeDialog:changeCell(jsonStr)
			elseif actionname == 'ReceiveDayCharge' then
				if jsonStr.code == 1 then
					DayChargeDialog:DestroyDialog()
					DayChargeDialog:getInstance()
				end
				GetCTipsManager():AddMessageTipByMsg(jsonStr.msg)
			elseif actionname == 'getChargeItemRole' then
				RoleChargeDialog:getInstanceNotCreate()
				RoleChargeDialog:changeCell(jsonStr)
			elseif actionname == 'ReceiveRoleCharge' then
				if jsonStr.code == 1 then
					RoleChargeDialog:DestroyDialog()
					RoleChargeDialog:getInstance()
				end
				GetCTipsManager():AddMessageTipByMsg(jsonStr.msg)
			elseif actionname == 'modifyPass' then
				if jsonStr.code == 1 then
					require("logic.passmodifydlg"):DestroyDialog()
				end
				GetCTipsManager():AddMessageTipByMsg(jsonStr.msg)
			end
		end
	)
end
function CTipsManager.clearMessages_()
    if _instance then
	    _instance:clearMessages()
    end
end
function CTipsManager.openChargeUrl(url)
	IOS_MHSD_UTILS.OpenURL(url)
end

-- yangbin---reBuild MessageTips 20151229
function CTipsManager:updateMessageTips(e)
    local updateArgs = CEGUI.toUpdateEventArgs(e)
	local fDelta = updateArgs.d_timeSinceLastFrame

	local MAXSHOW = 2

	local winMgr = CEGUI.WindowManager:getSingleton()

	for i = 0, #self.m_vecMessageTips - 1 do
		local msgTip = nil
		if winMgr:isWindowPresent(self.m_vecMessageTips[i + 1]) then
			msgTip = CEGUI.toMessageTips(winMgr:getWindow(self.m_vecMessageTips[i + 1]))

			-- yangbin----每次update都要检查第一条是不是隐藏的，某些界面设置模态，隐藏其他界面后，界面关闭会把tips所有条目隐藏
			if i == 0 and not msgTip:isVisible() then
				msgTip:setVisible(true)
			end

			local continue1 = false
			if msgTip:GetTextureIsLoading() then
				continue1 = true
			end

			if not continue1 then
				local ParentHeight = msgTip:getParentPixelHeight()
				local size = #self.m_vecMessageTips

				local loop =(size - i > MAXSHOW - 1 and MAXSHOW) or size - i
				if size - i > MAXSHOW - 1 then
					loop = MAXSHOW
				else
					loop = size - i
				end

				local h = msgTip:getHeight().offset + TIPSDISHEIGHT

				-- //loop-1为了刨去本身
				for j = 0, loop - 1 do
					if winMgr:isWindowPresent(self.m_vecMessageTips[(i + 1) + j + 1]) then
						local pNext = CEGUI.toMessageTips(winMgr:getWindow(self.m_vecMessageTips[(i + 1) + j + 1]))
						h = h + pNext:getHeight().offset + TIPSDISHEIGHT
					end
				end
				msgTip:SetDestYPos(self.tipsStartYPos - h / ParentHeight)

				if i > 0 then
					local pPrev = CEGUI.toMessageTips(winMgr:getWindow(self.m_vecMessageTips[(i + 1) -1]))
					local a = pPrev:getYPosition().scale
					local b = msgTip:getYPosition().scale
					local c =(b - a) * ParentHeight
					local d = pPrev:getHeight().offset + TIPSDISHEIGHT
					if c >= d and not msgTip:isVisible() then
						msgTip:setVisible(true)
						break
					end
				end

				local continue2 = false
				if not msgTip:isVisible() then
					continue2 = true
				end

				if not continue2 then
					local WndH = self.m_fHeightFactor / 10
					-- //这里需要一个恒定的值，来确保不同高度的窗口上升速率是一样的
					local time = fDelta
					local speed = WndH /(self.m_fTipDisplayTime / 2 / time)

					msgTip:SetStartYPos(msgTip:GetStartYPos() - speed)

					local continue3 = false
					if msgTip:GetStartYPos() <= msgTip:GetDestYPos() then
						-- //如果超过了3个，那么最先到达顶端的删掉
						if size - i > MAXSHOW then
							winMgr:destroyWindow(msgTip)
							table.remove(self.m_vecMessageTips, i + 1)
							i = i - 1
							continue3 = true
						else
							msgTip:SetStartYPos(msgTip:GetDestYPos())
						end
					end

					if not continue3 then
						msgTip:setYPosition(CEGUI.UDim(msgTip:GetStartYPos(), 0))
					end
				end

			end

		else
			table.remove(self.m_vecMessageTips, i + 1)
			i = i - 1
		end
	end
end

return CTipsManager
--endregion
