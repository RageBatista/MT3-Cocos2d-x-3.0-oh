require "utils.tableutil"
Achive = {}
Achive.__index = Achive


function Achive:new()
	local self = {}
	setmetatable(self, Achive)
	self.currnumber = 0
	self.totalnum = 0
	self.flag = 0

	return self
end
function Achive:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.currnumber)
	_os_:marshal_int32(self.totalnum)
	_os_:marshal_int32(self.flag)
	return _os_
end

function Achive:unmarshal(_os_)
	self.currnumber = _os_:unmarshal_int32()
	self.totalnum = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return Achive
