GuideManager = {}
GuideManager.__index = GuideManager

------------------- public: -----------------------------------
--成就数据管理
local _instance;
function GuideManager.getInstance()
	LogInfo("enter get GuideManager instance")
	if not _instance then
		_instance = GuideManager:new()
	end
	
	return _instance
end

function GuideManager.getInstanceNotCreate()
	return _instance
end

function GuideManager.Destroy()
	if _instance then
		_instance = nil
	end
end

function GuideManager:new()
	local self = {}
	setmetatable(self, GuideManager)


    self.m_leftLabelData = {}
    self.m_CellData={}

    self.m_leftLabelCount = 0 
    --根据服务器的数据计算第一个可以领取的等级标签
    self.m_SelectLabel = 1
    self.m_Effectid = 0
    --当前应该显示的cell
    self.m_SelectCell = 0
    self.m_CellCount = 0
    --服务器 数据
    self.m_CellStatus = {}
    self.m_HasHongdian = false
    local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourse")):getAllID()
    for i=1,#ids do
        local v = ids[i]
		local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourse")):getRecorder(v)
        table.insert(self.m_CellStatus, record.id, 0)
    end
    

	return self
end

function GuideManager:HasHongdian()
    self.m_HasHongdian = false
    self.m_Effectid = 0
    self.m_SelectLabel = 99
    for i,v in pairs(self.m_CellStatus) do
        if v == 0 then
            local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourse")):getRecorder(i)
            if record and record.group < self.m_SelectLabel then
                self.m_SelectLabel = record.group
            end
        end
    end
    for i,v in pairs(self.m_CellStatus) do
        if v == 1 then
            local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourse")):getRecorder(i)
            local data = gGetDataManager():GetMainCharacterData()
		    local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
            --判断等级是否达到
            if nLvl + 10 >= record.enterlevel then
                self.m_HasHongdian = true
                if self.m_Effectid == 0 then
                    self.m_Effectid = record.id
                    self.m_SelectLabel = record.group
                else
                    if self.m_Effectid > record.id then
                        self.m_Effectid = record.id
                        self.m_SelectLabel = record.group
                    end
                end
            end
        end
    end
    if self.m_SelectLabel == 99 then
        self.m_SelectLabel = 1
    end
end
function GuideManager:getData()
    self:getLabelData()
    self:getCellData()
    
end
function GuideManager:sortData()
    table.sort(self.m_CellData, function(a,b) return a.id<b.id end)
    local CellDataFinish = {}
    local CellDataNormal = {}
    local CellDataGet={}

    for i,v in pairs(self.m_CellData) do
        if self.m_CellStatus[v.id] == 1 then
            table.insert(CellDataFinish, v)
        elseif self.m_CellStatus[v.id] == 0 then
            table.insert(CellDataNormal, v)
        elseif self.m_CellStatus[v.id] == 2 then
            table.insert(CellDataGet, v)
        end
    end

    self.m_CellData = {}

    for i,v in pairs(CellDataFinish) do
        table.insert(self.m_CellData, v)
    end
    for i,v in pairs(CellDataNormal) do
        table.insert(self.m_CellData, v)
    end
    for i,v in pairs(CellDataGet) do
        table.insert(self.m_CellData, v)
    end
    
end
function GuideManager:getCellData()
    self.m_CellData={}
    self.m_CellCount = 0
    local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourse")):getAllID()
    local data = gGetDataManager():GetMainCharacterData()
	local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    for i=1,#ids do
		local v = ids[i]
		local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourse")):getRecorder(v)
        if record.group == self.m_SelectLabel then
           table.insert(self.m_CellData, record)
           self.m_CellCount = self.m_CellCount + 1
        end
    end
    self:sortData()
end
function GuideManager:getLabelData()
    self.m_leftLabelData = {}
    self.m_leftLabelCount = 0
    -- has vector
    local cguidecourselabel = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourselabel"))
    local data = gGetDataManager():GetMainCharacterData()
	local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
    local len = cguidecourselabel:getSize()
    --计算需要显示label的数量
    for i=1,len do
		local record = BeanConfigManager.getInstance():GetTableByName(CheckTableName("mission.cguidecourselabel")):getRecorder(i)
        if nLvl + 10 >= record.level then
           table.insert(self.m_leftLabelData,record)
           self.m_leftLabelCount = self.m_leftLabelCount + 1
        end
    end
end
return GuideManager
