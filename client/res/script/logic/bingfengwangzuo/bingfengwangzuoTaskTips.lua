require "logic.dialog"

bingfengTaskTips = {}
setmetatable(bingfengTaskTips, Dialog)
bingfengTaskTips.__index = bingfengTaskTips

local _instance
function bingfengTaskTips.getInstance()
	if not _instance then
		_instance = bingfengTaskTips:new()
		_instance:OnCreate()
	end
	return _instance
end

function bingfengTaskTips.getInstanceAndShow()
	if not _instance then
		_instance = bingfengTaskTips:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function bingfengTaskTips.getInstanceNotCreate()
	return _instance
end

function bingfengTaskTips.DestroyDialog()
	if _instance then
        NotificationCenter.removeObserver(Notifi_TeamListChange, bingfengTaskTips.handleEventMemberChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function bingfengTaskTips.ToggleOpenClose()
	if not _instance then
		_instance = bingfengTaskTips:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function bingfengTaskTips.GetLayoutFileName()
	return "jingyingfuben_mtg.layout"
end

function bingfengTaskTips:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengTaskTips)
	return self
end

function bingfengTaskTips:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    local curModalTarget = CEGUI.System:getSingleton():getModalTarget()
    if curModalTarget then
        self:GetWindow():setAlpha(0)
    end

	self.m_pCell = CEGUI.toPushButton(winMgr:getWindow("jingyingfuben_mtgcell"))
	self.m_pName = winMgr:getWindow("jingyingfuben_mtg/name")
	self.m_pFightText = winMgr:getWindow("jingyingfuben_mtg/mark")
	self.m_pNowStage = CEGUI.toRichEditbox(winMgr:getWindow("jingyingfuben_mtg/main"))
	self.m_pLeaveTeam = CEGUI.toPushButton(winMgr:getWindow("jingyingfuben_mtg/lidui"))
	self.m_pButtonMap = CEGUI.toPushButton(winMgr:getWindow("jingyingfuben_mtgcell/btnditu"))
	self.m_pLeaveButton = CEGUI.toPushButton(winMgr:getWindow("jingyingfuben_mtgcell/btnlikai"))
    if GetTeamManager():IsOnTeam()==true then
        self.m_pLeaveTeam:setVisible(true)
    end
	self.m_pName:setText(MHSD_UTILS.get_resstring(11339))
	self.m_pCell:EnableClickAni(false);
	self.m_pLeaveButton:setVisible(true);
	self.m_pButtonMap:setVisible(true);
	self.m_pFightText:setVisible(false);
	self.m_pButtonMap:subscribeEvent("MouseClick", bingfengTaskTips.HandleMapBtnClicked, self);
	self.m_pLeaveButton:subscribeEvent("MouseClick",bingfengTaskTips.HandleLeaveBtnClicked, self);
	self.m_pCell:subscribeEvent("MouseClick", bingfengTaskTips.HandleTextClicked, self);
	self.m_pLeaveTeam:subscribeEvent("MouseClick", bingfengTaskTips.HandleLeaveTeamClicked, self);
    NotificationCenter.addObserver(Notifi_TeamListChange, bingfengTaskTips.handleEventMemberChange)
    self.zoneId = 0
    self.stageId = 0
    self.progress = 0.0
    self.nowShowNpcBaseId = 0
end

function bingfengTaskTips.handleEventMemberChange()
    if _instance.m_pLeaveTeam then
        local isOnTeam = GetTeamManager():IsOnTeam()
        _instance.m_pLeaveTeam:setVisible(isOnTeam)
    end
end

--刷新左侧面板和当前npc
function bingfengTaskTips:updateInfo( _zoneId, _stageId, goTo, finishstage)
    self.zoneId = _zoneId
    self.stageId = _stageId
    print(self.zoneId.."sssssss"..self.stageId)
    local  p = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(self:getIndexId(self.zoneId, self.stageId))
    if not p then
        return
    end
    local npcBaseId = p.FocusNpc
    if p.levelall == 0 then
        self.progress = 0.0
    else
        self.progress = self.stageId / p.levelall
    end
	gGetScene():HideJumpEffect();
	local info = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(self:getIndexId(self.zoneId, self.stageId));
	if gGetScene():GetMapID() ~= info.Map then
		gGetScene():ShowJumpEffect();
	end
    -- 保存新的npcID
    self.nowShowNpcBaseId = npcBaseId
    self.m_pNowStage:Clear()
    if p.levelall ~= p.state then-- 不是最后一个npc
        local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(npcBaseId)
        if config then
            local npcName = config.name
            local text = GameTable.message.GetCMessageTipTableInstance():getRecorder(144852).msg
            text = string.gsub(text, "%$parameter%$", tostring(self.stageId+1))
            text = string.gsub(text, "%$parameter2%$", npcName)
            self.m_pNowStage:AppendParseText(CEGUI.String(text))
        end
    else -- 是最后一个npc
        self.m_pNowStage:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(2703)));
    end
    self.m_pNowStage:AppendBreak();
    self.m_pNowStage:Refresh();
   
	if goTo > 0 then
		self:HandleTextClicked();
	end
end

function bingfengTaskTips:getIndexId(zoneId, stageId)
    local index = zoneId * 100 + stageId
    return index
end

function bingfengTaskTips:HandleTextClicked(args)
    local p = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(self:getIndexId(self.zoneId, self.stageId));
    -- 寻路到传送点
	if self.stageId-1 >= 0 then
		local lastInfo = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(self:getIndexId(self.zoneId, self.stageId - 1))
		if lastInfo.boss == 1 and gGetScene():GetMapID() ~= p.Map then
			local loc = gGetScene():getJumpPoint1Pos()
			local mapId = gGetScene():GetMapID()
            GetMainCharacter():FlyOrWarkToPos(mapId, loc.x, loc.y, 0)
			return true;
		end
	end
    if p then
        local mapId = p.Map
        local npcBaseId = p.FocusNpc
        local pNpc = gGetScene():FindNpcByBaseID(npcBaseId)
        --寻路到npc怪处
        if pNpc then
            local x = pNpc:GetNpcConfig().xPos
            local y = pNpc:GetNpcConfig().yPos
            local npcKey = pNpc:GetID()
            if p.state ~= p.levelall then
                GetMainCharacter():FlyOrWarkToPos(mapId, x, y, npcBaseId)
            end
        end
    end
    return true
end

function bingfengTaskTips:HandleMapBtnClicked(args)
    local p = require "protodef.fire.pb.instancezone.bingfeng.creqbingfengrank".new()
    local level = 1
    if GetMainCharacter():GetLevel() >= 90 then
        level = 3
    elseif GetMainCharacter():GetLevel() >= 70  then
        level = 2
    end
    p.landid = level
    require "manager.luaprotocolmanager":send(p)
    return true
end

function bingfengTaskTips:HandleLeaveBtnClicked(args)
    local send = require "protodef.fire.pb.instancezone.bingfeng.cleavebingfengland":new()
    require "manager.luaprotocolmanager":send(send)
	return true;
end

function bingfengTaskTips:HandleLeaveTeamClicked(args)
	if not GetTeamManager():IsOnTeam() then
		GetCTipsManager():AddMessageTipById(160486);
		return true;
	end
	GetTeamManager():RequestQuitTeam();
	return true
end

return bingfengTaskTips
