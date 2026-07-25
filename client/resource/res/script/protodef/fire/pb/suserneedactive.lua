require "utils.tableutil"
SUserNeedActive = {}
SUserNeedActive.__index = SUserNeedActive



SUserNeedActive.PROTOCOL_TYPE = 786511

function SUserNeedActive.Create()
	print("enter SUserNeedActive create")
	return SUserNeedActive:new()
end
function SUserNeedActive:new()
	local self = {}
	setmetatable(self, SUserNeedActive)
	self.type = self.PROTOCOL_TYPE
	self.retcode = 0

	return self
end
function SUserNeedActive:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUserNeedActive:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.retcode)
	return _os_
end

function SUserNeedActive:unmarshal(_os_)
	self.retcode = _os_:unmarshal_char()
	return _os_
end

return SUserNeedActive
