require "logic.dialog"

familybossBloodBar = {}
setmetatable(familybossBloodBar, Dialog)
familybossBloodBar.__index = familybossBloodBar

local _instance
function familybossBloodBar.getInstance()
	if not _instance then
		_instance = familybossBloodBar:new()
		_instance:OnCreate()
	end
	return _instance
end

function familybossBloodBar.getInstanceAndShow()
	if not _instance then
		_instance = familybossBloodBar:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function familybossBloodBar.getInstanceNotCreate()
	return _instance
end

function familybossBloodBar.DestroyDialog()
	if _instance then 
        if _instance.m_aniopen then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:destroyAnimationInstance(_instance.m_aniopen)
        end
        if _instance.m_aniopen1 then
            local aniMan = CEGUI.AnimationManager:getSingleton()
            aniMan:destroyAnimationInstance(_instance.m_aniopen1)
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function familybossBloodBar.ToggleOpenClose()
	if not _instance then
		_instance = familybossBloodBar:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function familybossBloodBar.GetLayoutFileName()
	return "zhandouwaiboss.layout"
end

function familybossBloodBar:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familybossBloodBar)
	return self
end

function familybossBloodBar:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.blood = {}
    self.m_IsTick = false
    self.m_Time = 0 
    self.zhandouwai = winMgr:getWindow("zhandouwaiboss/bossxuetiao/effet")
    self.base = winMgr:getWindow("zhandouwaiboss/bosstouxiangtubiao")
	self.headicon = CEGUI.toItemCell(winMgr:getWindow("zhandouwaiboss/bosstouxiangdi"))
	self.bloodBar = CEGUI.toProgressBar(winMgr:getWindow("zhandouwaiboss/bossxuetiao"))
    self.bossName = winMgr:getWindow("zhandouwaiboss/bossming")
    self.bossNameBg = winMgr:getWindow("zhandouwaiboss/di")
    self.NormalTime= winMgr:getWindow("zhandouwaiboss/daojishi1")
    self.NormalTimeText= winMgr:getWindow("zhandouwaiboss/cd1")
    self.battleTime = winMgr:getWindow("zhandouwaiboss/daojishi2")
    self.battleTimeText = winMgr:getWindow("zhandouwaiboss/cd2")
    
    self.aniWindow = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {},
        [6] = {},
        [7] = {},
        [8] = {},
        [9] = {},
        [10] = {},
        [11] = {},
    }
    self.aniWindow[1].name = winMgr:getWindow("zhandouwaiboss/maozi1")
    self.aniWindow[1].blood = winMgr:getWindow("zhandouwaiboss/shuzhi1")
    self.aniWindow[2].name = winMgr:getWindow("zhandouwaiboss/maozi2")
    self.aniWindow[2].blood = winMgr:getWindow("zhandouwaiboss/shuzhi2")
    self.aniWindow[3].name = winMgr:getWindow("zhandouwaiboss/maozi3")
    self.aniWindow[3].blood = winMgr:getWindow("zhandouwaiboss/shuzhi3")
    self.aniWindow[4].name = winMgr:getWindow("zhandouwaiboss/maozi4")
    self.aniWindow[4].blood = winMgr:getWindow("zhandouwaiboss/shuzhi4")
    self.aniWindow[5].name = winMgr:getWindow("zhandouwaiboss/maozi5")
    self.aniWindow[5].blood = winMgr:getWindow("zhandouwaiboss/shuzhi5")
    self.aniWindow[6].name = winMgr:getWindow("zhandouwaiboss/maozi6")
    self.aniWindow[6].blood = winMgr:getWindow("zhandouwaiboss/shuzhi6")
    self.aniWindow[7].name = winMgr:getWindow("zhandouwaiboss/maozi7")
    self.aniWindow[7].blood = winMgr:getWindow("zhandouwaiboss/shuzhi7")
    self.aniWindow[8].name = winMgr:getWindow("zhandouwaiboss/maozi8")
    self.aniWindow[8].blood = winMgr:getWindow("zhandouwaiboss/shuzhi8")
    self.aniWindow[9].name = winMgr:getWindow("zhandouwaiboss/maozi9")
    self.aniWindow[9].blood = winMgr:getWindow("zhandouwaiboss/shuzhi9")
    self.aniWindow[10].name = winMgr:getWindow("zhandouwaiboss/maozi10")
    self.aniWindow[10].blood = winMgr:getWindow("zhandouwaiboss/shuzhi10")
    self.aniWindow[11].name = winMgr:getWindow("zhandouwaiboss/maozi11")
    self.aniWindow[11].blood = winMgr:getWindow("zhandouwaiboss/shuzhi11")
    
    self.zhandounei = winMgr:getWindow("zhandouwaiboss/zhandouneiboss/bossxuetiao/effet")
    self.battlebase = winMgr:getWindow("zhandouwaiboss/zhandouneiboss/bosstouxiangtubiao")
	self.battleheadicon = CEGUI.toItemCell(winMgr:getWindow("zhandouwaiboss/zhandouneiboss/bosstouxiangdi"))
	self.battlebloodBar = CEGUI.toProgressBar(winMgr:getWindow("zhandouwaiboss/zhandouneiboss/bossxuetiao"))
    self.battleBossName = winMgr:getWindow("zhandouwaiboss/bossming1")
    self.battlebossNameBg = winMgr:getWindow("zhandouwaiboss/di2")
    self.zhandouwai:setVisible(false)
    self.zhandounei:setVisible(false)
        
    self:setState(1)
end

function familybossBloodBar:initInfo(bossMonsterID, hp, maxhp, roleName, blood)
    local NpcBase= BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(bossMonsterID)
    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(NpcBase.modelID)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.headicon:SetImage(image)
    self.bloodBar:setProgress(hp/maxhp)
	self.battleheadicon:SetImage(image)
    self.battlebloodBar:setProgress(hp/maxhp)
    self.bossName:setText(NpcBase.name)
    self.battleBossName:setText(NpcBase.name)
    
    local nStrEn = tostring(math.ceil(hp*100/maxhp)) .. "%"
    self.bloodBar:setText(nStrEn)
    self.battlebloodBar:setText(nStrEn)

    if roleName ~= "" and blood ~= 0 then
        local bloodInfo = {
        blood = blood,
        roleName = roleName
        }
        table.insert(self.blood, bloodInfo)
    end
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        self:setState(2)
    else
        self:setState(1)
    end
end

function familybossBloodBar:setState(state)
    if state == 1 then
        self.state = 1
        self.base:setVisible(true)
        self.headicon:setVisible(true)
        self.bloodBar:setVisible(true)
        self.bossName:setVisible(true)
        self.bossNameBg:setVisible(true)
        self.battlebase:setVisible(false)
        self.battleheadicon:setVisible(false)
        self.battlebloodBar:setVisible(false)
        self.battleBossName:setVisible(false)
        self.battlebossNameBg:setVisible(false)
    else
        self.state = 2
        self.base:setVisible(false)
        self.headicon:setVisible(false)
        self.bloodBar:setVisible(false)
        self.bossName:setVisible(false)
        self.bossNameBg:setVisible(false)
        self.battlebase:setVisible(true)
        self.battleheadicon:setVisible(true)
        self.battlebloodBar:setVisible(true)
        self.battleBossName:setVisible(true)
        self.battlebossNameBg:setVisible(true)
    end
end

function familybossBloodBar:run(dt)
    if self.m_IsTick == false and #self.blood ~= 0 then
        local info = nil
        for k,v in pairs(self.blood) do
            info = v
            table.remove(self.blood, k)
            break
        end
        if info then
            self:animation(info.roleName, info.blood)
        end
    end

    local manager = require("manager.buffmanager").getInstance()
    if manager then
        if manager.mapBuff[500344] and math.floor(manager.mapBuff[500344].time) > 0 then
            if GetBattleManager():IsInBattle() then
                self.battleTime:setVisible(true)
                self.battleTimeText:setVisible(true)
                self.battleTime:setText(tostring(math.floor(manager.mapBuff[500344].time)))
                self.NormalTime:setVisible(false)
                self.NormalTimeText:setVisible(false)
            else
                self.battleTime:setVisible(false)
                self.battleTimeText:setVisible(false)
                self.NormalTime:setVisible(true)
                self.NormalTimeText:setVisible(true)
                self.NormalTime:setText(tostring(math.floor(manager.mapBuff[500344].time)))
            end
        else
            self.battleTime:setVisible(false)
            self.battleTimeText:setVisible(false)
            self.NormalTime:setVisible(false)
            self.NormalTimeText:setVisible(false)
        end
    end
end

function familybossBloodBar:animation(name, blood)
    self.m_IsTick = true
    local index
    if self.state == 1 then
        index = math.random(1, 6)
    else
        index = math.random(7, 11)
    end
    self.aniWindow[index].name:setText(name)
    self.aniWindow[index].blood:setText(blood)
    local aniMan = CEGUI.AnimationManager:getSingleton()
    if aniMan then
        if self.m_aniopen then
            aniMan:destroyAnimationInstance(self.m_aniopen)
        end
        if self.m_anihit then
            aniMan:destroyAnimationInstance(self.m_anihit)
        end
    end
    self.animationOpen = aniMan:getAnimation("CombatEffect1")
    self.m_aniopen = aniMan:instantiateAnimation(self.animationOpen)
    self.aniWindow[index].name:setVisible(true)
    self.m_aniopen:setTargetWindow(self.aniWindow[index].name)
    self.aniWindow[index].name:subscribeEvent("AnimationEnded", self.HandleAnimationOver, self)
    self.m_aniopen:unpause()

    self.animationOpen1 = aniMan:getAnimation("CombatEffect1")
    self.m_aniopen1 = aniMan:instantiateAnimation(self.animationOpen1)
    self.aniWindow[index].blood:setVisible(true)
    self.m_aniopen1:setTargetWindow(self.aniWindow[index].blood)
    self.aniWindow[index].blood:subscribeEvent("AnimationEnded", self.HandleAnimation1Over, self)
    self.m_aniopen1:unpause()
    
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        local aniMan = CEGUI.AnimationManager:getSingleton()
        self.animationHit = aniMan:getAnimation("biankuangred")
        self.m_anihit = aniMan:instantiateAnimation(self.animationHit)
        self.m_anihit:setTargetWindow(self.zhandounei)
        self.zhandounei:setVisible(true)
        self.zhandounei:subscribeEvent("AnimationEnded", self.HandleAnimationHitOver, self)
        self.m_anihit:unpause()
    else
        local aniMan = CEGUI.AnimationManager:getSingleton()
        self.animationHit = aniMan:getAnimation("biankuangred")
        self.m_anihit = aniMan:instantiateAnimation(self.animationHit)
        self.m_anihit:setTargetWindow(self.zhandouwai)
        self.zhandouwai:setVisible(true)
        self.zhandouwai:subscribeEvent("AnimationEnded", self.HandleAnimationHitOver, self)
        self.m_anihit:unpause()
    end
end

function familybossBloodBar:HandleAnimation1Over(args)
    self.m_aniopen1:stop()
    self.m_IsTick = false
end

function familybossBloodBar:HandleAnimationOver(args)
    self.m_aniopen:stop()
    self.m_IsTick = false  
end

function familybossBloodBar:HandleAnimationHitOver(args)
    self.m_anihit:stop() 
    self.zhandouwai:setVisible(false)
    self.zhandounei:setVisible(false)
end
return familybossBloodBar