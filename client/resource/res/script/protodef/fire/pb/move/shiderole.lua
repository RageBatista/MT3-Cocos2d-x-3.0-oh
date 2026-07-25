require "utils.tableutil"
SHideRole = {}
SHideRole.__index = SHideRole



SHideRole.PROTOCOL_TYPE = 790458

function SHideRole.Create()
	print("enter SHideRole create")
	return SHideRole:new()
end
function SHideRole:new()
	local self = {}
	setmetatable(self, SHideRole)
	self.type = self.PROTOCOL_TYPE
	self.hide = 0

	return self
end
function SHideRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SHideRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.hide)
	return _os_
end

function SHideRole:unmarshal(_os_)
	self.hide = _os_:unmarshal_int32()
	return _os_
end

return SHideRole
