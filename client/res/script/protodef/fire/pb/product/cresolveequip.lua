require "utils.tableutil"
CResolveEquip = {}
CResolveEquip.__index = CResolveEquip



CResolveEquip.PROTOCOL_TYPE = 803452

function CResolveEquip.Create()
	print("enter CResolveEquip create")
	return CResolveEquip:new()
end
function CResolveEquip:new()
	local self = {}
	setmetatable(self, CResolveEquip)
	self.type = self.PROTOCOL_TYPE
	self.itemkey = 0

	return self
end
function CResolveEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CResolveEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CResolveEquip:unmarshal(_os_)
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CResolveEquip
