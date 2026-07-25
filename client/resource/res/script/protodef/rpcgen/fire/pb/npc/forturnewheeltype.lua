require "utils.tableutil"
ForturneWheelType = {}
ForturneWheelType.__index = ForturneWheelType


function ForturneWheelType:new()
	local self = {}
	setmetatable(self, ForturneWheelType)
	self.itemtype = 0
	self.id = 0
	self.num = 0
	self.times = 0

	return self
end
function ForturneWheelType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.id)
	_os_:marshal_int64(self.num)
	_os_:marshal_int32(self.times)
	return _os_
end

function ForturneWheelType:unmarshal(_os_)
	self.itemtype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int64()
	self.times = _os_:unmarshal_int32()
	return _os_
end

return ForturneWheelType
