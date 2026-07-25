require "utils.tableutil"
SimpleActivityInfo = {}
SimpleActivityInfo.__index = SimpleActivityInfo


function SimpleActivityInfo:new()
	local self = {}
	setmetatable(self, SimpleActivityInfo)
	self.num = 0
	self.num2 = 0
	self.activevalue = 0

	return self
end
function SimpleActivityInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.num2)
	_os_:marshal_int32(self.activevalue)
	return _os_
end

function SimpleActivityInfo:unmarshal(_os_)
	self.num = _os_:unmarshal_int32()
	self.num2 = _os_:unmarshal_int32()
	self.activevalue = _os_:unmarshal_int32()
	return _os_
end

return SimpleActivityInfo
