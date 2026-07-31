BattleZhenFa = {}

setmetatable(BattleZhenFa, Dialog);
BattleZhenFa.__index = BattleZhenFa;

local _instance;

function BattleZhenFa.getInstance()
	if _instance == nil then
		_instance = BattleZhenFa:new();
		_instance:OnCreate();
	end

	return _instance;
end

function BattleZhenFa.peekInstance()
	return _instance;
end

function BattleZhenFa.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function BattleZhenFa:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, BattleZhenFa);

	return zf;
end

function BattleZhenFa.GetLayoutFileName()
	return "zhenfainfo.layout";
end

function BattleZhenFa:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_pFriend = winMgr:getWindow("zhenfainfo/right");
	self.m_pEnemy  = winMgr:getWindow("zhenfainfo/left");

	self.m_pFriend:subscribeEvent("MouseClick", BattleZhenFa.HandleFriendClicked, self);
	self.m_pEnemy:subscribeEvent("MouseClick", BattleZhenFa.HandleEnemyClicked, self);
	
	self.m_iFriendZf = GetBattleManager():GetFriendFormation();
	self.m_iEnemyZf = GetBattleManager():GetEnemyFormation();

	self.m_iFriendZfLv = GetBattleManager():GetFriendFormationLvl();
	self.m_iEnemyZfLv = GetBattleManager():GetEnemyFormationLvl();

	self.m_bFriendBeikezhi = self:IsFriendFormationForbear();
	self.m_bEnemyBeikezhi = self:IsEnemyFormationForbear();

	local fc = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(self.m_iFriendZf);
	local fc2 = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(self.m_iEnemyZf);

	self.m_pFriend:setProperty("Image", fc.imagepath);
	self.m_pEnemy:setProperty("Image", fc2.imagepath);

	print(self.m_iFriendZfLv, self.m_iEnemyZfLv, "+++++++++++++");

	if self.m_iFriendZf == 0 then
		self.m_pFriend:setVisible(false);
	end

	if self.m_iEnemyZf == 0 then
		self.m_pEnemy:setVisible(false);
	end

	if self.m_bFriendBeikezhi == true then
        local bShow = true
        if GetBattleManager() and GetBattleManager():IsOnBattleWatch() then
            bShow = false
        end
        if bShow then
		    GetCTipsManager():AddMessageTipById(145371)
        end
	end

	self:GetWindow():moveToBack()
end

function BattleZhenFa:IsContainFormationID(formationIdsStr, formationid)
    for id in formationIdsStr:gmatch("(%d+)") do
        if tonumber(id) == formationid then
            return true
        end
    end
    return false
end

function BattleZhenFa:IsFriendFormationForbear()
    if self.m_iFriendZf ~= 0 then
        local formation = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(self.m_iFriendZf)
        if formation then
            if self:IsContainFormationID(formation.fear1, self.m_iEnemyZf) or self:IsContainFormationID(formation.fear2, self.m_iEnemyZf) then
                return true
            end
        end
    end
    return false
end

function BattleZhenFa:IsEnemyFormationForbear()
    if self.m_iEnemyZf ~= 0 then
        local formation = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(self.m_iEnemyZf)
        if formation then
            if self:IsContainFormationID(formation.fear1, self.m_iFriendZf) or self:IsContainFormationID(formation.fear2, self.m_iFriendZf) then
                return true
            end
        end
    end
    return false
end

function BattleZhenFa:HandleFriendClicked(arg)
	local zf = ZhenFaTip.getInstance();
	zf:SetZhenfaConfig(self.m_iFriendZf, self.m_iFriendZfLv, self.m_iEnemyZf)
end

function BattleZhenFa:HandleEnemyClicked(arg)
	local zf = ZhenFaTip.getInstance();
	zf:SetZhenfaConfig(self.m_iEnemyZf, self.m_iEnemyZfLv, self.m_iFriendZf)
end

