require "utils.tableutil"
CNpcService = {}
CNpcService.__index = CNpcService



CNpcService.PROTOCOL_TYPE = 795435

function CNpcService.Create()
	print("enter CNpcService create")
	return CNpcService:new()
end
function CNpcService:new()
	local self = {}
	setmetatable(self, CNpcService)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.serviceid = 0

	return self
end
function CNpcService:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CNpcService:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.serviceid)
	return _os_
end

function CNpcService:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.serviceid = _os_:unmarshal_int32()
	return _os_
end

return CNpcService
