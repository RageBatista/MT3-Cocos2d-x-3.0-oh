require "utils.tableutil"
SNotifyShieldState = {}
SNotifyShieldState.__index = SNotifyShieldState



SNotifyShieldState.PROTOCOL_TYPE = 786516

function SNotifyShieldState.Create()
	print("enter SNotifyShieldState create")
	return SNotifyShieldState:new()
end
function SNotifyShieldState:new()
	local self = {}
	setmetatable(self, SNotifyShieldState)
	self.type = self.PROTOCOL_TYPE
	self.state = 0

	return self
end
function SNotifyShieldState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNotifyShieldState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.state)
	return _os_
end

function SNotifyShieldState:unmarshal(_os_)
	self.state = _os_:unmarshal_char()
	return _os_
end

return SNotifyShieldState
