require "utils.tableutil"
CAddPointToAttr = {}
CAddPointToAttr.__index = CAddPointToAttr



CAddPointToAttr.PROTOCOL_TYPE = 786444

function CAddPointToAttr.Create()
	print("enter CAddPointToAttr create")
	return CAddPointToAttr:new()
end
function CAddPointToAttr:new()
	local self = {}
	setmetatable(self, CAddPointToAttr)
	self.type = self.PROTOCOL_TYPE
	self.cons = 0
	self.iq = 0
	self.str = 0
	self.agi = 0
	self.endu = 0

	return self
end
function CAddPointToAttr:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAddPointToAttr:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.cons)
	_os_:marshal_int32(self.iq)
	_os_:marshal_int32(self.str)
	_os_:marshal_int32(self.agi)
	_os_:marshal_int32(self.endu)
	return _os_
end

function CAddPointToAttr:unmarshal(_os_)
	self.cons = _os_:unmarshal_int32()
	self.iq = _os_:unmarshal_int32()
	self.str = _os_:unmarshal_int32()
	self.agi = _os_:unmarshal_int32()
	self.endu = _os_:unmarshal_int32()
	return _os_
end

return CAddPointToAttr
