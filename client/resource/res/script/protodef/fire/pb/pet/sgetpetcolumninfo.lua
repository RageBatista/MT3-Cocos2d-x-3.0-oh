require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
SGetPetcolumnInfo = {}
SGetPetcolumnInfo.__index = SGetPetcolumnInfo



SGetPetcolumnInfo.PROTOCOL_TYPE = 788447

function SGetPetcolumnInfo.Create()
	print("enter SGetPetcolumnInfo create")
	return SGetPetcolumnInfo:new()
end
function SGetPetcolumnInfo:new()
	local self = {}
	setmetatable(self, SGetPetcolumnInfo)
	self.type = self.PROTOCOL_TYPE
	self.columnid = 0
	self.pets = {}
	self.colunmsize = 0

	return self
end
function SGetPetcolumnInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetPetcolumnInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.columnid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.pets))
	for k,v in ipairs(self.pets) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.colunmsize)
	return _os_
end

function SGetPetcolumnInfo:unmarshal(_os_)
	self.columnid = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_pets=0,_os_null_pets
	_os_null_pets, sizeof_pets = _os_: uncompact_uint32(sizeof_pets)
	for k = 1,sizeof_pets do
		----------------unmarshal bean
		self.pets[k]=Pet:new()

		self.pets[k]:unmarshal(_os_)

	end
	self.colunmsize = _os_:unmarshal_int32()
	return _os_
end

return SGetPetcolumnInfo
