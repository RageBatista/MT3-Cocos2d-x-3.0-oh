require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SAddPetToColumn = {}
SAddPetToColumn.__index = SAddPetToColumn



SAddPetToColumn.PROTOCOL_TYPE = 788444

function SAddPetToColumn.Create()
	print("enter SAddPetToColumn create")
	return SAddPetToColumn:new()
end
function SAddPetToColumn:new()
	local self = {}
	setmetatable(self, SAddPetToColumn)
	self.type = self.PROTOCOL_TYPE
	self.columnid = 0
	self.petdata = Pet:new()

	return self
end
function SAddPetToColumn:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddPetToColumn:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.columnid)
	----------------marshal bean
	self.petdata:marshal(_os_) 
	return _os_
end

function SAddPetToColumn:unmarshal(_os_)
	self.columnid = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.petdata:unmarshal(_os_)

	return _os_
end

return SAddPetToColumn
