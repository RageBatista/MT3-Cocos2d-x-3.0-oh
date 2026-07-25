require "utils.tableutil"
SUpdateMemberState = {}
SUpdateMemberState.__index = SUpdateMemberState



SUpdateMemberState.PROTOCOL_TYPE = 794458

function SUpdateMemberState.Create()
	print("enter SUpdateMemberState create")
	return SUpdateMemberState:new()
end
function SUpdateMemberState:new()
	local self = {}
	setmetatable(self, SUpdateMemberState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.state = 0

	return self
end
function SUpdateMemberState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateMemberState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.state)
	return _os_
end

function SUpdateMemberState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return SUpdateMemberState
