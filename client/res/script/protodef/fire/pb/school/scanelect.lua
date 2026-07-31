require "utils.tableutil"
SCanElect = {}
SCanElect.__index = SCanElect



SCanElect.PROTOCOL_TYPE = 810437

function SCanElect.Create()
	print("enter SCanElect create")
	return SCanElect:new()
end
function SCanElect:new()
	local self = {}
	setmetatable(self, SCanElect)
	self.type = self.PROTOCOL_TYPE
	self.shouxikey = 0

	return self
end
function SCanElect:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCanElect:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.shouxikey)
	return _os_
end

function SCanElect:unmarshal(_os_)
	self.shouxikey = _os_:unmarshal_int64()
	return _os_
end

return SCanElect
