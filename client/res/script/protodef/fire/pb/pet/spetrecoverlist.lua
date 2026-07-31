require "utils.tableutil"
require "protodef.rpcgen.fire.pb.pet.petrecoverinfobean"
SPetRecoverList = {}
SPetRecoverList.__index = SPetRecoverList



SPetRecoverList.PROTOCOL_TYPE = 788584

function SPetRecoverList.Create()
	print("enter SPetRecoverList create")
	return SPetRecoverList:new()
end
function SPetRecoverList:new()
	local self = {}
	setmetatable(self, SPetRecoverList)
	self.type = self.PROTOCOL_TYPE
	self.pets = {}

	return self
end
function SPetRecoverList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPetRecoverList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.pets))
	for k,v in ipairs(self.pets) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SPetRecoverList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_pets=0 ,_os_null_pets
	_os_null_pets, sizeof_pets = _os_: uncompact_uint32(sizeof_pets)
	for k = 1,sizeof_pets do
		----------------unmarshal bean
		self.pets[k]=PetRecoverInfoBean:new()

		self.pets[k]:unmarshal(_os_)

	end
	return _os_
end

return SPetRecoverList
