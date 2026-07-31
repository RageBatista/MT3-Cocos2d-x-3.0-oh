require "utils.tableutil"
RuneRequestInfo = {}
RuneRequestInfo.__index = RuneRequestInfo


function RuneRequestInfo:new()
	local self = {}
	setmetatable(self, RuneRequestInfo)
	self.itemid = 0

	return self
end
function RuneRequestInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	return _os_
end

function RuneRequestInfo:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	return _os_
end

return RuneRequestInfo
