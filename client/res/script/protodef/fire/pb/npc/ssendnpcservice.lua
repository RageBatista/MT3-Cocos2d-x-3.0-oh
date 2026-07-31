require "utils.tableutil"
SSendNpcService = {}
SSendNpcService.__index = SSendNpcService



SSendNpcService.PROTOCOL_TYPE = 795689

function SSendNpcService.Create()
	print("enter SSendNpcService create")
	return SSendNpcService:new()
end
function SSendNpcService:new()
	local self = {}
	setmetatable(self, SSendNpcService)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.service = 0
	self.title = "" 

	return self
end
function SSendNpcService:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendNpcService:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.service)
	_os_:marshal_wstring(self.title)
	return _os_
end

function SSendNpcService:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.service = _os_:unmarshal_int32()
	self.title = _os_:unmarshal_wstring(self.title)
	return _os_
end

return SSendNpcService
