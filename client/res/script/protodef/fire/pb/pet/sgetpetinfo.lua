require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SGetPetInfo = {}
SGetPetInfo.__index = SGetPetInfo



SGetPetInfo.PROTOCOL_TYPE = 788526

function SGetPetInfo.Create()
	print("enter SGetPetInfo create")
	return SGetPetInfo:new()
end
function SGetPetInfo:new()
	local self = {}
	setmetatable(self, SGetPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.petinfo = Pet:new()

	return self
end
function SGetPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.petinfo:marshal(_os_) 
	return _os_
end

function SGetPetInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.petinfo:unmarshal(_os_)

	return _os_
end

return SGetPetInfo
