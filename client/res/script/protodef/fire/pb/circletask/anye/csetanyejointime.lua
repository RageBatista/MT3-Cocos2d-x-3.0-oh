require "utils.tableutil"
CSetAnYeJoinTime = {}
CSetAnYeJoinTime.__index = CSetAnYeJoinTime



CSetAnYeJoinTime.PROTOCOL_TYPE = 807457

function CSetAnYeJoinTime.Create()
	print("enter CSetAnYeJoinTime create")
	return CSetAnYeJoinTime:new()
end
function CSetAnYeJoinTime:new()
	local self = {}
	setmetatable(self, CSetAnYeJoinTime)
	self.type = self.PROTOCOL_TYPE
	self.jointime = 0

	return self
end
function CSetAnYeJoinTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetAnYeJoinTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.jointime)
	return _os_
end

function CSetAnYeJoinTime:unmarshal(_os_)
	self.jointime = _os_:unmarshal_int64()
	return _os_
end

return CSetAnYeJoinTime
