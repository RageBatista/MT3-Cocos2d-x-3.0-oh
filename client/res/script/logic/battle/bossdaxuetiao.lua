require "logic.dialog"

bossdaxuetiao = {}
setmetatable(bossdaxuetiao, Dialog)
bossdaxuetiao.__index = bossdaxuetiao

local _instance
function bossdaxuetiao.getInstance()
	if not _instance then
		_instance = bossdaxuetiao:new()
		_instance:OnCreate()
	end
	return _instance
end

function bossdaxuetiao.getInstanceAndShow()
	if not _instance then
		_instance = bossdaxuetiao:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function bossdaxuetiao.getInstanceNotCreate()
	return _instance
end

function bossdaxuetiao.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function bossdaxuetiao.ToggleOpenClose()
	if not _instance then
		_instance = bossdaxuetiao:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function bossdaxuetiao.GetLayoutFileName()
	return "bossdaxuetiao.layout"
end

function bossdaxuetiao:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bossdaxuetiao)
	return self
end

function bossdaxuetiao:OnCreate()
	Dialog.OnCreate(self)
    
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.battlerList = {}

    for i = 1,3 do
        local info = {}
	    info.bID = 0
	    info.MonsterID = 0
	    info.MaxHP = 1.0
	    info.HP = 1.0    
        if i == 1 then
            info.lyout = winMgr:getWindow("bossdaxuetiao")
	        info.headicon = winMgr:getWindow("bossdaxuetiao/bosstouxiangtubiao")
	        info.bloodBar = CEGUI.toProgressBar(winMgr:getWindow("bossdaxuetiao/bossxuetiao"))
            info.name = winMgr:getWindow("bossdaxuetiao/name")
        else
            info.lyout = winMgr:getWindow("bossdaxuetiao".. tostring(i))
	        info.headicon = winMgr:getWindow("bossdaxuetiao".. tostring(i) .."/bosstouxiangtubiao")
	        info.bloodBar = CEGUI.toProgressBar(winMgr:getWindow("bossdaxuetiao".. tostring(i) .."/bossxuetiao"))
            info.name = winMgr:getWindow("bossdaxuetiao".. tostring(i) .."/name")
        end
        info.lyout:setVisible(false)
        info.lyout:setAlwaysOnBottom(true)
	    table.insert(self.battlerList,info)
    end
    self.used = 0
end
function bossdaxuetiao:OnClose()
	Dialog.OnClose(self)
    
    local sz = #self.battlerList
    for index  = 1, sz do
        table.remove(self.battlerList,1)
	end
    self.battlerList = nil
end

function bossdaxuetiao:setUseCount(usecount)
    if self.used >= usecount then
        return
    end
    self.used = usecount
    if self.used == 1 then
        self.battlerList[1].lyout:setVisible(false)
        self.battlerList[2].lyout:setVisible(false)
        self.battlerList[3].lyout:setVisible(true)
    elseif self.used == 2 then

        self:SetMonsterID(self.battlerList[3].bID,self.battlerList[3].MonsterID)

        self.battlerList[1].lyout:setVisible(true)
        self.battlerList[2].lyout:setVisible(true)
        self.battlerList[3].lyout:setVisible(false)
    else 
        self.battlerList[1].lyout:setVisible(false)
        self.battlerList[2].lyout:setVisible(false)
        self.battlerList[3].lyout:setVisible(false)
    end
end
function bossdaxuetiao:getBattlerData(battleID)
    
    local info
    local usecount = 0
    for i=1,#self.battlerList do
        usecount = usecount + 1
        info = self.battlerList[i]
        if info.bID == 0 then
            info.bID = battleID
            if i == 1 then
                self.battlerList[3].bID = battleID
            end
            break
        end 
        if info.bID == battleID then
            break
        end 
    end
    self:setUseCount(usecount)

    for i=1,#self.battlerList do
        info = self.battlerList[i]
        if info.bID == battleID then
            if self.used == 1 then
                if i == 1 then
                    info = self.battlerList[3]
                end
            end
            break
        end 
    end
    return info
end

function bossdaxuetiao:SetMonsterID(battleID, MonsterID)
    local info = self:getBattlerData(battleID)
    if info == nil then return end
	info.MonsterID = MonsterID
    local NpcBase= GameTable.npc.GetCMonsterConfigTableInstance():getRecorder(info.MonsterID)
    if NpcBase.modelID == 0 then
        return
    end
    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(NpcBase.modelID)
	local iconPath = gGetIconManager():GetImagePathByID(shapeData.littleheadID):c_str()
	info.headicon:setProperty("Image",iconPath)
    info.name:setText(NpcBase.name)
end
function bossdaxuetiao:SetHP(battleID, HP)
    local info = self:getBattlerData(battleID)
    if info == nil then return end
	info.HP = HP
	self:SetHPMaxHP(battleID,info.HP, info.MaxHP)
end
function bossdaxuetiao:SetMaxHP(battleID, MaxHP)
    local info = self:getBattlerData(battleID)
    if info == nil then return end
	info.MaxHP = MaxHP
	self:SetHPMaxHP(battleID, info.HP, info.MaxHP)
end
function bossdaxuetiao:SetHPMaxHP(battleID, HP, MaxHP)
    local info = self:getBattlerData(battleID)
    if info == nil then return end
	info.HP = HP
	info.MaxHP = MaxHP
	info.bloodBar:setProgress(info.HP / info.MaxHP)
end

function bossdaxuetiao.CSetMonsterID(battleID,MonsterID)
	if bossdaxuetiao.getInstanceNotCreate() == nil then
		return
	end
	bossdaxuetiao.getInstanceAndShow():SetMonsterID(battleID,MonsterID)
end
function bossdaxuetiao.CSetHP(battleID,HP)
	if bossdaxuetiao.getInstanceNotCreate() == nil then
		return
	end
	bossdaxuetiao.getInstanceAndShow():SetHP(battleID,HP)
end
function bossdaxuetiao.CSetMaxHP(battleID,MaxHP)
	if bossdaxuetiao.getInstanceNotCreate() == nil then
		return
	end
	bossdaxuetiao.getInstanceAndShow():SetMaxHP(battleID,MaxHP)
end
function bossdaxuetiao.CSetHPMaxHP(battleID,HP, MaxHP)
	if bossdaxuetiao.getInstanceNotCreate() == nil then
		return
	end
	bossdaxuetiao.getInstanceAndShow():SetHPMaxHP(battleID,HP, MaxHP)
end
function bossdaxuetiao.CSetVisible(Visible)
	if Visible == false then
		if bossdaxuetiao.getInstanceNotCreate() == nil then
			return
		end
	end
	bossdaxuetiao.getInstance():SetVisible(Visible)
end

return bossdaxuetiao