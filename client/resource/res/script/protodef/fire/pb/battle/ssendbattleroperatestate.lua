require "utils.tableutil"
SSendBattlerOperateState = {}
SSendBattlerOperateState.__index = SSendBattlerOperateState



SSendBattlerOperateState.PROTOCOL_TYPE = 793450

function SSendBattlerOperateState.Create()
	print("enter SSendBattlerOperateState create")
	return SSendBattlerOperateState:new()
end
function SSendBattlerOperateState:new()
	local self = {}
	setmetatable(self, SSendBattlerOperateState)
	self.type = self.PROTOCOL_TYPE
	self.battleid = 0
	self.state = 0

	return self
end
function SSendBattlerOperateState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendBattlerOperateState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.battleid)
	_os_:marshal_int32(self.state)
	return _os_
end

function SSendBattlerOperateState:unmarshal(_os_)
	self.battleid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return SSendBattlerOperateState
