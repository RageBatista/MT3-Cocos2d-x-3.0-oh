require "utils.tableutil"
CTakeOffEquip = {}
CTakeOffEquip.__index = CTakeOffEquip



CTakeOffEquip.PROTOCOL_TYPE = 787446

function CTakeOffEquip.Create()
	print("enter CTakeOffEquip create")
	return CTakeOffEquip:new()
end
function CTakeOffEquip:new()
	local self = {}
	setmetatable(self, CTakeOffEquip)
	self.type = self.PROTOCOL_TYPE
	self.equipkey = 0
	self.posinpack = 0

	return self
end
function CTakeOffEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTakeOffEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.equipkey)
	_os_:marshal_int32(self.posinpack)
	return _os_
end

function CTakeOffEquip:unmarshal(_os_)
	self.equipkey = _os_:unmarshal_int32()
	self.posinpack = _os_:unmarshal_int32()
	return _os_
end

return CTakeOffEquip
