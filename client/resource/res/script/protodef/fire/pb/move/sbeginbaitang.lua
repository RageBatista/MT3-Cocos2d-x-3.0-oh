require "utils.tableutil"
SBeginBaitang = {}
SBeginBaitang.__index = SBeginBaitang



SBeginBaitang.PROTOCOL_TYPE = 790483

function SBeginBaitang.Create()
	print("enter SBeginBaitang create")
	return SBeginBaitang:new()
end
function SBeginBaitang:new()
	local self = {}
	setmetatable(self, SBeginBaitang)
	self.type = self.PROTOCOL_TYPE
	self.roleid1 = 0
	self.roleid2 = 0

	return self
end
function SBeginBaitang:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBeginBaitang:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid1)
	_os_:marshal_int64(self.roleid2)
	return _os_
end

function SBeginBaitang:unmarshal(_os_)
	self.roleid1 = _os_:unmarshal_int64()
	self.roleid2 = _os_:unmarshal_int64()
	return _os_
end

return SBeginBaitang
