require "utils.tableutil"
CReqJionActivity = {}
CReqJionActivity.__index = CReqJionActivity



CReqJionActivity.PROTOCOL_TYPE = 805517

function CReqJionActivity.Create()
	print("enter CReqJionActivity create")
	return CReqJionActivity:new()
end
function CReqJionActivity:new()
	local self = {}
	setmetatable(self, CReqJionActivity)
	self.type = self.PROTOCOL_TYPE
	self.activitytype = 0

	return self
end
function CReqJionActivity:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqJionActivity:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.activitytype)
	return _os_
end

function CReqJionActivity:unmarshal(_os_)
	self.activitytype = _os_:unmarshal_char()
	return _os_
end

return CReqJionActivity
