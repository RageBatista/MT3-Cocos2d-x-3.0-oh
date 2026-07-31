require "utils.tableutil"
FunOpenClose = {}
FunOpenClose.__index = FunOpenClose


function FunOpenClose:new()
	local self = {}
	setmetatable(self, FunOpenClose)
	self.key = 0
	self.state = 0

	return self
end
function FunOpenClose:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.state)
	return _os_
end

function FunOpenClose:unmarshal(_os_)
	self.key = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return FunOpenClose
