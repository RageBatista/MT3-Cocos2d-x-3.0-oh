require "utils.tableutil"
LineInfo = {}
LineInfo.__index = LineInfo


function LineInfo:new()
	local self = {}
	setmetatable(self, LineInfo)
	self.id = 0
	self.state = 0
	self.finish = 0

	return self
end
function LineInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.finish)
	return _os_
end

function LineInfo:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	self.finish = _os_:unmarshal_int32()
	return _os_
end

return LineInfo
