require "utils.tableutil"
Pos = {}
Pos.__index = Pos


function Pos:new()
	local self = {}
	setmetatable(self, Pos)
	self.x = 0
	self.y = 0

	return self
end
function Pos:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.x)
	_os_:marshal_short(self.y)
	return _os_
end

function Pos:unmarshal(_os_)
	self.x = _os_:unmarshal_short()
	self.y = _os_:unmarshal_short()
	return _os_
end

return Pos
