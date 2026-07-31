require "utils.tableutil"
SShowPetAround = {}
SShowPetAround.__index = SShowPetAround



SShowPetAround.PROTOCOL_TYPE = 788434

function SShowPetAround.Create()
	print("enter SShowPetAround create")
	return SShowPetAround:new()
end
function SShowPetAround:new()
	local self = {}
	setmetatable(self, SShowPetAround)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.showpetkey = 0
	self.showpetid = 0
	self.showpetname = "" 
	self.colour = 0
	self.size = 0
	self.showeffect = 0

	return self
end
function SShowPetAround:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SShowPetAround:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.showpetkey)
	_os_:marshal_int32(self.showpetid)
	_os_:marshal_wstring(self.showpetname)
	_os_:marshal_char(self.colour)
	_os_:marshal_char(self.size)
	_os_:marshal_char(self.showeffect)
	return _os_
end

function SShowPetAround:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.showpetkey = _os_:unmarshal_int32()
	self.showpetid = _os_:unmarshal_int32()
	self.showpetname = _os_:unmarshal_wstring(self.showpetname)
	self.colour = _os_:unmarshal_char()
	self.size = _os_:unmarshal_char()
	self.showeffect = _os_:unmarshal_char()
	return _os_
end

return SShowPetAround
