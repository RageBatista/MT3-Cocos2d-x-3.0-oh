require "utils.tableutil"
CNpcToTrigger = {}
CNpcToTrigger.__index = CNpcToTrigger



CNpcToTrigger.PROTOCOL_TYPE = 817932

function CNpcToTrigger.Create()
	print("enter CNpcToTrigger create")
	return CNpcToTrigger:new()
end
function CNpcToTrigger:new()
	local self = {}
	setmetatable(self, CNpcToTrigger)
	self.type = self.PROTOCOL_TYPE
	self.triggerid = 0
	self.npckey = 0

	return self
end
function CNpcToTrigger:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CNpcToTrigger:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.triggerid)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CNpcToTrigger:unmarshal(_os_)
	self.triggerid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CNpcToTrigger
