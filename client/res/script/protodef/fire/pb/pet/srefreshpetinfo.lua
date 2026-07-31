require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SRefreshPetInfo = {}
SRefreshPetInfo.__index = SRefreshPetInfo



SRefreshPetInfo.PROTOCOL_TYPE = 788437

function SRefreshPetInfo.Create()
	print("enter SRefreshPetInfo create")
	return SRefreshPetInfo:new()
end
function SRefreshPetInfo:new()
	local self = {}
	setmetatable(self, SRefreshPetInfo)
	self.type = self.PROTOCOL_TYPE
	self.petinfo = Pet:new()

	return self
end
function SRefreshPetInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshPetInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.petinfo:marshal(_os_) 
	return _os_
end

function SRefreshPetInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.petinfo:unmarshal(_os_)

	return _os_
end

return SRefreshPetInfo
