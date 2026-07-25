require "utils.tableutil"
Pos1 = {}
Pos1.__index = Pos1


function Pos1:new()
	local self = {}
	setmetatable(self, Pos1)
	self.x = 0
	self.y = 0

	return self
end
function Pos1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.x)
	_os_:marshal_int32(self.y)
	return _os_
end

function Pos1:unmarshal(_os_)
	self.x = _os_:unmarshal_int32()
	self.y = _os_:unmarshal_int32()
	return _os_
end

return Pos1
