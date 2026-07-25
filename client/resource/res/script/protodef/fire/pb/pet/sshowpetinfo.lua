require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SShowPetInfo = {}
SShowPetInfo.__index = SShowPetInfo



SShowPetInfo.PROTOCOL_TYPE = 788457

function SShowPetInfo.Create()
	print("enter SShowPetInfo create")
	return SShowPetInfo:new()
end
function SShowPetInfo:new()
	local self = {}
	setmetatable(self, SShowPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.isxunbaopet = 0
	self.petdata = Pet:new()

	return self
end
function SShowPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SShowPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.isxunbaopet)
	----------------marshal bean
	self.petdata:marshal(_os_) 
	return _os_
end

function SShowPetInfo:unmarshal(_os_)
	self.isxunbaopet = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.petdata:unmarshal(_os_)

	return _os_
end

return SShowPetInfo
