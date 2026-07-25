require "utils.tableutil"
CHeChengItem = {}
CHeChengItem.__index = CHeChengItem



CHeChengItem.PROTOCOL_TYPE = 787689

function CHeChengItem.Create()
	print("enter CHeChengItem create")
	return CHeChengItem:new()
end
function CHeChengItem:new()
	local self = {}
	setmetatable(self, CHeChengItem)
	self.type = self.PROTOCOL_TYPE
	self.money = 0
	self.isall = 0
	self.hammer = 0
	self.keyinpack = 0

	return self
end
function CHeChengItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CHeChengItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.money)
	_os_:marshal_char(self.isall)
	_os_:marshal_char(self.hammer)
	_os_:marshal_int32(self.keyinpack)
	return _os_
end

function CHeChengItem:unmarshal(_os_)
	self.money = _os_:unmarshal_char()
	self.isall = _os_:unmarshal_char()
	self.hammer = _os_:unmarshal_char()
	self.keyinpack = _os_:unmarshal_int32()
	return _os_
end

return CHeChengItem
