require "utils.tableutil"
SRefreshGoldOrderState = {}
SRefreshGoldOrderState.__index = SRefreshGoldOrderState



SRefreshGoldOrderState.PROTOCOL_TYPE = 810676

function SRefreshGoldOrderState.Create()
	print("enter SRefreshGoldOrderState create")
	return SRefreshGoldOrderState:new()
end
function SRefreshGoldOrderState:new()
	local self = {}
	setmetatable(self, SRefreshGoldOrderState)
	self.type = self.PROTOCOL_TYPE
	self.pid = 0
	self.state = 0

	return self
end
function SRefreshGoldOrderState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshGoldOrderState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pid)
	_os_:marshal_int32(self.state)
	return _os_
end

function SRefreshGoldOrderState:unmarshal(_os_)
	self.pid = _os_:unmarshal_int64()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return SRefreshGoldOrderState
