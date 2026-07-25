
require "utils.binutil"

CEquipMakeInfoTable = {}
CEquipMakeInfoTable.__index = CEquipMakeInfoTable

function CEquipMakeInfoTable:new()
	local self = {}
	setmetatable(self, CEquipMakeInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipMakeInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipMakeInfoTable:getAllID()
	return self.allID
end

function CEquipMakeInfoTable:getSize()
	return self.memberCount
end

function CEquipMakeInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=6164943 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.nlevel = util:Load_int()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.tuzhiid = util:Load_int()
		if not status then return false end
		status,bean.tuzhinum = util:Load_int()
		if not status then return false end
		status,bean.hantieid = util:Load_int()
		if not status then return false end
		status,bean.hantienum = util:Load_int()
		if not status then return false end
		status,bean.zhizaofuid = util:Load_int()
		if not status then return false end
		status,bean.zhizaofunum = util:Load_int()
		if not status then return false end
		status,bean.qianghuaid = util:Load_int()
		if not status then return false end
		status,bean.qianghuanum = util:Load_int()
		if not status then return false end
		status,bean.moneynum = util:Load_int()
		if not status then return false end
		status,bean.moneytype = util:Load_int()
		if not status then return false end
		status,bean.chanchuequipid = util:Load_int()
		if not status then return false end
		status,bean.vptdazhaoid = util:Load_Vint()
		if not status then return false end
		status,bean.vptdazhaorate = util:Load_Vint()
		if not status then return false end
		status,bean.vqhdazhaoid = util:Load_Vint()
		if not status then return false end
		status,bean.vqhdazhaorate = util:Load_Vint()
		if not status then return false end
		status,bean.vcailiaotie = util:Load_Vint()
		if not status then return false end
		status,bean.vcailiaotienum = util:Load_Vint()
		if not status then return false end
		status,bean.vcailiaozhizaofu = util:Load_Vint()
		if not status then return false end
		status,bean.vcailiaozhizaofunum = util:Load_Vint()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipMakeInfoTable
