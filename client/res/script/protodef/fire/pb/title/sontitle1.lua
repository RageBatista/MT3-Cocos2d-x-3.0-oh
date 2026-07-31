require "utils.tableutil"
SOnTitle1 = {}
SOnTitle1.__index = SOnTitle1



SOnTitle1.PROTOCOL_TYPE = 817982

function SOnTitle1.Create()
	print("enter SOnTitle1 create")
	return SOnTitle1:new()
end
function SOnTitle1:new()
	local self = {}
	setmetatable(self, SOnTitle1)
	self.type = self.PROTOCOL_TYPE
	self.titleid = 0

	return self
end
function SOnTitle1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOnTitle1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.titleid)
	return _os_
end

function SOnTitle1:unmarshal(_os_)
	self.titleid = _os_:unmarshal_int32()
	return _os_
end

return SOnTitle1
