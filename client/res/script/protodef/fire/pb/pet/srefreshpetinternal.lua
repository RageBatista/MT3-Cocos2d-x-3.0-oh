require "utils.tableutil"
require "protodef.rpcgen.fire.pb.petskill"
SRefreshPetInternal = {}
SRefreshPetInternal.__index = SRefreshPetInternal



SRefreshPetInternal.PROTOCOL_TYPE = 788455

function SRefreshPetInternal.Create()
	print("enter SRefreshPetInternal create")
	return SRefreshPetInternal:new()
end
function SRefreshPetInternal:new()
	local self = {}
	setmetatable(self, SRefreshPetInternal)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.skills = {}
	self.expiredtimes = {}

	return self
end
function SRefreshPetInternal:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetInternal:marshal(ostream)
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

function SRefreshPetInternal:unmarshal(_os_)
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

return SRefreshPetInternal
