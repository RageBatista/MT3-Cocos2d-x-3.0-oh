require "utils.tableutil"
HuoBanInfo = {
	white = 1,
	green = 2,
	blue = 3,
	purple = 4,
	orange = 5,
	golden = 6,
	pink = 7,
	red = 8
}
HuoBanInfo.__index = HuoBanInfo


function HuoBanInfo:new()
	local self = {}
	setmetatable(self, HuoBanInfo)
	self.huobanid = 0
	self.infight = 0
	self.weekfree = 0
	self.state = 0

	return self
end
function HuoBanInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.huobanid)
	_os_:marshal_int32(self.infight)
	_os_:marshal_int32(self.weekfree)
	_os_:marshal_int64(self.state)
	return _os_
end

function HuoBanInfo:unmarshal(_os_)
	self.huobanid = _os_:unmarshal_int32()
	self.infight = _os_:unmarshal_int32()
	self.weekfree = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int64()
	return _os_
end

return HuoBanInfo
