require "utils.tableutil"
CShareActivity = {}
CShareActivity.__index = CShareActivity



CShareActivity.PROTOCOL_TYPE = 805489

function CShareActivity.Create()
	print("enter CShareActivity create")
	return CShareActivity:new()
end
function CShareActivity:new()
	local self = {}
	setmetatable(self, CShareActivity)
	self.type = self.PROTOCOL_TYPE
	self.activityid = 0

	return self
end
function CShareActivity:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShareActivity:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.activityid)
	return _os_
end

function CShareActivity:unmarshal(_os_)
	self.activityid = _os_:unmarshal_int32()
	return _os_
end

return CShareActivity
