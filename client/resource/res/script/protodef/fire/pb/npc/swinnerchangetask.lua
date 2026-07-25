require "utils.tableutil"
SWinnerChangeTask = {}
SWinnerChangeTask.__index = SWinnerChangeTask



SWinnerChangeTask.PROTOCOL_TYPE = 795483

function SWinnerChangeTask.Create()
	print("enter SWinnerChangeTask create")
	return SWinnerChangeTask:new()
end
function SWinnerChangeTask:new()
	local self = {}
	setmetatable(self, SWinnerChangeTask)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SWinnerChangeTask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SWinnerChangeTask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SWinnerChangeTask:unmarshal(_os_)
	return _os_
end

return SWinnerChangeTask
