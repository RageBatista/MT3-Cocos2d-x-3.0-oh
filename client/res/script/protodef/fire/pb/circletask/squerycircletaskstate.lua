require "utils.tableutil"
SQueryCircleTaskState = {}
SQueryCircleTaskState.__index = SQueryCircleTaskState



SQueryCircleTaskState.PROTOCOL_TYPE = 807453

function SQueryCircleTaskState.Create()
	print("enter SQueryCircleTaskState create")
	return SQueryCircleTaskState:new()
end
function SQueryCircleTaskState:new()
	local self = {}
	setmetatable(self, SQueryCircleTaskState)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0
	self.state = 0

	return self
end
function SQueryCircleTaskState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQueryCircleTaskState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	_os_:marshal_int32(self.state)
	return _os_
end

function SQueryCircleTaskState:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	self.state = _os_:unmarshal_int32()
	return _os_
end

return SQueryCircleTaskState
