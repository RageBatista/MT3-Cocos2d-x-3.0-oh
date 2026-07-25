require "utils.tableutil"
CReqLineTask = {}
CReqLineTask.__index = CReqLineTask



CReqLineTask.PROTOCOL_TYPE = 805476

function CReqLineTask.Create()
	print("enter CReqLineTask create")
	return CReqLineTask:new()
end
function CReqLineTask:new()
	local self = {}
	setmetatable(self, CReqLineTask)
	self.type = self.PROTOCOL_TYPE
	self.taskid = 0

	return self
end
function CReqLineTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqLineTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.taskid)
	return _os_
end

function CReqLineTask:unmarshal(_os_)
	self.taskid = _os_:unmarshal_int32()
	return _os_
end

return CReqLineTask
