require "utils.tableutil"
CRequestLearnParticleSkill = {}
CRequestLearnParticleSkill.__index = CRequestLearnParticleSkill



CRequestLearnParticleSkill.PROTOCOL_TYPE = 800505

function CRequestLearnParticleSkill.Create()
	print("enter CRequestLearnParticleSkill create")
	return CRequestLearnParticleSkill:new()
end
function CRequestLearnParticleSkill:new()
	local self = {}
	setmetatable(self, CRequestLearnParticleSkill)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.times = 0
	self.itemid = 0

	return self
end
function CRequestLearnParticleSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestLearnParticleSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.times)
	_os_:marshal_int32(self.itemid)
	return _os_
end

function CRequestLearnParticleSkill:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.times = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int32()
	return _os_
end

return CRequestLearnParticleSkill
