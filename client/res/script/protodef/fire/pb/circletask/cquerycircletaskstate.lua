require "utils.tableutil"
CQueryCircleTaskState = {}
CQueryCircleTaskState.__index = CQueryCircleTaskState



CQueryCircleTaskState.PROTOCOL_TYPE = 807452

function CQueryCircleTaskState.Create()
	print("enter CQueryCircleTaskState create")
	return CQueryCircleTaskState:new()
end
function CQueryCircleTaskState:new()
	local self = {}
	setmetatable(self, CQueryCircleTaskState)
	self.type = self.PROTOCOL_TYPE
	self.questid = 0

	return self
end
function CQueryCircleTaskState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQueryCircleTaskState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questid)
	return _os_
end

function CQueryCircleTaskState:unmarshal(_os_)
	self.questid = _os_:unmarshal_int32()
	return _os_
end

return CQueryCircleTaskState
