require "utils.tableutil"
SRequestHaveTeam = {}
SRequestHaveTeam.__index = SRequestHaveTeam



SRequestHaveTeam.PROTOCOL_TYPE = 794516

function SRequestHaveTeam.Create()
	print("enter SRequestHaveTeam create")
	return SRequestHaveTeam:new()
end
function SRequestHaveTeam:new()
	local self = {}
	setmetatable(self, SRequestHaveTeam)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0

	return self
end
function SRequestHaveTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestHaveTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	return _os_
end

function SRequestHaveTeam:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SRequestHaveTeam
