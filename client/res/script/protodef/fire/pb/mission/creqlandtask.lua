require "utils.tableutil"
CReqLandTask = {}
CReqLandTask.__index = CReqLandTask



CReqLandTask.PROTOCOL_TYPE = 805468

function CReqLandTask.Create()
	print("enter CReqLandTask create")
	return CReqLandTask:new()
end
function CReqLandTask:new()
	local self = {}
	setmetatable(self, CReqLandTask)
	self.type = self.PROTOCOL_TYPE
	self.taskid = 0
	self.tasktype = 0

	return self
end
function CReqLandTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqLandTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.taskid)
	_os_:marshal_int32(self.tasktype)
	return _os_
end

function CReqLandTask:unmarshal(_os_)
	self.taskid = _os_:unmarshal_int32()
	self.tasktype = _os_:unmarshal_int32()
	return _os_
end

return CReqLandTask
