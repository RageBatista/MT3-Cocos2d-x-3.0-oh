require "utils.tableutil"
require "protodef.rpcgen.fire.pb.petskill"
SRefreshPetSkill = {}
SRefreshPetSkill.__index = SRefreshPetSkill



SRefreshPetSkill.PROTOCOL_TYPE = 788454

function SRefreshPetSkill.Create()
	print("enter SRefreshPetSkill create")
	return SRefreshPetSkill:new()
end
function SRefreshPetSkill:new()
	local self = {}
	setmetatable(self, SRefreshPetSkill)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.skills = {}
	self.expiredtimes = {}

	return self
end
function SRefreshPetSkill:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetSkill:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.skills))
	for k,v in ipairs(self.skills) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.expiredtimes))
	for k,v in pairs(self.expiredtimes) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRefreshPetSkill:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_skills=0 ,_os_null_skills
	_os_null_skills, sizeof_skills = _os_: uncompact_uint32(sizeof_skills)
	for k = 1,sizeof_skills do
		----------------unmarshal bean
		self.skills[k]=Petskill:new()

		self.skills[k]:unmarshal(_os_)

	end
	----------------unmarshal map
	local sizeof_expiredtimes=0,_os_null_expiredtimes
	_os_null_expiredtimes, sizeof_expiredtimes = _os_: uncompact_uint32(sizeof_expiredtimes)
	for k = 1,sizeof_expiredtimes do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.expiredtimes[newkey] = newvalue
	end
	return _os_
end

return SRefreshPetSkill
