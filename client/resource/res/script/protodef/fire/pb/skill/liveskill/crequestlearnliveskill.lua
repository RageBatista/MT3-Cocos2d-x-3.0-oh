require "utils.tableutil"
CRequestLearnLiveSkill = {}
CRequestLearnLiveSkill.__index = CRequestLearnLiveSkill



CRequestLearnLiveSkill.PROTOCOL_TYPE = 800515

function CRequestLearnLiveSkill.Create()
	print("enter CRequestLearnLiveSkill create")
	return CRequestLearnLiveSkill:new()
end
function CRequestLearnLiveSkill:new()
	local self = {}
	setmetatable(self, CRequestLearnLiveSkill)
	self.type = self.PROTOCOL_TYPE
	self.id = 0

	return self
end
function CRequestLearnLiveSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestLearnLiveSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	return _os_
end

function CRequestLearnLiveSkill:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	return _os_
end

return CRequestLearnLiveSkill
