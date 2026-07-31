require "utils.tableutil"
CRequestLiveSkillList = {}
CRequestLiveSkillList.__index = CRequestLiveSkillList



CRequestLiveSkillList.PROTOCOL_TYPE = 800513

function CRequestLiveSkillList.Create()
	print("enter CRequestLiveSkillList create")
	return CRequestLiveSkillList:new()
end
function CRequestLiveSkillList:new()
	local self = {}
	setmetatable(self, CRequestLiveSkillList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestLiveSkillList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestLiveSkillList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestLiveSkillList:unmarshal(_os_)
	return _os_
end

return CRequestLiveSkillList
