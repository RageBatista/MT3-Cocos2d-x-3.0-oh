require "utils.tableutil"
SWaitRollTime = {}
SWaitRollTime.__index = SWaitRollTime



SWaitRollTime.PROTOCOL_TYPE = 805543

function SWaitRollTime.Create()
	print("enter SWaitRollTime create")
	return SWaitRollTime:new()
end
function SWaitRollTime:new()
	local self = {}
	setmetatable(self, SWaitRollTime)
	self.type = self.PROTOCOL_TYPE
	self.messageid = 0

	return self
end
function SWaitRollTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SWaitRollTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.messageid)
	return _os_
end

function SWaitRollTime:unmarshal(_os_)
	self.messageid = _os_:unmarshal_int32()
	return _os_
end

return SWaitRollTime
