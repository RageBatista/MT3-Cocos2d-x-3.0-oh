require "utils.tableutil"
require "protodef.rpcgen.fire.pb.skill.particleskill.particleskill"
SUpdateLearnParticleSkill = {}
SUpdateLearnParticleSkill.__index = SUpdateLearnParticleSkill



SUpdateLearnParticleSkill.PROTOCOL_TYPE = 800506

function SUpdateLearnParticleSkill.Create()
	print("enter SUpdateLearnParticleSkill create")
	return SUpdateLearnParticleSkill:new()
end
function SUpdateLearnParticleSkill:new()
	local self = {}
	setmetatable(self, SUpdateLearnParticleSkill)
	self.type = self.PROTOCOL_TYPE
	self.skill = ParticleSkill:new()

	return self
end
function SUpdateLearnParticleSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateLearnParticleSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.skill:marshal(_os_) 
	return _os_
end

function SUpdateLearnParticleSkill:unmarshal(_os_)
	----------------unmarshal bean

	self.skill:unmarshal(_os_)

	return _os_
end

return SUpdateLearnParticleSkill
