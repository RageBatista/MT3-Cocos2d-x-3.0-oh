
require "utils.binutil"

CArrowEffectSimpTable = {}
CArrowEffectSimpTable.__index = CArrowEffectSimpTable

function CArrowEffectSimpTable:new()
	local self = {}
	setmetatable(self, CArrowEffectSimpTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CArrowEffectSimpTable:getRecorder(id)
	return self.m_cache[id]
end

function CArrowEffectSimpTable:getAllID()
	return self.allID
end

function CArrowEffectSimpTable:getSize()
	return self.memberCount
end

function CArrowEffectSimpTable:LoadBeanFromBinFile(filename)
	local util = BINUtil:new()
	local ret = util:init(filename)
	if not ret then
		return false
	end
	local status=1
	local fileType,fileLength,version,memberCount,checkNumber
	status,fileType=util:Load_int()
	if not status then return false end
	if fileType~=1499087948 then
		return false
	end
	status,fileLength=util:Load_int()
	if not status then return false end
	status,version=util:Load_short()
	if not status then return false end
	if version~=101 then
		return false
	end
	status,memberCount=util:Load_short()
	if not status then return false end
	self.memberCount=memberCount
	status,checkNumber=util:Load_int()
	if not status then return false end
	if checkNumber~=1966587 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.step = util:Load_int()
		if not status then return false end
		status,bean.task = util:Load_int()
		if not status then return false end
		status,bean.startlevel = util:Load_int()
		if not status then return false end
		status,bean.level = util:Load_int()
		if not status then return false end
		status,bean.screen = util:Load_int()
		if not status then return false end
		status,bean.button = util:Load_string()
		if not status then return false end
		status,bean.usebutton = util:Load_string()
		if not status then return false end
		status,bean.item = util:Load_int()
		if not status then return false end
		status,bean.skill = util:Load_int()
		if not status then return false end
		status,bean.text = util:Load_string()
		if not status then return false end
		status,bean.uiposition = util:Load_int()
		if not status then return false end
		status,bean.textposition = util:Load_int()
		if not status then return false end
		status,bean.imagename = util:Load_string()
		if not status then return false end
		status,bean.cleareffect = util:Load_int()
		if not status then return false end
		status,bean.functionid = util:Load_int()
		if not status then return false end
		status,bean.battleId = util:Load_int()
		if not status then return false end
		status,bean.battleRoundId = util:Load_int()
		if not status then return false end
		status,bean.battlePos = util:Load_int()
		if not status then return false end
		status,bean.startAni = util:Load_int()
		if not status then return false end
		status,bean.isAllwaysLock = util:Load_int()
		if not status then return false end
		status,bean.conditionItemId = util:Load_int()
		if not status then return false end
		status,bean.onTeam = util:Load_int()
		if not status then return false end
		status,bean.guideType = util:Load_int()
		if not status then return false end
		status,bean.guideEffectId = util:Load_int()
		if not status then return false end
		status,bean.assistEffectId = util:Load_int()
		if not status then return false end
		status,bean.effectScale = util:Load_int()
		if not status then return false end
		status,bean.teamInfo = util:Load_int()
		if not status then return false end
		status,bean.guideModel = util:Load_int()
		if not status then return false end
		status,bean.isEquipGuide = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CArrowEffectSimpTable
