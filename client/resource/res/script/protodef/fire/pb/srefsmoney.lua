require "utils.tableutil"
SRefSmoney = {}
SRefSmoney.__index = SRefSmoney



SRefSmoney.PROTOCOL_TYPE = 786450

function SRefSmoney.Create()
	print("enter SRefSmoney create")
	return SRefSmoney:new()
end
function SRefSmoney:new()
	local self = {}
	setmetatable(self, SRefSmoney)
	self.type = self.PROTOCOL_TYPE
	self.smoney = 0

	return self
end
function SRefSmoney:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefSmoney:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.smoney)
	return _os_
end

function SRefSmoney:unmarshal(_os_)
	self.smoney = _os_:unmarshal_int64()
	return _os_
end

return SRefSmoney
