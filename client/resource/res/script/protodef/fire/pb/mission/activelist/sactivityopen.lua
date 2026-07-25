require "utils.tableutil"
SActivityOpen = {}
SActivityOpen.__index = SActivityOpen



SActivityOpen.PROTOCOL_TYPE = 805486

function SActivityOpen.Create()
	print("enter SActivityOpen create")
	return SActivityOpen:new()
end
function SActivityOpen:new()
	local self = {}
	setmetatable(self, SActivityOpen)
	self.type = self.PROTOCOL_TYPE
	self.activityid = 0

	return self
end
function SActivityOpen:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SActivityOpen:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.activityid)
	return _os_
end

function SActivityOpen:unmarshal(_os_)
	self.activityid = _os_:unmarshal_int32()
	return _os_
end

return SActivityOpen
