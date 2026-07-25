------------------------------------------------------------------
-- 新手引导管理类
------------------------------------------------------------------

local guideDlgXoffset = 50
local guideDlgYoffset = 0

NEW_GUIDE_FIRST_TEAM            = 33230 --多人组队进入战斗引导聊天

-------------------------------------------------------------

stGuideTarget = {}
stGuideTarget.__index = stGuideTarget

function stGuideTarget:new()
    local self = {}
    setmetatable(self, stGuideTarget)
    self:init()
    return self
end

function stGuideTarget:init()
	self.id                 = 0     -- 引导ID
	self.nameHighlightWnd   = ""    -- 高亮窗口名称
    self.nameClickWnd       = ""    -- 点击窗口名称
end

-------------------------------------------------------------

stGuideInf = {}
stGuideInf.__index = stGuideInf

function stGuideInf:new()
    local self = {}
    setmetatable(self, stGuideInf)
    self:init()
    return self
end

function stGuideInf:init()
	self.id                 = 0     -- 引导ID
	self.nameHighlightWnd   = ""    -- 高亮窗口名称
    self.nameClickWnd       = ""    -- 点击窗口名称
	self.ClickRect          = nil   -- 点击区域
	self.HighLightRect      = nil   -- 高亮区域，粒子显示框
    self.pGuideDlg          = nil   -- 引导对话框
end

-------------------------------------------------------------

NewRoleGuideManager = {}
NewRoleGuideManager.__index = NewRoleGuideManager

local _instance

function NewRoleGuideManager.getInstance()
    if not _instance then
        _instance = NewRoleGuideManager:new()
    end
    return _instance
end

function NewRoleGuideManager.destroyInstance()
    if _instance then
        for _, effect in pairs(_instance.m_pTargetEffect) do
            Nuclear.GetEngine():ReleaseEffect(effect)
        end
        _instance.m_vWaitingList = {}
	    if _instance.aniWindow then
		    CEGUI.WindowManager:getSingleton():destroyWindow(_instance.aniWindow)
		    _instance.aniWindow = nil
	    end

        _instance = nil
    end
end

function NewRoleGuideManager:new()
    local self = {}
    setmetatable(self, NewRoleGuideManager)

	self.m_bLockScreen          = false -- 是否需要锁屏
	self.m_iCurGuideId          = 0     -- 当前锁屏引导id
	self.m_bReceiveGuideList    = true
	self.m_fLockTime            = 0.0
	self.m_fNoLockTime          = 0.0
	self.m_bIsFinishProcess     = false -- 判断接收完服务器消息
	self.m_bIsTimeOver          = false -- 判断锁屏时间到
	self.m_bIsNoLock            = false
	self.isMoveToBack           = false
	self.startPlayAni           = false
	self.endPlayAni             = false
	self.aniWindow              = nil
	self.luaGetWindow           = nil
	self.guideModel             = -1    -- 引导模式  0新手 1老手  -1全部引导
	self.m_listCurGuide         = {}    -- 当前进行的引导列表
	self.m_mapGuideState        = {}    -- 新手引导的完成状态
	
	self.m_vWaitingList         = {}    -- 等待引导列表
	self.GuideEffectMap         = {}	-- 新手引导粒子特效时间表
	self.m_pBeginAni            = nil
	self.m_iPreGuideID          = 0
	self.m_mapGuidePaticle      = {}
    self.m_pTargetEffect        = {}    -- 锁屏引导中的特效

    -- 粒子速度
	self.s_fGuidePaticleSpeed = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(169).value)
    -- 锁屏时间
	self.lockTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(170).value)
    -- 非锁屏下一步时间
	self.noLockTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(223).value)

    return self
end

----------------------------------------------------------------------

function NewRoleGuideManager:setGuideModel(model)
    self.guideModel = model
end

function NewRoleGuideManager:getGuideModel()
    return self.guideModel
end

function NewRoleGuideManager:setLuaGetWindow(pWindow)
	self.luaGetWindow = pWindow
end

function NewRoleGuideManager:getLuaGetWindow()
	return self.luaGetWindow
end

-- 查看引导是否永久锁屏
function NewRoleGuideManager:getGuideIsAllwaysLock()
	local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(self.m_iCurGuideId)
	return record and record.isAllwaysLock == 1 or false
end

-- 判断是否正在播放引导动画
function NewRoleGuideManager:isPlayingAni()
	if self.startPlayAni or self.endPlayAni then
		return true
    end
	return false
end

-- 计算引导动画与实际需要引导按钮的距离
function NewRoleGuideManager:calculateDistance()
	local pt1 = self.aniWindow:GetScreenPosOfCenter()
	local pt2 = self:GetGuideClickWnd(self.m_iCurGuideId):GetScreenPosOfCenter()
	local dis = pt1 - pt2
	if math.abs(dis.x) < 0.1 then
		self.endPlayAni = true
    end
end

-- 播放引导动画
function NewRoleGuideManager:playGuideAni()
	if CEGUI.System:getSingleton() and CEGUI.System:getSingleton():getGUISheet() then
		self.startPlayAni = true
		local winMgr = CEGUI.WindowManager:getSingleton()
		local cp = Nuclear.GetEngine():GetWorld():GetViewport()
		local ptPos = Nuclear.NuclearPoint((cp.right - cp.left) / 2, (cp.bottom - cp.top) / 2)
		local windowName = tostring(self.m_iCurGuideId)
		self.aniWindow = winMgr:createWindow("TaharezLook/StaticImage", windowName)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(self.aniWindow)
		self.aniWindow:setPosition(CEGUI.UVector2(CEGUI.UDim(0,ptPos.x), CEGUI.UDim(0,ptPos.y)))
		self.aniWindow:setSize(CEGUI.UVector2(CEGUI.UDim(0,60), CEGUI.UDim(0,60)))
		self.aniWindow:setProperty("Image", "set:zhuanpanui image:zhiyin")
		self.aniWindow:setTopMost(true)
		local aniMgr = CEGUI.AnimationManager:getSingleton()
		self.aniWindow:subscribeEvent("AnimationEnded", NewRoleGuideManager.HandleGuideAniEnd, self)
		self.m_pBeginAni = aniMgr:instantiateAnimation(aniMgr:getAnimation("xinshouyindao"))
		self.m_pBeginAni:setTargetWindow(self.aniWindow)
		self.m_pBeginAni:start()
    end
end

function NewRoleGuideManager:getFinshProcess()
	return self.m_bIsFinishProcess
end

function NewRoleGuideManager:SetFinshProcess(finish)
	self.m_bIsFinishProcess = finish
end

-- 判断战斗中引导是否通过
function NewRoleGuideManager:isBattleGuideFinsh(battleId, roundId)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.battleId == battleId and record.battleRoundId == roundId then
			return self:isGuideFinish(record.id)
        end
    end
	return true
end

-- 根据战斗id与波次id发起引导
function NewRoleGuideManager:GuideStartBattle(battleId, roundId)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.battleId == battleId and record.battleRoundId == roundId then
			if record.guideModel ~= -1 and record.guideModel ~= self:getGuideModel() then
				return
			else
				if GetBattleManager():IsAutoOperate() then
					GetBattleManager():EndAutoOperate()
					CharacterOperateDlg.InitOperateBtnEnbale()
                end
				self:AddToWaitingList(record.id, record.button, record.usebutton)
            end
        end
    end
end

-- 根据获得道具id发起引导
function NewRoleGuideManager:GuideStartConditionItem(itemId)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.conditionItemId == itemId then
			self:AddToWaitingList(record.id, record.usebutton, record.usebutton)
        end
    end
end

-- 根据功能id发起引导
function NewRoleGuideManager:GuideStartFunction(funcitionId)
	--YinCang.CShowAllEx()
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.functionid == funcitionId then
			self:AddToWaitingList(record.id, record.usebutton, record.usebutton)
        end
    end
end

-- 根据道具id发起引导
function NewRoleGuideManager:GuideStartProperty(propertyId, clickName, highlightName)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.item == propertyId then
			self:AddToWaitingList(record.id, clickName, highlightName)
        end
    end
end

-- 根据任务id发起引导
function NewRoleGuideManager:GuideStartTask(taskId, clickName, highlightName)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.task == taskId
        and record.id ~= 31001
        and record.id ~= 31002
        and record.id ~= 31003
        and record.id ~= 31004
        and record.id ~= 31005
        and record.id ~= 31006
        and record.id ~= 31009
        and record.id ~= 31010
        and record.id ~= 31011 then -- 第一条任务引导写死，由于没找到更好的方法
			self:AddToWaitingList(record.id, clickName, highlightName)
        end
    end
end

function NewRoleGuideManager:getPreGuideID()
	return self.m_iPreGuideID
end

function NewRoleGuideManager:setPreGuideID(id)
	self.m_iPreGuideID = id
end

function NewRoleGuideManager:GuideTaskID(id)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.task == id then
			self:AddToWaitingList(record.id)
        end
    end
end

function NewRoleGuideManager:getReceiveGuideList()
	return self.m_bReceiveGuideList
end

function NewRoleGuideManager:setReceiveGuideList(b)
	self.m_bReceiveGuideList = b
end

-- 处理某个window的引导完成
function NewRoleGuideManager:HandleParticalEnd(e)
	local wndE = CEGUI.toWindowEventArgs(e)
	if wndE.window then
		local pParticleEffect = self:GetGuidePaticleEffectByWnd(wndE.window)
		if pParticleEffect then
			gGetGameUIManager():RemoveUIEffect(pParticleEffect)
        end
    end
	return true
end

function NewRoleGuideManager:AddParticalToWnd(pWnd, bAlwaysOn)
    if bAlwaysOn == nil then
        bAlwaysOn = false
    end

	if pWnd then
		local pParticleEffect = self:GetGuidePaticleEffectByWnd(pWnd)
		if pParticleEffect then
			return
        end
    end

	local pEffect = gGetGameUIManager():AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10068), true, 0, 0, true)
	if pEffect then
		self.m_mapGuidePaticle[pEffect] = 0.0
		self:UpdateGuidePaticleEffect(pEffect, pWnd)
		local pParticleEffect = pEffect:TryConvertToParticle()
		if pParticleEffect then
			pParticleEffect:SetCycleMode(Nuclear.XPPCM_ALWAY_EMISSION)
        end

		pWnd:SetGuideState(true)
		if not bAlwaysOn then
			pWnd:removeEvent("GuideEnd")
			pWnd:subscribeEvent("GuideEnd", NewRoleGuideManager.HandleParticalEnd, self)
        end
    end
end

function NewRoleGuideManager:UnLockBtn()
	ShowHide.NewRoleGuide()
end

-- 每一级需要的引导
function NewRoleGuideManager:GuideLevel(level)
    local ids = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getAllID()
    for i = 1, #ids do
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(ids[i])
		if record.startlevel == level then
			self:AddToWaitingList(record.id)
        end
    end
end

function NewRoleGuideManager:UpdateGuideRect()
    for _, guide in pairs(self.m_listCurGuide) do
		if guide.id == self.m_iCurGuideId then
			local pClickWnd = self:GetGuideClickWnd(guide.id, guide.nameClickWnd)
			local pHighlightWnd = self:GetGuideHighLightWnd(guide.id, guide.nameHighlightWnd)
			if pClickWnd and pClickWnd:isVisible() and pHighlightWnd and pHighlightWnd:isVisible() then
				if string.find(pClickWnd:getType(), "RichEditbox") then     -- 30001 首次和NPC对话做任务引导,设置RichEditbox中的高亮区域
					local pt = CEGUI.Vector2()
					local cpnSize = CEGUI.Size()
					local pBox = CEGUI.toRichEditbox(pHighlightWnd)
					local str = pHighlightWnd:getType()
					if pBox then
						local pCpn = pBox:GetFirstLinkTextCpn()
						if pCpn then
							pt = pBox:GetCpnScreenPos(pCpn)
							cpnSize = pCpn:getPixelSize()
						end
					end
					guide.HighLightRect = Nuclear.NuclearFRectt(Nuclear.NuclearFPoint(pHighlightWnd:GetScreenPos().x, pt.y + 6), pHighlightWnd:getPixelSize().width, cpnSize.height)
					guide.ClickRect = guide.HighLightRect
				else
					guide.HighLightRect = Nuclear.NuclearFRectt(Nuclear.NuclearFPoint(pHighlightWnd:GetScreenPos().x, pHighlightWnd:GetScreenPos().y), pHighlightWnd:getPixelSize().width, pHighlightWnd:getPixelSize().height)
					guide.ClickRect = Nuclear.NuclearFRectt(Nuclear.NuclearFPoint(pClickWnd:GetScreenPos().x, pClickWnd:GetScreenPos().y), pClickWnd:getPixelSize().width, pClickWnd:getPixelSize().height)
				end
			end
			break
		end
	end
end

-- 某个window的引导完成
function NewRoleGuideManager:FinishGuideInWindow(pWnd)
	if pWnd then
		pWnd:setTopMost(false)
		local finishid = self:GetGuideIDByHighLightWnd(pWnd:getName())

        for index, guide in pairs(self.m_listCurGuide) do
			if guide.id == finishid then
				-- 继续下一步引导
				local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(guide.id)
				if record and record.step ~= 0 then
					self:AddToWaitingList(record.step)
				end
				self.m_listCurGuide[index] = nil
				break
	        end
        end

		local pParticleEffect = self:GetGuidePaticleEffectByWnd(pWnd)
		if pParticleEffect then
			gGetGameUIManager():RemoveUIEffect(pParticleEffect)
		end
		newguidebg.DestroyDialog()
	end
end

-- 处理某个window的引导完成
function NewRoleGuideManager:HandleParticalGuideEnd(e)
	local wndE = CEGUI.toWindowEventArgs(e)
	if wndE.window then
		self:FinishGuideInWindow(wndE.window)
	end
	return true
end

-- 判断引导目标是否在最外层对话框
function NewRoleGuideManager:isTargetInDlg()
	local ModalWindow = CEGUI.System:getSingleton():getModalTarget()

	if ModalWindow then
		if self:GetGuideClickWnd(self.m_iCurGuideId) then
			if self:GetGuideClickWnd(self.m_iCurGuideId):getName() == "commontipdlgitemtips_mtg/btnshiyong" then
				return true
			end
			local parent = self:GetGuideClickWnd(self.m_iCurGuideId):getParent()
			while true do
				if parent then
					if ModalWindow:getName() == parent:getName() then
						return true
					end
					parent = parent:getParent()
				else
					break
				end
			end
			return false
	    end
    end
	return true
end

-- 添加粒子特效 id 为特效id
function NewRoleGuideManager:AddParticalEffect(pWnd, id)
    if not id then
        id = 10068
    end

	gGetGameUIManager():RemoveUIEffect(pWnd)

	local pEffect = gGetGameUIManager():AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(id), true, 0, 0, true)
	if pEffect then
		self.m_mapGuidePaticle[pEffect] = 0.0
		self:UpdateGuidePaticleEffect(pEffect, pWnd)
		local pParticleEffect = pEffect:TryConvertToParticle()
		if pParticleEffect then
			pParticleEffect:SetCycleMode(Nuclear.XPPCM_ALWAY_EMISSION)
		end

		pWnd:SetGuideState(true)
		pWnd:removeEvent("GuideEnd")
		pWnd:subscribeEvent("GuideEnd", NewRoleGuideManager.HandleParticalGuideEnd, self)
	end
end

function NewRoleGuideManager:CheckTargetWindow()
	local pTargetWnd = nil
    for _, guide in pairs(self.m_listCurGuide) do
		if guide.id == self.m_iCurGuideId then
			pTargetWnd = self:GetGuideClickWnd(self.m_iCurGuideId, guide.nameClickWnd)
		end
	end

	-- 点击某个按钮的引导
	local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(self.m_iCurGuideId)
	if pTargetWnd and pTargetWnd:isVisible() and pTargetWnd:getEffectiveAlpha() > 0.95 then
		return true
	elseif record and record.battlePos ~= 0 then  -- 战斗选中敌人引导
		return true
	end
	return false
end

function NewRoleGuideManager:HandleGuideAniEnd(e)
	self.m_pBeginAni:stop()
	local startPt = self.aniWindow:GetScreenPosOfCenter()
	local endPt = self:GetGuideClickWnd(self.m_iCurGuideId):GetScreenPosOfCenter()
	self.aniWindow:FlyToScreenPoint(endPt, 0.5)
	return true
end

function NewRoleGuideManager:HandleNoLockGuideEnd(e)
	self:FinishNoLockGuide(true)
	return true
end

function NewRoleGuideManager:HandleGuideEnd(e)
	self:FinishGuide()
	return true
end

function NewRoleGuideManager:RemoveFromWaitingList(id)
    for index, waitingGuide in pairs(self.m_vWaitingList) do
		if waitingGuide.id == id then
			self.m_vWaitingList[index] = nil
			return
		end
	end
end

-- 将新手引导项加入到引导队列中
function NewRoleGuideManager:AddToWaitingList(id, clickName, highlightName)
    if not clickName then
        clickName = ""
    end
    if not highlightName then
        highlightName = ""
    end

	local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(id)
	if record and record.guideModel ~= -1 and record.guideModel ~= self:getGuideModel() then
		return
	end

    for _, waitingGuide in pairs(self.m_vWaitingList) do
		if waitingGuide.id == id then
			return
		end
	end
	self.m_vWaitingList = {}
	
	local waiting = stGuideTarget:new()
	waiting.id = id
	waiting.nameClickWnd = clickName
	waiting.nameHighlightWnd = highlightName
	table.insert(self.m_vWaitingList, waiting)
end

-- 是否点击了应点击的区域
function NewRoleGuideManager:isClickInRect(x, y)
	if not self:CheckTargetWindow() then
		self:FailGuide()
		return true
	end

	if gGetSceneMovieManager():isOnSceneMovie() then
		return true
	end

	if self:GetGuideClickWnd(self.m_iCurGuideId) and self:GetGuideClickWnd(self.m_iCurGuideId):getEffectiveAlpha() < 0.05 then
		return true
	end

    local clickRect = self:GetClickRect(self:getCurGuideId())
    local left = clickRect.left
    local top = clickRect.top
    local right = clickRect.right
    local bottom = clickRect.bottom
    local ceguiRect = CEGUI.Rect(left, top, right, bottom)
    local ceguiPoint = CEGUI.Vector2(x, y)
	if ceguiRect:isPointInRect(ceguiPoint) then
		return true
	end

	return false
end

-- 得到引导的目标窗口可点击区域
function NewRoleGuideManager:GetClickRect(id)
    for _, guide in pairs(self.m_listCurGuide) do
		if guide.id == id then
			return guide.ClickRect
		end
	end
	return Nuclear.NuclearFRectt(0, 0, 0, 0)
end

function NewRoleGuideManager:getCurGuideId()
	return self.m_iCurGuideId
end

function NewRoleGuideManager:setCurGuideId(id)
	self.m_iCurGuideId = id
end

function NewRoleGuideManager:NeedLockScreen()
	return self.m_bLockScreen
end

function NewRoleGuideManager:setLockScreen(b)
	self.m_bLockScreen = b
end

function NewRoleGuideManager:UpdateGuidePaticleEffect(pEffect, pWnd)
	local elapseTime = self.m_mapGuidePaticle[pEffect]
	if elapseTime then
		if pWnd then
			local x = 0
			local y = 0
			local screenPt = pWnd:GetScreenPos()
			local wndSize = pWnd:getPixelSize()

			local width = math.floor(wndSize.width)
			local height =  math.floor(wndSize.height)
			local totalLength = math.floor(elapseTime * self.s_fGuidePaticleSpeed)
			local rectLength = (width + height) * 2
			local length = totalLength % rectLength
			if length < width then
				x = length
				y = 0 + 3
			elseif length < (width + height) then
				x = width - 3
				y = length - width
			elseif length < (2 * width + height) then
				x = width - (length - width - height)
				y = height - 3
			else
				x = 0 + 3
				y = height - (length - 2 * width - height)
			end
			x = x + math.floor(screenPt.x)
			y = y + math.floor(screenPt.y)
			if pEffect then
				pEffect:SetLocation(Nuclear.NuclearPoint(x, y))
			end
		end
	end
end

-- 通过某个window获得引导粒子特效
function NewRoleGuideManager:GetGuidePaticleEffectByWnd(pWnd)
	if pWnd then
        for first, _ in pairs(self.m_mapGuidePaticle) do
			local pCurWnd = gGetGameUIManager():GetWndByEffect(first)
			if pCurWnd == pWnd then
				return first
			end
		end
	end

	return nil
end

function NewRoleGuideManager:RemoveGuidePaticleEffect(pEffect)
    if self.m_mapGuidePaticle[pEffect] then
        self.m_mapGuidePaticle[pEffect] = nil
    end
end

function NewRoleGuideManager:GetGuideIDByHighLightWnd(wndName)
    for _, guide in pairs(self.m_listCurGuide) do
		if guide.nameHighlightWnd == wndName then
			return guide.id
		end
	end
	return -1
end

function NewRoleGuideManager:FailGuide()
	self:SetGuideStateId(self.m_iCurGuideId, false)
	self.m_bLockScreen = false
    for index, guide in pairs(self.m_listCurGuide) do
		if guide.id == self.m_iCurGuideId then
			if self.m_iCurGuideId ~= 30001 then
				self:AddToWaitingList(guide.id, guide.nameClickWnd, guide.nameHighlightWnd)
            end

			local winMgr = CEGUI.WindowManager:getSingleton()
			if guide.pGuideDlg then
				winMgr:destroyWindow(guide.pGuideDlg)
			    guide.pGuideDlg = nil
			end

            for i, effect in pairs(self.m_pTargetEffect) do
				if effect then
					Nuclear.GetEngine():ReleaseEffect(effect)
					self.m_pTargetEffect[i] = nil
				end
			end

			self.m_iCurGuideId = 0
			self.m_listCurGuide[index] = nil
			break
		end
	end
end

function NewRoleGuideManager:FinishGuideInBattle()
    if self.m_iCurGuideId == NEW_GUIDE_FIRST_TEAM then
        return
    end

	local finishid = self.m_iPreGuideID
	self.m_bLockScreen = false
	self.m_bIsTimeOver = false
	self.m_iCurGuideId = 0
	self:RemoveFromWaitingList(finishid)
	newguidebg.DestroyDialog()
    for index, guide in pairs(self.m_listCurGuide) do
		if guide.id == finishid then
			local winMgr = CEGUI.WindowManager:getSingleton()
			if guide.pGuideDlg then
				winMgr:destroyWindow(guide.pGuideDlg)
			    guide.pGuideDlg = nil
			end

            for i, effect in pairs(self.m_pTargetEffect) do
				if effect then
					Nuclear.GetEngine():ReleaseEffect(effect)
					self.m_pTargetEffect[i] = nil
				end
			end

			if self:GetGuideHighLightWnd(guide.id) then
				self:GetGuideHighLightWnd(guide.id):setTopMost(false)
			end

			self.m_listCurGuide[index] = nil
			break
		end
	end
end

-- 锁屏引导完成不执行下一步
function NewRoleGuideManager:FinishGuideAndNotDoNext(hasEffect)
	local finishid = self.m_iCurGuideId
	self.m_bLockScreen = false
	self.m_bIsTimeOver = true
	newguidebg.DestroyDialog()
    for index, guide in pairs(self.m_listCurGuide) do
		if guide.id == finishid then
			local winMgr = CEGUI.WindowManager:getSingleton()
			if guide.pGuideDlg then
				winMgr:destroyWindow(guide.pGuideDlg)
			    guide.pGuideDlg = nil
			end

            for i, effect in pairs(self.m_pTargetEffect) do
				if effect then
					Nuclear.GetEngine():ReleaseEffect(effect)
					self.m_pTargetEffect[i] = nil
				end
			end

			local pClickWnd = self:GetGuideClickWnd(guide.id, guide.nameClickWnd)
			local pParticleEffect = self:GetGuidePaticleEffectByWnd(pClickWnd)
			if pParticleEffect then
				self.m_bIsNoLock = false
				gGetGameUIManager():RemoveUIEffect(pParticleEffect)
			end

			if self:GetGuideHighLightWnd(guide.id) then
				self:GetGuideHighLightWnd(guide.id):setTopMost(false)
			end

			if hasEffect then
				self:AddParticalEffect(self:GetGuideClickWnd(guide.id))
			end
			break
		end
	end
end

-- 非锁屏引导完成
function NewRoleGuideManager:FinishNoLockGuide(doNext)
	local finishid = self.m_iCurGuideId
	self.m_bIsTimeOver = false
	self.m_bIsNoLock = false
	self.m_iCurGuideId = 0
    for index, guide in pairs(self.m_listCurGuide) do
		if guide.id == finishid then
			local winMgr = CEGUI.WindowManager:getSingleton()
			if guide.pGuideDlg then
				winMgr:destroyWindow(guide.pGuideDlg)
			    guide.pGuideDlg = nil
			end

			local pClickWnd = self:GetGuideClickWnd(guide.id, guide.nameClickWnd)
			local pParticleEffect = self:GetGuidePaticleEffectByWnd(pClickWnd)
			if pParticleEffect then
				gGetGameUIManager():RemoveUIEffect(pParticleEffect)
			end

			-- 继续下一步引导
			if doNext then
			    local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(guide.id)
			    if record and record.step ~= 0 then
				    self:AddToWaitingList(record.step)
			    end
			end

			self.m_listCurGuide[index] = nil
			break
		end
	end
end

-- 锁屏引导完成
function NewRoleGuideManager:FinishGuide()
	local finishid = self.m_iCurGuideId
	self.m_bLockScreen = false
	self.m_bIsTimeOver = false
	self.m_bIsNoLock = false
	self.m_iCurGuideId = 0
	newguidebg.DestroyDialog()
    for index, guide in pairs(self.m_listCurGuide) do
		if guide.id == finishid then
			local winMgr = CEGUI.WindowManager:getSingleton()
			if guide.pGuideDlg then
				winMgr:destroyWindow(guide.pGuideDlg)
			    guide.pGuideDlg = nil
			end

            for i, effect in pairs(self.m_pTargetEffect) do
				if effect then
					Nuclear.GetEngine():ReleaseEffect(effect)
					self.m_pTargetEffect[i] = nil
				end
			end

			if self:GetGuideHighLightWnd(guide.id) then
				self:GetGuideHighLightWnd(guide.id):setTopMost(false)
			end

			-- 继续下一步引导
			local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(guide.id)
			if record and record.step ~= 0 then
				self:AddToWaitingList(record.step)
			end

			self.m_listCurGuide[index] = nil
			break
		end
	end

	self:UnLockBtn()
end

-- 发送某个id的新手引导完成消息
function NewRoleGuideManager:SendGuideFinish(id)
	self:SetGuideStateId(id, true)

    local cmd = require("protodef.fire.pb.cbeginnertipshowed"):new()
	cmd.tipid = id
	LuaProtocolManager:send(cmd)
end

-- 得到某个id的提示窗口
function NewRoleGuideManager:GetGuideDialog(id)
    for _, guide in pairs(self.m_listCurGuide) do
		if guide.id == id then
			return guide.pGuideDlg
		end
	end

	return nil
end

-- 获取点击窗口
function NewRoleGuideManager:GetGuideClickWnd(id, name)
	if not name then
        name = ""
    end
    
    local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(id)
	if not record then
		return nil
	end

	local winMgr = CEGUI.WindowManager:getSingleton()

	if name ~= "" then
		if winMgr:isWindowPresent(name) then
			return winMgr:getWindow(name)
		end
		return nil
	elseif record.usebutton ~= "0" then
		if id == GetNumberValueForStrKey("NEW_GUIDE_ZHENFA1") and GetTeamManager():IsOnTeam() then
			if winMgr:isWindowPresent("teamdialognew/teamView/zhenxing") then
				return winMgr:getWindow("teamdialognew/teamView/zhenxing")
		    end
		else
			if winMgr:isWindowPresent(record.button) then
				return winMgr:getWindow(record.button)
		    end
		end
		return nil
	elseif record.item > 0 then
		if gGetRoleItemManager():GetItemCellAtQuestBag(record.item) then
			return gGetRoleItemManager():GetItemCellAtQuestBag(record.item)
		elseif gGetRoleItemManager():GetItemCellAtBag(record.item) then
			return gGetRoleItemManager():GetItemCellAtBag(record.item)
		end
	elseif id == GetNumberValueForStrKey("NEW_GUIDE_BATTLE_PET_ID") then
		if gGetDataManager():GetBattlePetID() == 0 then
			self:AddToWaitingList(GetNumberValueForStrKey("NEW_GUIDE_NEW_PET_ID"))
		else
			PetPropertyDlgNew.getBattlePet()
			if self:getLuaGetWindow() then
				return self:getLuaGetWindow()
		    end
		end
	elseif id == GetNumberValueForStrKey("NEW_GUIDE_NEW_PET_ID") then
		PetPropertyDlgNew.getNewPet()
		if self:getLuaGetWindow() then
			return self:getLuaGetWindow()
		end
    elseif id == GetNumberValueForStrKey("NEW_GUIDE_NEW_PET_ID_1") then
		PetPropertyDlgNew.getNewPet()
		if self:getLuaGetWindow() then
			return self:getLuaGetWindow()
		end
	elseif id == GetNumberValueForStrKey("NEW_GUIDE_BUSINESS") then
		Comefromtips.getFirstCell()
		if self:getLuaGetWindow() then
			return self:getLuaGetWindow()
		end
    elseif id == GetNumberValueForStrKey("NEW_GUIDE_CHAT") then
        
        local strPrefix = ""
        local sex = gGetDataManager():GetMainCharacterData().sex
		if sex == eSexMale then
             strPrefix = "0"
        else
            strPrefix = "1"
        end
       
        local pWnd = winMgr:getWindow(strPrefix.."insetchatcell")
	    return pWnd
		
               
	end

	return nil
end

function NewRoleGuideManager:CreateGuideEffect()
	-- 框四周特效
	for i = 0, 3 do
		self.m_pTargetEffect[i + 1] = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(10301 + i), true)
		if self.m_pTargetEffect[i + 1] then
			self.m_pTargetEffect[i + 1]:SetLocation(Nuclear.NuclearPoint(-100, -100))
		end
	end
end

function NewRoleGuideManager:removeEquipGuide()
    for index, waitingGuide in pairs(self.m_vWaitingList) do
		local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(waitingGuide.id)
        if record and record.isEquipGuide == 1 then
			self.m_vWaitingList[index] = nil
			break
		end
	end
end

-- 设置某个新手引导完成的状态
function NewRoleGuideManager:SetGuideStateId(guideID, state) 
	self.m_mapGuideState[guideID] = state
end

-- 某个新手引导是否已经完成
function NewRoleGuideManager:isGuideFinish(id)
    local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(id)
    if not record then return false end

    local state = self.m_mapGuideState[id]
	if state ~= nil then
		if not state then
			-- 超过引导等级上限
			if record.level < gGetDataManager():GetMainCharacterLevel() then
				self:SendGuideFinish(id)
				self:RemoveFromWaitingList(id)
				return true
			else
				return false
			end
		end
		return true
	end

	-- 引导结果还没有从服务器获取到
	-- 超过引导等级上限
	if record.level < gGetDataManager():GetMainCharacterLevel() then
		self:SendGuideFinish(id)
		self:RemoveFromWaitingList(id)
		return true
	else
		return false
	end

	return false
end

-- 开始某个新手引导
function NewRoleGuideManager:StartGuide(id, clickName, highlightName)
    if not clickName then
        clickName = ""
    end
    if not highlightName then
        highlightName = ""
    end

 	if not self:getFinshProcess() then
		return
	end

	-- 先判断是否播过引导
	if self:isGuideFinish(id) then
        self:RemoveFromWaitingList(id)
		return
	end

	if self.m_iPreGuideID ~= id then
		self:RemoveFromWaitingList(id)
	end
    
    self:AddToWaitingList(id, clickName, highlightName)
    
	local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(id)
    
	if not record then
        self:RemoveFromWaitingList(id)
		return
	end

	if record.onTeam ~= 0 and GetTeamManager():IsOnTeam() then
		self:RemoveFromWaitingList(id)
		return
	end

	-- 新老玩家引导判断 -1都引导 0新手 1老手
	if record.guideModel ~= -1 and record.guideModel ~= self:getGuideModel() then
		self:RemoveFromWaitingList(id)
		return
	end

	if record.teamInfo ~= 0 then
		setTeamGuideIndex(record.teamInfo)
	end
 
    -- 没有收到引导列表，暂不做引导
    if not self.m_bReceiveGuideList then
        return
	end

    -- 锁屏引导同时只进行一个
	if self.m_iCurGuideId ~= 0 and self.m_iCurGuideId ~= id and (not self.m_bIsTimeOver) and (self.m_bIsNoLock or self.m_bLockScreen) then
		self:FinishGuideAndNotDoNext(false)
        return
	end

	-- 屏幕锁定不进行引导
	local locked = getLocked()
	if locked == 1 then
		return
	end

	self.luaGetWindow = nil

    -- LUA中预处理，解决一些特殊引导
    self.m_iPreGuideID = id
	local ret = LuaNewRoleGuide.PreGuide()
	if ret == 0 then
		return
	end
    
    -- 锁屏引导
    if record.screen == 1 then
        -- 场景动画延迟引导
		if NpcSceneSpeakDialog.isShow() then
			return
	    end

		if gGetMessageManager():isHaveConfirmBox() then
			return
	    end

		self.m_bIsTimeOver = false
        self.m_iCurGuideId = id
        self.m_fLockTime = 0.0
		local pClickWnd = self:GetGuideClickWnd(id, clickName)
		local pHighlightWnd = self:GetGuideHighLightWnd(id, highlightName)

        -- 点击某个按钮的引导
        if pClickWnd and pClickWnd:isVisible() and pHighlightWnd and pHighlightWnd:isVisible() then
			self.m_bLockScreen = true
			-- 如需播放指引动画
			if record.startAni ~= 0 then
				if not self:isTargetInDlg() then
					return
				end
				if not self.startPlayAni then
					self:playGuideAni()
					return
				end
				if not self.endPlayAni then
					return
				end
				if self.aniWindow then
					CEGUI.WindowManager:getSingleton():destroyWindow(self.aniWindow)
					self.aniWindow = nil
				end
			end

			local chatStartId = GetNumberValueForStrKey("NEW_GUIDE_CHAT_START")
			local chatEndId = GetNumberValueForStrKey("NEW_GUIDE_CHAT_END")
			if id < chatStartId or id > chatEndId then
				CChatOutputDialog.ToHide_()
			end

			local guidePetId = GetNumberValueForStrKey("NEW_GUIDE_PET_ID")
			if id == guidePetId and 1 == GetMainPackDlg() then -- 打开背包情况下出宠物引导有问题特殊处理一下
				require "logic.item.mainpackdlg"
                if CMainPackDlg:getInstanceOrNot() then
                    CMainPackDlg:getInstanceOrNot():DestroyDialog()
                end
			end
            -- 阵法引导特殊处理
            local zhenfaId = GetNumberValueForStrKey("NEW_GUIDE_ZHENFA")
            if id == zhenfaId then
                TeamDialogNew.DestroyDialog()
                require("logic.shop.shoplabel").hide()
                ZhenFaDlg.DestroyDialog()
                require "logic.team.huobanzhuzhandialog"
                HuoBanZhuZhanDialog.DestroyDialog()
                require "logic.item.mainpackdlg"
                if CMainPackDlg:getInstanceOrNot() then
                    CMainPackDlg:getInstanceOrNot():DestroyDialog()
                end
            end
			local guideEquipId = GetNumberValueForStrKey("NEW_GUIDE_EQUIP_ID")
			local guideEquipId2 = GetNumberValueForStrKey("NEW_GUIDE_EQUIP_ID2")
			local guideEquipId3 = GetNumberValueForStrKey("NEW_GUIDE_EQUIP_ID3")
			local guideEquipId4 = GetNumberValueForStrKey("NEW_GUIDE_EQUIP_ID4")
			if (id == guideEquipId or id == guideEquipId2 or id == guideEquipId3 or id == guideEquipId4) and 1 == GetMainPackDlg() then
				require "logic.item.mainpackdlg"
                if CMainPackDlg:getInstanceOrNot() then
                    CMainPackDlg:getInstanceOrNot():setScrollPosByCell(record.item)
                end
			end
			if record.functionid == 0 then
				YinCang.CShowAllEx()
			end
            self:AddGuideToWindow(id, pHighlightWnd, pClickWnd, record.text)
		elseif record.battlePos ~= 0 then -- 战斗选择敌人引导
			ZhanDouAnNiu.HideZhandouAnNiu()
			local winMgr = CEGUI.WindowManager:getSingleton()
            local str = ""
            str = str .. "guidedlg"
            if record.uiposition ~= 0 then
                str = str .. tostring(record.uiposition)
            end
            str = str .. ".layout"
			local pGuideDlg = winMgr:loadWindowLayout(str, tostring(id))
            if pGuideDlg then
				CEGUI.System:getSingleton():getGUISheet():addChildWindow(pGuideDlg)

                local pEffect = LockEffect:new()
                pGuideDlg:getGeometryBuffer():setRenderEffect(pEffect)
            end

            -- 没有文字提示
            if record.text == "" then
                self:FinishGuide()
                return
			-- 文字提示
            else
                local str2 = ""
				str2 = str2 .. tostring(id)
				str2 = str2 .. "guidedlg"
                if record.uiposition ~= 0 then
					str2 = str2 .. tostring(record.uiposition)
                end
				str2 = str2 .. "/text"
				local pContentBox = CEGUI.toRichEditbox(winMgr:getWindow(str2))
                if pContentBox then
                    pContentBox:setReadOnly(true)
                    pContentBox:SetHoriAutoCenter(true)
                    pContentBox:SetVertAutoCenter(true)
                    pContentBox:SetForceHideVerscroll(true)
					pContentBox:setMaxTextLength(30)
                    local strFormatMsg = CEGUI.String(record.text)
                    pContentBox:AppendParseText(strFormatMsg)
                    pContentBox:Refresh()		
                end
            end

            local Inf = stGuideInf:new()
            Inf.id = id
			Inf.HighLightRect = GetBattleManager():GetBattlerRect(record.battlePos)
            Inf.pGuideDlg = pGuideDlg
            Inf.nameClickWnd = ""
            Inf.nameHighlightWnd = ""
            Inf.ClickRect = Inf.HighLightRect
            table.insert(self.m_listCurGuide, Inf)
            
			if record.guideType == 1 then -- 方框特效
				self:CreateGuideEffect()
			elseif record.guideType == 0 then  -- 圆圈特效
				self.m_pTargetEffect[5] = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(record.guideEffectId), true)
				if self.m_pTargetEffect[5] then
					self.m_pTargetEffect[5]:SetLocation(Nuclear.NuclearPoint(-100, -100))
				end
				if record.assistEffectId ~= -1 then -- 手特效
					self.m_pTargetEffect[6] = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(record.assistEffectId), true)
				end
			end
			pClickWnd = GetBattleManager():GetBattlerWindow(record.battlePos)
			gGetGameUIManager():RemoveUIEffect(pClickWnd)

			pClickWnd:SetGuideState(true)
			pClickWnd:removeEvent("GuideEnd")
			pClickWnd:subscribeEvent("GuideEnd", NewRoleGuideManager.HandleGuideEnd, self)
            
            -- 成功显示则发送结束消息
            self:SendGuideFinish(id)
            self:RemoveFromWaitingList(id)
			if GetBattleManager():IsInBattle() then
				gGetGameUIManager():CloseDialogBeforeBattle()
			end
        else
            self.m_iCurGuideId = 0
            self.m_bLockScreen = false  -- 没找到引导窗口，解除锁屏
        end
    elseif record.screen == 0 then	-- 粒子特效引导
		self.m_iCurGuideId = id
		local pTargetWnd = self:GetGuideClickWnd(id)
        if pTargetWnd and pTargetWnd:isVisible() then
			--YinCang.CShowAllEx()
			local pGuideDlg = nil
			self.m_bIsNoLock = true
			self.m_fNoLockTime = 0.0
			if record.text == "" then
			else -- 文字提示
				local winMgr = CEGUI.WindowManager:getSingleton()
				local str = ""
				str = str .. "guidedlg"
				if record.uiposition ~= 0 then
					str = str .. tostring(record.uiposition)
				end
				str = str .. ".layout"
				pGuideDlg = winMgr:loadWindowLayout(str, tostring(id))
				if pGuideDlg then
					CEGUI.System:getSingleton():getGUISheet():addChildWindow(pGuideDlg)
					pGuideDlg:setTopMost(true)

					local pEffect = LockEffect:new()
					pGuideDlg:getGeometryBuffer():setRenderEffect(pEffect)
				end
				local str1 = ""
				str1 = str1 .. tostring(id)
				str1 = str1 .. "guidedlg"
				if record.uiposition ~= 0 then
					str1 = str1 .. tostring(record.uiposition)
				end
				str1 = str1 .. "/text"
				local pContentBox = CEGUI.toRichEditbox(winMgr:getWindow(str1))
				if pContentBox then
					pContentBox:setReadOnly(true)
					pContentBox:SetHoriAutoCenter(true)
					pContentBox:SetVertAutoCenter(true)
					pContentBox:SetForceHideVerscroll(true)
					pContentBox:setMaxTextLength(30)
					local strFormatMsg = CEGUI.String(record.text)
					pContentBox:AppendParseText(strFormatMsg)
					pContentBox:Refresh()
				end
			end

            local Inf = stGuideInf:new()
            Inf.id = id
			Inf.pGuideDlg = pGuideDlg
            Inf.nameHighlightWnd = pTargetWnd:getName()
            Inf.nameClickWnd = pTargetWnd:getName()
			Inf.HighLightRect = Nuclear.NuclearFRectt(Nuclear.NuclearFPoint(pTargetWnd:GetScreenPos().x, pTargetWnd:GetScreenPos().y), pTargetWnd:getPixelSize().width, pTargetWnd:getPixelSize().height)
			Inf.ClickRect = Nuclear.NuclearFRectt(0, 0, 0, 0)
            table.insert(self.m_listCurGuide, Inf)

			self:AddParticalToWnd(pTargetWnd, true)
			pTargetWnd:SetGuideState(true)
			pTargetWnd:removeEvent("GuideEnd")
			pTargetWnd:subscribeEvent("GuideEnd", NewRoleGuideManager.HandleNoLockGuideEnd, self)
            self:SendGuideFinish(id)
            self:RemoveFromWaitingList(id)
        end
    end
end

-- 获取高亮窗口
function NewRoleGuideManager:GetGuideHighLightWnd(id, name)
	if not name then
        name = ""
    end
    
    local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(id)
	if not record then
		return nil
	end

	local winMgr = CEGUI.WindowManager:getSingleton()
    
    if name ~= "" then
        if winMgr:isWindowPresent(name) then
			return winMgr:getWindow(name)
		end
		return nil
	elseif record.button ~= "0" then
		if id == GetNumberValueForStrKey("NEW_GUIDE_ZHENFA1") and GetTeamManager():IsOnTeam() then
			if winMgr:isWindowPresent("teamdialognew/teamView/zhenxing") then
				return winMgr:getWindow("teamdialognew/teamView/zhenxing")
		    end
		else
			if winMgr:isWindowPresent(record.button) then
				return winMgr:getWindow(record.button)
		    end
		end
		return nil
    elseif record.item > 0 then
		if gGetRoleItemManager():GetItemCellAtQuestBag(record.item) then
            return gGetRoleItemManager():GetItemCellAtQuestBag(record.item)
        elseif gGetRoleItemManager():GetItemCellAtBag(record.item) then
            return gGetRoleItemManager():GetItemCellAtBag(record.item)
		end
	-- 引导宠物下阵特殊处理
	elseif id == GetNumberValueForStrKey("NEW_GUIDE_BATTLE_PET_ID") then
		if gGetDataManager():GetBattlePetID() == 0 then
			self:AddToWaitingList(GetNumberValueForStrKey("NEW_GUIDE_NEW_PET_ID"))
		else
			PetPropertyDlgNew.getBattlePet()
			if self:getLuaGetWindow() then
				return self:getLuaGetWindow()
		    end
		end
	-- 引导新宠物上阵特殊处理
	elseif id == GetNumberValueForStrKey("NEW_GUIDE_NEW_PET_ID") then
		PetPropertyDlgNew.getNewPet()
		if self:getLuaGetWindow() then
			return self:getLuaGetWindow()
		end
    elseif id == GetNumberValueForStrKey("NEW_GUIDE_NEW_PET_ID_1") then
		PetPropertyDlgNew.getNewPet()
		if self:getLuaGetWindow() then
			return self:getLuaGetWindow()
		end
	elseif id == GetNumberValueForStrKey("NEW_GUIDE_BUSINESS") then
		Comefromtips.getFirstCell()
		if self:getLuaGetWindow() then
			return self:getLuaGetWindow()
		end
    elseif id == GetNumberValueForStrKey("NEW_GUIDE_CHAT") then
        
        local strPrefix = ""
        local sex = gGetDataManager():GetMainCharacterData().sex
		if sex == eSexMale then
             strPrefix = "0"
        else
            strPrefix = "1"
        end
       
         local pWnd = winMgr:getWindow(strPrefix.."insetchatcell")
	     return pWnd
		
               
	
	end
	return nil
end

-- 按钮引导
function NewRoleGuideManager:AddGuideToWindow(id, pHightLightWnd, pClickWnd, guideText)
	if pHightLightWnd and pClickWnd then
		local winMgr = CEGUI.WindowManager:getSingleton()
        
        local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(id)
        if not record then
            self:FinishGuide()
            return
        end

        local str = ""
        str = str .. "guidedlg"
        if record.uiposition ~= 0 then
            str = str .. tostring(record.uiposition)
        end
        str = str .. ".layout"

		local pGuideDlg = winMgr:loadWindowLayout(str, tostring(id))
		if pGuideDlg then
			CEGUI.System:getSingleton():getGUISheet():addChildWindow(pGuideDlg)
			if not GetBattleManager():IsInBattle() then
				pGuideDlg:setTopMost(true)
			else
				pGuideDlg:setAlwaysOnTop(true)
            end

            -- 需要锁屏则使用锁屏特效
            if self.m_bLockScreen then
                local pEffect = LockEffect:new()
                pGuideDlg:getGeometryBuffer():setRenderEffect(pEffect)
            end
        end

		-- 没有文字提示
        if guideText == "" then
            self:FinishGuide()
            return
		-- 文字提示
        else
			local str2 = ""
			str2 = str2 .. tostring(id)
			str2 = str2 .. "guidedlg"
            if record.uiposition ~= 0 then
				str2 = str2 .. tostring(record.uiposition)
            end
			str2 = str2 .. "/text"
			local pContentBox = CEGUI.toRichEditbox(winMgr:getWindow(str2))
            if pContentBox then
                pContentBox:setReadOnly(true)
                pContentBox:SetHoriAutoCenter(true)
                pContentBox:SetVertAutoCenter(true)
                pContentBox:SetForceHideVerscroll(true)
				pContentBox:setMaxTextLength(30)
                local strFormatMsg = CEGUI.String(guideText)
                pContentBox:AppendParseText(strFormatMsg)
                pContentBox:Refresh()       
            end
        end

        local Inf = stGuideInf:new()
        Inf.id = id
        Inf.pGuideDlg = pGuideDlg
        Inf.nameHighlightWnd = pHightLightWnd:getName()
        Inf.nameClickWnd = pClickWnd:getName()
		if string.find(pClickWnd:getType(), "RichEditbox") then -- 设置RichEditbox中的高亮区域
			local pt = CEGUI.Vector2()
			local cpnSize = CEGUI.Size()
			local pBox = CEGUI.toRichEditbox(pHightLightWnd)
            if pBox then
				local pCpn = pBox:GetFirstLinkTextCpn()
                if pCpn then
                    pt = pBox:GetCpnScreenPos(pCpn)
                    cpnSize = pCpn:getPixelSize()
                end
            end
			Inf.HighLightRect = Nuclear.NuclearFRectt(Nuclear.NuclearFPoint(pHightLightWnd:GetScreenPos().x, pt.y + 6), pHightLightWnd:getPixelSize().width, cpnSize.height)
            Inf.ClickRect = Inf.HighLightRect
        else
			Inf.HighLightRect = Nuclear.NuclearFRectt(Nuclear.NuclearFPoint(pHightLightWnd:GetScreenPos().x, pHightLightWnd:GetScreenPos().y), pHightLightWnd:getPixelSize().width, pHightLightWnd:getPixelSize().height)
			Inf.ClickRect = Inf.HighLightRect
        end
        table.insert(self.m_listCurGuide, Inf)

		if record.guideType == 1 then -- 方框特效
			self:CreateGuideEffect()
		elseif record.guideType == 0 then  -- 圆圈特效
			self.m_pTargetEffect[5] = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(record.guideEffectId), true)
			if self.m_pTargetEffect[5] then
				self.m_pTargetEffect[5]:SetLocation(Nuclear.NuclearPoint(-100, -100))
			end

			if record.assistEffectId ~= -1 then -- 手特效
				self.m_pTargetEffect[6] = Nuclear.GetEngine():CreateEffect(MHSD_UTILS.get_effectpath(record.assistEffectId), true)
				if self.m_pTargetEffect[6] then
					self.m_pTargetEffect[6]:SetLocation(Nuclear.NuclearPoint(-100, -100))
			    end
			end
		end

        gGetGameUIManager():RemoveUIEffect(pClickWnd)
        pClickWnd:SetGuideState(true)
		pClickWnd:removeEvent("GuideEnd")
		pClickWnd:subscribeEvent("GuideEnd", NewRoleGuideManager.HandleGuideEnd, self)

        -- 成功显示则发送结束消息
        self:SendGuideFinish(id)
        self:RemoveFromWaitingList(id)
        if GetBattleManager():IsInBattle() then
            gGetGameUIManager():CloseDialogBeforeBattle()
        end
		self.startPlayAni = false
		self.endPlayAni = false
	end
end

function NewRoleGuideManager:Run(elapse)
	for first, _ in pairs(self.m_mapGuidePaticle) do
		self.m_mapGuidePaticle[first] = self.m_mapGuidePaticle[first] + elapse
	end
    
    for _, waitingGuide in pairs(self.m_vWaitingList) do
        self:StartGuide(waitingGuide.id, waitingGuide.nameClickWnd, waitingGuide.nameHighlightWnd)
        break
	end
    
	if self.m_iCurGuideId ~= 0 and self:GetGuideClickWnd(self.m_iCurGuideId)
		and self:GetGuideDialog(self.m_iCurGuideId) and self:GetGuideClickWnd(self.m_iCurGuideId):getEffectiveAlpha() < 0.05 then
        self:GetGuideDialog(self.m_iCurGuideId):setVisible(false)
	elseif self.m_iCurGuideId ~= 0 and self:GetGuideClickWnd(self.m_iCurGuideId) and self:GetGuideDialog(self.m_iCurGuideId) and (not self.m_bIsTimeOver) and (not self.m_bIsNoLock) then
        self:GetGuideDialog(self.m_iCurGuideId):setVisible(true)
        self:UpdateGuideRect()
	end

	if self.m_iCurGuideId ~= 0 and self.m_bIsNoLock and self:GetGuideClickWnd(self.m_iCurGuideId) then
		local pTargetWnd = self:GetGuideClickWnd(self.m_iCurGuideId)
		if pTargetWnd and (not pTargetWnd:isVisible()) then
			self:FinishNoLockGuide(true)
	    end
	end

	if self:GetGuideClickWnd(self.m_iCurGuideId) and self.startPlayAni and (not self.endPlayAni) then
		self:calculateDistance()
	end

	if self.m_iCurGuideId ~= 0 and self:GetGuideDialog(self.m_iCurGuideId) and self.isMoveToBack and self:isTargetInDlg() then
		self:GetGuideDialog(self.m_iCurGuideId):moveToFront()
		self.isMoveToBack = false
	end

	if self.m_iCurGuideId ~= 0 and self:GetGuideDialog(self.m_iCurGuideId) and (not self.isMoveToBack) and (not self:isTargetInDlg()) then
		self:GetGuideDialog(self.m_iCurGuideId):moveToBack()
		self.isMoveToBack = true
	end
    
    if self.m_bLockScreen then
        self.m_fLockTime = self.m_fLockTime + elapse
		if self.m_fLockTime > self.lockTime and (not self:getGuideIsAllwaysLock()) then
			self:FinishGuideAndNotDoNext(true)
        end
	elseif (not self.m_bLockScreen) and self.m_iCurGuideId ~= 0 and (not self.m_bIsTimeOver) and self.m_bIsNoLock then  -- 非锁屏引导自动触发下一条
		self.m_fNoLockTime = self.m_fNoLockTime + elapse
		if self.m_fNoLockTime > self.noLockTime and (not self:getGuideIsAllwaysLock()) then
			self:FinishNoLockGuide(true)
		end
	end

	if self.m_bIsNoLock and self.m_iCurGuideId ~= 0 and (not self:GetGuideClickWnd(self.m_iCurGuideId)) then
		self:FinishNoLockGuide(true)
	end

	if self.m_iCurGuideId == 0 then
		newguidebg.DestroyDialog()
	end
end

function NewRoleGuideManager:ShowLockEffect()
    local guideInf = stGuideInf:new()
    for _, guide in pairs(self.m_listCurGuide) do
		if guide.id == self.m_iCurGuideId then
			guideInf = guide
            break
		end
	end

    if guideInf.pGuideDlg == nil then
        return
    end
    CEGUI.System:getSingleton():getRenderer():endRendering()

    -- 四个角特效
    if self.m_pTargetEffect[1] then
		self.m_pTargetEffect[1]:SetLocation(Nuclear.NuclearPoint(guideInf.HighLightRect.left, guideInf.HighLightRect.top))
        Nuclear.GetEngine():DrawEffect(self.m_pTargetEffect[1])
	end
 
    if self.m_pTargetEffect[2] then
		self.m_pTargetEffect[2]:SetLocation(Nuclear.NuclearPoint(guideInf.HighLightRect.left, guideInf.HighLightRect.bottom))
        Nuclear.GetEngine():DrawEffect(self.m_pTargetEffect[2])
	end

    if self.m_pTargetEffect[3] then
		self.m_pTargetEffect[3]:SetLocation(Nuclear.NuclearPoint(guideInf.HighLightRect.right, guideInf.HighLightRect.top))
        Nuclear.GetEngine():DrawEffect(self.m_pTargetEffect[3])
	end

    if self.m_pTargetEffect[4] then
		self.m_pTargetEffect[4]:SetLocation(Nuclear.NuclearPoint(guideInf.HighLightRect.right, guideInf.HighLightRect.bottom))
        Nuclear.GetEngine():DrawEffect(self.m_pTargetEffect[4])
	end

	if self.m_pTargetEffect[5] then
		self.m_pTargetEffect[5]:SetLocation((Nuclear.NuclearPoint(guideInf.HighLightRect.right - (guideInf.HighLightRect.right - guideInf.HighLightRect.left) / 2, guideInf.HighLightRect.top - (guideInf.HighLightRect.top - guideInf.HighLightRect.bottom) / 2)))
		Nuclear.GetEngine():DrawEffect(self.m_pTargetEffect[5])
	end

	if self.m_pTargetEffect[6] then
		self.m_pTargetEffect[6]:SetLocation((Nuclear.NuclearPoint(guideInf.HighLightRect.right - (guideInf.HighLightRect.right - guideInf.HighLightRect.left) / 2, guideInf.HighLightRect.top - (guideInf.HighLightRect.top - guideInf.HighLightRect.bottom) / 2)))
		Nuclear.GetEngine():DrawEffect(self.m_pTargetEffect[6])
	end
    
    -- 更新位置
	local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(self.m_iCurGuideId)
    if record then
	    if record.textposition == 1 then        -- 左上内
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.left))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.top - guideDlgYoffset - guideInf.pGuideDlg:getPixelSize().height))
	    elseif record.textposition == 2 then    -- 右上内
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.right + guideDlgXoffset))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.top - guideDlgYoffset - guideInf.pGuideDlg:getPixelSize().height))
	    elseif record.textposition == 3 then    -- 右下外
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.right + guideDlgXoffset))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.bottom + guideDlgYoffset))
	    elseif record.textposition == 4 then    -- 左下内
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.left))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.bottom + guideDlgYoffset))
	    elseif record.textposition == 5 then    -- 左下外
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.left - guideDlgXoffset - guideInf.pGuideDlg:getPixelSize().width))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.bottom + guideDlgYoffset))
	    elseif record.textposition == 6 then    -- 左上外
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.left - guideDlgXoffset - guideInf.pGuideDlg:getPixelSize().width))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.top - guideDlgYoffset - guideInf.pGuideDlg:getPixelSize().height))
	    elseif record.textposition == 7 then    -- 左中
 		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.left - guideDlgXoffset - guideInf.pGuideDlg:getPixelSize().width + 10))
 		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.top - (guideInf.HighLightRect.top - guideInf.HighLightRect.bottom) / 2 - guideInf.pGuideDlg:getPixelSize().height / 2))
	    elseif record.textposition == 8 then    -- 右中
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.right + guideDlgXoffset))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.top - (guideInf.HighLightRect.top - guideInf.HighLightRect.bottom) / 2 - guideInf.pGuideDlg:getPixelSize().height / 2))
	    elseif record.textposition == 9 then    -- 右上外
		    guideInf.pGuideDlg:setXPosition(CEGUI.UDim(0,guideInf.HighLightRect.right + guideDlgXoffset))
		    guideInf.pGuideDlg:setYPosition(CEGUI.UDim(0,guideInf.HighLightRect.top - guideDlgYoffset - guideInf.pGuideDlg:getPixelSize().height * 2.5))
	    end
    end
    CEGUI.System:getSingleton():getRenderer():beginRendering()
end

function NewRoleGuideManager:canShowChatView()
    if self.m_bIsTimeOver then
        return true
    end

    if self.m_iCurGuideId == NEW_GUIDE_FIRST_TEAM then
        return false
    end

    if GetTeamManager() and GetTeamManager():isPrepareToGuideTeam() then
        return false
    end

    return true
end

return NewRoleGuideManager
