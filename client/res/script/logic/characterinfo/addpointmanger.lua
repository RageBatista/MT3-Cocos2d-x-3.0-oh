require "utils.mhsdutils"
require "logic.dialog"

AddPointManager = {}
AddPointManager.__index = AddPointManager
local _instance;
function AddPointManager.getInstance()
	LogInfo("enter get AddPointManager instance")
    if not _instance then
        _instance = AddPointManager:new()
    end
    
    return _instance
end
function AddPointManager.getInstanceNotCreate()
    return _instance
end
function AddPointManager.Destroy()
	if _instance then 
		LogInfo("destroy AddPointManager")
		gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
		_instance = nil
	end
end
function AddPointManager.getInstanceAndUpdate()
	LogInfo("AddPointManager.getInstanceExistAndUpdate")
	if not _instance then
        _instance = AddPointManager:new()
    end
	_instance:Update()
	characterpropertyaddptrresetdlg.getInstanceExistAndShow()
    return _instance

end

function AddPointManager:new()
    local self = {}
	setmetatable(self, AddPointManager)
	self:Init()

    	return self
end
function AddPointManager:Init()
	LogInfo("AddPointManager Init")

	self.totalPoint = 0
	self.surplus = 0
	-- 3组方案
	self.addedpointschemeArray = {
							{2, 2, 2, 3, 4}, 
							{1, 3, 2, 3, 4}, 
							{5, 2, 3, 1, 1}, 
						};
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(AddPointManager.getInstanceAndUpdate)
	self.m_hookData = {}
	self:Update()
end

function AddPointManager:Update()
	LogInfo("AddPointManager Update")
	local data = gGetDataManager():GetMainCharacterData()
	
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	self.totalPoint = level*5
	self.surplus = 0
	local map1 = data.cons_save
	local map2 = data.iq_save
	local map3 = data.str_save
	local map4 = data.endu_save
	local map5 = data.agi_save
	for idxMap1  = 1 , 3 do
		self.addedpointschemeArray[idxMap1][1] = map1[idxMap1]
	end
	for idxMap2  = 1 , 3 do
		self.addedpointschemeArray[idxMap2][2] = map2[idxMap2]
	end
	for idxMap3  = 1 , 3 do
		self.addedpointschemeArray[idxMap3][3] = map3[idxMap3]
	end
	for idxMap4  = 1 , 3 do
		self.addedpointschemeArray[idxMap4][4] = map4[idxMap4]
	end	
	for idxMap5  = 1 , 3 do
		self.addedpointschemeArray[idxMap5][5] = map5[idxMap5]
	end
	
end
function AddPointManager:GetAddedPoint( schemeID, protype )
    self:Update()
	if protype > 5 then
		local total = 0
		for v = 1 , 5 do
			total = total + self.addedpointschemeArray[schemeID][v]	
		end
		return total
	end
	return self.addedpointschemeArray[schemeID][protype]	
end
function AddPointManager:GetSurplusPoint( schemeID )
    self:Update()
	local Point = 0
	local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	self.totalPoint = level * 5
	for v = 1 , 5 do
		Point = self.addedpointschemeArray[schemeID][v] + Point
	end

	--剩余点数
	self.surplus = self.totalPoint - Point
	return self.surplus
end
function AddPointManager:GetTotalPointByIndex(protypeIndex)
	local data = gGetDataManager():GetMainCharacterData()
	local tili = data:GetValue(fire.pb.attr.AttrType.CONS)
	local moli = data:GetValue(fire.pb.attr.AttrType.IQ)
    local naili = data:GetValue(fire.pb.attr.AttrType.ENDU)
	local minjie = data:GetValue(fire.pb.attr.AttrType.AGI)
	local liliang = data:GetValue(fire.pb.attr.AttrType.STR)
	local array = {tili, moli, liliang, naili, minjie}
	return array[protypeIndex]
end

function AddPointManager:GetAllProResetPoint(schemeID)
    self:Update()
	local Point = 0
	for v = 1 , 5 do
		Point = self.addedpointschemeArray[schemeID][v] + Point
	end
	return Point
end
return AddPointManager
