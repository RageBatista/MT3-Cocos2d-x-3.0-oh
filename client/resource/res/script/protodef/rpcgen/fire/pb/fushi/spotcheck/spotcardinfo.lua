require "utils.tableutil"
SpotCardInfo = {}
SpotCardInfo.__index = SpotCardInfo


function SpotCardInfo:new()
	local self = {}
	setmetatable(self, SpotCardInfo)
	self.num = 0
	self.price = 0

	return self
end
function SpotCardInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.price)
	return _os_
end

function SpotCardInfo:unmarshal(_os_)
	self.num = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	return _os_
end

return SpotCardInfo
