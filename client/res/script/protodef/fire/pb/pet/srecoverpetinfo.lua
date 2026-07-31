require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SRecoverPetInfo = {}
SRecoverPetInfo.__index = SRecoverPetInfo



SRecoverPetInfo.PROTOCOL_TYPE = 788588

function SRecoverPetInfo.Create()
	print("enter SRecoverPetInfo create")
	return SRecoverPetInfo:new()
end
function SRecoverPetInfo:new()
	local self = {}
	setmetatable(self, SRecoverPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.petinfo = Pet:new()

	return self
end
function SRecoverPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRecoverPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.petinfo:marshal(_os_) 
	return _os_
end

function SRecoverPetInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.petinfo:unmarshal(_os_)

	return _os_
end

return SRecoverPetInfo
