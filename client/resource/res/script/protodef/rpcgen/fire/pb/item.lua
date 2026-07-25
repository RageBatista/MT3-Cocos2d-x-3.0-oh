require "utils.tableutil"
Item = {
	BIND = 0x00000001,
	FUSHI = 0x0000002,
	ONSTALL = 0x0000004,
	ONCOFCSELL = 0x0000008,
	CANNOTONSTALL = 0x10,
	LOCK = 0x0000020,
	TIMEOUT = 0x0000040
}
Item.__index = Item


function Item:new()
	local self = {}
	setmetatable(self, Item)
	self.id = 0
	self.flags = 0
	self.key = 0
	self.position = 0
	self.number = 0
	self.timeout = 0
	self.isnew = 0
	self.loseeffecttime = 0
	self.markettime = 0

	return self
end
function Item:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.flags)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.position)
	_os_:marshal_int32(self.number)
	_os_:marshal_int64(self.timeout)
	_os_:marshal_int32(self.isnew)
	_os_:marshal_int64(self.loseeffecttime)
	_os_:marshal_int64(self.markettime)
	return _os_
end

function Item:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.flags = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.position = _os_:unmarshal_int32()
	self.number = _os_:unmarshal_int32()
	self.timeout = _os_:unmarshal_int64()
	self.isnew = _os_:unmarshal_int32()
	self.loseeffecttime = _os_:unmarshal_int64()
	self.markettime = _os_:unmarshal_int64()
	return _os_
end

return Item
