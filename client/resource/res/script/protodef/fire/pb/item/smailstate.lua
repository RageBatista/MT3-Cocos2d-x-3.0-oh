require "utils.tableutil"
SMailState = {}
SMailState.__index = SMailState



SMailState.PROTOCOL_TYPE = 787706

function SMailState.Create()
	print("enter SMailState create")
	return SMailState:new()
end
function SMailState:new()
	local self = {}
	setmetatable(self, SMailState)
	self.type = self.PROTOCOL_TYPE
	self.kind = 0
	self.id = 0
	self.statetype = 0
	self.statevalue = 0

	return self
end
function SMailState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMailState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.kind)
	_os_:marshal_int64(self.id)
	_os_:marshal_char(self.statetype)
	_os_:marshal_char(self.statevalue)
	return _os_
end

function SMailState:unmarshal(_os_)
	self.kind = _os_:unmarshal_char()
	self.id = _os_:unmarshal_int64()
	self.statetype = _os_:unmarshal_char()
	self.statevalue = _os_:unmarshal_char()
	return _os_
end

return SMailState
