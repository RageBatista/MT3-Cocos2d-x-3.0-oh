require "utils.tableutil"
SAskforSetLeader = {}
SAskforSetLeader.__index = SAskforSetLeader



SAskforSetLeader.PROTOCOL_TYPE = 794454

function SAskforSetLeader.Create()
	print("enter SAskforSetLeader create")
	return SAskforSetLeader:new()
end
function SAskforSetLeader:new()
	local self = {}
	setmetatable(self, SAskforSetLeader)
	self.type = self.PROTOCOL_TYPE
	self.leaderid = 0

	return self
end
function SAskforSetLeader:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAskforSetLeader:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.leaderid)
	return _os_
end

function SAskforSetLeader:unmarshal(_os_)
	self.leaderid = _os_:unmarshal_int64()
	return _os_
end

return SAskforSetLeader
