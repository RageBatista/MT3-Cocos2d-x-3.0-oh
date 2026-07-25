require "utils.tableutil"
CWinnerChangeTask = {}
CWinnerChangeTask.__index = CWinnerChangeTask



CWinnerChangeTask.PROTOCOL_TYPE = 795484

function CWinnerChangeTask.Create()
	print("enter CWinnerChangeTask create")
	return CWinnerChangeTask:new()
end
function CWinnerChangeTask:new()
	local self = {}
	setmetatable(self, CWinnerChangeTask)
	self.type = self.PROTOCOL_TYPE
	self.acceptflag = 0

	return self
end
function CWinnerChangeTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CWinnerChangeTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.acceptflag)
	return _os_
end

function CWinnerChangeTask:unmarshal(_os_)
	self.acceptflag = _os_:unmarshal_int32()
	return _os_
end

return CWinnerChangeTask
