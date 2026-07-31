require "utils.tableutil"
CPetSetAutoAddPoint = {}
CPetSetAutoAddPoint.__index = CPetSetAutoAddPoint



CPetSetAutoAddPoint.PROTOCOL_TYPE = 788512

function CPetSetAutoAddPoint.Create()
	print("enter CPetSetAutoAddPoint create")
	return CPetSetAutoAddPoint:new()
end
function CPetSetAutoAddPoint:new()
	local self = {}
	setmetatable(self, CPetSetAutoAddPoint)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.str = 0
	self.iq = 0
	self.cons = 0
	self.endu = 0
	self.agi = 0

	return self
end
function CPetSetAutoAddPoint:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetSetAutoAddPoint:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.str)
	_os_:marshal_int32(self.iq)
	_os_:marshal_int32(self.cons)
	_os_:marshal_int32(self.endu)
	_os_:marshal_int32(self.agi)
	return _os_
end

function CPetSetAutoAddPoint:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.str = _os_:unmarshal_int32()
	self.iq = _os_:unmarshal_int32()
	self.cons = _os_:unmarshal_int32()
	self.endu = _os_:unmarshal_int32()
	self.agi = _os_:unmarshal_int32()
	return _os_
end

return CPetSetAutoAddPoint
