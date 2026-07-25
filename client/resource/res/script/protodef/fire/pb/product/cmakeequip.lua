require "utils.tableutil"
CMakeEquip = {}
CMakeEquip.__index = CMakeEquip



CMakeEquip.PROTOCOL_TYPE = 803451

function CMakeEquip.Create()
	print("enter CMakeEquip create")
	return CMakeEquip:new()
end
function CMakeEquip:new()
	local self = {}
	setmetatable(self, CMakeEquip)
	self.type = self.PROTOCOL_TYPE
	self.equipid = 0
	self.maketype = 0

	return self
end
function CMakeEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMakeEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.equipid)
	_os_:marshal_short(self.maketype)
	return _os_
end

function CMakeEquip:unmarshal(_os_)
	self.equipid = _os_:unmarshal_int32()
	self.maketype = _os_:unmarshal_short()
	return _os_
end

return CMakeEquip
