require "utils.tableutil"
SRefreshChargeState = {}
SRefreshChargeState.__index = SRefreshChargeState



SRefreshChargeState.PROTOCOL_TYPE = 812461

function SRefreshChargeState.Create()
	print("enter SRefreshChargeState create")
	return SRefreshChargeState:new()
end
function SRefreshChargeState:new()
	local self = {}
	setmetatable(self, SRefreshChargeState)
	self.type = self.PROTOCOL_TYPE
	self.state = 0
	self.flag = 0

	return self
end
function SRefreshChargeState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshChargeState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.flag)
	return _os_
end

function SRefreshChargeState:unmarshal(_os_)
	self.state = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return SRefreshChargeState
