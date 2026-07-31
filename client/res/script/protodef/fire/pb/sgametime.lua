require "utils.tableutil"
SGameTime = {}
SGameTime.__index = SGameTime



SGameTime.PROTOCOL_TYPE = 786439

function SGameTime.Create()
	print("enter SGameTime create")
	return SGameTime:new()
end
function SGameTime:new()
	local self = {}
	setmetatable(self, SGameTime)
	self.type = self.PROTOCOL_TYPE
	self.servertime = 0

	return self
end
function SGameTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGameTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.servertime)
	return _os_
end

function SGameTime:unmarshal(_os_)
	self.servertime = _os_:unmarshal_int64()
	return _os_
end

return SGameTime
