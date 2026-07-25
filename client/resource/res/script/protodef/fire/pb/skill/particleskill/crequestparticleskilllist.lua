require "utils.tableutil"
CRequestParticleSkillList = {}
CRequestParticleSkillList.__index = CRequestParticleSkillList



CRequestParticleSkillList.PROTOCOL_TYPE = 800503

function CRequestParticleSkillList.Create()
	print("enter CRequestParticleSkillList create")
	return CRequestParticleSkillList:new()
end
function CRequestParticleSkillList:new()
	local self = {}
	setmetatable(self, CRequestParticleSkillList)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestParticleSkillList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestParticleSkillList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestParticleSkillList:unmarshal(_os_)
	return _os_
end

return CRequestParticleSkillList
