require "utils.tableutil"
SModPetName = {}
SModPetName.__index = SModPetName



SModPetName.PROTOCOL_TYPE = 788451

function SModPetName.Create()
	print("enter SModPetName create")
	return SModPetName:new()
end
function SModPetName:new()
	local self = {}
	setmetatable(self, SModPetName)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.petkey = 0
	self.petname = "" 

	return self
end
function SModPetName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SModPetName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.petkey)
	_os_:marshal_wstring(self.petname)
	return _os_
end

function SModPetName:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.petkey = _os_:unmarshal_int32()
	self.petname = _os_:unmarshal_wstring(self.petname)
	return _os_
end

return SModPetName
