require "utils.tableutil"
CTradingOpenState = {}
CTradingOpenState.__index = CTradingOpenState



CTradingOpenState.PROTOCOL_TYPE = 812645

function CTradingOpenState.Create()
	print("enter CTradingOpenState create")
	return CTradingOpenState:new()
end
function CTradingOpenState:new()
	local self = {}
	setmetatable(self, CTradingOpenState)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CTradingOpenState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTradingOpenState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CTradingOpenState:unmarshal(_os_)
	return _os_
end

return CTradingOpenState
