require "utils.tableutil"
STradingOpenState = {}
STradingOpenState.__index = STradingOpenState



STradingOpenState.PROTOCOL_TYPE = 812646

function STradingOpenState.Create()
	print("enter STradingOpenState create")
	return STradingOpenState:new()
end
function STradingOpenState:new()
	local self = {}
	setmetatable(self, STradingOpenState)
	self.type = self.PROTOCOL_TYPE
	self.openstate = 0

	return self
end
function STradingOpenState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STradingOpenState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.openstate)
	return _os_
end

function STradingOpenState:unmarshal(_os_)
	self.openstate = _os_:unmarshal_char()
	return _os_
end

return STradingOpenState
