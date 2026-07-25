require "utils.tableutil"
CGetTimeAward = {}
CGetTimeAward.__index = CGetTimeAward



CGetTimeAward.PROTOCOL_TYPE = 787506

function CGetTimeAward.Create()
	print("enter CGetTimeAward create")
	return CGetTimeAward:new()
end
function CGetTimeAward:new()
	local self = {}
	setmetatable(self, CGetTimeAward)
	self.type = self.PROTOCOL_TYPE
	self.awardid = 0

	return self
end
function CGetTimeAward:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetTimeAward:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.awardid)
	return _os_
end

function CGetTimeAward:unmarshal(_os_)
	self.awardid = _os_:unmarshal_int32()
	return _os_
end

return CGetTimeAward
