require "utils.tableutil"
require "protodef.rpcgen.fire.pb.skill.particleskill.particleskill"
SRequestParticleSkillList = {}
SRequestParticleSkillList.__index = SRequestParticleSkillList



SRequestParticleSkillList.PROTOCOL_TYPE = 800504

function SRequestParticleSkillList.Create()
	print("enter SRequestParticleSkillList create")
	return SRequestParticleSkillList:new()
end
function SRequestParticleSkillList:new()
	local self = {}
	setmetatable(self, SRequestParticleSkillList)
	self.type = self.PROTOCOL_TYPE
	self.skilllist = {}
	self.curcontribution = 0

	return self
end
function SRequestParticleSkillList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestParticleSkillList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.skilllist))
	for k,v in ipairs(self.skilllist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.curcontribution)
	return _os_
end

function SRequestParticleSkillList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_skilllist=0 ,_os_null_skilllist
	_os_null_skilllist, sizeof_skilllist = _os_: uncompact_uint32(sizeof_skilllist)
	for k = 1,sizeof_skilllist do
		----------------unmarshal bean
		self.skilllist[k]=ParticleSkill:new()

		self.skilllist[k]:unmarshal(_os_)

	end
	self.curcontribution = _os_:unmarshal_int32()
	return _os_
end

return SRequestParticleSkillList
