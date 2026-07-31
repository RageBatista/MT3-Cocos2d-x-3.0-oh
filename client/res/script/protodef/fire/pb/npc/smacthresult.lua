require "utils.tableutil"
SMacthResult = {}
SMacthResult.__index = SMacthResult



SMacthResult.PROTOCOL_TYPE = 795671

function SMacthResult.Create()
	print("enter SMacthResult create")
	return SMacthResult:new()
end
function SMacthResult:new()
	local self = {}
	setmetatable(self, SMacthResult)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.result = 0

	return self
end
function SMacthResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMacthResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.result)
	return _os_
end

function SMacthResult:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.result = _os_:unmarshal_int32()
	return _os_
end

return SMacthResult
