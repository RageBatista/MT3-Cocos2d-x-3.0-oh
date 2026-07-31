require "utils.tableutil"
SAddPrePrentice = {}
SAddPrePrentice.__index = SAddPrePrentice



SAddPrePrentice.PROTOCOL_TYPE = 816470

function SAddPrePrentice.Create()
	print("enter SAddPrePrentice create")
	return SAddPrePrentice:new()
end
function SAddPrePrentice:new()
	local self = {}
	setmetatable(self, SAddPrePrentice)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SAddPrePrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddPrePrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SAddPrePrentice:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SAddPrePrentice
