require "utils.tableutil"
Coutpetequip = {}
Coutpetequip.__index = Coutpetequip



Coutpetequip.PROTOCOL_TYPE = 817977

function Coutpetequip.Create()
	print("enter Coutpetequip create")
	return Coutpetequip:new()
end
function Coutpetequip:new()
	local self = {}
	setmetatable(self, Coutpetequip)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.itemid = 0
	self.itemkey = 0

	return self
end
function Coutpetequip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function Coutpetequip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function Coutpetequip:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.itemid = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return Coutpetequip
