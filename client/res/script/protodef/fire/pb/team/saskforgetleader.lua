require "utils.tableutil"
SAskforGetLeader = {}
SAskforGetLeader.__index = SAskforGetLeader



SAskforGetLeader.PROTOCOL_TYPE = 794451

function SAskforGetLeader.Create()
	print("enter SAskforGetLeader create")
	return SAskforGetLeader:new()
end
function SAskforGetLeader:new()
	local self = {}
	setmetatable(self, SAskforGetLeader)
	self.type = self.PROTOCOL_TYPE
	self.leaderid = 0

	return self
end
function SAskforGetLeader:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAskforGetLeader:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.leaderid)
	return _os_
end

function SAskforGetLeader:unmarshal(_os_)
	self.leaderid = _os_:unmarshal_int64()
	return _os_
end

return SAskforGetLeader
