require "utils.tableutil"
GoldOrder = {}
GoldOrder.__index = GoldOrder


function GoldOrder:new()
	local self = {}
	setmetatable(self, GoldOrder)
	self.pid = 0
	self.number = 0
	self.price = 0
	self.publicity = 0
	self.locktime = 0
	self.state = 0
	self.time = 0

	return self
end
function GoldOrder:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pid)
	_os_:marshal_int64(self.number)
	_os_:marshal_int64(self.price)
	_os_:marshal_int32(self.publicity)
	_os_:marshal_int32(self.locktime)
	_os_:marshal_int32(self.state)
	_os_:marshal_int64(self.time)
	return _os_
end

function GoldOrder:unmarshal(_os_)
	self.pid = _os_:unmarshal_int64()
	self.number = _os_:unmarshal_int64()
	self.price = _os_:unmarshal_int64()
	self.publicity = _os_:unmarshal_int32()
	self.locktime = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	self.time = _os_:unmarshal_int64()
	return _os_
end

return GoldOrder
