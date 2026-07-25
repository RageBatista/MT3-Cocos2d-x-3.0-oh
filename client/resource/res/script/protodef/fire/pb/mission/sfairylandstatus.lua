require "utils.tableutil"
SFairylandStatus = {}
SFairylandStatus.__index = SFairylandStatus



SFairylandStatus.PROTOCOL_TYPE = 805453

function SFairylandStatus.Create()
	print("enter SFairylandStatus create")
	return SFairylandStatus:new()
end
function SFairylandStatus:new()
	local self = {}
	setmetatable(self, SFairylandStatus)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SFairylandStatus:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFairylandStatus:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.status)
	return _os_
end

function SFairylandStatus:unmarshal(_os_)
	self.status = _os_:unmarshal_int32()
	return _os_
end

return SFairylandStatus
