require "utils.tableutil"
CRefreshActivityListFinishTimes = {}
CRefreshActivityListFinishTimes.__index = CRefreshActivityListFinishTimes



CRefreshActivityListFinishTimes.PROTOCOL_TYPE = 805484

function CRefreshActivityListFinishTimes.Create()
	print("enter CRefreshActivityListFinishTimes create")
	return CRefreshActivityListFinishTimes:new()
end
function CRefreshActivityListFinishTimes:new()
	local self = {}
	setmetatable(self, CRefreshActivityListFinishTimes)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRefreshActivityListFinishTimes:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRefreshActivityListFinishTimes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRefreshActivityListFinishTimes:unmarshal(_os_)
	return _os_
end

return CRefreshActivityListFinishTimes
