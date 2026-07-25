require "utils.tableutil"
SRequestSetLeaderSucc = {}
SRequestSetLeaderSucc.__index = SRequestSetLeaderSucc



SRequestSetLeaderSucc.PROTOCOL_TYPE = 794483

function SRequestSetLeaderSucc.Create()
	print("enter SRequestSetLeaderSucc create")
	return SRequestSetLeaderSucc:new()
end
function SRequestSetLeaderSucc:new()
	local self = {}
	setmetatable(self, SRequestSetLeaderSucc)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SRequestSetLeaderSucc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestSetLeaderSucc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SRequestSetLeaderSucc:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SRequestSetLeaderSucc
