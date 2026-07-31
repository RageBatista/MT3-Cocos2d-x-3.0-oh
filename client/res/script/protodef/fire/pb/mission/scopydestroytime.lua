require "utils.tableutil"
SCopyDestroyTime = {}
SCopyDestroyTime.__index = SCopyDestroyTime



SCopyDestroyTime.PROTOCOL_TYPE = 805471

function SCopyDestroyTime.Create()
	print("enter SCopyDestroyTime create")
	return SCopyDestroyTime:new()
end
function SCopyDestroyTime:new()
	local self = {}
	setmetatable(self, SCopyDestroyTime)
	self.type = self.PROTOCOL_TYPE
	self.destroytime = 0

	return self
end
function SCopyDestroyTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCopyDestroyTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.destroytime)
	return _os_
end

function SCopyDestroyTime:unmarshal(_os_)
	self.destroytime = _os_:unmarshal_int64()
	return _os_
end

return SCopyDestroyTime
